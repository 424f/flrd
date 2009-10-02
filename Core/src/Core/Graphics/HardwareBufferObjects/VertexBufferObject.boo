namespace Core.Graphics

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL

class VertexBufferObject(HardwareBufferObject):
	public def constructor():
		super(BufferTarget.ArrayBuffer)