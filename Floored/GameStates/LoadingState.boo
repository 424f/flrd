namespace Floored

import System
import OpenTK
import OpenTK.Graphics.OpenGL

import Core.Graphics

import Box2DX.Collision
import Box2DX.Common

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
			return GameState(Game)
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