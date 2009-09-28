namespace Core.Graphics

import System
import OpenTK
import OpenTK.Graphics.OpenGL

class MatrixStacks:
	static public ModelView = MatrixStack(OpenTK.Graphics.OpenGL.MatrixMode.Modelview)
	static public Projection = MatrixStack(OpenTK.Graphics.OpenGL.MatrixMode.Projection)
	static public User = MatrixStack(null, false)
	static protected Previous as MatrixStack = null
	static public Current as MatrixStack
	
	static public def Rotate(axis as Vector3, angle as single):
		Current.Rotate(axis, angle)
		
	static public def Rotate(angle as single, x as single, y as single, z as single):
		Rotate(Vector3(x, y, z), angle * Math.PI / 180f)
	
	static public def SetUserMode(enable as bool):
	"""Enables or disables the user mode. In user mode, all transformations performed via the static MatrixStacks methods
	are applied to the user matrix stack, which can be accessed via `User`."""
		if enable:
			User.Clear()
			Current = User
		else:
			Current = Previous
	
	static public def MatrixMode(mode as OpenTK.Graphics.OpenGL.MatrixMode):
		if mode == OpenTK.Graphics.OpenGL.MatrixMode.Modelview:
			Current = ModelView
		elif mode == OpenTK.Graphics.OpenGL.MatrixMode.Projection:
			Current = Projection
		GL.MatrixMode(mode)
	
	static public def Translate(v as Vector3):
		Current.Translate(v)
	
	static public def Translate(x as single, y as single, z as single):
		Translate(Vector3(x, y, z))
	
	static public def Load(m as Matrix4):
		Current.Load(m)
		
	static public def LoadIdentity():
		Current.LoadIdentity()
		
	static public def Push():
		Current.Push()
		
	static public def Pop():
		Current.Pop()
	
	static public def Scale(x as single, y as single, z as single):
		Current.Scale(x, y, z)
		
	static public def Multiply(m as Matrix4):
		Current.Multiply(m)

	static public def LookAt(eye as Vector3, center as Vector3, up as Vector3):
		raise "Not a modelview matrix" if Current != ModelView
		m = Matrix4.LookAt(eye, center, up)                   
		Current.Multiply(m)

	static public def Perspective(fovy as single, aspect as single, zNear as single, zFar as single):
		raise "Not a projection matrix" if Current != Projection
		m as Matrix4
		Matrix4.CreatePerspectiveFieldOfView(fovy * Math.PI / 180f, aspect, zNear, zFar, m)
		Current.Load(m)

	static public def Ortho2D(left as single, right as single, bottom as single, top as single):
		m as Matrix4
		Matrix4.CreateOrthographicOffCenter(left, right, bottom, top, -1, 1, m)
		raise "Not a projection matrix" if Current != Projection
		Current.Load(m)


class MatrixStack:
"""Description of MatrixStack"""
	final MaxSize = 16
	Matrices = array(Matrix4, MaxSize)
	Position = 0
	AutoLoad as bool
	
	public Matrix as Matrix4:
		get: return Matrices[Position]

	public def constructor(x as object):
		self(x, true)
		
	public def constructor(x as object, autoLoad as bool):
		AutoLoad = autoLoad
		LoadIdentity()
		
	public def Clear():
		Position = 0
		LoadIdentity()

	public def Multiply(m as Matrix4):
		Load(Matrix4.Mult(m, Matrices[Position]))
		
	public def Rotate(axis as Vector3, angle as single):
		Multiply(OpenTK.Matrix4.Rotate(axis, angle))		

	public def Translate(v as Vector3):
		Multiply(Matrix4.CreateTranslation(v))
	
	public def Scale(x as single, y as single, z as single):
		Multiply(OpenTK.Matrix4.Scale(x, y, z))
		
	public def Load(m as Matrix4):
		Matrices[Position] = m
		if AutoLoad:
			GL.LoadMatrix(Matrices[Position])
		
	public def LoadIdentity():
		Load(Matrix4.Identity)
		
	public def Push():
		Position += 1
		Matrices[Position] = Matrices[Position - 1]
		
	public def Pop():
		Position -= 1
		Load(Matrices[Position])