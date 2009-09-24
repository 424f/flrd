namespace Core.Graphics.Md3

import System
import System.IO
import System.Runtime.InteropServices

import Tao.OpenGl.Gl
import Core.Graphics

class Mesh:
"""
Is a simple meshthat is part of a Model. To improve performance, frames are automatically 
cached as display lists.
"""
	[Getter(Model)] _model as Model
	[Getter(Header)] _header as MeshHeader
	[Getter(Triangles)] _triangles as (Triangle)
	[Getter(TexCoords)] _texCoords as (TexCoords)
	[Getter(Frames)] _frames as (Vertex, 2)
	[Getter(DisplayLists)] _displayLists as (int)
	[Getter(Texture)] _texture as Texture

	private static final MESH_ID = 0x33504449
	private static final COORD_FACTOR = 1.0f / 64.0f

	def constructor(model as Model, stream as IO.Stream):
		_model = model
		rawArrayIndexing: 	
			offset = stream.Position
			_header = Core.Util.Structs.Create(stream, MeshHeader)
			assert _header.Ident == MESH_ID
			
	
			LoadSkins(stream, offset)	
			LoadTriangles(stream, offset)
			LoadTexCoords(stream, offset)
			LoadVertices(stream, offset)
			
			# Allocate space for display lists
			_displayLists = array(int, _header.NumFrames)
			
			# Jump to end of file
			stream.Seek(offset + _header.OffsetEOF, IO.SeekOrigin.Begin)
	
	protected def LoadSkins(stream as IO.Stream, offset as int):
		# Load skins
		stream.Seek(offset + _header.OffsetSkins, IO.SeekOrigin.Begin)
		for i in range(_header.NumSkins):
			skin as Skin = Core.Util.Structs.Create(stream, Skin)
			
			# If the skin name isn't empty, we'll try to load the "skin" as a texture
			if skin.Name.Length > 0:
				try:
					_texture = Texture.Load(Path.Combine(Path.GetDirectoryName(Model.Path), IO.Path.GetFileName(skin.Name)))
				except:
					pass 		
	
	protected def LoadTriangles(stream as IO.Stream, offset as int):
		# Load triangles
		stream.Seek(offset + _header.OffsetTriangles, IO.SeekOrigin.Begin)
		_triangles = array(Triangle, _header.NumTriangles)
		stream.Seek(offset + _header.OffsetTriangles, IO.SeekOrigin.Begin)
		buf = array(byte, Marshal.SizeOf(Triangle)*_header.NumTriangles)
		stream.Read(buf, 0, buf.Length)
		unsafe ptr as void = _triangles:
			Marshal.Copy(buf, 0, IntPtr(ptr), buf.Length)
		/*for i in range(_header.NumTriangles):
			_triangles[i] = Core.Util.Structs.Create(stream, Triangle)*/
	
	protected def LoadTexCoords(stream as IO.Stream, offset as int):
		# Load texture coordinates
		stream.Seek(offset + _header.OffsetTexCoords, IO.SeekOrigin.Begin)
		_texCoords = array(Md3.TexCoords, _header.NumVertices)
		buf = array(byte, Marshal.SizeOf(Md3.TexCoords)*_header.NumVertices)
		stream.Read(buf, 0, buf.Length)
		unsafe ptr as void = _texCoords:
			Marshal.Copy(buf, 0, IntPtr(ptr), buf.Length)
		for i in range(_header.NumVertices):
			_texCoords[i].V = 1.0f - _texCoords[i].V
		
		/*	
			c as TexCoords = Core.Util.Structs.Create(stream, Md3.TexCoords)
			c.V = 1.0f - c.V
			_texCoords[i] = c*/		
	
	protected def LoadVertices(stream as IO.Stream, offset as int):
		# Load vertices
		stream.Seek(offset + _header.OffsetVertices, IO.SeekOrigin.Begin)
		_frames = matrix(Vertex, _header.NumFrames, _header.NumVertices)
		buf = array(byte, Marshal.SizeOf(Md3.EncodedVertex)*_header.NumVertices)
		encoded = array(EncodedVertex, _header.NumVertices)
		
		for j in range(_header.NumFrames):
			stream.Read(buf, 0, buf.Length)
			unsafe ptr as void = encoded:
				Marshal.Copy(buf, 0, IntPtr(ptr), buf.Length)
			
			for i in range(_header.NumVertices):
				rawArrayIndexing: 	
					raw as EncodedVertex = encoded[i]
				v as Vertex
				
				# Decode Position (mind that we swap y <--> z values)
				v.Pos = Md3.Util.DecodeVector(Vec3f(cast(single, raw.X) * COORD_FACTOR,
					                            cast(single, raw.Y) * COORD_FACTOR,
					                            cast(single, raw.Z) * COORD_FACTOR))
				
				# Decode normal vector			
				lat as single = 2.0f * Math.PI * cast(single, raw.Normal0) / 255.0f
				lng as single = 2.0f * Math.PI * cast(single, raw.Normal1) / 255.0f
				v.Normal = Util.DecodeVector(Vec3f(cast(single, Math.Cos(lat) * Math.Sin(lng)),
					                               cast(single, Math.Sin(lat) * Math.Sin(lng)),
					                               cast(single, Math.Cos(lng))))
				
				# Add texture coordinates
				rawArrayIndexing: 	
					v.Tu = _texCoords[i].U
				rawArrayIndexing: 	
					v.Tv = _texCoords[i].V
				
				rawArrayIndexing:
					_frames[j, i] = v		
	
	def Render(frame as int):
		frame = frame % _header.NumFrames
		dl = _displayLists[frame]
		if dl == 0:
			CreateDisplayList(frame)
		glCallList(_displayLists[frame])
		
	def CreateDisplayList(frame as int):
		index as int = glGenLists(1)
		_displayLists[frame] = index
		glNewList(index, GL_COMPILE)
		if _texture is not null:
			_texture.Bind()
		glBegin(GL_TRIANGLES)
		for i in range(_header.NumTriangles):
			indices = _triangles[i].Indices
			for j in range(2, -1, -1):
				a = indices[j]
				glNormal3f(_frames[frame, a].Normal.X,
				           _frames[frame, a].Normal.Y,
				           _frames[frame, a].Normal.Z)
				glTexCoord2f(_texCoords[a].U, _texCoords[a].V)
				pos = _frames[frame, a].Pos
				glVertex3f(pos.X, pos.Y, pos.Z)
		glEnd()		
		
		// Draw normals
		/*glBegin(GL_LINES)
		for i in range(_header.NumTriangles):
			indices = _triangles[i].Indices
			for j in range(2, -1, -1):
				a = indices[j]
				pos = _frames[frame, a].Pos
				glVertex3f(pos.X, pos.Y, pos.Z)		
				glVertex3f(pos.X + _frames[frame, a].Normal.X, \
				           pos.Y + _frames[frame, a].Normal.Y, \
				           pos.Z + _frames[frame, a].Normal.Z)
		glEnd()*/
		
		glEndList()
