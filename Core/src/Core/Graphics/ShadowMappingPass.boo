namespace Core.Graphics

import System
import OpenTK
import OpenTK.Graphics.OpenGL
import Core
import Core.Graphics
import Tao.OpenGl.Gl

class ShadowMappingPass:
"""
A primitive shadow mapping pass

Export to fragment shader:
	calculateShadow()
"""
	[Getter(ShadowMap)] _ShadowMap as Texture
	
	BiasMatrix as Matrix4:
		get:
			Vframe = MatrixStacks.ModelView.Matrix	
			bias = Matrix4(0.5, 0, 0, 0.5,
			               0, 0.5, 0, 0.5,
			               0, 0, 0.5, 0.5,
			               0, 0, 0, 1)
			bias.Transpose() // OpenGL is column-major, constructor of Matrix4 is row-major		
			return Matrix4.Invert(Vframe) * View * Projection * bias		
	
	OutFragmentShader as Shader
	OutVertexShader as Shader
	Width as int
	Height as int
	FrameBuffer as FrameBufferObject
	public View as Matrix4
	public Projection as Matrix4
	Frustum as Frustum
	
	public def constructor(width as int, height as int):
		Width = width
		Height = height
		FrameBuffer = FrameBufferObject()		
		_ShadowMap = Core.Graphics.Texture(Width, Height, PixelInternalFormat.DepthComponent, OpenTK.Graphics.OpenGL.PixelFormat.DepthComponent, PixelType.UnsignedByte)
		ShadowMap.Bind()
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
		glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_R_TO_TEXTURE)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC_ARB, GL_LEQUAL)
		glTexParameteri(GL_TEXTURE_2D, GL_DEPTH_TEXTURE_MODE_ARB, GL_INTENSITY)
		FrameBuffer.BeginUsage()
		FrameBuffer.Attach(ShadowMap, FramebufferAttachment.DepthAttachment)
		Tao.OpenGl.Gl.glDrawBuffer(0)
		FrameBuffer.EndUsage()
		
		OutFragmentShader = Shader(ShaderType.FragmentShader, "../Data/Shaders/ShadowMappingOut.frag")
		OutVertexShader = Shader(ShaderType.VertexShader, "../Data/Shaders/ShadowMappingOut.vert")
		Frustum = Frustum()
	
	public def Export(nextPass as ShaderProgram):
		nextPass.Attach(OutFragmentShader)
		nextPass.Attach(OutVertexShader)
	
	public def UpdateVariables(program as ShaderProgram):
		program.BindUniformTexture("ShadowMap", ShadowMap, 3)
		program.BindUniformMatrix("biasMatrix", BiasMatrix)
	
	public def Inject(shader as ShaderProgram):
		shader.Attach(OutFragmentShader)
		shader.Attach(OutVertexShader)		
	
	public def Run(light as Vector3, lightAt as Vector3, renderCall as callable(Frustum)):
		GL.Enable(EnableCap.CullFace)
		glCullFace(GL_FRONT)
		FrameBuffer.BeginUsage()
		GL.Viewport(0, 0, Width, Height)
		GL.Clear(ClearBufferMask.DepthBufferBit)
		GL.Enable(EnableCap.DepthTest)
		OpenTK.Graphics.OpenGL.GL.DepthMask(true)
		
		MatrixStacks.MatrixMode(MatrixMode.Projection)
		MatrixStacks.LoadIdentity()
		//MatrixStacks.Perspective(45.0, Width / cast(double, Height), 1.0, 300.0)
		MatrixStacks.Ortho(20.0, 20.0, 0.5, 300.0)
		
		MatrixStacks.MatrixMode(MatrixMode.Modelview)
		MatrixStacks.LoadIdentity()
		MatrixStacks.LookAt(light, lightAt, Vector3(0, 1, 0))
		
		Projection = MatrixStacks.Projection.Matrix
		View = MatrixStacks.ModelView.Matrix
		
		Frustum.Update(View, Projection)
		
		renderCall(Frustum)
		FrameBuffer.EndUsage()

		glCullFace(GL_BACK);