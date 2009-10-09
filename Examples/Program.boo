namespace Examples

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Platform
import OpenTK.Graphics.OpenGL
import OpenTK.Input
import Tao.DevIl

import Core
import Core.Graphics
import Core.Util.Ext

import System
import System.Collections.Generic
import OpenTK
import OpenTK.Graphics.OpenGL
import AwesomiumDotNet
import Tao.OpenGl.Gl
import Tao.OpenGl

abstract class AbstractGame(OpenTK.GameWindow):
	public def constructor():
		super(512, 512, OpenTK.Graphics.GraphicsMode(ColorFormat(32), 32, 32, 0, ColorFormat(32)), "FLOORED")
		VSync = VSyncMode.Off	

	public override def OnLoad(e as EventArgs):
		Il.ilInit()
		Ilut.ilutInit()
		Ilut.ilutRenderer(Ilut.ILUT_OPENGL)		
		
		Core.Sound.Sound.Init()
	
	protected override def OnResize(e as EventArgs):
		GL.Viewport(0, 0, self.Width, self.Height)
		MatrixStacks.MatrixMode(MatrixMode.Projection)
		MatrixStacks.LoadIdentity()
		MatrixStacks.Perspective(45.0, Width / cast(double, Height), 1.0, 300.0)

class Game(AbstractGame):
	private struct Vertex:
		def constructor(x as single, y as single, z as single, r as single, g as single, b as single, a as single):
			Position = Vector3(x, y, z)
			Color = Vector3(r, g, b)
			U = (x + 20f) / 40f
			V = (z + 20f) / 40f
		
		U as single
		V as single
		Color as Vector3
		Position as Vector3
		
	public static Instance as Game:
		get:
			if _Instance == null:
				_Instance = Game()
			return _Instance
	private static _Instance as Game
	
	// -- Graphics --
	public Camera as Camera
	public Light as Light
	public Skydome as IRenderable
	
	public Tank as IRenderable
	public pbo as PixelBufferObject

	public foo as Ui.Dialog 
	vbo as VertexBufferObject
	Ibo as IndexBufferObject
	Character as Md3.CharacterInstance

	indices = (2, 1, 0, 0, 3, 2, 2, 1, 0, 0, 3, 2)
	yy = -3f
	dy = 0.01f
	dim = 50f
	vertices = (of Vertex: Vertex(-dim, yy, -dim, 1f, 1f, 1f, 1f), Vertex(dim, yy, -dim, 1f, 1f, 1f, 1f), Vertex(dim, yy, dim, 1f, 1f, 1f, 1f), Vertex(-dim, yy, dim, 1f, 1f, 1f, 1f),
	                       Vertex(-dim, yy-dy, -dim, 1f, 0, 0, 1f), Vertex(dim, yy-dy, -dim, 0f, 1f, 0f, 1f), Vertex(dim, yy-dy, dim, 0f, 0f, 1f, 1f), Vertex(-dim, yy-dy, dim, 1f, 0f, 1f, 1f))

	VisualizeDepthShader as ShaderProgram 
	biasMatrixLocation as int
	
	TimePassed = 0f
	EyeView = false
	dt as single
	
	FloorTexture as Texture
	
	ShadowMappingPass as ShadowMappingPass

	public override def OnLoad(e as EventArgs):
		super.OnLoad(e)
		self.Keyboard.KeyDown += def(sender as object, e as OpenTK.Input.KeyboardKeyEventArgs):
			if e.Key == OpenTK.Input.Key.Escape:
				self.Keyboard.KeyDown += { self.Exit() }
			elif e.Key == OpenTK.Input.Key.F1:
				EyeView = not EyeView
		Tank = Core.Graphics.Wavefront.Model.Load("""L:\Floored\Data\Models\tank.obj""")
		
		// Set up a camera and a light
		Camera = Camera(Vector3(-15, 20, 0), Vector3(0, 0, 0), Vector3(0, 1, 0))
		Light = Light(Tao.OpenGl.Gl.GL_LIGHT0)
	
		// Set up skydome
		Skydome = NullRenderable() # Skydome(Texture.Load("../Data/Textures/Sky.jpg"), 150f)
		
		pbo = PixelBufferObject(512, 512)
		foo = Ui.Dialog(512, 512)
		foo.LoadUrl("http://424f.com")
		
		vbo = VertexBufferObject()
		vbo.BeginUsage()
		// Copy data to VBO
		OpenTK.Graphics.OpenGL.GL.BufferData[of Vertex](OpenTK.Graphics.OpenGL.BufferTarget.ArrayBuffer, IntPtr(4*8*vertices.Length), vertices, OpenTK.Graphics.OpenGL.BufferUsageHint.StaticDraw)
		vbo.EndUsage()
		vertices = null
		
		Ibo = IndexBufferObject()
		Ibo.BeginUsage()
		OpenTK.Graphics.OpenGL.GL.BufferData(OpenTK.Graphics.OpenGL.BufferTarget.ElementArrayBuffer, IntPtr(4*indices.Length), indices, OpenTK.Graphics.OpenGL.BufferUsageHint.StaticDraw)
		Ibo.EndUsage()
		indices = null
		
		Model = Core.Graphics.Md3.CharacterModel.Load("../Data/Models/Players/Bender/")
		skin = Model.Skins["default"]
		Character = skin.CreateInstance()
		Character.Scale = 0.1f
		Character.Position.Y = -3f
		Character.LowerAnimation = Model.GetAnimation(Md3.AnimationId.LEGS_WALK)
		Character.UpperAnimation = Model.GetAnimation(Md3.AnimationId.TORSO_GESTURE)
		
		VisualizeDepthShader = Core.Graphics.ShaderProgram("../Data/Shaders/VisualizeDepth.vert", "../Data/Shaders/VisualizeDepth.frag", false)
		VisualizeDepthShader.Attach(Shader(ShaderType.FragmentShader, "../Data/Shaders/ShadowMappingOut.frag"))
		VisualizeDepthShader.Attach(Shader(ShaderType.VertexShader, "../Data/Shaders/ShadowMappingOut.vert"))
		VisualizeDepthShader.Link()
		
		biasMatrixLocation = VisualizeDepthShader.GetUniformLocation("biasMatrix")
		
		FloorTexture = Texture.Load("../Data/Textures/wall.dds")
		
		ShadowMappingPass = ShadowMappingPass(512, 512)
		
	public override def OnRenderFrame(e as FrameEventArgs):
		Character.Tick(e.Time)
		TimePassed += e.Time
		dt = e.Time
		
		Camera.Eye = Vector3(System.Math.Cos(TimePassed*0.5f)*12f, Camera.Eye.Y, System.Math.Sin(TimePassed*0.5f)*12f)
		Light.Position = Vector4(System.Math.Cos(TimePassed)*5f, 10.0f, 5f*System.Math.Sin(TimePassed), 1f).AsArray()
		
		// Set up scene
		GL.ClearColor(System.Drawing.Color.SkyBlue)
		
		GL.Enable(EnableCap.DepthTest)
		GL.Enable(EnableCap.CullFace)
		//GL.Disable(EnableCap.CullFace)
				
		// First pass
		ShadowMappingPass.Run(Vector3(Light.Position[0], Light.Position[1], Light.Position[2]), Vector3.Zero, RenderScene)
		
		// -----------------------
		
		// Second pass
		GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit | ClearBufferMask.StencilBufferBit)
		GL.Viewport(0, 0, Width, Height)
		
		MatrixStacks.MatrixMode(MatrixMode.Projection)
		MatrixStacks.LoadIdentity()
		MatrixStacks.Perspective(45.0, Width / cast(double, Height), 1.0, 300.0)
		
		if EyeView:
			MatrixStacks.Ortho(20.0, 20.0, 0.5, 300.0)
			
		MatrixStacks.MatrixMode(MatrixMode.Modelview)
		if not EyeView:
			MatrixStacks.LoadIdentity()
			Camera.Push()		
		
		Light.Enable()
		VisualizeDepthShader.Apply()
		VisualizeDepthShader.BindUniformMatrix("biasMatrix", ShadowMappingPass.BiasMatrix)
		VisualizeDepthShader.BindUniformTexture("ShadowMap", ShadowMappingPass.ShadowMap, 2)
		RenderScene()
		VisualizeDepthShader.Remove()
		if not EyeView:
			Camera.Pop()
		
		SwapBuffers()
		
		print RenderFrequency

	vel = 0f
	public def RenderScene():		
		vbo.BeginUsage()
		Ibo.BeginUsage()

		FloorTexture.Bind()

		OpenTK.Graphics.OpenGL.GL.EnableClientState(OpenTK.Graphics.OpenGL.EnableCap.VertexArray)
		OpenTK.Graphics.OpenGL.GL.EnableClientState(OpenTK.Graphics.OpenGL.EnableCap.ColorArray)
		OpenTK.Graphics.OpenGL.GL.EnableClientState(OpenTK.Graphics.OpenGL.EnableCap.TextureCoordArray)
		
		OpenTK.Graphics.OpenGL.GL.TexCoordPointer(2, OpenTK.Graphics.OpenGL.TexCoordPointerType.Float, 4*8, IntPtr.Zero)
		OpenTK.Graphics.OpenGL.GL.ColorPointer(3, OpenTK.Graphics.OpenGL.ColorPointerType.Float, 4*8, 4*2)
		OpenTK.Graphics.OpenGL.GL.VertexPointer(3, OpenTK.Graphics.OpenGL.VertexPointerType.Float, 4*8, 4*5)
		
		GL.Normal3(0, 1, 0)
		
		// Should be: glVertexAttribPointer 
		OpenTK.Graphics.OpenGL.GL.DrawElements(OpenTK.Graphics.OpenGL.BeginMode.Triangles, 12, OpenTK.Graphics.OpenGL.DrawElementsType.UnsignedInt, IntPtr.Zero)
		
		Ibo.EndUsage()
		vbo.EndUsage()		
		
		OpenTK.Graphics.OpenGL.GL.DisableClientState(OpenTK.Graphics.OpenGL.EnableCap.VertexArray)
		OpenTK.Graphics.OpenGL.GL.DisableClientState(OpenTK.Graphics.OpenGL.EnableCap.ColorArray)
		OpenTK.Graphics.OpenGL.GL.DisableClientState(OpenTK.Graphics.OpenGL.EnableCap.TextureCoordArray)

		MatrixStacks.Push()

		pos = Character.Position
		Character.Render()	
		
		Character.Position.X = -5
		Character.Position.Z = 5
		Character.Render()
		
		Character.Position = pos
		
		for pos in (Vector3(0, 2, 3), Vector3(0, 0, 5), Vector3(3, 0, 0), Vector3(3, 10, 3)):
			MatrixStacks.Push()
			MatrixStacks.Translate(pos)
			q = Glu.gluNewQuadric()
			Glu.gluSphere(q, 2f, 10, 10)
			Glu.gluDeleteQuadric(q)
			MatrixStacks.Pop()

		MatrixStacks.Pop()
		
	public override def OnUpdateFrame(e as FrameEventArgs):		
		System.Windows.Forms.Cursor.Current = Windows.Forms.Cursors.Cross
		//foo.Update()
		//foo.UpdateTexture()

game = Game.Instance
game.Run()
game.Dispose()
