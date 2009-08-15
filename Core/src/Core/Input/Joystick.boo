namespace Core.Input

import Tao.Sdl.Sdl

class Joystick(AbstractController):
	_id as int
	_device as System.IntPtr
	
	[Getter(Buttons)] _buttons as (AbstractValue)
	[Getter(Axes)] _axes as (AbstractValue)
	[Getter(Hats)] _hats as (AbstractValue)
	[Getter(Balls)] _balls as (AbstractValue)
  
	def constructor(joystickId as int):
		_id = joystickId
		_name = "Joystick " + _id
		_device = SDL_JoystickOpen(_id)
		
		# Set up mapping for our values
		_buttons = array(AbstractValue, SDL_JoystickNumButtons(_device))
		for i in range(_buttons.Length):
			_buttons[i] = AbstractValue("Button #" + i)
		_values += array(_buttons)
		
		_axes = array(AbstractValue, SDL_JoystickNumAxes(_device))
		for i in range(_axes.Length):
			_axes[i] = AbstractValue("Axis #" + i)
		_values += array(_axes)

		_hats = array(AbstractValue, SDL_JoystickNumHats(_device))
		for i in range(_hats.Length):
			_hats[i] = AbstractValue("Hat #" + i)
		_values += array(_hats)
		
		_balls = array(AbstractValue, SDL_JoystickNumBalls(_device))
		for i in range(_balls.Length):
			_balls[i] = AbstractValue("Ball #" + i)
		_values += array(_balls)		
		
	def destructor():
		SDL_JoystickClose(_device)
		
	def HandleButton(buttonId as int, state as double):
		HandleDefault(_buttons[buttonId], state)
		
	def HandleAxis(axisId as int, value as double):
		HandleDefault(_axes[axisId], value)
		
	def HandleBall(ballId as int, xrel as double, yrel as double):
		pass
	  
	def HandleHats(hatId as int, value as double):  
		pass
