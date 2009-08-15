namespace Core.Common

class FPSCounter:
"""
FPSCounter is a simple utility class that can be used to calculate the frames per second of a program. All you
need to do is instantiate a FPSCounter object and call the method frame() on it every frame. You can then access
the framesPerSecond property which is always updated with the most recently calculated value.
"""
	[Getter(FramesPerSecond)]
	_framesPerSecond as int
	"""The number of frames rendered during the previous second"""

	[Getter(Updated)]
	_updated = false
	"""Has the value just been updated?"""

	private _frames as int = 0
	private _lastSecond as System.DateTime

	def constructor():
		_framesPerSecond = 0
		_frames = 0
		_lastSecond = System.DateTime.Now
		
	def Frame():
	"""Call this method at the end of every frame"""
		_frames++
		now = System.DateTime.Now
		if now.Second != _lastSecond.Second:
			_framesPerSecond = _frames
			_lastSecond = now
			_frames = 0
			_updated = true
		else:
			_updated = false

	
