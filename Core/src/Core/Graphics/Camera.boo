namespace Core.Graphics

import OpenTK
import Tao.OpenGl.Gl
import Tao.OpenGl.Glu

class Camera: 
	[Property(Eye)] _eye as Vector3
	[Property(LookAt)] _lookAt as Vector3
	[Property(Up)] _up as Vector3

	public def constructor(eye as Vector3, lookAt as Vector3, up as Vector3):
		_eye = eye
		_lookAt = lookAt
		_up = up

	virtual def Push():
		MatrixStacks.MatrixMode(Graphics.OpenGL.MatrixMode.Modelview)
		MatrixStacks.LoadIdentity()
		MatrixStacks.LookAt(Eye, LookAt, Up)
		MatrixStacks.Push()
	
	virtual def Pop():
		MatrixStacks.Pop()
