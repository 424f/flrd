namespace Floored

import System
import Core.Graphics
import OpenTK.Graphics

public class Material:
"""A material that can be assigned to an object and contains properties like
the diffuse and normal texture or lighting properties"""
	[Property(Name)] _Name as String
	[Property(DiffuseTexture)] _DiffuseTexture as Texture
	[Property(NormalTexture)] _NormalTexture as Texture
	
	public def constructor(name as String):
		Name = name
	
	public def Apply(program as ShaderProgram):
	"""Applies the current material to a given shader program. It will look for uniform
	variables 'NormalTexture' and 'DiffuseTexture' and load the according textures using
	texture units 0 and 1"""
		program.BindUniformTexture('DiffuseTexture', DiffuseTexture, 0)
		program.BindUniformTexture('NormalTexture', NormalTexture, 1)
		GL.ActiveTexture(TextureUnit.Texture0)	

