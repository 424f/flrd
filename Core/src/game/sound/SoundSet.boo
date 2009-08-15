namespace Game.Sound

import System.IO
import System.Collections.Generic
import Core.Sound

class SoundSet:
"""
Wraps a collection of sounds that belong together with the possibility of 
having multiple alternate recordings of the same sound.
"""
	sounds = Dictionary[of string, List[of Buffer]]()
	"""For each possible sound, contains a list of all available alternate recordings"""

	def constructor(directory as string):
		if not Directory.Exists(directory):
			raise "Directory ${directory} doesn't exist."
		for file in Directory.GetFiles(directory):
			name = Path.GetFileNameWithoutExtension(file).Split(("_",), 3, System.StringSplitOptions.None)[0]
			if not sounds.ContainsKey(name):
				sounds.Add(name, List[of Buffer]())
			sounds[name].Add(Core.Common.ResourceManager.LoadSound(file))
			#_footSound = Core.Sound.Source(ResourceManager.LoadSound("data/sound/footsteps/wood.Wav"))

	def Play(name as string, Position as OpenTK.Math.Vector3):
		if not sounds.ContainsKey(name):
			print "*** WARNING *** Didn't find sound ${name}"
			return
		source = Core.Sound.Source(sounds[name][0])
		source.Position = Position
		source.Play()
		print "Now playing ${name}.."
