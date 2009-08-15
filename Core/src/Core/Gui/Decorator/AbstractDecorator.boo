namespace Core.Gui.Decorator

import System
import Core.Gui
import OpenTK.Math

abstract class AbstractDecorator(Widget):
"""

"""

	[Getter(Widget)] _widget as Widget
	"""The widget this decorator is wrapping"""

	Position:
		override get:
			return _widget.Position
		override set:
			_widget.Position = value

	Color:
		override get:
			return _widget.Color
		override set:
			_widget.Color = value

	def constructor(widget as Widget):
		self._widget = widget
		_children.Add(widget)

	override def AddChild(child as Widget):
		Widget.AddChild(child)
		
	override def RemoveChild(child as Widget):
		Widget.RemoveChild(child)
		
	override def InternalOnClick(Position as Vector2):
		Widget.InternalOnClick(Position)
