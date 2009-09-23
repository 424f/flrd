namespace Floored

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL
import OpenTK.Platform
import OpenTK.Input
import Tao.DevIl

import Core.Graphics
import Core.Util.Ext

import AwesomiumDotNet

import Box2DX.Collision
import Box2DX.Common
def LoadShader(vertexPath as string, fragmentPath as string) as ShaderProgram:
	result = ShaderProgram()
	vertexShader = Shader(ShaderType.VertexShader, vertexPath)
	fragmentShader = Shader(ShaderType.FragmentShader, vertexPath)
	result.Attach(vertexShader)
	result.Attach(fragmentShader)
	result.Link()
	return result

abstract class AbstractGame(OpenTK.GameWindow):
	public WebCore as WebCore
	public webView as WebView
	browserTexture as int
	
	public def constructor():
		super(1280, 720, OpenTK.Graphics.GraphicsMode(ColorFormat(32), 32, 32, 0, ColorFormat(32)), "FLOORED")
		VSync = VSyncMode.Off	

	public override def OnLoad(e as EventArgs):		
		Il.ilInit()
		Ilut.ilutInit()
		Ilut.ilutRenderer(Ilut.ILUT_OPENGL)		
		
		Core.Sound.Sound.Init()
		
		WebCore = AwesomiumDotNet.WebCore()
		webView = WebCore.CreateWebView(Width, Height, true, true)
		webView.BeginLoading += { print "Loading!!" }
		isRunning = true
		webView.FinishLoading += def():
			print "Finished loading"
			isRunning = false
		
		webView.BeginNavigation += { print "begin navigation" }
		webView.Callback += { print "Callback" }
		webView.ChangeCursor += { print "cursor" }
		webView.ChangeKeyboardFocus += { print "keyboard focus" }
		webView.ChangeTargetURL += { print "target url" }
		webView.ChangeTooltip += { print "Tooltip" }
		webView.ReceiveTitle += { print "Receive title" }
		webView.SetCallback("Eval")
		

		def convert(mb as OpenTK.Input.MouseButton) as AwesomiumDotNet.MouseButton:
			if mb == OpenTK.Input.MouseButton.Left:
				return AwesomiumDotNet.MouseButton.Left
			elif mb == OpenTK.Input.MouseButton.Middle:
				return AwesomiumDotNet.MouseButton.Middle
			elif mb == OpenTK.Input.MouseButton.Right:
				return AwesomiumDotNet.MouseButton.Right
		
				
		self.Mouse.Move += { sender as object, e as OpenTK.Input.MouseMoveEventArgs | webView.InjectMouseMove(e.X, e.Y) }
		self.Mouse.ButtonDown += { sender as object, mbe as OpenTK.Input.MouseButtonEventArgs | webView.InjectMouseDown(convert(mbe.Button)) }
		self.Mouse.ButtonUp += { sender as object, mbe as OpenTK.Input.MouseButtonEventArgs | webView.InjectMouseUp(convert(mbe.Button)) }
		
		def MapKey(k as OpenTK.Input.Key):
			i = 0
			try:
				i = cast(int, System.Windows.Forms.Keys.Parse(System.Windows.Forms.Keys, k.ToString()))
			except:
				pass
			return i
		
		//System.Windows.Forms.7
		self.Keyboard.KeyDown += { sender as object, e as KeyboardKeyEventArgs | webView.InjectKeyboardEvent(IntPtr.Zero, AwesomiumDotNet.WM.Char, MapKey(e.Key), 0); 
		                                                                         webView.InjectKeyboardEvent(IntPtr.Zero, AwesomiumDotNet.WM.KeyDown, MapKey(e.Key), 0)}
		self.Keyboard.KeyUp += { sender as object, e as KeyboardKeyEventArgs | webView.InjectKeyboardEvent(IntPtr.Zero, AwesomiumDotNet.WM.KeyUp, MapKey(e.Key), 0) }
		self.KeyPress += { sender as object, e as OpenTK.KeyPressEventArgs | print "lawl" }
		
		browserTexture = GL.GenTexture()
				
		//GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMinFilter, cast(int, TextureMinFilter.LinearMipmapLinear));
		//GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMagFilter, cast(int, TextureMagFilter.Linear));	

		
		//OpenTK.Graphics.Glu.Build2DMipmap(TextureTarget.Texture2D, cast(int, PixelInternalFormat.Rgba), data.Width, data.Height, OpenTK.Graphics.PixelFormat.Bgra, PixelType.UnsignedByte, data.Scan0)
		/*bmp = Bitmap(Width, Height)
		data = bmp.LockBits(Rectangle(0, 0, Width, Height), ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format24bppRgb)
		GL.ReadPixels(0, 0, Width, Height, OpenTK.Graphics.PixelFormat.Bgr, PixelType.UnsignedByte, data.Scan0)
		GL.Finish()
		bmp.UnlockBits(data)
		bmp.RotateFlip(RotateFlipType.RotateNoneFlipY);
		n = DateTime.Now
		def fill(a as int, i as int):
			return string.Format("{0:d${i}}", a)
		bmp.Save("Screenshots/Screenshot ${n.Year}-${fill(n.Month, 2)}-${fill(n.Day, 2)} - ${fill(n.Hour, 2)}${fill(n.Minute, 2)}${fill(n.Second, 2)}.png", ImageFormat.Png);*/
		
		webView.LoadURL("""L:\Floored\Data\UI\loading.htm""")			

	protected override def OnResize(e as EventArgs):
		GL.Viewport(0, 0, self.Width, self.Height)
		GL.MatrixMode(MatrixMode.Projection)
		GL.LoadIdentity()
		Tao.OpenGl.Glu.gluPerspective(25.0, Width / cast(double, Height), 1.0, 10000.0)

	protected def UpdateGui():
		self.WebCore.Update()
		if webView.IsDirty():
			width = Width
			height = Height
			buffer = array(byte, width*height*4)
			bytesPerRow = 4*width
			
			webView.Render(buffer, bytesPerRow, 4)
			GL.ActiveTexture(TextureUnit.Texture0)
			GL.BindTexture(TextureTarget.Texture2D, browserTexture)
			GL.TexImage2D[of byte](TextureTarget.Texture2D, 0,PixelInternalFormat.Rgba, width, height, 0, OpenTK.Graphics.OpenGL.PixelFormat.Bgra, PixelType.UnsignedByte, buffer)			
			GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMinFilter, cast(int, TextureMinFilter.Linear));
			GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMagFilter, cast(int, TextureMagFilter.Linear));				

	protected def RenderGui():
		GL.MatrixMode(MatrixMode.Projection)
		GL.PushMatrix()
		GL.LoadIdentity()
		
		GL.MatrixMode(MatrixMode.Modelview)
		GL.PushMatrix()
		GL.LoadIdentity()
		Tao.OpenGl.Glu.gluOrtho2D(0, Width, Height, 0)
		
		GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha)
		GL.Enable(EnableCap.Blend)
		GL.Enable(EnableCap.Texture2D)
		GL.BindTexture(TextureTarget.Texture2D, browserTexture)
		GL.Begin(BeginMode.Triangles)
		GL.TexCoord2(0, 0)
		GL.Vertex3(0, 0, 0)
		GL.TexCoord2(1, 0)
		GL.Vertex3(Width, 0, 0)
		GL.TexCoord2(1, 1)
		GL.Vertex3(Width, Height, 0)

		GL.TexCoord2(1, 1)
		GL.Vertex3(Width, Height, 0)
		GL.TexCoord2(0, 1)
		GL.Vertex3(0, Height, 0)
		GL.TexCoord2(0, 0)
		GL.Vertex3(0, 0, 0)
		

		GL.End()		

		GL.MatrixMode(MatrixMode.Projection)
		GL.PopMatrix()
		
		GL.MatrixMode(MatrixMode.Modelview)
		GL.PopMatrix()			

class Game(AbstractGame):
	public static Instance as Game:
		get:
			if _Instance == null:
				_Instance = Game()
			return _Instance
	private static _Instance as Game
	
	// -- Graphics --
	public Camera as Camera
	public Light as Light
	public Skydome as Skydome
	public DefaultShader as ShaderProgram
	public Md3Shader as ShaderProgram
	public Particles as ParticleEngine
	public Terrain as Terrain
	
	// -- Gameplay --
	public ReloadTime = 0f
	public PrimaryReloadTime = 0f
	public Level as Levels.Level
	public Player as Objects.Player
	[Getter(Dt)] _Dt = 0.0f
	
	// -- Physics --
	public World as Floored.World
	public PhysicsTime = 0.0f
	public TimePassed = 0.0f
	
	// -- Settings --
	public ShowPhysics = false
	
	public Box as Shapes.Box
	public wall as Material
	public Tank as IRenderable	
	public FpsCounter as Core.Common.FPSCounter
	
	public Skin as Md3.CharacterSkin
	
	// -- Sound --
	public Listener as Core.Sound.Listener
	public Sound as Core.Sound.Buffer
	public Source as Core.Sound.Source
	public GSound as Core.Sound.Buffer
	public GSource as Core.Sound.Source
	
	public State as State
	
	public override def OnLoad(e as EventArgs):
		super.OnLoad(e)

		Tank = NullRenderable()

		self.Keyboard.KeyDown += KeyDown
		self.Keyboard.KeyUp += KeyUp
		
		// Set up a camera and a light
		Camera = Camera(Vector3(0, 3, 10), Vector3(0, 0, 0), Vector3(0, 1, 0))
		Light = Light(Tao.OpenGl.Gl.GL_LIGHT0)
		
		FpsCounter = Core.Common.FPSCounter()
		
		State = LoadingState(self)
		
	public override def OnRenderFrame(e as FrameEventArgs):
		FpsCounter.Frame()
		if FpsCounter.Updated:		
			webView.ExecuteJavaScript("updateFPS(${RenderFrequency})")			
		UpdateGui()
		State.Render()
		RenderGui()
		SwapBuffers()
		
	public def KeyDown(sender as object, e as KeyboardKeyEventArgs):
		key = e.Key
		if key == Input.Key.A:
			Player.WalkDirection.X += -1.0f
		elif key == Input.Key.D:
			Player.WalkDirection.X += 1.0f
		elif key == Input.Key.W:
			Player.DoJump = true
		
	public def KeyUp(sender as object, e as KeyboardKeyEventArgs):
		key = e.Key
		if key == Key.F1:
			ShowPhysics = not ShowPhysics
		elif key == Input.Key.A:
			Player.WalkDirection.X -= -1.0f
		elif key == Input.Key.D:
			Player.WalkDirection.X -= 1.0f			
		elif key == Key.W:
			Player.DoJump = false
		
	public override def OnUpdateFrame(e as FrameEventArgs):		
		_Dt = e.Time
		State = State.Update(_Dt)

game = Game.Instance
game.Run()
print "Floored"

