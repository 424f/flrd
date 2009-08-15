namespace Core.Common

import System
import Core

class ResourceManager:
"""
TODO: implement a resource manager that caches multiply requested files and verifies that the requested path corresponds _exactly_
to the actual file found, for compatibility with UNIX filesystems
"""
	static private _resources = {}

	static def LoadMD3Model(path as string):
		if path not in _resources:
			_resources[path] = Graphics.Md3.Model(path)
		return _resources[path] as Graphics.Md3.Model
		
	static def LoadMD3Character(path as string):
		if path not in _resources:
			_resources[path] = Graphics.Md3.CharacterModel(path)
		return _resources[path] as Graphics.Md3.CharacterModel
			
	static def LoadTexture(path as string):
		if path not in _resources:
			_resources[path] = Graphics.Texture.Load(path)
		return _resources[path] as Graphics.Texture
	
	static def LoadSound(path as string):
		if path not in _resources:
			_resources[path] = Sound.Buffer(path)
		return _resources[path]
