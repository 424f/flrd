namespace Core.Input
import Tao.Sdl.Sdl

import Core.Gui
import OpenTK.Math
import Core.Graphics

class Mouse(AbstractController):  
	static BUTTON_COUNT = 4
  
	_name = "Mouse"
	_values = []
	
	[Getter(LeftButton)]
	_leftButton as AbstractValue
	
	[Getter(RightButton)]
	_rightButton as AbstractValue
	
	[Property(Widget)] _widget as Widget
	"""The top-level widget (normally Screen)"""
	
	[Property(Camera)] _Camera as Camera
	"""Just some hack so i can scroll around with the mouse"""
	
	_xValue as AbstractValue
	_yValue as AbstractValue
	
	[Getter(XRel)] _xRel = AbstractValue("X relative")
	[Getter(YRel)] _yRel = AbstractValue("Y relative")
	
	_x as double
	X:
		get: return _x
		set:
			_x = value
			_xValue.Value = value

	_y as double
	Y:
		get: return _y
		set:
			_y = value
			_yValue.Value = value
	
	def constructor():
		_x = 0.0
		_y = 0.0
		
		_xValue = AbstractValue("Mouse X")
		_yValue = AbstractValue("Mouse Y")
		_leftButton = AbstractValue("Left button")
		_rightButton = AbstractValue("Right button")
		
	def HandleClick(state as int, button as int, x as int, y as int):
	"""
	type: SDL_MOUSEBUTTONDOWN or SDL_MOUSEBUTTONUP
	button in (SDL_BUTTON_LEFT, SDL_BUTTON_MIDDLE, SDL_BUTTON_RIGHT)
	"""
		if _widget is not null:
			_widget.InternalOnClick(Vector2(x, y))
		if button == SDL_BUTTON_LEFT:
			_leftButton.Fired = true
			_leftButton.Value = (1.0 if state == SDL_PRESSED else 0.0)
			print "STATE: ${state}"
		elif button == SDL_BUTTON_RIGHT:
			_rightButton.Fired = true
			_rightButton.Value = (1.0 if state == SDL_PRESSED else 0.0)
	
	def HandleWheelUp():
		if _Camera is not null:
			_Camera.Eye.Y += 3.0f
		
	def HandleWheelDown():
		if _Camera is not null:
			_Camera.Eye.Y -= 3.0f
	
	def HandleRelativeMovement(xrel as single, yrel as single):
		/*_xRel.Value += xrel / 200.0
		if System.Math.Abs(_xRel.Value) > 1.0f:
			_xRel.Value = _xRel.Value / System.Math.Abs(_xRel.Value)
		_yRel.Value += yrel / 200.0
		if System.Math.Abs(_yRel.Value) > 1.0f:
			_yRel.Value = _yRel.Value / System.Math.Abs(_yRel.Value)			*/
		_xRel.Value = xrel
		_yRel.Value = yrel
