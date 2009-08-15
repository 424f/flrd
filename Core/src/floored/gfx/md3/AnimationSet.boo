namespace Core.Graphics.Md3

import System
import System.IO
import System.Collections

class AnimationDescriptor:
	public FirstFrame as Int32 = 0
	public NumFrames as Int32 = 1
	public LoopingFrames as Int32 = 1
	public FramesPerSecond as Int32 = 0

enum AnimationId:
	BOTH_DEATH_1 = 0
	BOTH_DEAD_1  = 1
	BOTH_DEATH_2 = 2
	BOTH_DEAD_2  = 3
	BOTH_DEATH_3 = 4
	BOTH_DEAD_3  = 5
	
	TORSO_GESTURE  = 6
	TORSO_ATTACK   = 7
	TORSO_ATTACK_2 = 8
	TORSO_DROP     = 9
	TORSO_RAISE    = 10
	TORSO_STAND    = 11
	TORSO_STAND_2  = 12
	
	LEGS_CROUCH    = 13
	LEGS_WALK      = 14
	LEGS_RUN       = 15
	LEGS_BACK      = 16
	LEGS_SWIM      = 17
	LEGS_JUMP      = 18
	LEGS_LAND      = 19
	LEGS_JUMPB     = 20
	LEGS_LANDB     = 21
	LEGS_IDLE      = 22
	LEGS_IDLE_CR   = 23
	LEGS_TURN      = 24

class AnimationSet:
"""Description of AnimationSet"""	
	#[Getter(Animations)] _animations as Generic.List[of AnimationDescriptor]
	[Getter(Animations)] _animations as (AnimationDescriptor)
	
	def constructor(path as string):
		anims = Generic.List[of AnimationDescriptor]()
		lowerOffset = 0
		using f = File.Open(path, FileMode.Open):
			s = StreamReader(f)
			line = ""
			while (line = s.ReadLine()) is not null:
				# strip comments
				commentPos = line.IndexOf("//")
				if commentPos != -1:
					line = line[:commentPos]
				continue if line.Length == 0
				
				# Values ar tab separated
				values = /\s+/.Split(line)
				continue if values.Length < 2
				
				# Character's sex
				if values[0] in ("sex", "headoffset", "footsteps"):
					pass
				# This is probably an animation descriptor, if not, we'll just ignore it
				elif values.Length >= 4:
					a = AnimationDescriptor()
					a.FirstFrame = int.Parse(values[0])
					a.NumFrames = int.Parse(values[1])
					a.LoopingFrames = int.Parse(values[2])
					a.FramesPerSecond = int.Parse(values[3])
					
					if a.LoopingFrames == 0: 
						a.LoopingFrames = 1
					
					# For the lower part, we need to adjust the start frames
					if anims.Count == AnimationId.LEGS_CROUCH:
						lowerOffset = a.FirstFrame - anims[cast(int, AnimationId.TORSO_GESTURE)].FirstFrame
					if anims.Count >= AnimationId.LEGS_CROUCH:
						a.FirstFrame -= lowerOffset
						
					anims.Add(a)

		# Now put the animation descriptors into an array for quick access
		_animations = array(AnimationDescriptor, anims)
		
	def GetAnimation(id as AnimationId) as AnimationDescriptor:
		return _animations[cast(int, id)]
