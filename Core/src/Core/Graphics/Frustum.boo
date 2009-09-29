namespace Core.Graphics

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL
import Core.Math

struct Plane:
	public Normal as Vector3
	public Distance as single
	
	public def Normalize():
		d = 1 / Normal.Length
		Normal = Normal * d
		Distance = Distance * d

	public def DistanceToPoint(pt as Vector3) as single:
		return Vector3.Dot(Normal, pt) + Distance

enum IntersectionResult:
	Out
	In
	Intersect

class Frustum:	
	public Planes = array(Plane, 6)

	public def constructor():
		pass
		
	public def Update(modelView as Matrix4, projection as Matrix4):
		mat as OpenTK.Matrix4 = modelView * projection
		v = Vector3(0, 0, 0)
		v2 = OpenTK.Vector3.Transform(v, mat)
		
		// Left plane
		Planes[0].Normal = Vector3(mat.M14 + mat.M11, mat.M24 + mat.M21, mat.M34 + mat.M31)
		Planes[0].Distance = mat.M44 + mat.M41
		Planes[0].Normalize()
		
		// Right plane
		Planes[1].Normal = Vector3(mat.M14 - mat.M11, mat.M24 - mat.M21, mat.M34 - mat.M31)
		Planes[1].Distance = mat.M44 - mat.M41
		Planes[1].Normalize()
		
		// Top clipping plane
		Planes[2].Normal = Vector3(mat.M14 - mat.M12, mat.M24 - mat.M22, mat.M34 - mat.M32)
		Planes[2].Distance = mat.M44 - mat.M42
		Planes[2].Normalize()
		
		// Bottom clipping plane
		Planes[3].Normal = Vector3(mat.M14 + mat.M12, mat.M24 + mat.M22, mat.M34 + mat.M32)
		Planes[3].Distance = mat.M44 + mat.M42
		Planes[3].Normalize()
		
		// Near clipping plane
		Planes[4].Normal = Vector3(mat.M14 + mat.M13, mat.M24 + mat.M23, mat.M34 + mat.M33)
		Planes[4].Distance = mat.M44 + mat.M43
		Planes[4].Normalize()
		
		// Far clipping plane
		Planes[5].Normal = Vector3(mat.M14 - mat.M13, mat.M24 - mat.M23, mat.M34 - mat.M33)
		Planes[5].Distance = mat.M44 - mat.M43
		Planes[5].Normalize()
			
	public def ContainsSphere(sphere as Sphere) as IntersectionResult:
		for plane as Plane in Planes:
			distance = plane.DistanceToPoint(sphere.Center)
			if distance < -sphere.Radius:
				return IntersectionResult.Out
			/*if Math.Abs(distance) < sphere.Radius:
				return IntersectionResult.Intersect*/
		return IntersectionResult.In

	public def Render():
	"""For debugging purposes, renders the current planes"""
		GL.Enable(EnableCap.Blend)
		GL.Begin(BeginMode.Triangles)
		for plane in Planes: //(Planes[1], Planes[2], ):
			n = plane.Normal
			v = Vector3(1, 0, 0)
			Dim = 20f
			b1 = Vector3.Cross(v, n)
			b2 = Vector3.Cross(n, b1)
			b1.Normalize()
			b2.Normalize()
			b1 = b1 * Dim
			b2 = b2 * Dim
			center = -plane.Normal * plane.Distance
			GL.Color4(Vector4(1, 0, 0, 0.4))
			GL.Vertex3(center - b1 - b2)
			GL.Color4(Vector4(1, 1, 0, 0.4))
			GL.Vertex3(center - b1 + b2)
			GL.Color4(Vector4(1, 1, 1, 0.4))
			GL.Vertex3(center + b1 + b2)

			GL.Color4(Vector4(1, 1, 1, 0.4))
			GL.Vertex3(center + b1 + b2)
			GL.Color4(Vector4(1, 1, 0, 0.4))
			GL.Vertex3(center + b1 - b2)
			GL.Color4(Vector4(1, 0, 0, 0.4))
			GL.Vertex3(center - b1 - b2)
			
			Diagnostics.Debug.Assert(plane.DistanceToPoint(center - b1 - b2) <= 0.1f, "Is ${plane.DistanceToPoint(center - b1 - b2)}")
			Diagnostics.Debug.Assert(plane.DistanceToPoint(center - b1 + b2) <= 0.1f, "Is ${plane.DistanceToPoint(center - b1 + b2)}")
			Diagnostics.Debug.Assert(plane.DistanceToPoint(center + b1 + b2) <= 0.1f, "Is ${plane.DistanceToPoint(center + b1 + b2)}")
			Diagnostics.Debug.Assert(plane.DistanceToPoint(center + b1 - b2) <= 0.1f, "Is ${plane.DistanceToPoint(center + b1 - b2)}")

			
		GL.End()