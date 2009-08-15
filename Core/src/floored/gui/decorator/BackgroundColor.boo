namespace Core.Gui.Decorator

import System
import Tao.OpenGl.Gl
import Core.Gui
import OpenTK.Math
import Core.Graphics

class BackgroundColor(AbstractDecorator):
"""Description of BackgroundColor"""
	
	[Property(BackgroundColor)] _backgroundColor as Vector4

	def constructor(widget as Widget, backgroundColor as Vector4):
		super(widget)
		_backgroundColor = backgroundColor
		
	def Render():
		glColor4f(BackgroundColor.X, BackgroundColor.Y, BackgroundColor.Z, BackgroundColor.W)
		Ortho.RenderRect(Widget._Position, BackgroundColor)
		Widget.Render()
