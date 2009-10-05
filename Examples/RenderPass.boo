namespace Examples

import System
import OpenTK
import OpenTK.Graphics.OpenGL
import Core
import Core.Graphics

interface IPass:
	def Export(nextPass as ShaderProgram)
	def Run()
	def UpdateVariables(program as ShaderProgram)

class ShadowMappingPass(IPass):
"""
A primitive shadow mapping pass

Export to fragment shader:
	calculateShadow()
"""
	[Getter(ShadowMap)] _ShadowMap as Texture
	[Getter(BiasMatrix)] _BiasMatrix as Matrix4
	OutFragmentShader as Shader
	OutVertexShader as Shader
	
	public def constructor():
		OutFragmentShader = Shader(ShaderType.FragmentShader, "../Data/Shaders/ShadowMappingOut.frag")
		OutVertexShader = Shader(ShaderType.VertexShader, "../Data/Shaders/ShadowMappingOut.vert")
	
	public def Export(nextPass as ShaderProgram):
		nextPass.Attach(OutFragmentShader)
		nextPass.Attach(OutVertexShader)
	
	public def UpdateVariables(program as ShaderProgram):
		program.BindUniformTexture("ShadowMap", ShadowMap, 3)
		program.BindUniformMatrix("biasMatrix", BiasMatrix)
	
	public def Run(light as Camera, renderCall as callable):
		pass

class RenderPass(IPass):
	Program as ShaderProgram
	public ShadowPass as ShadowMappingPass
	
	public def constructor():
		Program = ShaderProgram("../Data/Shaders/VisualizeDepth.vert", "../Data/Shaders/VisualizeDepth.frag", false)
	
	public def Compile():
		ShadowPass.Export(self.Program)
		Program.Link()
	
	public def Run(camera as Camera, renderCall as callable):
		pass //Program.BindUniformMatrix("ShadowMap", 
		
class RenderExample:
	def RunProgram():
		shadowPass = ShadowMappingPass()
		
		renderPass = RenderPass()
		renderPass.ShadowPass = shadowPass
		
		renderSchedule = (of IPass: shadowPass, renderPass)
		for p in renderSchedule:
			p.Run()