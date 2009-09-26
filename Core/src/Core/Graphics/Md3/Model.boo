namespace Core.Graphics.Md3

import System
import System.IO

import Tao.OpenGl.Gl
import Tao.OpenGl.Glu
import OpenTK
import System.Collections.Generic

import Core.Util
import Core.Graphics

class Model(AbstractRenderable):  
	[Getter(Header)] _header as ModelHeader
	[Getter(Frames)] _frames as (Frame)
	[Getter(Tags)] _tags as (Tag, 2)
	[Getter(TagsByName)] _tagsByName = Dictionary[of string, Tag]()
	[Getter(Meshes)] _meshes as (Mesh)
	[Getter(Path)] _path as string 

	private final MAGIC = 0x33504449
	private final VERSION = 15
	
	[Property(Scale)] _Scale = 1.0f

	def constructor(filename as string):
		if not File.Exists(filename):
			raise FileNotFoundException("The model '${filename}' could not be found.")
		_path = filename
	
		stream = FileStream(filename, FileMode.Open, FileAccess.Read, FileShare.None)
		
		# Read and verify the header
		_header = Structs.Create(stream, ModelHeader)
		assert _header.Magic == MAGIC
		assert _header.Version == VERSION
		
		# Load all frames
		_frames = array(Frame, _header.NumFrames)
		stream.Seek(_header.OffsetFrames, IO.SeekOrigin.Begin)
		for i in range(_header.NumFrames):
			_frames[i] = Structs.Create(stream, Frame)
			_frames[i].MinBounds = Util.DecodeVector(_frames[i].MinBounds)
			_frames[i].MaxBounds = Util.DecodeVector(_frames[i].MaxBounds)
		
		# Load all tags
		_tags = matrix(Tag, _header.NumFrames, _header.NumTags)
		stream.Seek(_header.OffsetTags, IO.SeekOrigin.Begin)
		for j in range(_header.NumFrames):
			for i in range(_header.NumTags):
				tag as Tag = Structs.Create(stream, Tag)
				TagsByName[tag.Name] = tag
				
				# Swap y <--> z coordinates for origin
				tag.Origin = Util.DecodeVector(tag.Origin)
				
				# Swap y <--> z coordinates for rotation
				for k in range(3):
					tag.Axis[k] = Util.DecodeVector(tag.Axis[k])
				#tag.Axis[2] = -tag.Axis[1]
				origX = tag.Axis[0]
				origY = tag.Axis[1]
				origZ = tag.Axis[2]
				tag.Axis[0] = -origY
				tag.Axis[1] = origZ
				tag.Axis[2] = -origX
				_tags[j, i] = tag
				
				# Some models don't have normalized values, so let's make sure they are
				for i in range(3):
					a = tag.Axis[i]
					v = Vector3(a.X, a.Y, a.Z)
					v.Normalize()
					tag.Axis[i] = Vec3f(v.X, v.Y, v.Z)
					//tag.Axis[i] = a
		
		# Load meshes
		_meshes = array(Mesh, _header.NumMeshes)
		stream.Seek(_header.OffsetMeshes, IO.SeekOrigin.Begin)
		for i in range(_header.NumMeshes):
			_meshes[i] = Mesh(self, stream)
		
		stream.Close()
		
	def Render():
		Render(0)
		
	def Render(frame as int):
		MatrixStacks.Push()
		MatrixStacks.Scale(Scale, Scale, Scale)
		for mesh in _meshes:
			mesh.Render(frame % mesh.Header.NumFrames)
		MatrixStacks.Pop()

	def RenderBoundingSphere(frame as int):
		# Draw sphere
		glDisable(GL_TEXTURE_2D)
		glColor4f(0, 1, 0, 1)

		i = gluNewQuadric()
		gluQuadricDrawStyle(i, GLU_SILHOUETTE)
		gluSphere(i,_frames[frame % Header.NumFrames].Radius, 5, 5)
		gluDeleteQuadric(i)		

		glColor4f(1, 1, 1, 1)
		glEnable(GL_TEXTURE_2D)
	
	def RenderBoundingBox(frame as int):
		glDisable(GL_TEXTURE_2D)
		glColor4f(0, 1, 0, 1)		
		glColor4f(1, 1, 1, 1)
		glEnable(GL_TEXTURE_2D)
	
	def GetTagMatrix(name as string, frame as int):
		frame = frame % _header.NumFrames
		for i in range(_tags.GetLength(1)):
			tag as Tag = _tags[frame, i]
			continue if tag.Name != name
			a = tag.Axis			
			return Matrix4(Vector4(a[0].X, a[0].Y, a[0].Z, 0),
			               Vector4(a[1].X, a[1].Y, a[1].Z, 0),
			               Vector4(a[2].X, a[2].Y, a[2].Z, 0),
			               Vector4(tag.Origin.X, tag.Origin.Y,  tag.Origin.Z,   1.0f ))
		return null
	
	def BeginTag(name as string, frame as int):
		frame = frame % _header.NumFrames
		for i in range(_tags.GetLength(1)):
			tag as Tag = _tags[frame, i]
			continue if tag.Name != name

			MatrixStacks.Push()			
			a = tag.Axis			
			rotationMatrix = ( a[0].X, a[0].Y, a[0].Z, 0,
			                   a[1].X, a[1].Y, a[1].Z, 0,
			                   a[2].X, a[2].Y, a[2].Z, 0,
			                   0.0f,   0.0f,   0.0f,   1.0f )
			MatrixStacks.Translate(tag.Origin.X, tag.Origin.Y, tag.Origin.Z)
			MatrixStacks.Multiply(Core.Util.Matrices.FromArray(rotationMatrix))
			return true
		return false
		
	def EndTag():
		MatrixStacks.Pop()
