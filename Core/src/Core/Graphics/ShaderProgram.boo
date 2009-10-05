namespace Core.Graphics

import System
import System.Collections.Generic
import OpenTK
import OpenTK.Graphics.OpenGL

public class ShaderProgram:
"""A shader program, consisting of a vertex and a fragment shader"""
	[Getter(Handle)] _Handle as int
	"""Internal handle for this program"""

	[Getter(IsLinked)] _IsLinked = false
	"""Has the program already been linked?"""

	[Getter(VertexShaders)] _VertexShaders = List[of Shader]()
	[Getter(FragmentShaders)] _FragmentShaders = List[of Shader]()
	
	protected UniformLocations = Dictionary[of string, int]()

	public def constructor():
		_Handle = GL.CreateProgram()
		
	public def constructor(vertexShaderPath as string, fragmentShaderPath as string, doLink as bool):
		self()
		Attach(Shader(ShaderType.VertexShader, vertexShaderPath))
		Attach(Shader(ShaderType.FragmentShader, fragmentShaderPath))
		if doLink:
			Link()
		
	public def Attach(shader as Shader):
		if shader.ShaderType == ShaderType.FragmentShader:
			_FragmentShaders.Add(shader)
		elif shader.ShaderType == ShaderType.VertexShader:
			_VertexShaders.Add(shader)
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
		for vs in (_VertexShaders, _FragmentShaders):
			for v in vs:
				GL.DetachShader(Handle, v.Handle)
				v.Reload() if v != null
				GL.AttachShader(Handle, v.Handle)
		Link()
		
	public def BindUniformTexture(name as string, texture as Texture, textureUnit as int):
		loc = GetUniformLocation(name)
		GL.ActiveTexture(TextureUnit.Parse(TextureUnit, "Texture${textureUnit}"))
		texture.Bind()		
		GL.Uniform1(loc, textureUnit)
		GL.ActiveTexture(TextureUnit.Texture0)
		
	public def BindUniformMatrix(name as string, m as Matrix4):
		loc = GetUniformLocation(name)
		GL.UniformMatrix4(loc, false, m)