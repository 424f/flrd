namespace Game.Objects

import System
import Core

class Sculpture(Common.GameObject):
	Model as Graphics.IRenderable
	Texture as Graphics.Texture
	
	def constructor():
		Model = Graphics.Wavefront.Model.Load("data/models/fallout/statue.obj")

	def Tick():
		pass
		
	def Render():
		Model.Render()
