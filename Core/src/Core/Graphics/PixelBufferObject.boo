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
		EndUsage()
	
	def BeginUsage():
		GL.BindBuffer(BufferTarget.PixelUnpackBuffer, Pbo)
	
	def MapUnpackBuffer() as IntPtr:
		GL.BufferData(BufferTarget.PixelUnpackBuffer, IntPtr(NumBytes), IntPtr.Zero, BufferUsageHint.StreamDraw)
		ptr as IntPtr = GL.MapBuffer(BufferTarget.PixelUnpackBuffer, BufferAccess.WriteOnly)
		return ptr

	def UnmapBuffer():
		GL.UnmapBuffer(BufferTarget.PixelUnpackBuffer)		
				
	def EndUsage():
		GL.BindBuffer(BufferTarget.PixelUnpackBuffer, 0)