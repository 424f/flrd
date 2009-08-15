namespace Core.Gui

import System
import Tao.OpenGl.Gl
import Core.Graphics
import Core.Math

class Image(Widget):
"""Description of Image"""

	[Property(Texture)] _texture as Texture

	def constructor(texture as Texture, Position as Rect):
		_texture = texture
		_Position = Position

	def Render():
		if _texture is not null:
			glColor4f(Color.X, Color.Y, Color.Z, Color.W)
			_texture.Render(_Position)
		
	def OnClick():
		pass
