namespace Core.Graphics

import System
import Tao.OpenGl.Gl

class Light:
"""Description of Light"""

	id as int
	"""Which OpenGL light does this source correspond to?"""
	
	[Property(Specular)] _Specular as (single)
	[Property(Ambient)] _Ambient as (single)
	[Property(Diffuse)] _Diffuse as (single)
	[Property(Position)] _Position as (single)
	
	def constructor(id as int):
		self.id = GL_LIGHT0
		Specular = (1.0f, 1.0f, 1.0f, 1.0f)
		Ambient = (0.3f, 0.3f, 0.3f, 1.0f)
		Diffuse = (1.0f, 1.0f, 1.0f, 1.0f)
		Position = (5.0f, 10.0f, -10.0f, 0.0f)
		
	def Enable():		
		glEnable(id)
		glLightfv(id, GL_SPECULAR, Specular)		
		glLightfv(id, GL_AMBIENT, Ambient)		
		glLightfv(id, GL_DIFFUSE, Diffuse)
		glLightfv(id, GL_POSITION, Position)
		//glLightModelf(GL_LIGHT_MODEL_LOCAL_VIEWER, 1.0f)
		//glShadeModel(GL_SMOOTH)
		//glFrontFace(GL_CCW)

		mcolor = (1.0f, 1.0f, 1.0f, 1.0f)
		glMaterialfv(GL_FRONT, GL_AMBIENT_AND_DIFFUSE, mcolor)
		
		specReflection = (1.0f, 1.0f, 1.0f, 1.0f)
		glMaterialfv(GL_FRONT, GL_SPECULAR, specReflection)
		
		glMateriali(GL_FRONT, GL_SHININESS, 20);

	
	def Disable():
		glDisable(id)
		
	def Apply():
		pass

	def PushLightView():
		glPushMatrix() 
		
	def PopLightView():
		glPopMatrix()
		
