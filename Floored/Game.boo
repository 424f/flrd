namespace Floored

import System
import System.Drawing
import System.Drawing.Imaging
import Core
import OpenTK
import OpenTK.Graphics.OpenGL
import OpenTK.Input

import Core.Graphics
import Floored


def LoadShader(vertexPath as string, fragmentPath as string) as ShaderProgram:
	result = ShaderProgram()
	vertexShader = Shader(ShaderType.VertexShader, vertexPath)
	fragmentShader = Shader(ShaderType.FragmentShader, vertexPath)
	result.Attach(vertexShader)
	result.Attach(fragmentShader)
	result.Link()
	return result

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
	public UpdateFrustum = true
	
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
	public TakeScreenshot = false
	
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
		
		self.KeyPress += { print "KeyPress" }

	public override def OnUpdateFrame(e as FrameEventArgs):		
		System.Windows.Forms.Cursor.Current = System.Windows.Forms.Cursors.Default
		_Dt = e.Time
		State = State.Update(_Dt)
		SwapBuffers()
		
	public override def OnRenderFrame(e as FrameEventArgs):
		UpdateGui()
		State.Render()
		RenderGui()
		
		if TakeScreenshot:
			bmp = Bitmap(Width, Height)
			data = bmp.LockBits(Rectangle(0, 0, Width, Height), ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format24bppRgb)
			GL.ReadPixels(0, 0, Width, Height, OpenTK.Graphics.OpenGL.PixelFormat.Bgr, PixelType.UnsignedByte, data.Scan0)
			GL.Finish()
			bmp.UnlockBits(data)
			bmp.RotateFlip(RotateFlipType.RotateNoneFlipY)
			n = DateTime.Now
			def fill(a as int, i as int):
				return string.Format("{0:d${i}}", a)
			bmp.Save("../Screenshots/Screenshot ${n.Year}-${fill(n.Month, 2)}-${fill(n.Day, 2)} - ${fill(n.Hour, 2)}${fill(n.Minute, 2)}${fill(n.Second, 2)}.png", ImageFormat.Png)
			TakeScreenshot = false
		
	public def KeyDown(sender as object, e as KeyboardKeyEventArgs):
		key = e.Key
		if key == Input.Key.A:
			Player.WalkDirection.X += -1.0f
		elif key == Input.Key.D:
			Player.WalkDirection.X += 1.0f
		elif key == Input.Key.W:
			Player.DoJump = true
		elif key == Input.Key.E:
			Player.DoFire = true
		elif key == Input.Key.R:
			Player.DoSecondaryFire = true
		elif key == Input.Key.Escape:
			Exit()
		
	public def KeyUp(sender as object, e as KeyboardKeyEventArgs):
		key = e.Key
		if key == Key.F1:
			ShowPhysics = not ShowPhysics
		elif key == Key.F2:
			UpdateFrustum = not UpdateFrustum
		elif key == Input.Key.A:
			Player.WalkDirection.X -= -1.0f
		elif key == Input.Key.D:
			Player.WalkDirection.X -= 1.0f			
		elif key == Key.W:
			Player.DoJump = false
		elif key == Input.Key.R:
			Player.DoSecondaryFire = false			
		elif key == Input.Key.E:
			Player.DoFire = false

game = Game.Instance
game.Run()
print "Floored"

