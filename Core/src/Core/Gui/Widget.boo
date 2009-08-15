namespace Core.Gui

import OpenTK.Math
import Tao.OpenGl.Gl
import Core.Math

abstract class Widget:
	Position as Rect:
		virtual get:
			return _Position
		virtual set:
			_Position = value
	_Position as Rect
	
	Color:
		virtual set:
			_color = value
		virtual get:
			return _color
	_color = Vector4(1, 1, 1, 1)
	
	[Getter(Children)] _children = []
	[Getter(Parent)] _parent as Widget
	
	virtual def Render():
	"""Used to render the widget. By default calls render() on all the children. If you'd like to keep that behaviour for your own widget, call this method"""
		glTranslatef(Position.Left, Position.Top, 0)		
		for child as Widget in _children:
			child.Render()
		glTranslatef(-Position.Left, -Position.Top, 0)		
		
	virtual def AddChild(child as Widget):
		_children += [child]
		if child._parent != null:
			child._parent.RemoveChild(child)
		child._parent = self
		
	virtual def RemoveChild(child as Widget):
		_children.Remove(child)
		child._parent = null
	
	virtual def InternalOnClick(position as Vector2):
		# First check whether a child overlaps the Position, only if that fails try self
		for child as Widget in Children:
			if child.Position.Contains(position):
				t = position
				t.X -= self.Position.Left
				t.Y -= self.Position.Top
				child.InternalOnClick(t)
				return
		if self.Position.Contains(position):
			OnClick()
	
	/* Events that can be used to control the behaviour of a certain widget */
	virtual def OnClick():
		pass
	virtual def OnMouseIn():
		pass
	virtual def OnMouseOut():
		pass
	virtual def OnChar(c as char):
		pass
