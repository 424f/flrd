namespace Core.Sound

import System
import Tao.OpenAl.Al
import Tao.OpenAl.Alut

class Buffer(IDisposable):
	[Getter(Id)] _id as int

	def constructor(path as string):
		# todo: cache files
		_id = alutCreateBufferFromFile(path)

	def Dispose():
		alDeleteBuffers(1, (_id))	
