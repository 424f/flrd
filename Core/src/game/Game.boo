namespace Game

import System
import Tao.OpenGl.Gl
import Core.Input
import Core.Common
import Core.Graphics
import OpenTK.Math
import Core.Gui

import Game.Objects

class Game(Application):
"""Description of Application"""

	_skybox as Skybox
	_font as Font
	_Model as Md3.CharacterModel
	_skin as Md3.CharacterSkin
	
	_floorTexture as Texture
	
	_player as Character
	_enemies as (Md3.CharacterInstance)
	_enemyController as HunterController
	_reflection as PlaneReflection

	_fpsLabel as Label
	
	_controller as Controller
	
	_enemyControllers = Collections.Generic.List[of HunterController]()
	
	[Getter(InverseModelMatrix)] _inverseModelMatrix as  OpenTK.Math.Matrix4
	
	[Getter(DeathSounds)] _deathSounds = array(Core.Sound.Buffer, 3)
	[Getter(Instance)] static _instance as Game
	[Getter(Objects)] _objects = Collections.Generic.List[of GameObject]()
	[Getter(Random)] _random = Random(System.DateTime.Now.Millisecond)
	
	[Property(WeaponLabel)] _weaponLabel as Label
	
	_muzzleTexture as Texture
	_crosshairTexture as Texture
	_crosshair as Image
	_arrow as IRenderable
	
	[Getter(Particles)] _particles as ParticleEngine
	
	# shadow
	shadowMapTexture as int
	shadowMapSize = 512
	# /shadow

	def constructor():
		super()

	def Init():
		super()
		
		Tao.Sdl.Sdl.SDL_ShowCursor(0)
		
		_instance = self
		

		_floorTexture = Texture.Load("data/textures/fallout/landscape/dirtwasteland01.dds")

		npc = Character()
		npcModel = Md3.CharacterModel("data/models/player/ryla/")
		npc.Skin = npcModel.Skins["default"]
		npc.Position = Vector3(100, 0, 0)
		npc.Faction = Faction.Instance("Player")
		npc.SetController(HunterController(npc, null))
		Objects.Add(npc)
		
		/*if System.Environment.GetCommandLineArgs().Length > 1:
			skin = Environment.GetCommandLineArgs()[1]
		else:
			skin = prompt("Model: ")*/
		skin = "ironside"
		_model = Md3.CharacterModel("data/models/player/${skin}/")

		_player = Character()
		_player.Health = 100000
		_player.Skin = _Model.Skins["default"] as Md3.CharacterSkin
		_player.Faction = Faction.Instance("Player")
		Objects.Add(_player)
		
		i = 0
		radius = 100.0f
		
		instantiateEnemyFunc = def(skin):
			result = Character()
			result.Skin = _model.Skins[skin]
			i++
			x = Math.Cos(i)*radius
			z = Math.Sin(i)*radius
			result.Position = Vector3(x, 0, z)
			result.Faction = Faction.Instance("Enemies")
			return result
		enemies = array(Character, map(_Model.Skins.Keys, instantiateEnemyFunc))
		_objects.AddRange(enemies)
		
		# Make enemies aggressive
		Faction.Instance("Enemies").SetRelation(_player.Faction, Relation.Hostile)
		
		r = Random(System.DateTime.Now.Millisecond)
		for enemy as Character in enemies:
			enemyController = HunterController(enemy, _objects[r.Next() % _objects.Count])
			_enemyControllers.Add(enemyController)
			enemy.SetController(enemyController)	
			
		fileNamesFunc = def (i): return "data/textures/skybox/basic_${i}.jpg"
		_skybox = Skybox(array(string, map(range(6), fileNamesFunc)))


		# Add images with the character icons
		box = Decorator.BackgroundColor(Layout.BoxLayout(Core.Math.Rect(10, 10, 200, 780), 10, 10), Vector4(0.0f, 0.0f, 0.0f, 0.3f))
		box = Decorator.BackgroundColor(Layout.BoxLayout(Core.Math.Rect(10, 10, 200, 780), 0, 10), Vector4(0.0f, 0.0f, 0.0f, 0.3f))
		box.AddChild(Gui.PlayerImage(_player, Core.Math.Rect(0, 0, 64, 64)))
		box.AddChild(Label(_player.Name, _serifFont, Core.Math.Rect(20, 20, 20, 20)))
		for enemy in enemies:
			box.AddChild(Gui.PlayerImage(enemy, Core.Math.Rect(0, 0, 64, 64)))
			box.AddChild(Label(enemy.Skin.Name, _serifFont, Core.Math.Rect(20, 20, 20, 20)))
		_screen.AddChild(box)
	
		_reflection = PlaneReflection()
		_Camera = Camera(Vector3(0, 300, 150), Vector3(0, 0, 0), Vector3(0, 1, 0))	
		Core.Input.Input.Mouse.Camera = _Camera # hack
		
		# Add an FPS label
		_fpsLabel = Label("Welcome!", _fpsFont, Core.Math.Rect(10, 728, 20, 20))
		_screen.AddChild(_fpsLabel)
		
		# GUI test stuff
		_weaponLabel = Label("", Font.Create("data/fonts/DejaVuSansBold.ttf", 12), Core.Math.Rect(400, 400, 400, 200))
		_weaponLabel.Color = Vector4(1.0f, 1.0f, 1.0f, 0.8f)
		_screen.AddChild(_weaponLabel)
		
		# Add an input box
		#textField = TextField("Console: ", _monoFont, Rect(200, 10, 600, 200))
		#_screen.AddChild(textField)
		
		for i in range(0, 3):
			_deathSounds[i] = Core.Sound.Buffer("data/sound/player/sergei/death${i+1}.Wav")
			
		# Set up a controller
		_controller = Controller()
		if Input.Joysticks.Length > 0 and false:
			joystick = Input.Joysticks[0]
			_controller.Bind(joystick.Axes[0], "l_x")
			_controller.Bind(joystick.Axes[1], "l_y")
			_controller.Bind(AmplifiedValue("", joystick.Axes[2], 13), "r_x")
			_controller.Bind(AmplifiedValue("", joystick.Axes[3], 13), "r_y")
			_controller.Bind(joystick.Buttons[5], "fire")
			_controller.Bind(joystick.Buttons[6], "punch")
			_controller.Bind(joystick.Buttons[4], "reload")
		else:
			m = Input.Mouse
			kb = Input.Keyboard
			_controller.Bind(AmplifiedValue("", m.XRel, 5), "r_x")
			_controller.Bind(AmplifiedValue("", m.YRel, 5), "r_y")
			_controller.Bind(CompositeValue("", kb.Values[Tao.Sdl.Sdl.SDLK_a], kb.Values[Tao.Sdl.Sdl.SDLK_d]), "l_x")
			_controller.Bind(CompositeValue("", kb.Values[Tao.Sdl.Sdl.SDLK_w], kb.Values[Tao.Sdl.Sdl.SDLK_s]), "l_y")
			_controller.Bind(m.LeftButton, "fire")
			_controller.Bind(m.RightButton, "punch")
			_controller.Bind(kb.Values[Tao.Sdl.Sdl.SDLK_r], "reload")
		
		_player.SetController(_controller)
		
		_muzzleTexture = Texture.Load("data/textures/particle/muzzle.tga")
		_crosshairTexture = Texture.Load("data/textures/crosshair.png")
		
		
		# Particles
		_particles = ParticleEngine(null)
		self._objects.Add(Decoration(_particles))
		
		# shadow
		//Create the shadow map texture
		glGenTextures(1, shadowMapTexture);
		glBindTexture(GL_TEXTURE_2D, shadowMapTexture);
		glTexImage2D(	GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, shadowMapSize, shadowMapSize, 0,
						GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE, null);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);		
		# /shadow
		
	private def RenderFloor():
		_floorTexture.Bind()
		y as single = -25
		dim as single = 500
		glBegin(GL_QUADS)
		glTexCoord2f(0, 0); glVertex3f(-dim, y, dim)
		glTexCoord2f(7, 0); glVertex3f(dim, y, dim)
		glTexCoord2f(7, 7); glVertex3f(dim, y, -dim)
		glTexCoord2f(0, 7); glVertex3f(-dim, y, -dim)
		glEnd()		
		
	private def RenderObjects():
		glEnable(GL_TEXTURE_2D)
		glEnable(GL_LIGHTING)
		for obj as GameObject in _objects:
			obj.Render()
		
		_skybox.Render()
		
		
	def Tick():
		# Close the application when escape is pressed
		v as Core.Input.AbstractValue = Input.Keyboard.Values[Tao.Sdl.Sdl.SDLK_ESCAPE]
		if v.Fired:
			_running = false
			return
		
		for enemyController in _enemyControllers:
			enemyController.Tick()
		
		# Tick on objects
		for i in range(_objects.Count):
			if i >= _objects.Count: # TODO: proper fix
				break
			obj = _objects[i] as GameObject
			obj.Tick()
		
		# Make the Camera follow the player
		#Camera.LookAt = _player.Position + Vector3(0, 30, 0) + _player.LookDirection * 15.0
		#Camera.eye = _player.Position + Vector3(0, 30, 0) + _player.LookDirection * 10.0
		
		Camera.LookAt = _player.Position +  _player.LookDirection * 15.0
		Camera.Eye = _player.Position - 200*_player.LookDirection + Vector3(0, 370, 0)		
		
		# Same for the listener
		_listener.Position = _player.Position
		_listener.Orientation = _player.LookDirection
		_skybox.Position = _player.Position
	
		# From time to time, create a new enemy
		if _random.NextDouble() > 0.999:
			result = Character()
			result.Skin = _Model.Skins["default"]
			result.Position = Vector3(100, 0, 100)
			result.Faction = Faction.Instance("Enemies")
			result.SetController(HunterController(result, _player))
			_objects.Add(result)
	
		# Update the fps counter
		if _counter.Updated:
			_fpsLabel.label = "${_counter.FramesPerSecond} FPS"
			print _fpsLabel.label
			print _player.Position
		_fpsLabel.label = "${self._player.Health}"
	
	def Render():
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
		
		_light.Enable()
		/*
		# shadow
		glMatrixMode(GL_PROJECTION)
		glPushMatrix()
		glLoadIdentity();
		gluPerspective(45.0f, 1.0f, 2.0f, 8.0f);
		m = array(single, 16)
		glGetFloatv(GL_MODELVIEW_MATRIX, m);
		lightProjectionMatrix = OpenTK.Math.Matrix4(
			OpenTK.Math.Vector4(m[0], m[1], m[2], m[3]),
			OpenTK.Math.Vector4(m[4], m[5], m[6], m[7]),
			OpenTK.Math.Vector4(m[8], m[9], m[10], m[11]),
			OpenTK.Math.Vector4(m[12], m[13], m[14], m[15]))	
		
		glMatrixMode(GL_MODELVIEW)
		glPushMatrix()
		glLoadIdentity();
		gluLookAt(	_light.Position[0], _light.Position[1], _light.Position[2],
					0.0f, 0.0f, 0.0f, #_player.Position.X, _player.Position.Y, _player.Position.Z,
					0.0f, 1.0f, 0.0f);
		glGetFloatv(GL_MODELVIEW_MATRIX, m);
		lightViewMatrix = OpenTK.Math.Matrix4(
			OpenTK.Math.Vector4(m[0], m[1], m[2], m[3]),
			OpenTK.Math.Vector4(m[4], m[5], m[6], m[7]),
			OpenTK.Math.Vector4(m[8], m[9], m[10], m[11]),
			OpenTK.Math.Vector4(m[12], m[13], m[14], m[15]))	
		
		
		//First pass - from light's point of view
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
		//Use viewport the same size as the shadow map
		glViewport(0, 0, shadowMapSize, shadowMapSize);
	
		//Draw back faces into the shadow map
		//glCullFace(GL_FRONT);
	
		//Disable color writes, and use flat shading for speed
		//glShadeModel(GL_FLAT);
		#glColorMask(false, false, false, false)
		
		//Draw the scene
		glEnable(GL_LIGHTING)
		_reflection.Render(renderObjects, renderFloor)
		renderObjects()
		
		//Read the depth buffer into the shadow map texture
		glBindTexture(GL_TEXTURE_2D, shadowMapTexture);
		glCopyTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, 0, 0, shadowMapSize, shadowMapSize);
	
		//restore states
		glCullFace(GL_BACK);
		glShadeModel(GL_SMOOTH);
		glColorMask(true, true, true, true)

		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glMatrixMode(GL_PROJECTION)
		glPopMatrix()
		#glGetFloatv(GL_MODELVIEW_MATRIX, lightProjectionMatrix);
		
		glMatrixMode(GL_MODELVIEW)
		glPopMatrix()		
		
		_muzzleTexture.id = shadowMapTexture
		Begin2d()
		_muzzleTexture.Render(Math.Rect(0, 0, 512, 512))
		End2d()
		
		// ----------------------
		a = """
		//2nd pass - Draw from Camera's point of view
		glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT); // todo: remove color buffer
		glViewport(0, 0, _screen.Position.Width, _screen.Position.Height)
	
		//Use dim light to represent shadowed areas
		_light.disable()
		
		# Render scene
		glEnable(GL_LIGHTING);
		_reflection.Render(renderObjects, renderFloor)
		renderObjects()
	
		_light.Enable()
	
		//3rd pass
		//Draw with bright light
	/*	white = (1.0f, 1.0f, 1.0f, 1.0f)
		glLightfv(GL_LIGHT0, GL_DIFFUSE, white);
		glLightfv(GL_LIGHT0, GL_SPECULAR, white);
	
		//Calculate texture matrix for projection
		//This matrix takes us from eye space to the light's clip space
		//It is postmultiplied by the inverse of the current view matrix when specifying texgen
		biasMatrix=Matrix4(Vector4(0.5f, 0.0f, 0.0f, 0.0f),
						   Vector4(0.0f, 0.5f, 0.0f, 0.0f),
						   Vector4(0.0f, 0.0f, 0.5f, 0.0f),
						   Vector4(0.5f, 0.5f, 0.5f, 1.0f));	//bias from [-1, 1] to [0, 1]
		textureMatrix=biasMatrix*lightProjectionMatrix*lightViewMatrix;
	
		def VectorToArray(v as Vector4):
			return (v.X, v.Y, v.Z, v.W)
	
		//Set up texture coordinate generation.
		glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
		glTexGenfv(GL_S, GL_EYE_PLANE, vectorToArray(textureMatrix.Row0));
		glEnable(GL_TEXTURE_GEN_S);
	
		glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
		glTexGenfv(GL_T, GL_EYE_PLANE, vectorToArray(textureMatrix.Row1));
		glEnable(GL_TEXTURE_GEN_T);
	
		glTexGeni(GL_R, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
		glTexGenfv(GL_R, GL_EYE_PLANE, vectorToArray(textureMatrix.Row2));
		glEnable(GL_TEXTURE_GEN_R);
	
		glTexGeni(GL_Q, GL_TEXTURE_GEN_MODE, GL_EYE_LINEAR);
		glTexGenfv(GL_Q, GL_EYE_PLANE, vectorToArray(textureMatrix.Row3));
		glEnable(GL_TEXTURE_GEN_Q);
	
		//Bind & Enable shadow map texture
		glBindTexture(GL_TEXTURE_2D, shadowMapTexture);
		glEnable(GL_TEXTURE_2D);
	
		//Enable shadow comparison
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE_ARB, GL_COMPARE_R_TO_TEXTURE);
	
		//Shadow comparison should be true (ie not in shadow) if r<=texture
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC_ARB, GL_LEQUAL);
	
		//Shadow comparison should generate an INTENSITY result
		glTexParameteri(GL_TEXTURE_2D, GL_DEPTH_TEXTURE_MODE_ARB, GL_INTENSITY);
	
		//Set alpha test to discard false comparisons
		glAlphaFunc(GL_GEQUAL, 0.99f);
		glEnable(GL_ALPHA_TEST);
	
		#_reflection.Render(renderObjects, renderFloor)
		renderObjects()
	
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
		//Restore other states
		glDisable(GL_LIGHTING);
		glDisable(GL_ALPHA_TEST);	
		glDisable(GL_TEXTURE_GEN_S);
		glDisable(GL_TEXTURE_GEN_T);
		glDisable(GL_TEXTURE_GEN_R);
		glDisable(GL_TEXTURE_GEN_Q);		*/
	"""
		*/
		
		_reflection.Render(RenderObjects, RenderFloor)
		RenderObjects()
		
		# Crosshair update
		model = array(double, 16)
		glGetDoublev(GL_MODELVIEW_MATRIX, model)
		proj = array(double, 16)
		glGetDoublev(GL_PROJECTION_MATRIX, proj)
		view = (0, 0, 1024, 768)
		glGetIntegerv(GL_VIEWPORT, view)
		
		winX as double
		winY as double
		winZ as double
		
		# Calculate model matrix inverse		
		/*m = array(single, 16)
		glGetFloatv(GL_MODELVIEW_MATRIX, m)
		_inverseModelMatrix = OpenTK.Math.Matrix4(
			OpenTK.Math.Vector4(m[0], m[1], m[2], m[3]),
			OpenTK.Math.Vector4(m[4], m[5], m[6], m[7]),
			OpenTK.Math.Vector4(m[8], m[9], m[10], m[11]),
			OpenTK.Math.Vector4(m[12], m[13], m[14], m[15]))	
		_inverseModelMatrix.Invert()
		*/	
		
		glTranslatef(100.0, 30.0, 100.0)
	
		Begin2d()
		glEnable(GL_BLEND)
		glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR)
		v = Vector3(_player.Position.X, _player.Position.Y, _player.Position.Z)
		_player.Instance.LookDirection.Normalize()
		v = v + _player.Instance.LookDirection * 50.0f
		Tao.OpenGl.Glu.gluProject(v.X, v.Y+70.0f, v.Z, model, proj, view, winX, winY, winZ)	
		_crosshairTexture.Render(Core.Math.Rect(winX-20, 768-(winY-20), 41, 42))
		End2d()	
	
		/*
		Begin2d()
		glEnable(GL_BLEND)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE)
		_muzzleTexture.Render(Rect(0, 512*(5-(System.DateTime.Now.Millisecond / 100) % 6), 512, 512), Rect(100, 100, 512, 512))
		_muzzleTexture.Render(Rect(0, 512*(5-(System.DateTime.Now.Millisecond / 100) % 6), 512, 512), Rect(125, 125, 512, 512))
		End2d()
		*/
		
	def RayIntersect(origin as Vector3, direction as Vector3, exlude as List, filter as callable) as GameObject:
		leastDistance = System.Single.MaxValue
		result = null
		
		for obj as GameObject in _objects:
			if obj not in exlude and filter(obj):
				a, b, c  = origin.X, origin.Y, origin.Z
				d, e, f = direction.X, direction.Y, direction.Z
				
				sphere = obj.BoundingSphere
				x0, y0, z0 = sphere.Center.X, sphere.Center.Y, sphere.Center.Z

				c_ = a*a - 2*a*x0 +x0*x0 + b*b - 2*b*y0 +y0*y0 + c*c - 2*c*z0 +z0*z0 - sphere.Radius*sphere.Radius
				b_ = 2.0*(a*d + b*e + c*f - d*x0 - e*y0 - f*z0)
				a_ = d*d + e*e + f*f

				D = b_*b_ - 4*a_*c_
				if D < 0.0:
					continue
				
				x1 = (-b_ + Math.Sqrt(b_*b_ - 4.0*a_*c_)) / (2.0*a_)
				x2 = (-b_ - Math.Sqrt(b_*b_ - 4.0*a_*c_)) / (2.0*a_)
				
				if x1 < 0.0f:
					x1 = x2
				if x1 < 0.0f:
					continue
				
				if x1 < leastDistance:
					result = obj
					leastDistance = x1
					
		return result
