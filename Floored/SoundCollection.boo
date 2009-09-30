namespace Floored

import System.IO
import System.Collections.Generic
import Core
import Core.Sound
import OpenTK

class SoundCollection:
	static protected SoundCollections = Dictionary[of string, SoundCollection]()
	static public def Load(path as string):
		if not SoundCollections.ContainsKey(path):
			SoundCollections[path] = SoundCollection(path)
		return SoundCollections[path]
	
	// ----
	
	protected Random = System.Random()
	protected Sounds = Dictionary[of string, List[of Buffer]]()
	protected Sources = array(Source, 6)
	
	private def constructor(path as string):
		files as (string) = Directory.GetFiles(path)
		for file in files:
			continue if not file.EndsWith(".wav")
			
			// Extract sound group
			filePath = file
			filename = Path.GetFileName(file.Substring(0, file.Length - 4))
			match = /([a-zA-Z]*)/.Match(filename)
			continue if not match.Success
			filename = match.Groups[0].Value
			
			// Load sound
			buffer = Buffer(filePath)
			if not Sounds.ContainsKey(filename):
				Sounds[filename] = List[of Buffer]()
			Sounds[filename].Add(buffer)
			
		// Create some Sources
		//for i in range(Sources.Length):
		//	Sources[i] = Source8
			
			
	public def Play(name as string, position as Vector3, s as Source):
		return if not Sounds.ContainsKey(name)
		buffers = Sounds[name]
		buffer = buffers[Random.Next(buffers.Count)]
		s.Stop()
		s.Buffer = buffer
		s.Position = position
		s.Play()