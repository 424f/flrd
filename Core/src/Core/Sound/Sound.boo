namespace Core.Sound

import System
import Tao.OpenAl.Al
import Tao.OpenAl.Alut
		
class OpenALException(Exception):
	def constructor(text as string):
		super(text)
		
class Sound:
	static def Init():
		alutInit()
		HandleErrors()
	
	static def Close():
		alutExit()
	
	private static _listener as Listener
	public static internal def GetListener():
		if _listener is null:
			_listener = Listener()
		return _listener

	static def HandleErrors():
		err = alGetError()
		if err != AL_NO_ERROR and false: # TODO: fix
			raise OpenALException("An OpenAL exception occured: #${err}")