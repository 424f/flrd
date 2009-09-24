namespace Core.Graphics

import System
import OpenTK
import OpenTK.Graphics.OpenGL

class MatrixStacks:
	static public ModelView = MatrixStack(OpenTK.Graphics.OpenGL.MatrixMode.Modelview)
	static public Projection = MatrixStack(OpenTK.Graphics.OpenGL.MatrixMode.Projection)
	static public Current as MatrixStack
	
	static public def Rotate(axis as Vector3, angle as single):
		Current.Rotate(axis, angle)
		
	static public def Rotate(angle as single, x as single, y as single, z as single):
		Rotate(Vector3(x, y, z), angle * Math.PI / 180f)
	
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
		F = center - eye
		F.Normalize()
		up.Normalize()
		s = Vector3.Normalize(Vector3.Cross(F, up))
		u = Vector3.Cross(s, F)
		m = OpenTK.Matrix4(s.X, s.Y, s.Z, 0, 
		                   u.X, u.Y, u.Z, 0,
		                   -F.X, -F.Y, -F.Z, 0,
		                   0, 0, 0, 1)
		Current.Multiply(m)
		Current.Translate(-eye)
		//GL.LoadIdentity()
		//Tao.OpenGl.Glu.gluLookAt(eye.X, eye.Y, eye.Z, center.X, center.Y, center.Z, up.X, up.Y, up.Z)

	static public def Perspective(fovy as single, aspect as single, zNear as single, zFar as single):
		raise "Not a projection matrix" if Current != Projection
		f = 1f / Math.Tan(fovy / 2f * Math.PI / 180f)
		m = OpenTK.Matrix4(f / aspect, 0, 0, 0,
		                   0, f, 0, 0,
		                   0, 0, (zFar + zNear) / (zNear - zFar), 2*zFar*zNear / (zNear - zFar),
		                   0, 0, -1, 0)
		Current.Load(m)
		//GL.LoadIdentity()
		//Tao.OpenGl.Glu.gluPerspective(fovy, aspect, zNear, zFar)

	static public def Ortho2D(left as single, right as single, bottom as single, top as single):
		raise "Not a projection matrix" if Current != Projection
		Ortho(left, right, bottom, top, -1, 1)

	static public def Ortho(l as single, r as single, b as single, t as single, n as single, f as single):
		raise "Not a projection matrix" if Current != Projection
		m = Matrix4(2 / (r - l), 0, 0, -(r+l) / (r-l),
		            0, 2 / (t-b), 0, -(t+b) / (t-b),
		            0, 0, -2 / (f-n), -(f + n) / (f - n),
		            0, 0, 0, 1)
		Current.Load(m)


class MatrixStack:
"""Description of MatrixStack"""
	final MaxSize = 16
	Matrices = array(Matrix4, MaxSize)
	Position = 0
	
	public Matrix as Matrix4:
		get: return Matrices[Position]

	public def constructor(x as object):
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
		OpenTK.Graphics.OpenGL.GL.LoadMatrix(Matrices[Position])
		
	public def LoadIdentity():
		Load(Matrix4.Identity)
		
	public def Push():
		Position += 1
		Matrices[Position] = Matrices[Position - 1]
		
	public def Pop():
		Position -= 1
		Load(Matrices[Position])