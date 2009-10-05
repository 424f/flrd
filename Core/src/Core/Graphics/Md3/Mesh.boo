namespace Core.Graphics.Md3

import System
import System.IO
import System.Runtime.InteropServices
import System.Collections.Generic

import OpenTK.Graphics.OpenGL
import Core.Graphics

class Mesh:
"""
Is a simple meshthat is part of a Model. To improve performance, frames are automatically 
cached as display lists.
"""
	private static final MESH_ID = 0x33504449
	private static final COORD_FACTOR = 1.0f / 64.0f
	private static final TRIANGLE_SIZE = 4 * 3
	private static final NORMAL_SIZE = 4 * 3
	private static final VERTEX_SIZE = 4 * 3
	private static final TEX_COORDS_SIZE = 4 * 2

	[Getter(Model)] _model as Model
	[Getter(Header)] _header as MeshHeader
	[Getter(Triangles)] _triangles as (Triangle)
	[Getter(TexCoords)] _texCoords as (TexCoords)
	[Getter(Frames)] _frames as List[of (Md3.Vertex)]
	[Getter(Texture)] _texture as Texture
	
	protected Vbos as (VertexBufferObject)
	protected Ibo as IndexBufferObject

	def constructor(model as Model, stream as IO.Stream):
		_model = model
	
		offset = stream.Position
		_header = Core.Util.Structs.Create(stream, MeshHeader)
		assert _header.Ident == MESH_ID
		

		LoadSkins(stream, offset)	
		LoadTriangles(stream, offset)
		LoadTexCoords(stream, offset)
		LoadVertices(stream, offset)
		
		# Create Ibo
		Ibo = IndexBufferObject()
		Ibo.BeginUsage()
		GL.BufferData[of Triangle](BufferTarget.ElementArrayBuffer, IntPtr(TRIANGLE_SIZE*_header.NumTriangles), _triangles, BufferUsageHint.StaticDraw)
		Ibo.EndUsage()
		_triangles = null
		
		# Create space for VBOs
		Vbos = array(VertexBufferObject, _header.NumFrames)		
				
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
	
	protected def LoadVertices(stream as IO.Stream, offset as int):
		# Load vertices
		stream.Seek(offset + _header.OffsetVertices, IO.SeekOrigin.Begin)
		_frames = List[of (Vertex)](_header.NumFrames)
		for i in range(_header.NumFrames):
			_frames.Add(array(Vertex, _header.NumVertices))
		buf = array(byte, Marshal.SizeOf(Md3.EncodedVertex)*_header.NumVertices)
		encoded = array(EncodedVertex, _header.NumVertices)
		
		for j in range(_header.NumFrames):
			stream.Read(buf, 0, buf.Length)
			unsafe ptr as void = encoded:
				Marshal.Copy(buf, 0, IntPtr(ptr), buf.Length)
			
			for i in range(_header.NumVertices):
				rawArrayIndexing: 	
					raw as EncodedVertex = encoded[i]
				v as Md3.Vertex
				
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
					v.Tv = _texCoords[i].V
					_frames[j][i] = v		
					
		self._texCoords = null
	
	def Render(frame as int):
		frame = frame % _header.NumFrames
		GL.FrontFace(FrontFaceDirection.Cw)
		//GL.PolygonMode(MaterialFace.FrontAndBack, PolygonMode.Line)
		vbo = Vbos[frame]
		if vbo == null:
			// Create vbo
			Vbos[frame] = VertexBufferObject()
			vbo = Vbos[frame]			
			vbo.BeginUsage()
			vs = _frames[frame]
			GL.BufferData(BufferTarget.ArrayBuffer, IntPtr(4*8*vs.Length), vs, BufferUsageHint.StaticDraw)
			vbo.EndUsage()
			_frames[frame] = null

		if _texture is not null:
			_texture.Bind()
			
		vbo = Vbos[frame]
		vbo.BeginUsage()
		Ibo.BeginUsage()

		GL.EnableClientState(EnableCap.VertexArray)
		GL.EnableClientState(EnableCap.NormalArray)
		GL.EnableClientState(EnableCap.TextureCoordArray)
			
		GL.NormalPointer(3, NormalPointerType.Float, 4*8, 4*2)
		GL.VertexPointer(3, VertexPointerType.Float, 4*8, 4*5)
		GL.TexCoordPointer(2, TexCoordPointerType.Float, 4*8, IntPtr.Zero)
		
		GL.DrawElements(BeginMode.Triangles, 3*_header.NumTriangles, DrawElementsType.UnsignedInt, IntPtr.Zero)
		
		GL.DisableClientState(EnableCap.VertexArray)
		GL.DisableClientState(EnableCap.NormalArray)	
		GL.DisableClientState(EnableCap.TextureCoordArray)
		
		Ibo.EndUsage()
		vbo.EndUsage()		

		GL.FrontFace(FrontFaceDirection.Ccw)