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

abstract class State:
	virtual def Update(dt as single) as State:
		pass

	virtual def Render():
		pass

class GameState(State):
	Game as Game
	
	def constructor(game as Game):
		Game = game
		Game.webView.LoadURL("""L:\Floored\Data\UI\index.htm""")			
	
	override def Update(dt as single) as State:
		Game.TimePassed += dt
		Game.PhysicsTime += dt
		StepSize = 0.015f
		while Game.PhysicsTime >= StepSize:								
			# Update character
			Game.ReloadTime -= StepSize
			Game.PrimaryReloadTime -= StepSize
			joystick = Game.Joysticks[0]
			#Player.WalkDirection = Vector2(joystick.Axis[0], joystick.Axis[1])
			//Player.LookDirection = Vector2(-joystick.Axis[2], -joystick.Axis[3])
			//Player.DoJump = joystick.Button[0]
			
			# Walking
			/*
			
				
				
			
			Dir = Vector3(dir2.X, dir2.Y, 0.0f);
			
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
				
			Game.Particles.Tick(dt)

			Game.World.Step(StepSize)
			Game.PhysicsTime -= StepSize
		
		# Listener
		Game.Listener.Position = Game.Player.Position + Vector3(0, 0, 2.0f)
		Game.Listener.Orientation = Vector3(0, 0, -1)
		return self
		
	override def Render():		
		// Center camera
		Game.Camera.Eye = Game.Player.Position + Vector3(0f, 2f, 20f)
		Game.Camera.LookAt = Game.Player.Position + Vector3(0f, 1f, 0f)
	
		// Set up scene
		GL.ClearColor(System.Drawing.Color.SkyBlue)
		GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit | ClearBufferMask.StencilBufferBit)
		GL.Fog(FogParameter.FogColor, (1f, 1f, 1f, 1f))
		
		GL.Disable(EnableCap.Texture2D)
		GL.Enable(EnableCap.DepthTest)
		GL.Enable(EnableCap.Blend)
		GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha)
		
		GL.MatrixMode(MatrixMode.Modelview)
		GL.LoadIdentity()
		
		Game.Camera.Push()
		
		Game.Light.Position = Vector4.Normalize(Vector4(0.5f, 1.0f, -2.0f, 0f)).AsArray()
		Game.Light.Enable()
		
		// Render skydome
		GL.PushMatrix()
		GL.Translate(0, -60f, 0)
		GL.Translate(Game.Camera.Eye)
		GL.Rotate(45.0, 0, 1, 0)
		Game.Skydome.Render()
		GL.PopMatrix()
		
		// Boxes
		RenderState.Instance.ApplyProgram(null)
		RenderState.Instance.ApplyProgram(Game.DefaultShader)
		RenderState.Instance.ApplyMaterial(Game.wall)
		// Floor
		//Box.Render()
		
		for o in Game.World.Objects:
			o.Render() if o.EnableRendering
		
		RenderState.Instance.ApplyProgram(null)
		
		// Visualize physics
		// Render AABBs
		GL.Disable(EnableCap.Texture2D)
		if Game.ShowPhysics:
			GL.Disable(EnableCap.DepthTest)
			aabb as AABB
			GL.Disable(EnableCap.Texture2D);
			GL.PolygonMode(MaterialFace.FrontAndBack, PolygonMode.Line);
			GL.Begin(BeginMode.Quads);
			b = Game.World.Physics.GetBodyList()
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
			joint = Game.World.Physics.GetJointList()
			while joint != null:
				GL.Vertex3(joint.Anchor1.X, joint.Anchor1.Y, 0.0f)
				GL.Vertex3(joint.Anchor2.X, joint.Anchor2.Y, 0.0f)
				GL.Vertex3(joint.GetBody1().GetPosition().X, joint.GetBody1().GetPosition().Y, 0.0f)
				GL.Vertex3(joint.GetBody2().GetPosition().X, joint.GetBody2().GetPosition().Y, 0.0f)
				joint = joint.GetNext()
			
			GL.End()
			GL.PolygonMode(MaterialFace.FrontAndBack, PolygonMode.Fill)
		
			GL.Enable(EnableCap.DepthTest)
	
		Game.Terrain.Render()
		
		Game.Particles.Render()
		
		Game.Camera.Pop()

class Task:
	private Function as callable
	public Description as string
	
	def constructor(description as string, function as callable):
		Function = function
		Description = description
		
	def Run():
		Function()

class LoadingState(State):
	Game as Game
	Tasks = List[of Task]()
	
	def constructor(game as Game):
		Game = game
		
		// Set up skydome
		t = def():
			Game.Skydome = Skydome(Texture.Load("../Data/Textures/Sky.jpg"), 150f)
		Tasks.Add(Task("Loading skydome", t))
	
		// Load shaders
		t = def():
			Program = ShaderProgram()
			VertexShader = Shader(ShaderType.VertexShader, "../Data/Shaders/bump.vert")
			FragmentShader = Shader(ShaderType.FragmentShader, "../Data/Shaders/bump.frag")
			Program.Attach(VertexShader)
			Program.Attach(FragmentShader)
			Program.Link()
			Game.DefaultShader = Program

			Program = ShaderProgram()
			VertexShader = Shader(ShaderType.VertexShader, "../Data/Shaders/md3_vertex.glsl")
			FragmentShader = Shader(ShaderType.FragmentShader, "../Data/Shaders/md3_fragment.glsl")
			Program.Attach(VertexShader)
			Program.Attach(FragmentShader)
			Program.Link()
			Game.Md3Shader = Program
		Tasks.Add(Task("Loading shaders", t))
		
		// Particles
		t = def():
			Game.Particles = ParticleEngine(Texture.Load("../Data/Textures/Particles/particle.tga"))
		Tasks.Add(Task("Loading particles", t))

		// Create materials
		t = def():
			Game.wall = Material("Wall");
			Game.wall.DiffuseTexture = Texture.Load("../Data/Textures/wall.dds")
			Game.wall.NormalTexture = Texture.Load("../Data/Textures/wall_n.dds")
			Game.Box = Shapes.Box(Vector3(6f, 0.01f, 6f))
		Tasks.Add(Task("Loading materials", t))
		
		// Load a character with weapon
		t = def():
			Model = Md3.CharacterModel("../Data/Models/Players/police/")
			Game.Skin = Model.Skins["default"]
		Tasks.Add(Task("Loading player model", t))			
		
		// Create world
		t = def():
			worldAABB = AABB()
			worldAABB.LowerBound.Set(-200f, -200f)
			worldAABB.UpperBound.Set(200f, 200f)
			Game.World = Floored.World(worldAABB, Vec2(0, -25f), 0.0f)
		Tasks.Add(Task("Creating world", t))			
		
		// Create player
		t = def():
			Game.Player = Objects.Player(Game.Skin)
			Game.Player.Weapon = Objects.Weapons.MachineGun()
			Game.World.Objects.Add(Game.Player)		
		Tasks.Add(Task("Creating player", t))		
		
		t = def():
			// Create NPCs
			npcModel = Md3.CharacterModel("../Data/Models/Players/sergei/")
			//skin = Model.Skins["default"]
			for i in range(3):
				skin = npcModel.Skins["default"]
				npc = Objects.Player(skin)
				npc.Position = Vector3(i * 2.0f, 30.0f, 0.0f)
				Game.World.Objects.Add(npc)
		Tasks.Add(Task("Loading npc model", t))

		t = def():
			// Create level
			Game.Level = Levels.Level(Game.World)
			
			// Sound
			Game.Listener = Core.Sound.Sound.GetListener()
			if Game.Sound == null:
				Game.Sound = Core.Sound.Buffer("../Data/Sound/Weapons/silenced.wav")
				Game.Source = Core.Sound.Source(Game.Sound)	
				Game.GSound = Core.Sound.Buffer("../Data/Sound/Weapons/grenlf1a.wav")
				Game.GSource = Core.Sound.Source(Game.GSound)	
			
			// Terrain
			Game.Terrain = Core.Graphics.Terrain({ file as string | Texture.Load(file) })
		Tasks.Add(Task("Loading Level, Terrain, Sounds", t))	
		
	
	override def Update(dt as single) as State:
		if Tasks.Count == 0:
			return self
		task = Tasks[0]
		Tasks.RemoveAt(0)
		before = DateTime.Now
		task.Run()
		passed = DateTime.Now - before
		passedStr = passed.Ticks / 10000000.0f
		description = task.Description + " (${passedStr}s)"
		description = description.Replace("\"", "\\\"")
		Game.webView.ExecuteJavaScript("finishedTask(\"${description}\")")
		return self

	override def Render():
		pass