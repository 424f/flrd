namespace Floored

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Platform
import OpenTK.Math
import OpenTK.Input
import Tao.DevIl

import Core
import Core.Graphics
import Core.Sound
import Core.Util.Ext

import AwesomiumDotNet

import Box2DX.Collision
import Box2DX.Common
import Box2DX.Dynamics

import System.Drawing
import System.Drawing.Imaging

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
		webView = WebCore.CreateWebView(400, 400)
		webView.BeginLoading += { print "Loading!!" }
		isRunning = true
		webView.FinishLoading += def():
			/*width = 400
			height = 400
			buffer = array(byte, width*height*4)
			bytesPerRow = 4*width
			//webView.Render(buffer, bytesPerRow, 4)
			
			bmp = System.Drawing.Bitmap(width, height)
			data = bmp.LockBits(Rectangle(0, 0, width, height), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb)
			webView.Render(data.Scan0.ToInt32(), bytesPerRow, 4)
			bmp.UnlockBits(data)
			
			bmp.Save("render.png", ImageFormat.Png)*/
			
			print "Finished loading"
			isRunning = false
		
		//AwesomiumDotNet.WebView().
		webView.BeginNavigation += { print "begin navigation" }
		webView.Callback += { print "Callback" }
		webView.ChangeCursor += { print "cursor" }
		webView.ChangeKeyboardFocus += { print "keyboard focus" }
		webView.ChangeTargetURL += { print "target url" }
		webView.ChangeTooltip += { print "Tooltip" }
		webView.ReceiveTitle += { print "Receive title" }
		

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
		
		webView.LoadURL("http://gasi.ch")			
		

	protected override def OnResize(e as ResizeEventArgs):
		GL.Viewport(0, 0, self.Width, self.Height)
		GL.MatrixMode(MatrixMode.Projection)
		GL.LoadIdentity()
		Glu.Perspective(25.0, Width / cast(double, Height), 1.0, 10000.0)

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
	
	// -- Physics --
	public World as Floored.World
	public PhysicsTime = 0.0f
	
	// -- Settings --
	public ShowPhysics = false
	
	Box as Shapes.Box
	wall as Material
	Tank as IRenderable	
	
	// -- Sound --
	Listener as Core.Sound.Listener
	Sound as Core.Sound.Buffer
	Source as Core.Sound.Source
	GSound as Core.Sound.Buffer
	GSource as Core.Sound.Source
	
	public override def OnLoad(e as EventArgs):
		super.OnLoad(e)

		Tank = NullRenderable()

		self.Keyboard.KeyDown += KeyDown
		self.Keyboard.KeyUp += KeyUp
		
		// Set up a camera and a light
		Camera = Camera(Vector3(0, 3, 10), Vector3(0, 0, 0), Vector3(0, 1, 0))
		Light = Light(0)
	
		// Set up skydome
		Skydome = Skydome(Texture.Load("../Data/Textures/Sky.jpg"), 150f)

		// Load shader
		//DefaultShader = LoadShader("../Data/Shaders/bump.vert", "../Data/Shaders/bump.frag")
		Program = ShaderProgram()
		VertexShader = Shader(ShaderType.VertexShader, "../Data/Shaders/bump.vert")
		FragmentShader = Shader(ShaderType.FragmentShader, "../Data/Shaders/bump.frag")
		Program.Attach(VertexShader)
		Program.Attach(FragmentShader)
		Program.Link()
		DefaultShader = Program

		Program = ShaderProgram()
		VertexShader = Shader(ShaderType.VertexShader, "../Data/Shaders/md3_vertex.glsl")
		FragmentShader = Shader(ShaderType.FragmentShader, "../Data/Shaders/md3_fragment.glsl")
		Program.Attach(VertexShader)
		Program.Attach(FragmentShader)
		Program.Link()
		Md3Shader = Program
		
		// Particles
		Particles = ParticleEngine(null)

		// Create materials
		wall = Material("Wall");
		wall.DiffuseTexture = Texture.Load("../Data/Textures/wall.dds")
		wall.NormalTexture = Texture.Load("../Data/Textures/wall_n.dds")
		
		Box = Shapes.Box(Vector3(6f, 0.01f, 6f))
		
		// Load a character with weapon
		Model = Md3.CharacterModel("../Data/Models/Players/police/")
		skin = Model.Skins["default"]

/*		Weapon = Md3.Model("../Data/Models/Weapons/machinegun/machinegun.md3")
		Character.WeaponModel = Weapon*/

		// Create world
		worldAABB = AABB()
		worldAABB.LowerBound.Set(-200f, -200f)
		worldAABB.UpperBound.Set(200f, 200f)
		World = Floored.World(worldAABB, Vec2(0, -25f), 0.0f)
	
		// Create player
		Player = Objects.Player(skin)
		Player.Weapon = Objects.Weapons.MachineGun()
		World.Objects.Add(Player)		
	
		// Create NPCs
		npcModel = Md3.CharacterModel("../Data/Models/Players/sergei/")
		//skin = Model.Skins["default"]
		for i in range(3):
			skin = npcModel.Skins["default"]
			npc = Objects.Player(skin)
			npc.Position = Vector3(i * 2.0f, 30.0f, 0.0f)
			World.Objects.Add(npc)
	

		
		// Create level
		Level = Levels.Level(World)
		
		// Sound
		Listener = Core.Sound.Sound.GetListener()
		if Sound == null:
			Sound = Core.Sound.Buffer("../Data/Sound/Weapons/silenced.wav")
			Source = Core.Sound.Source(Sound)	
			GSound = Core.Sound.Buffer("../Data/Sound/Weapons/grenlf1a.wav")
			GSource = Core.Sound.Source(GSound)	
		
		// Terrain
		Terrain = Core.Graphics.Terrain({ file as string | Texture.Load(file) })
		
	public override def OnRenderFrame(e as RenderFrameEventArgs):
		self.WebCore.Update()
		if webView.IsDirty():
			width = 400
			height = 400
			buffer = array(byte, width*height*4)
			bytesPerRow = 4*width
			
			webView.Render(buffer, bytesPerRow, 4)
			GL.ActiveTexture(TextureUnit.Texture0)
			GL.BindTexture(TextureTarget.Texture2D, browserTexture)
			OpenTK.Graphics.GL.TexImage2D[of byte](TextureTarget.Texture2D, 0, OpenTK.Graphics.PixelInternalFormat.Rgba, width, height, 0, OpenTK.Graphics.PixelFormat.Rgba, OpenTK.Graphics.PixelType.UnsignedByte, buffer)			
			GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMinFilter, cast(int, TextureMinFilter.Linear));
			GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMagFilter, cast(int, TextureMagFilter.Linear));				

			/*bmp = System.Drawing.Bitmap(width, height)
			data = bmp.LockBits(Rectangle(0, 0, width, height), System.Drawing.Imaging.ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb)
			webView.Render(data.Scan0.ToInt32(), bytesPerRow, 4)
			bmp.UnlockBits(data)
			
			bmp.Save("render.png", ImageFormat.Png)*/
		
		// Center camera
		Camera.Eye = Player.Position + Vector3(0f, 2f, 20f)
		Camera.LookAt = Player.Position + Vector3(0f, 1f, 0f)

		// Set up scene
		GL.ClearColor(System.Drawing.Color.SkyBlue)
		GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit | ClearBufferMask.StencilBufferBit)
		
		GL.Disable(EnableCap.Texture2D)
		GL.Enable(EnableCap.DepthTest)
		GL.Enable(EnableCap.Blend)
		GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha)
		
		GL.MatrixMode(MatrixMode.Modelview)
		GL.LoadIdentity()
		
		Camera.Push()
		
		Light.Position = (Camera.Eye.X, Camera.Eye.Y, -Camera.Eye.Z, 0)
		Light.Enable()
		
		// Render skydome
		GL.PushMatrix()
		GL.Translate(0, -60f, 0)
		GL.Translate(Camera.Eye)
		GL.Rotate(45.0, 0, 1, 0)
		Skydome.Render()
		GL.PopMatrix()
		
		// Boxes
		RenderState.Instance.ApplyProgram(null)
		RenderState.Instance.ApplyProgram(DefaultShader)
		RenderState.Instance.ApplyMaterial(wall)
		// Floor
		//Box.Render()
		
		for o in World.Objects:
			o.Render() if o.EnableRendering
		
		RenderState.Instance.ApplyProgram(null)
		
		// Visualize physics
		// Render AABBs
		GL.Disable(EnableCap.Texture2D)
		if ShowPhysics:
			GL.Disable(EnableCap.DepthTest)
			aabb as AABB
			GL.Disable(EnableCap.Texture2D);
			GL.PolygonMode(MaterialFace.FrontAndBack, PolygonMode.Line);
			GL.Begin(BeginMode.Quads);
			b = World.Physics.GetBodyList()
			while b != null:
				s = b.GetShapeList()
				while s != null:
					if not b.IsSleeping():
						GL.Color4(System.Drawing.Color.Green)
					else:
						GL.Color4(System.Drawing.Color.Gray);									
					if s.IsSensor:
						si = s.UserData as SensorInformation
						if si.__LastContact < 1.0f:
							GL.Color4(System.Drawing.Color.Purple)
							si.__LastContact += 0.01f
					s.ComputeAABB(aabb, b.GetXForm());
					GL.Vertex3(aabb.LowerBound.X, aabb.LowerBound.Y, 0.0f);
					GL.Vertex3(aabb.UpperBound.X, aabb.LowerBound.Y, 0.0f);
					GL.Vertex3(aabb.UpperBound.X, aabb.UpperBound.Y, 0.0f);
					GL.Vertex3(aabb.LowerBound.X, aabb.UpperBound.Y, 0.0f);
					s = s.GetNext()
				b = b.GetNext()
			
			// Render Joints
			GL.Color4(System.Drawing.Color.Blue);
			joint = World.Physics.GetJointList()
			while joint != null:
				GL.Vertex3(joint.Anchor1.X, joint.Anchor1.Y, 0.0f)
				GL.Vertex3(joint.Anchor2.X, joint.Anchor2.Y, 0.0f)
				GL.Vertex3(joint.GetBody1().GetPosition().X, joint.GetBody1().GetPosition().Y, 0.0f)
				GL.Vertex3(joint.GetBody2().GetPosition().X, joint.GetBody2().GetPosition().Y, 0.0f)
				joint = joint.GetNext()
			
			GL.End()
			GL.PolygonMode(MaterialFace.FrontAndBack, PolygonMode.Fill)
		
			GL.Enable(EnableCap.DepthTest)

		Terrain.Render()
		
		Particles.Render()
		
		// Render GUI
		GL.MatrixMode(MatrixMode.Projection)
		GL.PushMatrix()
		GL.LoadIdentity()
		
		GL.MatrixMode(MatrixMode.Modelview)
		GL.PushMatrix()
		GL.LoadIdentity()
		Glu.Ortho2D(0, Width, Height, 0)
		
		GL.Enable(EnableCap.Texture2D)
		GL.BindTexture(TextureTarget.Texture2D, browserTexture)
		GL.Begin(BeginMode.Triangles)
		GL.TexCoord2(0, 0)
		GL.Vertex3(0, 0, 0)
		GL.TexCoord2(1, 0)
		GL.Vertex3(400, 0, 0)
		GL.TexCoord2(1, 1)
		GL.Vertex3(400, 400, 0)

		GL.TexCoord2(1, 1)
		GL.Vertex3(400, 400, 0)
		GL.TexCoord2(0, 1)
		GL.Vertex3(0, 400, 0)
		GL.TexCoord2(0, 0)
		GL.Vertex3(0, 0, 0)
		

		GL.End()		

		GL.MatrixMode(MatrixMode.Projection)
		GL.PopMatrix()
		
		GL.MatrixMode(MatrixMode.Modelview)
		GL.PopMatrix()	
		
		Camera.Pop()
		
		SwapBuffers()
		
	public def KeyDown(sender as KeyboardDevice, key as Key):
		pass
		
	public def KeyUp(sender as KeyboardDevice, key as Key):
		if key == Key.F1:
			ShowPhysics = not ShowPhysics
		
	public override def OnUpdateFrame(e as UpdateFrameEventArgs):		
		// Gameplay
		dt as single = e.Time
		
		PhysicsTime += dt
		StepSize = 0.015f
		while PhysicsTime >= StepSize:					
			# Is player touching the ground?
			# ???
			
			# Update character
			ReloadTime -= StepSize
			PrimaryReloadTime -= StepSize
			joystick = Joysticks[0]
			Player.WalkDirection = Vector2(joystick.Axis[0], joystick.Axis[1])
			Player.LookDirection = Vector2(-joystick.Axis[2], -joystick.Axis[3])
			Player.DoJump = joystick.Button[0]
			
			# Walking
			/*
			
				
				
			
			Dir = Vector3(dir2.X, dir2.Y, 0.0f);
			/*if KeyStates.ContainsKey(Keys.Space):
				Dir.Y = 7.0f;*/
			walkingThreshold = 2.0f;
			runningThreshold = 4.0f;
			maxSpeed = 10.5f;
			accel = 2.0f;
			walking = Dir.Length >= walkingThreshold;
			running = Dir.Length >= runningThreshold;
		
			
			if Dir.Y > 0.1f:
				Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_JUMP)
			elif Dir.Y < -0.1f:
				Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_LAND)
			elif Dir.Length >= runningThreshold:
				Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_RUN)
			elif Dir.Length >= walkingThreshold:
				Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_WALK)
			else:
				Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_IDLE)
			
			# Shooting
			for i in range(joystick.Button.Count):
				if joystick.Button[i]:
					pass
		
					
			if joystick.Button[5] and ReloadTime <= 0f:
				o = Objects.Grenade(World)
				look = Vector3.Normalize(Character.LookDirection)
				o.Body.SetXForm((PlayerBody.GetPosition()) + (look * 0.7f).AsVec2(), 0.0f)
				o.Body.ApplyImpulse(o.Body.GetMass() * look.AsVec2() * 30.0f, Vec2.Zero)
				World.Objects.Add(o)
				ReloadTime = 0.5f
				GSource.Position = Character.Position
				//Source.Direction = Character.LookDirection
				GSource.Velocity = Character.LookDirection * 100.0f
				GSource.Play()*/
				
			Particles.Tick(dt)

			World.Step(StepSize)
			PhysicsTime -= StepSize
		
		# Update
		/*pos = PlayerBody.GetPosition()
		Character.Position = Vector3(pos.X, pos.Y - 1.0f, Character.Position.Z)		*/
		
		# Listener
		Listener.Position = Player.Position + Vector3(0, 0, 2.0f)
		Listener.Orientation = Vector3(0, 0, -1)
		
game = Game.Instance
game.Run()
print "Floored"

