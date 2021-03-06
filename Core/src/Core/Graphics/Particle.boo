namespace Core.Graphics

import System
import System.Collections.Generic
import OpenTK.Graphics.OpenGL
import OpenTK
import Tao.OpenGl.Gl

class ParticleEngine(AbstractRenderable):
"""
A particle source using a certain textures and behaviours

Features to implement:
	- Align to Camera (for fire, explosions, ..)	
	- Align to floor (for blood)
	- Define texture
	- Define size
	- Define gravity behaviour (smoke goes up, blood falls down)
	- ARB_point_sprite 
	
TODO: completely rewrite
"""
	_texture as Texture
	particles = List[of Particle]()
	static counter = 0

	def constructor(texture as Texture):
		_texture = texture
	
	def Tick(dt as single):
		for p in particles:
			p.Velocity.Y -= 2.0f * dt
			p.Position = p.Position + p.Velocity * dt
			p.Velocity -= Vector3(0, dt*25f, 0)
			p.Color.W -= dt * 0.3
		particles.RemoveAll({ p as Particle | p.Color.W <= 0.0 })		
	
	def Render():
		# calculate up and right vector
		model = MatrixStacks.ModelView.Matrix
		right = Vector3(model.M11, model.M12, model.M13) * 3.0f
		up = Vector3(model.M21, model.M22, model.M23) * 3.0f
		

		glEnable(GL_TEXTURE_2D)
		glDisable(GL_LIGHTING)
		glEnable(GL_BLEND)
		glDepthMask(false)
		glAlphaFunc(GL_GREATER, 0.1)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE)
		glEnable(GL_ALPHA_TEST)

		glEnable(GL_TEXTURE_2D)
		_texture.Bind()
		
		glBegin(GL_QUADS)
		for p in particles:
			glColor4f(p.Color.X, p.Color.Y, p.Color.Z, p.Color.W)
			glTexCoord2f(0, 0)
			GL.Vertex3(p.Position + up - right)
			glTexCoord2f(0, 1f)
			GL.Vertex3(p.Position - up - right)
			glTexCoord2f(1f, 1f)
			GL.Vertex3(p.Position - up + right)
			glTexCoord2f(1f, 0)
			GL.Vertex3(p.Position + up + right)
		glEnd()
		glDisable(GL_BLEND)
		glColor4f(1, 1, 1, 1)
		glDepthMask(true)
		
	def Add(Position as Vector3, velocity as Vector3, color as Vector4):
		//color = Vector4(0.6, 0.3, 0.1, 1)
		p = Particle()
		p.Color = color
		p.Position = Position
		p.Velocity = velocity
		counter++
		//p.UV = Vector2(0.5*(counter % 2), 0.5*((counter % 4) / 2))
		//p.UV = Vector2(
		self.particles.Add(p)
	
	class Particle:
	"""Stores the state of a single particle"""
		public Position as Vector3
		public Velocity as Vector3
		public Color as Vector4
		public UV as Vector2
		
		
