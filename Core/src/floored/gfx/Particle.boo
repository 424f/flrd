namespace Core.Graphics

import System
import System.Collections.Generic
import OpenTK.Graphics
import OpenTK.Math
import Tao.OpenGl.Gl

class ParticleEngine(IRenderable):
"""
A particle source using a certain textures and behaviours

Features to implement:
	- Align to Camera (for fire, explosions, ..)	
	- Align to floor (for blood)
	- Define texture
	- Define size
	- Define gravity behaviour (smoke goes up, blood falls down)
	- ARB_point_sprite 
"""
	textures as (Texture)
	_texture as Texture
	_bump as Texture
	particles = List[of Particle]()
	static counter = 0

	def constructor(textures as (Texture)):
		_texture = Texture.Load("data/textures/blooddecal.dds")
		_bump = Texture.Load("data/textures/dirtwastes01_n.dds")
	
	private def GlVertex(v as Vector3):
		glVertex3f(v.X, v.Y, v.Z)
	
	def Render():
		# step
		dt = 1.0 / 30.0
		for p in particles:
			p.Position = p.Position + p.Velocity * dt
			p.Velocity -= Vector3(0, dt*50, 0)
			if p.Position.Y < -24.5:
				p.Position.Y = -24.5
				p.Velocity = Vector3.Zero
			p.Color.W -= dt * 0.02
		particles.RemoveAll({ p as Particle | p.Color.W <= 0.0 })
		
		# calculate up and right vector
		model = array(double, 16)
		glGetDoublev(GL_MODELVIEW_MATRIX, model)
		right = Vector3(model[0], model[4], model[8]) * 20
		up = Vector3(model[1], model[5], model[9]) * 20
		
		right = Vector3(1, 0, 0) * 20
		up = Vector3(0, 0, -1) * 20
		
		glEnable(GL_TEXTURE_2D)
		glDisable(GL_LIGHTING)
		glEnable(GL_BLEND)
		glDepthMask(false)
		glAlphaFunc(GL_GREATER, 0.1)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
		glEnable(GL_ALPHA_TEST)

		glEnable(GL_TEXTURE_2D)
		_texture.Bind()
		
		glBegin(GL_QUADS)
		for p in particles:
			glColor4f(p.Color.X, p.Color.Y, p.Color.Z, p.Color.W)
			glTexCoord2f(p.UV.X + 0, p.UV.Y + 0)
			GL.Vertex3(p.Position + up - right)
			glTexCoord2f(p.UV.X + 0, p.UV.Y + 0.5)
			GL.Vertex3(p.Position - up - right)
			glTexCoord2f(p.UV.X + 0.5,p.UV.Y +  0.5)
			GL.Vertex3(p.Position - up + right)
			glTexCoord2f(p.UV.X + 0.5, p.UV.Y + 0)
			GL.Vertex3(p.Position + up + right)
		glEnd()
		glEnable(GL_LIGHTING)
		glDisable(GL_BLEND)
		glColor4f(1, 1, 1, 1)
		glDepthMask(true)
		
	def Add(Position as Vector3, velocity as Vector3, color as Vector4):
		color = Vector4(1, 1, 1, 1)
		p = Particle()
		p.Color = color
		p.Position = Position
		p.Velocity = velocity
		counter++
		p.UV = Vector2(0.5*(counter % 2), 0.5*((counter % 4) / 2))
		self.particles.Add(p)
	
	class Particle:
	"""Stores the state of a single particle"""
		public Position as Vector3
		public Velocity as Vector3
		public Color as Vector4
		public UV as Vector2
		
		
