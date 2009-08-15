namespace Core.Gui.Layout

import System
import Core.Gui
import Core.Math

class BoxLayout(Widget):
"""Description of BoxLayout"""
	[Getter(Spacing)] _spacing as single
	[Getter(Padding)] _padding as single

	def constructor(Position as Rect, spacing as single, padding as single):
		_Position = Position
		_spacing = spacing
		_padding = padding

	private def ApplyLayout():
		y = Padding
		max_width = 0
		for child as Widget in self.Children:
			if y != Padding:
				y += self.Spacing
			child.Position.Top = y
			child.Position.Left = Padding
			width = Padding + child.Position.Width + Padding
			if width > max_width:
				max_width = width
			y += child.Position.Height	
		y += Padding
		self.Position.Height = y
		self.Position.Width = max_width
		
	def AddChild(child as Widget):
		super(child)
		ApplyLayout()
		
	def Render():
		super()
