namespace Floored

import System.Collections.Generic
import Core.Input

class Controller:
	_keys = Dictionary[of string, AbstractValue]()
	
	public AbsoluteMode = false
	"""If set to true, controlling the character is absolute, i.e.
	pointing to the left corner makes the character walk to the left instead 
	of turning in the appropriate direction"""
	
	def constructor():
		pass
		
	def Bind(key as AbstractValue, action as string):
		_keys[action] = key

	def GetBinding(action as string) as AbstractValue:
		if _keys.ContainsKey(action):
			return _keys[action]
		return DummyValue()
