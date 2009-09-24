namespace Core.Graphics

import System
import System.Collections.Generic
import OpenTK.Graphics.OpenGL

public class ShaderProgram:
"""A shader program, consisting of a vertex and a fragment shader"""
	[Getter(Handle)] _Handle as int
	"""Internal handle for this program"""

	[Getter(IsLinked)] _IsLinked = false
	"""Has the program already been linked?"""

	// TODO: multiple shaders are possible (see glAttachShader doc)
	[Getter(VertexShader)] _VertexShader as Shader
	[Getter(FragmentShader)] _FragmentShader as Shader
	
	protected UniformLocations = Dictionary[of string, int]()

	public def constructor():
		_Handle = GL.CreateProgram()
		
	public def constructor(vertexShaderPath as string, fragmentShaderPath as string):
		Attach(Shader(ShaderType.VertexShader, vertexShaderPath))
		Attach(Shader(ShaderType.FragmentShader, fragmentShaderPath))
		Link()
		
	public def Attach(shader as Shader):
		if shader.ShaderType == ShaderType.FragmentShader:
			raise Exception("There is already a fragment shader attached to this program.") if _FragmentShader != null
			_FragmentShader = shader				
		elif shader.ShaderType == ShaderType.VertexShader:
			raise Exception("There is already a vertex shader attached to this program.") if _VertexShader != null
			_VertexShader = shader
		GL.AttachShader(Handle, shader.Handle)
		
	public def Link():
		GL.LinkProgram(Handle)
		_IsLinked = true
		
	public def Apply():
		raise Exception("Program has to be linked first") if not IsLinked
		GL.UseProgram(Handle)
		
	public def Remove():
		raise Exception("Program has to be linked first") if not IsLinked
		GL.UseProgram(0)
		
	public def GetUniformLocation(location as string) as int:
		if not UniformLocations.ContainsKey(location):
			UniformLocations[location] = GL.GetUniformLocation(Handle, location)
		return UniformLocations[location]
		
	public def Reload():
	"""Reloads all the shaders attached to this program"""
		UniformLocations.Clear()
		for v in (_VertexShader, _FragmentShader):
			GL.DetachShader(Handle, v.Handle)
			v.Reload() if v != null
			GL.AttachShader(Handle, v.Handle)
		Link()
		
	public def BindUniformTexture(name as string, texture as Texture, textureUnit as int):
		loc = GetUniformLocation(name)
		GL.ActiveTexture(TextureUnit.Parse(TextureUnit, "Texture${textureUnit}"))
		texture.Bind()		
		GL.Uniform1(loc, textureUnit)