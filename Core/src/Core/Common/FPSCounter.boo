namespace Core.Common

class FPSCounter:
"""
FPSCounter is a simple utility class that can be used to calculate the frames per second of a program. After creating an
FPSCounter instance, call Frame() after every rendered frame. You can then access
the FramesPerSecond property which is always updated with the most recently calculated value.
"""
	[Getter(FramesPerSecond)]
	_framesPerSecond as int
	"""The number of frames rendered during the previous second"""

	[Getter(Updated)]
	_updated = false
	"""Has the value just been updated?"""

	private _frames as int
	private _passed as single

	def constructor():
		_framesPerSecond = 0
		_frames = 0
		_passed = 0f
		
	def Frame(dt as single):
	"""Call this method at the end of every frame"""
		_frames++
		_passed += dt
		if _passed >= 1f:
			_framesPerSecond = _frames / _passed
			_passed = 0f
			_frames = 0
			_updated = true
		else:
			_updated = false

	
