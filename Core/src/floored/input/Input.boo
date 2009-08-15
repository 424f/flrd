namespace Core.Input

import Tao.Sdl.Sdl

class Input:
	[Property(Controllers)] static _controllers = []	
	[Getter(Mouse)] static _mouse as Mouse	
	[Getter(Keyboard)] static _keyboard as Keyboard	
	[Getter(Joysticks)] static _joysticks as (Joystick)
	
	public static PRESSED as double = 1.0
	public static RELEASED as double = 0.0
	public static MAX_AXIS_VALUE as double = 32767.0
	
  
	static def FindControllers():
	"""Needs to be called for the input devices to be loaded"""
		# Load keyboard & mouse
		#SDL_WM_GrabInput(SDL_GRAB_ON)
		_keyboard = Keyboard()
		_controllers += [_keyboard]
		_mouse = Mouse()
		_controllers += [_mouse]
	  
		# Load the joysticks
		numJoysticks = SDL_NumJoysticks()
		_joysticks = array(Joystick, numJoysticks)
		for i in range(numJoysticks):
			#print 'Loading joystick', i
			_joysticks[i] = Joystick(i)
		_controllers += _joysticks
			
	static def HandleEvents():
		_mouse.HandleRelativeMovement(0, 0)
		ev as SDL_Event
		while SDL_PollEvent(ev) == 1:
			# Handling of mouse
			if ev.type == SDL_MOUSEMOTION:
				_mouse.X = ev.motion.x
				_mouse.Y = ev.motion.y
				_mouse.HandleRelativeMovement(ev.motion.xrel, ev.motion.yrel)
			elif ev.type == SDL_MOUSEBUTTONUP or ev.type == SDL_MOUSEBUTTONDOWN:
				_mouse.HandleClick(ev.button.state, ev.button.button, ev.button.x, ev.button.y)
				if ev.button.button == SDL_BUTTON_WHEELUP:
					_mouse.HandleWheelUp()
				if ev.button.button == SDL_BUTTON_WHEELDOWN:
					_mouse.HandleWheelDown()
			# Handling of keyboard
			elif ev.type == SDL_KEYDOWN:
				_keyboard.HandleKey(ev.key.keysym.sym, (Input.PRESSED if ev.key.state == SDL_PRESSED else Input.RELEASED))
				_keyboard.HandleChar(cast(char, ev.key.keysym.unicode))
			elif ev.type == SDL_KEYUP:
				_keyboard.HandleKey(ev.key.keysym.sym, (Input.PRESSED if ev.key.state == SDL_PRESSED else Input.RELEASED))
			# Handling of joystick
			elif ev.type == SDL_JOYBUTTONDOWN or ev.type == SDL_JOYBUTTONUP:
				_joysticks[ev.jbutton.which].HandleButton(ev.jbutton.button, (Input.PRESSED if ev.jbutton.state == SDL_PRESSED else Input.RELEASED))
			elif ev.type == SDL_JOYAXISMOTION:
				_joysticks[ev.jaxis.which].HandleAxis(ev.jaxis.axis, cast(double, ev.jaxis.val) / Input.MAX_AXIS_VALUE)
			elif ev.type == SDL_JOYBALLMOTION:
				_joysticks[ev.jball.which].HandleBall(ev.jball.ball, ev.jball.xrel, ev.jball.yrel)
  		_mouse.HandleRelativeMovement(0, 0)

class AbstractValue:
	def constructor(name as string):
		_name = name
  
	_name = "Abstract value"
	Name:
		get: return _name

	_value as double = Input.RELEASED
	Value:
		virtual get: return _value
		virtual set: _value = value
		
	public Fired as bool
	
class AmplifiedValue(AbstractValue):
	V as AbstractValue	
	Multiplier = 0.0
	
	Value:
		get: return V.Value * Multiplier
		set: pass
	
	def constructor(name as string, v as AbstractValue, multiplier as double):
		super(name)
		self.V = v
		self.Multiplier = multiplier

class CompositeValue(AbstractValue):
"""A composite taking to values v1 and v2 and having the value v2 - v1"""
	_v1 as AbstractValue
	_v2 as AbstractValue
	
	Value:
		get: return _v2.Value - _v1.Value
		set: pass
	
	def constructor(name as string, v1 as AbstractValue, v2 as AbstractValue):
		super(name)
		_v1 = v1
		_v2 = v2

class DummyValue(AbstractValue):
	private static _inst as DummyValue
	static def Instance():
		if _inst is null:
			_inst = DummyValue()
		return _inst
		
	def constructor():
		super("Dummy value")

class AbstractController:
"""A generic controller that provides input values (see AbstractValue)"""  
	_name as string = "AbstractController"
	Name as string:
		get: return _name

	_values = []
	Values:
		get: return _values
		
	protected def HandleDefault(v as AbstractValue, value as double):
		# TODO: use buffering for fired
		v.Fired = value == Input.PRESSED and v.Value == Input.RELEASED
		v.Value = value
