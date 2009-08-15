namespace Core.Gui

import Core.Graphics
import OpenTK.Math
import Core.Math

class TextField(Widget):
	_font as Font

	text:
		set:
			# TODO: cache rendered image
			RecalculateBounds()
			_text = value
		get:
			return _text
	_text as string
	

	def constructor(text as string, font as Font, Position as Rect):
		_Position = Position
		_font = font
		self.text = text
	
	private def RecalculateBounds():
		pass #bbox = _font.BoundingBox(_text)

	def Render():
		_font.Render(_text, Position.Left + 2, Position.Bottom + 2, Vector4(0, 0, 0, 1))
		_font.Render(_text, Position.Left, Position.Bottom, Vector4(1, 1, 1, 1))

	override def OnChar(c as char):
		if c == 8:
			if text.Length > 0:
				text = text[:-1]
			return
		text += c
