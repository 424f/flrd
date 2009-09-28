namespace Core.Graphics.Md3

import System
import Tao.OpenGl.Gl
import OpenTK
import Core.Math
import Core.Graphics

class CharacterInstance(AbstractRenderable):
"""An instance of a CharacterModel using a given CharacterSkin"""
	[Property(Position)] _Position as Vector3
	"""World position where instance will be rendered"""
	[Getter(Skin)] _skin as CharacterSkin
	"""Skin describing the textures to be used to render this character instance"""
	
	[Property(LowerFrame)] _lowerFrame as single
	"""Current frame of legs animation"""
	[Property(UpperFrame)] _upperFrame as single
	"""Current frame of torso animation"""
	
	[Property(Scale)] _Scale = 1.0f
	"""The factor by which the character is scaled"""
	
	LookDirection: 
		get:
			return _lookDirection
		set:
			_lookDirection = value
			_lookAngle = Math.Atan2(value.X, -value.Z) / Math.PI * 180
			tmp = Vector3(_lookDirection.X, 0.0, _lookDirection.Z)
			angle = Vector3.CalculateAngle(_lookDirection, tmp) / Math.PI * 180
			// TODO: real fix
			if single.IsNaN(angle):
				angle = 90f
			_VerticalLookAngle = Math.Sign(_lookDirection.Y) * angle
	_lookDirection as Vector3
	
	LookAngle:
		get:
			return _lookAngle
		set:
			v = value * Math.PI / 180.0
			LookDirection = Vector3(Math.Sin(v), 0, -Math.Cos(v))			
	_lookAngle as single			

	WalkDirection: 
		get:
			return _walkDirection
		set:
			_walkDirection = value
			_walkAngle = Math.Atan2(value.X, -value.Z) / Math.PI * 180
	_walkDirection as Vector3
	
	WalkAngle:
		get:
			return _walkAngle
		set:
			v = value * Math.PI / 180.0
			WalkDirection = Vector3(Math.Sin(v), 0, -Math.Cos(v))			
	_walkAngle as single		
	
	[Property(WeaponModel)] _WeaponModel as IRenderable
	
	Model:
		get: return _skin.Model
	
	LowerAnimation as AnimationDescriptor:
		set:
			SetLowerAnimation(value, false)
		get:
			return _lowerAnimation
	_lowerAnimation = AnimationDescriptor()

	UpperAnimation as AnimationDescriptor:
		set:
			SetUpperAnimation(value, false)
		get:
			return _upperAnimation
	_upperAnimation = AnimationDescriptor()
	
	[Property(VerticalLookAngle)] _VerticalLookAngle = 0.0f
	
	def constructor(skin as CharacterSkin):
		_Position = Vector3(0, 0, 0)
		_skin = skin
		_lowerFrame = 0
		_upperFrame = 0
		_lookDirection = Vector3(0, 0, -1)
		_walkDirection = Vector3(0, 0, -1)
	
	def SetUpperAnimation(animation as AnimationDescriptor, forceRestart as bool):
		return if not forceRestart and _upperAnimation == animation
		_upperAnimation = animation
		_upperFrame = animation.FirstFrame

	def SetLowerAnimation(animation as AnimationDescriptor, forceRestart as bool):
		return if not forceRestart and _lowerAnimation == animation
		_lowerAnimation = animation
		_lowerFrame = animation.FirstFrame
	
	def Render():
		MatrixStacks.Push()
		MatrixStacks.Translate(_Position.X, _Position.Y, _Position.Z)
		MatrixStacks.Scale(Scale, Scale, Scale)
		MatrixStacks.Translate(0, 25.5f, 0)
		_skin.Render(self)
		MatrixStacks.Pop()
		
	def Tick(dt as single):			
		# Lower animation
		_lowerFrame += dt * _lowerAnimation.FramesPerSecond
		while _lowerFrame >= cast(single, _lowerAnimation.FirstFrame + _lowerAnimation.NumFrames):
			_lowerFrame -= _lowerAnimation.LoopingFrames

		# Upper animation
		_upperFrame += dt * _upperAnimation.FramesPerSecond
		while _upperFrame >= cast(single, _upperAnimation.FirstFrame + _upperAnimation.NumFrames):
			_upperFrame -= _upperAnimation.LoopingFrames
			
	def GetBoundingSphere() as Sphere:
		frameinfo as Frame = Model.Lower.Frames[self.LowerFrame % Model.Lower.Header.NumFrames]
		return Sphere(self.Position, frameinfo.Radius)
		
	def CalculateWeaponPosition():
		MatrixStacks.SetUserMode(true)
		
		MatrixStacks.Rotate(-WalkAngle, 0, 1, 0)
		MatrixStacks.Multiply(Model.Lower.GetTagMatrix("tag_torso", self._lowerFrame))
		MatrixStacks.Rotate(-LookAngle + WalkAngle, 0, 1, 0)
		MatrixStacks.Rotate(VerticalLookAngle, 1, 0, 0)
		MatrixStacks.Multiply(Model.Upper.GetTagMatrix("tag_weapon", self._upperFrame))
		
		m = MatrixStacks.User.Matrix
		x = Vector4.Transform(Vector4(0, 0, 0, 1), m)
		
		MatrixStacks.SetUserMode(false)
		return Scale*Vector3(x.X, x.Y, x.Z)