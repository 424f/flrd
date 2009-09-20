namespace Core.Graphics.Md3

import System
import System.IO
import System.Collections.Generic

class CharacterModel:
	[Getter(Lower)] _lower as Model
	[Getter(Upper)] _upper as Model
	[Getter(Head)] _head as Model
	
	[Getter(Path)] _path as string
	[Getter(Skins)] _skins = Dictionary[of string, CharacterSkin]()
	
	[Getter(AnimationSet)] _animationSet as AnimationSet
	
	def constructor(path as string):
		if not Directory.Exists(path):
			raise Exception("Directory ${path} does not exits")
		_path = path		
		
		# Load the models making up the character
		_lower = Model(IO.Path.Combine(path, "lower.Md3"))
		_upper = Model(IO.Path.Combine(path, "upper.Md3"))
		_head = Model(IO.Path.Combine(path, "head.Md3"))
		
		# Load animations
		_animationSet = AnimationSet(IO.Path.Combine(path, "animation.cfg"))
		
		# Find all the available skins
		files as (string) = Directory.GetFiles(path)
		for file in files:
			filename = IO.Path.GetFileName(file)
			r = /lower_(?<name>.*).skin/.Match(filename)
			continue if not r.Success
			name = r.Groups["name"].Value
			_skins[name] = CharacterSkin(self, path, name)

	def Render(frame as int):
		_lower.Render(frame)
		_lower.BeginTag("tag_torso", frame)
		_upper.Render(frame)
		_upper.BeginTag("tag_head", frame)
		_head.Render(frame)
		_upper.EndTag()		
		_lower.EndTag()
		
	def GetAnimation(id as AnimationId) as AnimationDescriptor:		
		return AnimationSet.GetAnimation(id)	
