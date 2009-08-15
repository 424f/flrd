namespace Game.Objects

import System
import Core
import Tao.OpenGl.Gl

class Wall(Common.GameObject):
	Model as Graphics.IRenderable
	Texture as Graphics.Texture
	
	def constructor():
		Model = Graphics.Wavefront.Model.Load("C:/Documents and Settings/bo/Desktop/wall.obj")

	def Tick():
		pass
		
	def Render():
		glPushMatrix()
		glTranslatef(self.Position.X, self.Position.Y, self.Position.Z)
		Model.Render()
		glPopMatrix()
