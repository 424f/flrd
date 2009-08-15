namespace Core.Gui

import System
import Core.Graphics
import OpenTK.Math
import Core.Math

class Label(Widget):
"""Description of Label"""
	_font as Font
	
	
	label:
		set:
			# TODO: cache rendered image
			#recalculateBounds()
			_label = value
		get:
			return _label
	_label as string
	

	def constructor(label as string, font as Font, Position as Rect):
		_Position = Position
		_font = font
		self.label = label
	
	protected def RecalculateBounds():
		bbox = _font.BoundingBox(_label)

	def Render():
		_font.Render(_label, Position.Left + 2, Position.Bottom + 2, Vector4(0, 0, 0, Color.W))
		_font.Render(_label, Position.Left, Position.Bottom, Color)
		
