namespace Core.Gui

import System
import Tao.OpenGl.Gl
import Core.Graphics
import Core.Math
import OpenTK.Math

class SlicedButton(AbstractButton):
"""Description of SlicedButton"""

	_labelWidget as Label

	_image as Texture
	label as string:
		get:
			return _label
		set:
			_label = value
			_labelWidget.label = value
	_label as string
	
	_clicked as bool

	def constructor():
		_image = Texture.Load("data/gui/button.png")
		# TODO: use the default font
		_labelWidget = Label("", Font.Create("data/fonts/DejaVuSansBold.ttf", 20), Rect(14, 30, 0, 0));
		_clicked = false
		_color = Vector4(0.4, 0.4, 0.4, 1.0)
		self.AddChild(_labelWidget)
		RecalculateBounds()
		
	override def Render():
		glColor4f(Color.X, Color.Y, Color.Z, Color.W)
		_image.Render(Rect(0, 0, 14, 46), Rect(Position.Left, Position.Top, 14, 46))
		_image.Render(Rect(14, 0, 1, 46), Rect(Position.Left + 14, Position.Top, Position.Width - 28, 46))
		_image.Render(Rect(15, 0, 14, 46), Rect(Position.Width - 14, Position.Top, 14, 46))
		glColor4f(1, 1, 1, 1)
		super()
	
	override def OnClick():
		_color = Vector4(0.8, 0.8, 0.0, 1.0)
		
	private def RecalculateBounds():
		self.Position.Width = 14 + 14 + _labelWidget.Position.Width + 200
		self.Position.Height = 46
