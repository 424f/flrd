namespace BooLandscape

import System
import System.Math
import System.Drawing
import System.Drawing.Imaging
import System.Collections.Generic
import OpenTK
import OpenTK.Math
import OpenTK.Graphics
import OpenTK.Platform
import OpenTK.Input

import Tao.OpenGl.Gl
import Tao.OpenGl.Glu
import Tao.DevIl

import Core.Graphics

class Camera:
	public Position as Vector3
	public LookDirection as Vector3
	public UpDirection as Vector3 = Vector3.UnitY
	public Angle as double = 0.0

	public def constructor():
		LookDirection = DirectionForAngle(Angle)
		//Position = Vector3(0, 300, 390)
		Position = Vector3(100, 150, 0)

	public def Apply():
		Glu.LookAt(Position, Position + LookDirection, UpDirection)
		//Glu.LookAt(390*Vector3.UnitZ + 100*Vector3.UnitY + 0*Vector3.UnitX, 200*Vector3.UnitZ + 70*Vector3.UnitY, Vector3.UnitY)		
	
	public def DirectionForAngle(angle as double):
		return Vector3.Normalize(Vector3(Cos(angle), -0.1, Sin(angle)))
	
	public def Move(v as Vector3):
		Position += v
		
	public def Turn(a as double):
		Angle += a
		LookDirection = DirectionForAngle(Angle)

class Vertex:
	public v as Vector3
	public c as Vector4
	public normal as Vector3

class TextureManager:
	textures = List[of int]()
	
	public def Load(path as string) as int:
		texture = 0
		
		bitmap = Bitmap(path)
		
		GL.Hint(HintTarget.PerspectiveCorrectionHint, HintMode.Nicest);
		
		GL.GenTextures(1, texture)
		GL.BindTexture(TextureTarget.Texture2D, texture)
		data = bitmap.LockBits(Rectangle(0, 0, bitmap.Width, bitmap.Height), \
		       ImageLockMode.ReadOnly, System.Drawing.Imaging.PixelFormat.Format32bppArgb)
		/*GL.TexImage2D(TextureTarget.Texture2D, 0, PixelInternalFormat.Rgba, data.Width, data.Height, 0, OpenTK.Graphics.PixelFormat.Bgra, \
			PixelType.UnsignedByte, data.Scan0)*/
		OpenTK.Graphics.Glu.Build2DMipmap(TextureTarget.Texture2D, cast(int, PixelInternalFormat.Rgba), data.Width, data.Height, OpenTK.Graphics.PixelFormat.Bgra, PixelType.UnsignedByte, data.Scan0)
		
		//No appropriate version of 'OpenTK.Graphics.Glu.Build2DMipmap' for the argument list '(OpenTK.Graphics.TextureTarget, int, OpenTK.Graphics.PixelInternalFormat, int, int, int, OpenTK.Graphics.PixelFormat, OpenTK.Graphics.PixelType, System.IntPtr)
		bitmap.UnlockBits(data)
		
		GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMinFilter, cast(int, TextureMinFilter.LinearMipmapLinear));
		GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMagFilter, cast(int, TextureMagFilter.Linear));			
		
		textures.Add(texture)
		return texture
		

	public def Dispose():
		for texture in textures:
			GL.DeleteTexture(texture)
class Game(OpenTK.GameWindow):
	printer as TextPrinter

	sans_serif as System.Drawing.Font = System.Drawing.Font(FontFamily.GenericSansSerif, 15.0f);

	MouseDown = false
	texTree as int	
	texSky as int
	texWater as int
	texBillboard as int
	texQuestion as int
	texCross as int
	md3program as ShaderProgram
	terrain as Terrain
	public CameraDistance = 1.0
	
	textureManager = TextureManager()
	TakeScreenshot = false
	light as Light
	TimePassed = 0.0
	
	characters = List[of Core.Graphics.Md3.CharacterInstance]()
	weapon as Core.Graphics.Md3.Model
	npc as Core.Graphics.Md3.CharacterInstance
	

	camera = Camera()
	
	public Frames = 0
	
	static public def NumberToOrdinal(i as int):
		if i < 1:
			raise "Ordinals only defined for positive numbers."
		digit = i % 10
		dec = i % 100
		if digit == 1 and dec != 11:
			return "${i}st"
		elif digit == 2 and dec != 12:
			return "${i}nd"
		elif digit == 3 and dec != 13:
			return "${i}rd"
		return "${i}th"
		
	public def constructor():
		super(1280, 720, OpenTK.Graphics.GraphicsMode(ColorFormat(32), 32, 32), "FLOORED")
		VSync = VSyncMode.Off	

	Destinations = Dictionary[of object, Vector3]()
	public LookY = 0.0
	public MouseAccel = 1.0
	Center = Point(300, 300)
	public override def OnUpdateFrame(e as UpdateFrameEventArgs) as void:
		if Keyboard[Key.Escape]:
			Exit()
		
		TimePassed += RenderTime
		/*if Keyboard[Key.W]:
			camera.Move(camera.LookDirection*500*RenderTime)
		if Keyboard[Key.S]:
			camera.Move(-camera.LookDirection*500*RenderTime)
		perp = Vector3.Cross(camera.LookDirection, camera.UpDirection)
		if Keyboard[Key.A]:
			camera.Move(-perp*500*RenderTime)
		if Keyboard[Key.D]:
			camera.Move(perp*500*RenderTime)
		if Keyboard[Key.Q]:
			camera.Turn(-4*RenderTime)
		if Keyboard[Key.E]:
			camera.Turn(4*RenderTime)		*/
		
		
		
		if Keyboard[Key.P]:
			TakeScreenshot = true
		if Keyboard[Key.R]:
			terrain.program.Reload()
			md3program.Reload()

		character = characters[0]			
		m as OpenTK.Input.MouseDevice = Mouse
		
		
		dx, dY = Mouse.XDelta, Mouse.YDelta
		//dx -= Joysticks[0].Axis[2] * 2.0
		//dY += Joysticks[0].Axis[3] * 2.0
		
		mouseDist = Sqrt(dx*dx + dY*dY)
		//pos = System.Windows.Forms.Cursor.Position
		//dx, dY = pos.X - Center.X, pos.Y - Center.Y
		//System.Windows.Forms.Cursor.Position = Center
		
		
		if Abs(dx) >= 1 and Abs(dx) <= 100:
			print "MOVED! ${dx} ${dY} ${character.LookAngle}"
			character.LookAngle += RenderTime * 360.0 / 5.0 * dx * MouseAccel / 4.0
			print "--> ${character.LookAngle}"
		
		if Abs(dY) >= 1 and Abs(dY) <= 100:
			LookY -= dY / 50.0 * MouseAccel / 4.0
			
		/*if mouseDist > 0.0:
			print MouseAccel
			if MouseAccel < 5.0:
				MouseAccel *= 1.8
			else:
				MouseAccel = 5.0
		else:
			MouseAccel = 1.0*/
		
		perp = Vector3.Cross(character.LookDirection, Vector3(0, 1, 0))
		walkDir = Vector3(0, 0, 0)
		walk = false
		if Keyboard[Key.A]: // or Joysticks[0].Axis[0] < -0.5:
			walkDir -= perp
			walk = true
		if Keyboard[Key.D]: // or Joysticks[0].Axis[0] > 0.5:
			walkDir += perp
			walk = true
		if Keyboard[Key.W]: //or Joysticks[0].Axis[1] > 0.5:
			walkDir += character.LookDirection
			walk = true
		if Keyboard[Key.S]: // or Joysticks[0].Axis[1] < -0.5:
			walkDir -= character.LookDirection
			walk = true
		
		if MouseDown:
			character.UpperAnimation = character.Model.GetAnimation(Core.Graphics.Md3.AnimationId.TORSO_ATTACK)
		
		// Fade to walk direction
		if walk:
			diff = walkDir - character.WalkDirection
			character.WalkDirection += diff / diff.Length * 5.0 * RenderTime			
			character.Position += Vector3.Normalize(character.WalkDirection)*RenderTime*250.0
			
		if Keyboard[Key.Space] and not Jumping:
			Velocity = 300.0
			
		if Abs(Velocity) <= 50.0:
			if Keyboard[Key.W] or Keyboard[Key.A] or Keyboard[Key.D]:
				ani = character.Model.GetAnimation(Core.Graphics.Md3.AnimationId.LEGS_RUN)
				if character.LowerAnimation != ani:
					character.LowerAnimation = ani
					print "RUN!"
				Walking = true
			elif Keyboard[Key.S]:
				backAni = character.Model.GetAnimation(Core.Graphics.Md3.AnimationId.LEGS_BACK)
				if character.LowerAnimation != backAni:
					character.LowerAnimation = backAni
					print "BACK!"
				Walking = true					
			else:
				if Walking or Jumping:
					ani = character.Model.GetAnimation(Core.Graphics.Md3.AnimationId.LEGS_IDLE)		
					if character.LowerAnimation != ani:
						character.LowerAnimation = ani		
						print "IDLE!"
					Walking = false
			Jumping = false
		else:
			if not Jumping:
				Jumping = true
				ani = character.Model.GetAnimation(Core.Graphics.Md3.AnimationId.LEGS_JUMP)		
				if character.LowerAnimation != ani:
					character.LowerAnimation = ani
					print "JUMP!"
			
				
		//character.LookDirection = character.WalkDirection
		wheelDelta = Mouse.WheelDelta
		if wheelDelta != 0.0:
			mult = Pow(0.5, wheelDelta)
			CameraDistance *= mult
		
		modified = CameraDistance
		if Keyboard[Key.Y]:
			modified *= -1.0
		lookDir = Vector3(character.LookDirection)
		lookDir = Vector3(Vector3.Transform(lookDir, Matrix4.Rotate(perp, LookY)))
		lookDir.Normalize()
		
		
		
		
		camera.Position = character.Position - modified*lookDir*130.0 + Vector3(0, 30.0, 0) + perp*10.0
		camera.LookDirection = lookDir
		
		//camera.Position = character.Position - modified*character.LookDirection * 100.0 + Abs(modified)*Vector3(0, 80.0, 0)
		//camera.LookDirection = modified*character.LookDirection + Vector3(0, LookY, 0)

		// Process character
		i = 0
		r = Random()
		for character in characters:
			if i == 0:
				try:
					p = terrain.PositionToIndex(character.Position)
					i, j = p.X, p.Y
					ground = terrain.heightMap[i, j].v.Y + 20.0
					character.Position.Y += Velocity*RenderTime
					g = -600.0
					Velocity += g*RenderTime
					character.Position.Y += 0.5*g*RenderTime*RenderTime;
					
					if character.Position.Y < ground:
						character.Position.Y = ground
						Velocity = 0.0
	
				except:
					character.Position.Z = 0.0				
			// Follow stuff
			else:
				if not Destinations.ContainsKey(character):
					i, j = r.Next(63), r.Next(63)
					destination = terrain.heightMap[i, j].v
					Destinations.Add(character, destination)
				walkAni = character.Model.GetAnimation(Core.Graphics.Md3.AnimationId.LEGS_CROUCH)
				idleAni = character.Model.GetAnimation(Core.Graphics.Md3.AnimationId.LEGS_IDLE_CR)
				dist = Destinations[character] - character.Position
				if dist.Length <= 50:
					Destinations.Remove(character)
				character.LookDirection = Vector3.Normalize(dist)
				if dist.Length > 50.0 and (character.LowerAnimation == walkAni or r.NextDouble() > 0.8):
					if character.LowerAnimation != walkAni:
						character.LowerAnimation = walkAni
					character.WalkDirection = character.LookDirection 
					character.Position += Vector3.Normalize(dist)*RenderTime*100.0
				else:
					if character.LowerAnimation != idleAni:
						character.LowerAnimation = idleAni
				
				try:
					p = terrain.PositionToIndex(character.Position)
					i, j = p.X, p.Y
					ground = terrain.heightMap[i, j].v.Y + 20.0
					character.Position.Y = ground
	
				except:
					character.Position.Z = 0.0
			character.Tick(self.RenderTime)		
			i += 1
			
	public Velocity = 0.0
	public Jumping = false
	
	public def SkydomeTex(v as Vector3):
		v.Normalize()
		result = Vector2(1-(Atan2(v.X, v.Z) / PI * 0.5) - 0.5, \
		                 1-Asin(v.Y) / PI * 2.0)
		return result
	
	skyList = -1
	public def DrawSkydome():
		n = 10
		phi = -PI * 0.5
		dphi = PI / n * 0.5
		dtheta = 2 * PI / n
		radius = 1600.0
		GL.Enable(EnableCap.Texture2D)
		
		if skyList == -1:	
			skyList = glGenLists(1)
			glNewList(skyList, GL_COMPILE)
			GL.BindTexture(TextureTarget.Texture2D, texSky)		
			GL.Begin(BeginMode.Triangles)
			for i in range(n):
				theta = 0.0
				for j in range(n):
					v1 = Vector3(radius * Sin(phi) * Cos(theta), \
					            radius * Cos(phi), \
					            radius * Sin(phi) * Sin(theta))
					v2 = Vector3(radius * Sin(phi+dphi) * Cos(theta), \
					            radius * Cos(phi+dphi), \
					            radius * Sin(phi+dphi) * Sin(theta))
					v3 = Vector3(radius * Sin(phi) * Cos(theta+dtheta), \
					            radius * Cos(phi), \
					            radius * Sin(phi) * Sin(theta+dtheta))
					v4 = Vector3(radius * Sin(phi+dphi) * Cos(theta+dtheta), \
					            radius * Cos(phi+dphi), \
					            radius * Sin(phi+dphi) * Sin(theta+dtheta))		
					t1 = SkydomeTex(v1)
					t2 = SkydomeTex(v2)
					t3 = SkydomeTex(v3)
					t4 = SkydomeTex(v4)
					
					if t1.X > t3.X:
						t3.X += 1.0
					if t2.X > t4.X:
						t4.X += 1.0
					
					//print "${j} ${SkydomeTex(v1, false)} ${SkydomeTex(v3, false)}"
					GL.Color4(Color.White)
					GL.TexCoord2(t1)
					GL.Vertex3(v1)
					GL.TexCoord2(t2)
					GL.Vertex3(v2)
					GL.TexCoord2(t3)
					GL.Vertex3(v3)
					
					GL.TexCoord2(t4)
					GL.Vertex3(v4)
					GL.TexCoord2(t3)
					GL.Vertex3(v3)
					GL.TexCoord2(t2)
					GL.Vertex3(v2)
					theta += dtheta
				phi += dphi	
			GL.End()
			glEndList()			
		
		glCallList(skyList)
			
	protected override def OnResize(e as ResizeEventArgs) as void:
		GL.Viewport(0, 0, self.Width, self.Height)
		GL.MatrixMode(MatrixMode.Projection)
		GL.LoadIdentity()
		Glu.Perspective(45.0, Width / cast(double, Height), 1.0, 10000.0)
	
	public override def OnLoad(e as EventArgs) as void:
		Il.ilInit()
		Ilut.ilutInit()
		Ilut.ilutRenderer(Ilut.ILUT_OPENGL)		
		
		printer = TextPrinter(TextQuality.Medium);
		
		Mouse.ButtonDown += { MouseDown = true }
		Mouse.ButtonUp += { MouseDown = false }
		
		texSky = textureManager.Load("""Data/Textures/Sky/SkySmall.jpg""")
		texBillboard = textureManager.Load("""Data/Textures/Billboards/Grass.png""")
		texQuestion = textureManager.Load("""Data/Textures/Billboards/QuestionMark.png""")
		texWater = textureManager.Load("""Data/Textures/Terrain/Water.jpg""")
		texCross = textureManager.Load("Data/UI/cross.bmp")

		// Load terrain
		terrain = Terrain({s as string | textureManager.Load(s)})
				
		// Try to load shaders
		try:
			md3vertexShader = Shader(ShaderType.VertexShader, "Data/Shaders/md3_vertex.glsl")
			md3fragmentShader = Shader(ShaderType.FragmentShader, "Data/Shaders/md3_fragment.glsl")
			
			md3program = ShaderProgram()
			md3program.Attach(md3vertexShader)
			md3program.Attach(md3fragmentShader)
			md3program.Link()
			
		except e:
			print e
			print Glu.ErrorString(GL.GetError())
			
		//fileNamesFunc = def (i): return "E:/Dev/BooLandscape/Textures/skybox/basic_${i}.jpg"
		//Skybox = Skybox(array(string, map(range(6), fileNamesFunc)))			
		
		// Set up event handlers
		self.Mouse.ButtonDown += { print "haha" }

		// Create NPC
		npcModel = Core.Graphics.Md3.CharacterModel("Data/Models/mistress/")
		npc = npcModel.Skins["default"].CreateInstance()
		npc.LowerAnimation = npc.Model.GetAnimation(Core.Graphics.Md3.AnimationId.LEGS_IDLE)
		npc.UpperAnimation = npc.Model.GetAnimation(Core.Graphics.Md3.AnimationId.TORSO_GESTURE)
		npc.Position = Vector3(-100, 0, 100)
		p = terrain.PositionToIndex(npc.Position)
		npc.Position.Y = terrain.heightMap[p.X, p.Y].v.Y + 20
		

		// Create charactesr
		model = Core.Graphics.Md3.CharacterModel("Data/Models/sarge/")
		i = 0
		r = Random()
		for key as string in model.Skins.Keys:
			skin as Core.Graphics.Md3.CharacterSkin = model.Skins[key]
			character = skin.CreateInstance()
			character.Position = Vector3(i * 50.0, 0.0, 200.0 - r.NextDouble()*100.0)
			character.LookDirection = Vector3(0, 0, -1)
			character.LowerAnimation = character.Model.GetAnimation(Core.Graphics.Md3.AnimationId.LEGS_CROUCH)
			character.UpperAnimation = character.Model.GetAnimation(Core.Graphics.Md3.AnimationId.TORSO_ATTACK_2)
			
			i += 1
			characters.Add(character)
		
		def loader(s as string) as Core.Graphics.Texture:
			Core.Graphics.Texture.Load("Data/Textures/${s}")
		//tankModel = Core.Graphics.wavefront.Model.load("Data/Models/Tank.obj")
		
		weapon = Core.Graphics.Md3.Model("Data/Models/Weapons/Machinegun/machinegun.Md3")
		
		// Set up a light
		light = Light(0)
		light.Position = (4.0f, 4.0f, 0.0f, 0.0f)
		
		// Set up fog
		glEnable(GL_FOG)
		glFogi(GL_FOG_COORD_SRC, GL_FOG_COORDINATE);
		glFogfv(GL_FOG_COLOR, (0.5f, 0.5f, 0.5f, 1.0f))
		glFogf(GL_FOG_DENSITY, 0.1)
		
	
	public override def OnUnload(e as EventArgs) as void:
		textureManager.Dispose()
	
	public def RenderLandscape():
		modelView = Core.Util.Matrices.ModelView
		v = Vector3.Transform(camera.Position, modelView)
		
		terrain.Render()
		
		/*glPushMatrix()
		glTranslatef(0, 100, 0)
		quadric = Tao.OpenGl.Glu.gluNewQuadric()
		GL.Color4(1, 0, 0, 1)
		Tao.OpenGl.Glu.gluQuadricTexture(quadric, 1)
		Tao.OpenGl.Glu.gluQuadricOrientation(quadric, Tao.OpenGl.Glu.GLU_OUTSIDE)
		Tao.OpenGl.Glu.gluSphere(quadric, 50.0, 30, 30)
		Tao.OpenGl.Glu.gluDeleteQuadric(quadric)
		glPopMatrix()*/

	
		drawCharacters()
	
		
	
		// Draw sun vectors
		/*GL.Disable(EnableCap.Texture2D)
		GL.Begin(BeginMode.Lines)
		for i in range(GridLength):
			for j in range(GridLength):
				continue if heightMap[i, j].c.W == 1.0
				GL.Color4(Color.Red)
				GL.Vertex3(heightMap[i, j].v)
				GL.Vertex3(heightMap[i, j].v + sun*20.0);
		GL.End()				*/
	
	public def drawCharacters():
		GL.Disable(EnableCap.Lighting)
		GL.Enable(EnableCap.Texture2D)	
		GL.Enable(EnableCap.Blend)
		md3program.Apply()
		
		for character in characters:
			character.WeaponModel = weapon
			character.Render()

		// Render NPC with question mark (TODO: move away from here)		
		npc.Tick(RenderTime)
		npc.Render()
		md3program.Remove()		
		
		/*model = array(double, 16)
		glGetDoublev(GL_MODELVIEW_MATRIX, model)
		
		GL.Enable(EnableCap.Blend)
		GL.Enable(EnableCap.Texture2D)
		//GL.AlphaFunc(AlphaFunction.Greater, 0.3)
		//GL.Enable(EnableCap.AlphaTest)
		
		GL.BindTexture(TextureTarget.Texture2D, texQuestion)
		glDisable(GL_LIGHTING)
		GL.Begin(BeginMode.Triangles)
		
		GL.Color4(Color.Yellow)
		c1 = Vector4(1, 1, 0, 1)
		c2 = Vector4(1, 1, 1, 1)
		mod = Abs((TimePassed - Floor(TimePassed))*2.0-1.0)
		clr = c1*mod + c2*(1-mod)
		GL.Color4(clr)

		
		ex = 40.0
		right = Vector3(model[0], model[4], model[8]) * ex
		up = Vector3(model[1], model[5], model[9]) * ex		
		grass = npc.Position + Vector3(0, Sin(5*TimePassed)*10.0 + 60.0, 0)
		GL.TexCoord2(0, 1.0)
		GL.Vertex3(grass - right)
		GL.TexCoord2(1, 1.0)
		GL.Vertex3(grass + right)
		GL.TexCoord2(1, 0)
		GL.Vertex3(grass + right + up)

		GL.TexCoord2(0, 1.0)
		GL.Vertex3(grass - right)
		GL.TexCoord2(0, 0)
		GL.Vertex3(grass - right + up)
		GL.TexCoord2(1, 0)
		GL.Vertex3(grass + right + up)
		GL.End()	*/	
		// ---

		glPushMatrix(); glScalef(100, 100, 100); 			
		//tankModel.render()
		glPopMatrix()
		
		GL.Disable(EnableCap.Blend)
	
	public def SaveScreenshot():
		bmp = Bitmap(Width, Height)
		data = bmp.LockBits(Rectangle(0, 0, Width, Height), ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format24bppRgb)
		GL.ReadPixels(0, 0, Width, Height, OpenTK.Graphics.PixelFormat.Bgr, PixelType.UnsignedByte, data.Scan0)
		GL.Finish()
		bmp.UnlockBits(data)
		bmp.RotateFlip(RotateFlipType.RotateNoneFlipY);
		n = DateTime.Now
		def fill(a as int, i as int):
			return string.Format("{0:d${i}}", a)
		bmp.Save("Screenshots/Screenshot ${n.Year}-${fill(n.Month, 2)}-${fill(n.Day, 2)} - ${fill(n.Hour, 2)}${fill(n.Minute, 2)}${fill(n.Second, 2)}.png", ImageFormat.Png);
	
	public def RenderWater():
		// Draw water
		GL.Disable(EnableCap.Lighting)
		GL.Enable(EnableCap.Texture2D)
		glBindTexture(GL_TEXTURE_2D, texWater)
		GL.Begin(BeginMode.Triangles)
		ground = 0.0
		dim = 1000.0
		tiled = 20.0
		GL.Color4(Vector4(0.5, 0.6, 0.6, 0.25))
		glTexCoord2f(0, 0);
		GL.Vertex3(-dim, ground, -dim)
		glTexCoord2f(tiled, 0);
		GL.Vertex3(dim, ground, -dim)
		glTexCoord2f(0, tiled);
		GL.Vertex3(-dim, ground, dim)

		glTexCoord2f(tiled, tiled);
		GL.Vertex3(dim, ground, dim)
		glTexCoord2f(tiled, 0);
		GL.Vertex3(dim, ground, -dim)
		glTexCoord2f(0, tiled);
		GL.Vertex3(-dim, ground, dim)

		GL.End()		
		GL.Disable(EnableCap.Texture2D)
	
	public def RenderSky(cameraPos as Vector3):
		glPushMatrix()
		glDepthMask(false)
		GL.Translate(cameraPos)
		DrawSkydome()
		glDepthMask(true)
		glPopMatrix()		
	
	public def RenderScene():
		GL.Enable(EnableCap.DepthTest)		

		RenderSky(Vector3(camera.Position.X, -100, camera.Position.Z))
		
		r = PlaneReflection()
		r.render({ RenderSky(Vector3(camera.Position.X, -100, camera.Position.Z)); RenderLandscape() }, RenderWater)
		RenderWater()
	

		//glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
		
		RenderLandscape()				
	
	FrameTimePassed = 0.0
	FramesRendered = 0
	public def OnRenderFrame(e as RenderFrameEventArgs) as void:
		GL.ClearColor(Color.SkyBlue)
		GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit | ClearBufferMask.StencilBufferBit)
		
		// Render shadow stuff
		//ShadowMapping.Run(Vector3(0, 300, 300), Vector3(0, 0, 0), Vector3(0, 1, 0), RenderLandscape)
		
		// Main render pass
		for i in range(1):		
			modified = 1.0
			try:
				if i == 0:
					//glViewport(0, 0, Width / 2.0, Height / 2.0)
					glViewport(0, 0, Width, Height)
				/*elif i == 1:
					glViewport(0, Height / 2.0, Width / 2.0, Height / 2.0)
					camera.Position = characters[i].Position - characters[i].LookDirection * 100.0 + Abs(modified)*Vector3(0, 80.0, 0)
					camera.LookDirection = modified*characters[i].LookDirection + Vector3(0, -0.4, 0)				
				elif i == 2:
					glViewport(Width / 2.0, 0, Width / 2.0, Height / 2.0)				
					camera.Position = characters[i].Position - characters[i].LookDirection * 100.0 + Abs(modified)*Vector3(0, 80.0, 0)
					camera.LookDirection = modified*characters[i].LookDirection + Vector3(0, -0.4, 0)				
				elif i == 3:
					glViewport(Width / 2.0, Height / 2.0, Width / 2.0, Height / 2.0)				
					camera.Position = characters[i].Position - characters[i].LookDirection * 100.0 + Abs(modified)*Vector3(0, 80.0, 0)
					camera.LookDirection = modified*characters[i].LookDirection + Vector3(0, -0.4, 0)	*/			
			except:
				pass				
			GL.MatrixMode(MatrixMode.Modelview)
			GL.LoadIdentity()
			
			camera.Apply()
			
			light.Enable()
					
			RenderScene()


			glMatrixMode(GL_PROJECTION)
			glPushMatrix()
			glLoadIdentity()
			gluOrtho2D(0, Width / 2.0, 0, Height / 2.0)

			glMatrixMode(GL_MODELVIEW)
			GL.LoadIdentity()
			glBindTexture(GL_TEXTURE_2D, texCross)
			glEnable(GL_TEXTURE_2D)
			glEnable(GL_BLEND)
			Tao.OpenGl.Gl.glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR)
			glBegin(GL_TRIANGLES)
			glColor4f(1.0, 1.0, 1.0, 1.0)
			x = Width / 4.0
			y = Height / 4.0
			dim = 64 / 2
			glTexCoord2f(0, 0)
			glVertex2f(x - dim, y - dim)
			glTexCoord2f(0, 1)
			glVertex2f(x - dim, y + dim)
			glTexCoord2f(1, 1)
			glVertex2f(x + dim, y + dim)

			glTexCoord2f(0, 0)
			glVertex2f(x - dim, y - dim)
			glTexCoord2f(1, 0)
			glVertex2f(x + dim, y - dim)
			glTexCoord2f(1, 1)
			glVertex2f(x + dim, y + dim)

			
			glEnd()
			glDisable(GL_BLEND)

			glMatrixMode(GL_PROJECTION)
			glPopMatrix()

			glMatrixMode(GL_MODELVIEW)
			
			printer.Begin();
			text = "Player ${i}" //FPS ~= ${(RenderFrequency / 100) * 100}"
			/*printer.Print(text, sans_serif, Color.Black, RectangleF(11, 10, 1000, 100));
			printer.Print(text, sans_serif, Color.Black, RectangleF(10, 11, 1000, 100));
			printer.Print(text, sans_serif, Color.Black, RectangleF(9, 10, 1000, 100));
			printer.Print(text, sans_serif, Color.Black, RectangleF(10, 9, 1000, 100));*/
			//printer.Print(text, sans_serif, Color.Black, RectangleF(9, 9, 1000, 100));
			names = ("ox424f", "Duderinho", "!!IMTEHBEST!!1337!!", "Don Knuth")
			printer.Print(names[i], sans_serif, Color.Black, RectangleF(9, 9, 1000, 100), TextPrinterOptions.NoCache);
			printer.Print(names[i], sans_serif, Color.White, RectangleF(10, 10, 1000, 100), TextPrinterOptions.NoCache);
			printer.Print("1st place", sans_serif, Color.Black, RectangleF(9, 29, 1000, 100), TextPrinterOptions.NoCache);
			printer.Print("1st place", sans_serif, Color.White, RectangleF(10, 30, 1000, 100), TextPrinterOptions.NoCache);
			
			printer.End();		
		
		# Print FPS
		FramesRendered += 1
		FrameTimePassed += RenderTime
		if FrameTimePassed >= 1.0:
			FPS = FramesRendered / FrameTimePassed 
			print "FPS ${FPS}"
			FrameTimePassed = 0.0
			FramesRendered = 0
		
		/*printer.Begin();
		
		text = "${RenderFrequency}" //FPS ~= ${(RenderFrequency / 100) * 100}"
		/*printer.Print(text, sans_serif, Color.Black, RectangleF(11, 10, 1000, 100));
		printer.Print(text, sans_serif, Color.Black, RectangleF(10, 11, 1000, 100));
		printer.Print(text, sans_serif, Color.Black, RectangleF(9, 10, 1000, 100));
		printer.Print(text, sans_serif, Color.Black, RectangleF(10, 9, 1000, 100));*/
		//printer.Print(text, sans_serif, Color.Black, RectangleF(9, 9, 1000, 100));
		printer.Print(text, sans_serif, Color.White, RectangleF(10, 10, 1000, 100), TextPrinterOptions.NoCache);
		
		printer.End();
		*/
		if TakeScreenshot:
			SaveScreenshot()
			TakeScreenshot = false
		
		SwapBuffers();
	
	Walking = false
	
game as GameWindow = Game()
game.Run()		