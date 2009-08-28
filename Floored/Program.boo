namespace Floored

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Platform
import OpenTK.Math
import Tao.DevIl

import Core
import Core.Graphics
import Core.Sound
import Core.Util.Ext

import Box2DX.Collision
import Box2DX.Common
import Box2DX.Dynamics

def LoadShader(vertexPath as string, fragmentPath as string) as ShaderProgram:
	result = ShaderProgram()
	vertexShader = Shader(ShaderType.VertexShader, vertexPath)
	fragmentShader = Shader(ShaderType.FragmentShader, vertexPath)
	result.Attach(vertexShader)
	result.Attach(fragmentShader)
	result.Link()
	return result

abstract class AbstractGame(OpenTK.GameWindow):
	public def constructor():
		super(1280, 720, OpenTK.Graphics.GraphicsMode(ColorFormat(32), 32, 32, 0, ColorFormat(32)), "FLOORED")
		VSync = VSyncMode.Off	

	public override def OnLoad(e as EventArgs):
		Il.ilInit()
		Ilut.ilutInit()
		Ilut.ilutRenderer(Ilut.ILUT_OPENGL)		
		
		Core.Sound.Sound.Init()

	protected override def OnResize(e as ResizeEventArgs):
		GL.Viewport(0, 0, self.Width, self.Height)
		GL.MatrixMode(MatrixMode.Projection)
		GL.LoadIdentity()
		Glu.Perspective(15.0, Width / cast(double, Height), 1.0, 10000.0)

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
	
	// -- Gameplay --
	public Character as Md3.CharacterInstance
	public ReloadTime = 0f
	public PrimaryReloadTime = 0f
	public Level as Levels.Level
	
	// -- Physics --
	public World as Floored.World
	public PhysicsTime = 0.0f
	public PlayerBody as Body
	
	Box as Shapes.Box
	wall as Material
	
	
	// -- Sound --
	Listener as Core.Sound.Listener
	Sound as Core.Sound.Buffer
	Source as Core.Sound.Source
	GSound as Core.Sound.Buffer
	GSource as Core.Sound.Source
	
	public override def OnLoad(e as EventArgs):
		super.OnLoad(e)
		
		// Set up a camera and a light
		Camera = Camera(Vector3(0, 3, 10), Vector3(0, 0, 0), Vector3(0, 1, 0))
		Light = Light(0)
		Light.Position = Camera.Eye.AsArray()
	
		// Set up skydome
		Skydome = Skydome(Texture.Load("../Data/Textures/Sky.jpg"))

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
		Character = skin.GetInstance()
		Character.Position = Vector3(0, 0, 0)
		Character.UpperAnimation = Character.Model.GetAnimation(Md3.AnimationId.TORSO_ATTACK)
		Character.LowerAnimation = Character.Model.GetAnimation(Md3.AnimationId.LEGS_WALK)
		Weapon = Md3.Model("../Data/Models/Weapons/machinegun/machinegun.md3")
		Character.WeaponModel = Weapon
		Character.Scale = 0.03f
		Character.LookDirection = Vector3(-1.0f, 0.0f, 0.0f)
		Character.WalkDirection = Character.LookDirection

		// Create world
		worldAABB = AABB()
		worldAABB.LowerBound.Set(-200f, -200f)
		worldAABB.UpperBound.Set(200f, 200f)
		World = Floored.World(worldAABB, Vec2(0, -25f), 0.0f)
	
		// Create NPCs
		for i in range(3):
			npc = Objects.Player(Model.Skins["red"])
			npc.Position = Vector3(i * 2.0f, 30.0f, 0.0f)
			World.Objects.Add(npc)
	
		// Create body for player
		bodyDef = BodyDef();
		bodyDef.Position.Set(Character.Position.X, Character.Position.Y + 2.0f);
		PlayerBody = World.Physics.CreateBody(bodyDef);
		
		shapeDef = PolygonDef();
		shapeDef.SetAsBox(0.5f, 1.0f, Vec2(0, 0.05f), 0f);
		shapeDef.Density = 50.0f;
		shapeDef.Friction = 0.0f;
		shapeDef.Restitution = 0.0f;
		shape = PlayerBody.CreateShape(shapeDef);
		shape.FilterData.MaskBits = ~cast(ushort, CollisionGroups.Player)
		shape.FilterData.CategoryBits = cast(ushort, CollisionGroups.Player)

		/*feetDef = PolygonDef()
		feetDef.SetAsBox(0.3f, 0.1f, Vec2(0f, -0.90f), 0f)
		feetDef.Density = 0.05f;
		feetDef.Friction= 0.0f
		feetDef.IsSensor = true
		shapeDef.Restitution = 0.0f
		PlayerBody.CreateShape(feetDef)*/
		
		
		PlayerBody.SetMassFromShapes();		
		
		// Create level
		Level = Levels.Level(World)
		
		// Sound
		Listener = Core.Sound.Sound.GetListener()
		if Sound == null:
			Sound = Core.Sound.Buffer("../Data/Sound/Weapons/silenced.wav")
			Source = Core.Sound.Source(Sound)	
			GSound = Core.Sound.Buffer("../Data/Sound/Weapons/grenlf1a.wav")
			GSource = Core.Sound.Source(GSound)	
		
	
	public override def OnRenderFrame(e as RenderFrameEventArgs):
		// Center camera
		Camera.Eye = Character.Position + Vector3(0f, 2f, 40f)
		Camera.LookAt = Character.Position + Vector3(0f, 1f, 0f)

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
		
		Light.Enable()
		
		// Render skydome
		GL.PushMatrix()
		GL.Translate(0, -250f, 0)
		GL.Translate(Camera.Eye)
		GL.Rotate(45.0, 0, 1, 0)
		Skydome.Render()
		GL.PopMatrix()
		
		// Boxes
		RenderState.Instance.ApplyProgram(null)
		RenderState.Instance.ApplyProgram(DefaultShader)
		RenderState.Instance.ApplyMaterial(wall)
		Box.Render()
		
		for o in World.Objects:
			o.Render()
		
		
		RenderState.Instance.ApplyProgram(Md3Shader)
		Character.Render()
		
		RenderState.Instance.ApplyProgram(null)
		
		// Visualize physics
		// Render AABBs
		GL.Disable(EnableCap.Texture2D)
		renderPhysics = Keyboard[OpenTK.Input.Key.F1]
		if renderPhysics:
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
				GL.Vertex3(joint.Anchor1.X, joint.Anchor1.Y, 0.0f);
				GL.Vertex3(joint.Anchor2.X, joint.Anchor2.Y, 0.0f);
				GL.Vertex3(joint.GetBody1().GetPosition().X, joint.GetBody1().GetPosition().Y, 0.0f);
				GL.Vertex3(joint.GetBody2().GetPosition().X, joint.GetBody2().GetPosition().Y, 0.0f);				
				joint = joint.GetNext()
			
			GL.End();		
			GL.PolygonMode(MaterialFace.FrontAndBack, PolygonMode.Fill);
		
			GL.Enable(EnableCap.DepthTest)
		Particles.Render()
		
		Camera.Pop()
		
		SwapBuffers()
		
	public override def OnUpdateFrame(e as UpdateFrameEventArgs):
		dt as single = e.Time
		
		PhysicsTime += dt
		StepSize = 0.015f
		while PhysicsTime >= StepSize:					
			# Is player touching the ground?
			# ???
			
			# Update character
			Character.Tick(StepSize)
			ReloadTime -= StepSize
			PrimaryReloadTime -= StepSize
			joystick = Joysticks[0]
			
			# Looking
			xlook = -joystick.Axis[2]
			ylook = -joystick.Axis[3]
			if xlook*xlook + ylook*ylook >= 0.2f:
				Character.LookDirection = Vector3(xlook, ylook, 0f)
			else:
				Character.LookDirection = Character.WalkDirection
				
			# Walking
			dir2 = PlayerBody.GetLinearVelocity();		
			PlayerBody.WakeUp()		
			x = joystick.Axis[0]
			y = joystick.Axis[1]
			if x*x + y*y >= 0.2f:
				Character.WalkDirection = Vector3(x, y, 0f)
			maxWalkVelocity = 7.0f
			onFloor = true
			if onFloor:
				if System.Math.Abs(x) > 0.2f:
					pass
				else:
					maxWalkVelocity = 0.0f
				
				maxWalkVelocity *= System.Math.Sign(x)
				impulse = PlayerBody.GetMass()*(maxWalkVelocity - dir2.X)*5.0f
				PlayerBody.ApplyForce(Vec2(impulse, 0.0f), Vec2.Zero)
			
			
			// Jumping
			maxJumpVelocity = 100f
			if joystick.Button[0]:
				impulse = PlayerBody.GetMass()*(maxJumpVelocity)
				PlayerBody.ApplyForce(Vec2(0, impulse), Vec2.Zero)
				
				
			
			Dir = Vector3(dir2.X, dir2.Y, 0.0f);
			/*if KeyStates.ContainsKey(Keys.Space):
				Dir.Y = 7.0f;*/
			walkingThreshold = 2.0f;
			runningThreshold = 4.0f;
			maxSpeed = 10.5f;
			accel = 2.0f;
			walking = Dir.Length >= walkingThreshold;
			running = Dir.Length >= runningThreshold;
		
			if PlayerBody.GetAngle() != 0f:
				PlayerBody.SetXForm(PlayerBody.GetPosition(), 0.0f)
				PlayerBody.SetAngularVelocity(0.0f)
			
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
			if joystick.Button[6] and PrimaryReloadTime <= 0f:
				PrimaryReloadTime = 0.1f				
				o as GameObject = Objects.Bullet(World)
				look = Vector3.Normalize(Character.LookDirection)
				o.Body.SetXForm((PlayerBody.GetPosition()) + (look * 0.7f).AsVec2(), 0.0f)
				o.Body.ApplyImpulse(o.Body.GetMass() * look.AsVec2() * 100.0f, Vec2.Zero)
				World.Objects.Add(o)
				
				Source.Position = Character.Position
				//Source.Direction = Character.LookDirection
				Source.Velocity = Character.LookDirection * 100.0f
				Source.Play()
	
					
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
				GSource.Play()
				
			Particles.Tick(dt)

			World.Step(StepSize)
			PhysicsTime -= StepSize
		
		# Update
		pos = PlayerBody.GetPosition()
		Character.Position = Vector3(pos.X, pos.Y - 1.0f, Character.Position.Z)		
		
		# Listener
		Listener.Position = Character.Position + Vector3(0, 0, 2.0f)
		Listener.Orientation = Vector3(0, 0, -1)
		
game = Game.Instance
game.Run()
print "Floored"

