namespace Core.Graphics

import OpenTK

class RenderCall:
	public Shader as ShaderProgram
	public Material as Material
	public ModelView as Matrix4 // modelview for this object
	public Call as callable() as void
	
	def CompareTo(call as RenderCall):
		pass

interface IRenderable:
	def Render()
	
	Shader as ShaderProgram:
		get
	
	Material as Material:
		get

abstract class AbstractRenderable(IRenderable):
	public Material:
	"""The material that is used to render this object"""
		virtual get:
			return _Material
		virtual set:
			_Material = value
	protected _Material as Material
	
	public Shader as ShaderProgram:
		virtual get:
			return _Shader
		virtual set:
			_Shader = value
	protected _Shader as ShaderProgram