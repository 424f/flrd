namespace Core.Sound

import Tao.OpenAl.Al
import OpenTK

class Listener:
	
	Position as Vector3:
		get:
			return _Position
		set:
			_Position = value
			alListenerfv(AL_POSITION, (value.X, value.Y, value.Z))
	private _Position as Vector3
	"""The listener's Position"""
	
	velocity as Vector3:
		get:
			return _velocity
		set:
			_velocity = value
			alListenerfv(AL_VELOCITY, (value.X, value.Y, value.Z))
	private _velocity as Vector3
	"""The listener's velocity"""

	Orientation as Vector3:
		get:
			return _orientation
		set:
			_orientation = value
			alListenerfv(AL_ORIENTATION, (value.X, value.Y, value.Z, up.X, up.Y, up.Z))
	_orientation as Vector3
	"""The direction the listener is looking at"""

	up as Vector3:
		get:
			return _up
		set:
			_up = value
			alListenerfv(AL_ORIENTATION, (Orientation.X, Orientation.Y, Orientation.Z, value.X, value.Y, value.Z))
	private _up as Vector3
	"""The listener's up-vector"""
	
	def constructor():
		Position = Vector3(0.0f, 0.0f, 0.0f)
		velocity = Vector3(0.0f, 0.0f, 0.0f)
		_orientation = Vector3(0.0f, 0.0f, -1.0f)
		up = Vector3(0, 1, 0)	
