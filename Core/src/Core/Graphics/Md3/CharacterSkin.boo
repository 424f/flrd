namespace Core.Graphics.Md3

import System
import System.IO
import System.Collections.Generic
import Tao.OpenGl.Gl
import Core.Graphics

class CharacterSkin:
"""Description of CharacterSkin"""
	
	[Getter(Name)] _name as string
	"""The skin's name"""
	
	[Getter(Model)] _Model as CharacterModel
	"""The CharacterModel this skin belongs to"""

	private _textureNames = Dictionary[of string, string]()
	"""Maps Mesh names to texture names"""
	
	private _textures = Dictionary[of Mesh, Texture]()
	"""Maps Mesh instances to OpenGL textures"""
	
	[Getter(Icon)] _icon as Texture
	"""The character icon for this skin"""

	def constructor(model as CharacterModel, path as string, name as string):
		_Model = model
		_name = name
		
		LoadSkinFile(Path.Combine(path, "lower_${name}.Skin"))
		LoadSkinFile(Path.Combine(path, "upper_${name}.Skin"))
		LoadSkinFile(Path.Combine(path, "head_${name}.Skin"))
		
		LoadTexturesForModel(Model.Lower)
		LoadTexturesForModel(Model.Upper)
		LoadTexturesForModel(Model.Head)
		
		try:
			_icon = Texture.Load(Path.Combine(path, "icon_${name}.tga"))
		except:
			pass
		
	private def LoadSkinFile(path as string):
		using f = File.Open(path, FileMode.Open):
			s = StreamReader(f)
			line = ""
			while (line = s.ReadLine()) is not null:
				r = /(?<mesh>.*?),(?<texture>.*)/.Match(line)
				if r.Success and r.Groups["texture"].Length > 0:
					meshName = r.Groups["mesh"].Value
					textureFile = r.Groups["texture"].Value
					_textureNames[meshName] = textureFile
					
	def LoadTexturesForModel(model as Model):
		for mesh as Mesh in model.Meshes:
			continue if _textures.ContainsKey(mesh)
			continue if not _textureNames.ContainsKey(mesh.Header.Name)
			filename = Path.GetFileName(_textureNames[mesh.Header.Name])
			try:
				_textures.Add(mesh, Texture.Load(Path.Combine(_Model.Path, filename)))
			except e:
				if not filename.Contains("."):
					filename += ".jpg"
				//print e
				try:
					_textures.Add(mesh, Texture.Load(Path.Combine(_Model.Path, filename.Replace(".jpg", ".tga"))))
				except:
					try:
						_textures.Add(mesh, Texture.Load(Path.Combine(_Model.Path, filename.Replace(".tga", ".jpg"))))
					except:
						print "***WARNING*** Couldn't load texture ${filename}." # TODO: Ok, this is getting really stupid :) identify textures only by name, not extension
					
	def Render(character as CharacterInstance):
		glRotatef(-character.WalkAngle, 0, 1, 0)
		RenderModel(_Model.Lower, character.LowerFrame)
		if _Model.Lower.BeginTag("tag_torso", character.LowerFrame):
			glRotatef(-character.LookAngle + character.WalkAngle, 0, 1, 0)
			glRotatef(character.VerticalLookAngle, 1, 0, 0) //TODO: looking up / down
			RenderModel(_Model.Upper, character.UpperFrame)
			if _Model.Upper.BeginTag("tag_head", character.UpperFrame):
				//glRotatef(45.0, 0, 1, 0) TODO: head rotation
				RenderModel(_Model.Head, character.UpperFrame)
				_Model.Upper.EndTag()
				
			if character.WeaponModel is not null:
				if _Model.Upper.BeginTag("tag_weapon", character.UpperFrame):
					character.WeaponModel.Render()
					_Model.Upper.EndTag()
				
			_Model.Lower.EndTag()
		
	private def RenderModel(model as Model, frame as int):
		#Model.RenderBoundingBox(frame)
		#Model.RenderBoundingSphere(frame)
		for mesh as Mesh in model.Meshes:		
			if mesh in _textures.Keys:
				tex as Texture = _textures[mesh]
				tex.Bind()
			mesh.Render(frame)
			
	def GetInstance():
		return CharacterInstance(self)
