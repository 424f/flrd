namespace Core.Graphics

import System
import System.IO
import OpenTK.Graphics.OpenGL
import OpenTK.Graphics.OpenGL.GL

public class Shader:
"""Provides around the function calls needed to set up a fragment or vertex shader"""
	[Getter(Handle)] _Handle as int
	"""The internal handle for this shader"""

	[Getter(ShaderType)] _ShaderType as ShaderType
	"""Describes what kind of shader this is"""

	protected _Path as string
	"""The file this shader was loaded from (if any). This is allows us to reload the
	shader anytime during runtime"""

	public def constructor(shaderType as ShaderType):
		_Handle = CreateShader(shaderType)
		_ShaderType = shaderType

	public def constructor(shaderType as ShaderType, path as string):
		self(shaderType)
		_Path = path
		Compile(File.ReadAllText(path))
	
	public def Compile(script as string):		
			ShaderSource(Handle, script)
			info as string
			statusCode as int
			
			CompileShader(Handle)
			GetShaderInfoLog(Handle, info)
			GetShader(Handle, ShaderParameter.CompileStatus, statusCode)
			
			if statusCode != 1:
				raise Exception("Compiling shader failed:\n${info}")
			
	public def Reload():
		return if _Path == null
		Compile(File.ReadAllText(_Path))