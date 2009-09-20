namespace Core.Input

import Tao.Sdl.Sdl

class Keyboard(AbstractController):
	static BUTTON_COUNT = 320
  
	_name = "Keyboard"
	
	def constructor():
		SDL_EnableUNICODE(1)
		_values = [AbstractValue("Key #" + i) for i in range(BUTTON_COUNT)]
	
	def HandleChar(c as char):
		if c == '0':
			return
		//Widget.OnChar(c)

	def HandleKey(key as int, value as double):
		if key < 0 or key >= BUTTON_COUNT:
			return
		HandleDefault(_values[key] as AbstractValue, value)
