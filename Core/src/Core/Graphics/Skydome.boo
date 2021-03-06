﻿namespace Core.Graphics

import System
import System.Drawing
import System.Math
import OpenTK.Graphics.OpenGL
import OpenTK
import Tao.OpenGl.Gl

class Skydome:
	private skyList as int = -1
	private Texture as Texture
	[Getter(Radius)] _Radius as single
	
	public def constructor(texture as Texture, radius as single):
		Texture = texture
		_Radius = radius
	
	public def Render():
		GL.Disable(EnableCap.CullFace)
		GL.DepthMask(false)
		OpenTK.Graphics.OpenGL.GL.ActiveTexture(OpenTK.Graphics.OpenGL.TextureUnit.Texture0)
		GL.Enable(EnableCap.Texture2D)
		if skyList == -1:	
			radius = _Radius
			n = 10
			phi = -PI * 0.5
			dphi = PI / n * 0.5
			dtheta = 2 * PI / n		
			skyList = glGenLists(1)
			glNewList(skyList, GL_COMPILE)
			GL.Enable(EnableCap.Texture2D)
			GL.Disable(EnableCap.Blend)
			Texture.Bind()
			GL.Begin(BeginMode.Triangles)
			for i in range(n):
				theta = 0.0
				for j in range(n):
					v1 = Vector3(radius * Sin(phi) * Cos(theta), \
					            radius * Cos(phi), \
					            radius * Sin(phi) * Sin(theta))
					v2 = Vector3(radius * Sin(phi+dphi) * Cos(theta), \
					            radius * Cos(phi+dphi), \
					            radius * Sin(phi+dphi) * Sin(theta))
					v3 = Vector3(radius * Sin(phi) * Cos(theta+dtheta), \
					            radius * Cos(phi), \
					            radius * Sin(phi) * Sin(theta+dtheta))
					v4 = Vector3(radius * Sin(phi+dphi) * Cos(theta+dtheta), \
					            radius * Cos(phi+dphi), \
					            radius * Sin(phi+dphi) * Sin(theta+dtheta))		
					t1 = SkydomeTex(v1)
					t2 = SkydomeTex(v2)
					t3 = SkydomeTex(v3)
					t4 = SkydomeTex(v4)
					
					if t1.X > t3.X:
						t3.X += 1.0
					if t2.X > t4.X:
						t4.X += 1.0
					
					GL.Color4(Vector4(1, 1, 1, 1))
					GL.TexCoord2(t1)
					GL.Vertex3(v1)
					GL.TexCoord2(t2)
					GL.Vertex3(v2)
					GL.TexCoord2(t3)
					GL.Vertex3(v3)
					
					GL.TexCoord2(t4)
					GL.Vertex3(v4)
					GL.TexCoord2(t3)
					GL.Vertex3(v3)
					GL.TexCoord2(t2)
					GL.Vertex3(v2)
					theta += dtheta
				phi += dphi	
			GL.End()
			glEndList()			
		
		glCallList(skyList)
		GL.DepthMask(true)
		GL.Enable(EnableCap.CullFace)

	static private def SkydomeTex(v as Vector3):
		v.Normalize()
		result = Vector2(1-(Atan2(v.X, v.Z) / PI * 0.5) - 0.5, \
		                 Asin(v.Y) / PI * 2.0)
		return result