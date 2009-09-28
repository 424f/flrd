namespace Core.Graphics

import System
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL

class PixelBufferObject:
	protected Pbo as int
	public Width as int
	public Height as int
	protected NumBytes = 0
	
	def constructor(width as int, height as int):
		GL.GenBuffers(1, Pbo)
		
		Width = width
		Height = height
		bytesPerPixel = 4
		NumBytes = Width * Height * bytesPerPixel

		GL.BindBuffer(BufferTarget.PixelUnpackBuffer, Pbo)		
		GL.BufferData(BufferTarget.PixelUnpackBuffer, IntPtr(NumBytes), IntPtr.Zero, BufferUsageHint.StreamDraw)	
	
	def BeginUsage():
		OpenTK.Graphics.OpenGL.GL.BindBuffer(OpenTK.Graphics.OpenGL.BufferTarget.PixelUnpackBuffer, Pbo)
	
	def MapUnpackBuffer() as IntPtr:
		GL.BufferData(BufferTarget.PixelUnpackBuffer, IntPtr(NumBytes), IntPtr.Zero, BufferUsageHint.StreamDraw)
		ptr as IntPtr = OpenTK.Graphics.OpenGL.GL.MapBuffer(OpenTK.Graphics.OpenGL.BufferTarget.PixelUnpackBuffer, OpenTK.Graphics.OpenGL.BufferAccess.WriteOnly)
		return ptr

	def UnmapBuffer():
		OpenTK.Graphics.OpenGL.GL.UnmapBuffer(OpenTK.Graphics.OpenGL.BufferTarget.PixelUnpackBuffer)		
				
	def EndUsage():
		OpenTK.Graphics.OpenGL.GL.BindBuffer(OpenTK.Graphics.OpenGL.BufferTarget.PixelUnpackBuffer, 0)