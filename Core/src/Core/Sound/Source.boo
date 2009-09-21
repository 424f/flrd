namespace Core.Sound

import Tao.OpenAl.Al
import OpenTK.Math

class Source(System.IDisposable):
	[Property(Id)] _id as int

	Position as Vector3:
		get:
			return _Position
		set:
			_Position = value
			alSourcefv(_id, AL_POSITION, (value.X, value.Y, value.Z))
	private _Position as Vector3
	"""The source's Position"""

	Velocity as Vector3:
		get:
			return _velocity
		set:
			_velocity = value
			alSourcefv(_id, AL_VELOCITY, (value.X, value.Y, value.Z))
	private _velocity as Vector3
	"""The source's velocity"""
	
	Direction as Vector3:
		get:
			return _direction
		set:
			_direction = value
			alSourcefv(_id, AL_DIRECTION, (value.X, value.Y, value.Z))
	private _direction as Vector3
	"""The source's direction"""	

	Buffer as Buffer:
	"""The buffer this source is playing"""
		get:
			return _Buffer
		set: 
			_Buffer = value
			alSourcei(_id, AL_BUFFER, value.Id)
	private _Buffer as Buffer
	
	def constructor(buffer as Buffer):
		ids = array(int, 1)
		alGenSources(1, ids)
		Sound.HandleErrors()
		_id = ids[0]
		
		alSourcei(_id, AL_BUFFER, buffer.Id)
		Sound.HandleErrors()
		
		//alSourcef(_id, AL_REFERENCE_DISTANCE, 30.0f)
		
		self.Position = Vector3(0.0f, 0.0f, 0.0f)
		self.Velocity = Vector3(0.0f, 0.0f, 0.0f)
		self.Direction = Vector3(0.0f, 0.0f, 0.0f)
		
		Buffer = buffer
		
	def Play():
		alSourcePlay(_id)
		
	def Stop():
		alSourceStop(_id)
		
	def Rewind():
		alSourceRewind(_id)
		
	def Pause():
		alSourcePause(_id)
		
	def Dispose():
		alDeleteSources(1, (_id))
