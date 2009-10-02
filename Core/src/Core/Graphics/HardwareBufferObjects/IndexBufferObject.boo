namespace Core.Graphics

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL

class IndexBufferObject(HardwareBufferObject):
	public def constructor():
		super(BufferTarget.ElementArrayBuffer)
	