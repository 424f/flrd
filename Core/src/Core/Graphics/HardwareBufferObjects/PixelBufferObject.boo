namespace Core.Graphics

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL

class PixelBufferObject(HardwareBufferObject):
	public Width as int
	public Height as int
	protected NumBytes = 0
	
	def constructor(width as int, height as int):
		super(BufferTarget.PixelUnpackBuffer)
		
		Width = width
		Height = height
		bytesPerPixel = 4
		NumBytes = Width * Height * bytesPerPixel

		BeginUsage()
		GL.BufferData(BufferTarget, IntPtr(NumBytes), IntPtr.Zero, BufferUsageHint.StreamDraw)	
		EndUsage()
	

	
	def MapUnpackBuffer() as IntPtr:
		GL.BufferData(BufferTarget, IntPtr(NumBytes), IntPtr.Zero, BufferUsageHint.StreamDraw)
		ptr as IntPtr = GL.MapBuffer(BufferTarget, BufferAccess.WriteOnly)
		return ptr

	def UnmapBuffer():
		GL.UnmapBuffer(BufferTarget.PixelUnpackBuffer)	