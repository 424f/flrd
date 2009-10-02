namespace Core.Graphics

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL

abstract class HardwareBufferObject(IDisposable):
	protected Id as int
	protected BufferTarget as BufferTarget
	
	def constructor(bufferTarget as BufferTarget):
		GL.GenBuffers(1, Id)
		BufferTarget = bufferTarget

	def BeginUsage():
		GL.BindBuffer(BufferTarget, Id)

	def Dispose():
		GL.DeleteBuffers(1, Id)

	def EndUsage():
		GL.BindBuffer(BufferTarget, 0)