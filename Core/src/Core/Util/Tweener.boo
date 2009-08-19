namespace Core.Util

import System
import System.Reflection

interface ITweener:
	def Update(dt as single):
		pass
	Finished as bool:
		get
		
class Tweener[of T](ITweener):
"""Description of Tweener"""
	[Getter(StartValue)] _StartValue as T
	[Getter(EndValue)] _EndValue as T
	[Getter(Target)] _Target as object
	[Getter(Transition)] _Transition as callable(object, T, T, single) as T
	[Getter(Duration)] _Duration as single
	[Getter(Elapsed)] _Elapsed as single
	Finished as bool:
		get: return Elapsed >= Duration

	public def constructor(target as object, startValue as T, endValue as T, transition as callable(object, T, T, single) as T, duration as single):
		_Target = target
		_StartValue = startValue
		_EndValue = endValue
		_Transition = transition
		_Duration = duration
		_Elapsed = 0.0f
		
	public def Update(dt as single):
		_Elapsed += dt	
		m = Elapsed / Duration
		Transition(Target, StartValue, EndValue, m)
	
	// Several transition functions
	static def Linear(a as single, b as single, m as single):
		return b*m + (1.0f-m)*a

	