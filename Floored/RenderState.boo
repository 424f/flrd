namespace Floored

import OpenTK.Graphics
import Core.Graphics

class RenderState:
"""The RenderState describes the renderer's state and allows to minimize state changes etc."""	
	static public Instance as RenderState:
	"""An application-wide render state"""
		get:
			if _Instance == null:
				_Instance = RenderState()
			return _Instance
	static private _Instance as RenderState

	[Getter(PreviousMaterial)] _PreviousMaterial as Material
	
	[Getter(CurrentProgram)] _CurrentProgram as ShaderProgram
	
	private def constructor():
		pass
		
	public def ApplyMaterial(material as Material):
		if material != null and material != PreviousMaterial:
			material.Apply(CurrentProgram)
		_PreviousMaterial = null
		
	public def ApplyProgram(program as ShaderProgram):
		if CurrentProgram != program and CurrentProgram != null:
			CurrentProgram.Remove()
		if program != null:
			program.Apply()
		_CurrentProgram = program
		GL.ActiveTexture(TextureUnit.Texture0)		
			

