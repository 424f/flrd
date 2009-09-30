namespace Floored

import System
import System.Collections.Generic
import OpenTK
import OpenTK.Graphics.OpenGL
import Core
import Core.Graphics
import Core.Util.Ext
import Core.Ui
import AwesomiumDotNet
import Box2DX.Collision
import Box2DX.Common
import Box2DX.Dynamics


abstract class State:
	virtual def Update(dt as single) as State:
		pass

	virtual def Render():
		pass						

class GameState(State):
	Game as Game
	Frustum = Frustum()
	ConfigDialog as Ui.ConfigDialog
	ConsoleDialog as Ui.Dialog
	
	PrevMousePosition as Drawing.Point
	AbsoluteMousePosition as Vector2
	
	VisualizePhysics = ConfigProperty("VisualizePhysics", JSValue(false))
	UpdateFrustum = ConfigProperty("UpdateFrustum", JSValue(true))
	Crosshair as Texture
	
	Tank as IRenderable
	TankMaterial as Material
	
	def constructor(game as Game):
		Game = game
		Game.FPSDialog.LoadUrl(IO.Path.Combine(IO.Directory.GetCurrentDirectory(), """../Data/UI/FPSDialog.htm"""))			
	
		Tank = Core.Graphics.Wavefront.Model.Load("../Data/Models/Tank.obj")
	
		// Load crosshair
		Crosshair = Texture.Load("../Data/Textures/crosshair.png")
		
		// Set up console
		ConsoleDialog = Ui.Dialog(Game.Width, 200)
		ConsoleDialog.LoadUrl(IO.Path.Combine(IO.Directory.GetCurrentDirectory(), """../Data/UI/ConsoleDialog.htm"""))			
		
		// Set up configuration dialog
		ConfigDialog = Ui.ConfigDialog()
		ConfigDialog.Opacity = 0.0f
		ConfigDialog.WebView.OnCallback += def(sender as object, e as Args.CallbackEventArgs):
			if e.Name == "TakeScreenshot":
				Game.TakeScreenshot = true
		
		ConfigDialog.AddProperty(VisualizePhysics)
		VisualizePhysics.Updated += { Game.ShowPhysics = VisualizePhysics.Value.ToBoolean() }
		
		ConfigDialog.AddProperty(UpdateFrustum)
		UpdateFrustum.Updated += { Game.UpdateFrustum = UpdateFrustum.Value.ToBoolean() }
		
		ConfigDialog.Position.X = Game.Width - ConfigDialog.Width
		ConfigDialog.Position.Y = Game.Height - ConfigDialog.Height

		Game.Mouse.ButtonDown += { Game.Player.DoFire = true }
		Game.Mouse.ButtonUp += { Game.Player.DoFire = false }
		
		PrevMousePosition = Windows.Forms.Cursor.Position
	
		TankMaterial = Material('Tank')
		TankMaterial.DiffuseTexture = Texture.Load('../Data/Textures/wood.jpg')
		TankMaterial.NormalTexture = Texture.Load('../Data/Textures/wood_n.jpg')

	
	override def Update(dt as single) as State:
		Game.FpsCounter.Frame(dt)

		// UI stuff
		if Game.FpsCounter.Updated:		
			Game.FPSDialog.WebView.ExecuteJavaScript("updateFPS(${Game.FpsCounter.FramesPerSecond})")			
		
		if Game.LoadingDialog != null:
			Game.LoadingDialog.Opacity -= dt * 1.0f
			if Game.LoadingDialog.Opacity <= 0f:
				Game.LoadingDialog.Dispose()
				Game.LoadingDialog = null
		
		ConsoleDialog.Position.Y = Game.Height - ConsoleDialog.Height
		
		// Mouse handling
		pos = System.Windows.Forms.Cursor.Position
		diff = Vector2(pos.X - PrevMousePosition.X, -(pos.Y - PrevMousePosition.Y))
		AbsoluteMousePosition += diff
		if System.Math.Abs(AbsoluteMousePosition.X) > 200f:
			AbsoluteMousePosition.X = 200f * System.Math.Sign(AbsoluteMousePosition.X)
		if System.Math.Abs(AbsoluteMousePosition.Y) > 200f:
			AbsoluteMousePosition.Y = 200f * System.Math.Sign(AbsoluteMousePosition.Y)	
		PrevMousePosition = pos
		//Windows.Forms.Cursor.Position = Drawing.Point(Game.Width / 2, Game.Height / 2)
		Game.Player.LookDirection = AbsoluteMousePosition / 200f
		
		// We ignore big steps
		dt = System.Math.Min(0.16f, dt)
		Game.TimePassed += dt
		Game.PhysicsTime += dt
		StepSize = 0.016f
		while Game.PhysicsTime >= StepSize:								
			# Update character
			Game.ReloadTime -= StepSize
			Game.PrimaryReloadTime -= StepSize
			//joystick = Game.Joysticks[0]
			#Player.WalkDirection = Vector2(joystick.Axis[0], joystick.Axis[1])
			//Player.LookDirection = Vector2(-joystick.Axis[2], -joystick.Axis[3])
			//Player.DoJump = joystick.Button[0]
			
				
			Game.Particles.Tick(dt)

			Game.World.Step(StepSize)
			Game.PhysicsTime -= StepSize
		
			# Listener
			Game.Listener.Position = Game.Player.Position + Vector3(0, 0, 2.0f)
			Game.Listener.Orientation = Vector3(0, 0, -1)
		return self
		
	override def Render():		
		// Center camera
		if Game.UpdateFrustum:
			Game.Camera.Eye = Game.Player.Position + Vector3(0f, 1f, 20f)
		else:
			if Game.Camera.Eye.Y < 50f:
				Game.Camera.Eye.Y += Game.RenderTime * 10f
				Game.Camera.Eye.Z = Game.Camera.Eye.Y * 3f
		Game.Camera.LookAt = Game.Player.Position + Vector3(0f, 1f, 0f)

		if Game.CameraShakeMagnitude > 0f:
			shake = Vector3(System.Math.Sin(Game.TimePassed*30f)*Game.CameraShakeMagnitude, System.Math.Sin(Game.TimePassed * 10f)*Game.CameraShakeMagnitude*0.5f, 0)
			Game.Camera.Eye += shake
			Game.Camera.LookAt += shake
			Game.CameraShakeMagnitude *= 0.9f
	
		// Set up scene
		GL.Fog(FogParameter.FogColor, (0.6f, 0.6f, 0.6f, 1f))
		GL.Fog(FogParameter.FogDensity, 0.3f)
		
		
		GL.Disable(EnableCap.Texture2D)
		GL.Enable(EnableCap.DepthTest)
		GL.Disable(EnableCap.Blend)
		//GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha)

		// Set up camera and build frustum		
		MatrixStacks.MatrixMode(MatrixMode.Modelview)
		Core.Graphics.MatrixStacks.LoadIdentity()		
		Game.Camera.Push()

		// Render skydome
		RenderState.Instance.ApplyProgram(null)
		MatrixStacks.Push()
		MatrixStacks.Translate(0, -60f, 0)
		MatrixStacks.Translate(Game.Camera.Eye)
		MatrixStacks.Rotate(45.0, 0, 1, 0)
		Game.Skydome.Render()
		MatrixStacks.Pop()	
		
		if Game.UpdateFrustum:
			Frustum.Update(MatrixStacks.ModelView.Matrix, MatrixStacks.Projection.Matrix)
		
		Game.Light.Position = Vector4.Normalize(Vector4(1f, 2.0f, 4.0f, 0f)).AsArray()
		Game.Light.Enable()	
		
		RenderState.Instance.ApplyProgram(Game.DefaultShader)
		RenderState.Instance.ApplyMaterial(TankMaterial)
		
		MatrixStacks.Push()
		MatrixStacks.Scale(3f, 3f, 3f)
		MatrixStacks.Translate(0, 0.2f, 0)
		//MatrixStacks.Rotate(Game.TimePassed * 45f, 0, 1, 0)
		Tank.Render()
		MatrixStacks.Pop()
		
		
		Game.Terrain.Render(Frustum)
		
		renderables = List[of IRenderable]()
		for o in Game.World.Objects:
			sphere = Core.Math.Sphere(o.Position, 0.2f)
			if Frustum.ContainsSphere(sphere) != IntersectionResult.Out:
				renderables.Add(o) if o.EnableRendering
		
		// Sort renderables by material, etc.
		comparison = def(a as IRenderable, b as IRenderable) as int:
			return -1 if a.Shader == null and b.Shader != null
			return 1 if a.Shader != null and b.Shader == null
			return 0 if a.Shader == b.Shader
			x = a.Shader.GetHashCode().CompareTo(b.Shader.GetHashCode())
			return x if x != 0
			return -1 if a.Material == null and b.Material != null
			return 1 if a.Material != null and b.Material == null
			return 0 if a.Material == b.Material
			x = a.Material.GetHashCode().CompareTo(b.Material.GetHashCode())
			return x if x != 0
			return 0


		// Boxes
		RenderState.Instance.ApplyProgram(null)
		RenderState.Instance.ApplyProgram(Game.DefaultShader)
		CurrentShader as ShaderProgram = Game.DefaultShader
		CurrentMaterial as Material = null
		
		renderables.Sort(comparison)
		for renderable in renderables:
			if renderable.Shader != CurrentShader and renderable.Shader != null:
				RenderState.Instance.ApplyProgram(renderable.Shader)
				CurrentShader = renderable.Shader
				CurrentMaterial = null
				//print "Switching shader to ${CurrentShader}"
			if renderable.Material != CurrentMaterial and renderable.Material != null:
				RenderState.Instance.ApplyMaterial(renderable.Material)
				CurrentMaterial = renderable.Material
				//print "Switching material to ${CurrentMaterial.Name}"
				
			renderable.Render()
		
		//print "--"
		RenderState.Instance.ApplyProgram(null)
			
		Game.Particles.Render()
			
		if not Game.UpdateFrustum:
			Frustum.Render()
		
		if Game.ShowPhysics:		
			Game.World.Visualize()

		Game.Camera.Pop()
		
		// Render crosshair
		MatrixStacks.MatrixMode(MatrixMode.Projection)
		MatrixStacks.Push()
		Core.Graphics.MatrixStacks.LoadIdentity()
		MatrixStacks.Ortho2D(-Game.Width / 2, Game.Width / 2, Game.Height / 2, -Game.Height / 2)
		
		MatrixStacks.MatrixMode(MatrixMode.Modelview)
		MatrixStacks.Push()
		Core.Graphics.MatrixStacks.LoadIdentity()
		GL.Color4(Drawing.Color.White)
		
		Tao.OpenGl.Gl.glBlendFunc(Tao.OpenGl.Gl.GL_SRC_COLOR, Tao.OpenGl.Gl.GL_ONE_MINUS_SRC_COLOR)
		GL.Enable(EnableCap.Blend)
		GL.Enable(EnableCap.Texture2D)
		
		
		MatrixStacks.Translate(cast(single, AbsoluteMousePosition.X), -cast(single, AbsoluteMousePosition.Y), 0)
		MatrixStacks.Scale(40f, 40f, 40f)
		GL.DepthMask(false)
		GL.BindTexture(TextureTarget.Texture2D, Crosshair.Id)
		GL.Color4(Vector4(1, 1, 1, 1))
		GL.Begin(BeginMode.Triangles)
		GL.TexCoord2(0, 0)
		GL.Vertex3(0, 0, 0)
		GL.TexCoord2(1, 0)
		GL.Vertex3(1, 0, 0)
		GL.TexCoord2(1, 1)
		GL.Vertex3(1, 1, 0)

		GL.TexCoord2(1, 1)
		GL.Vertex3(1, 1, 0)
		GL.TexCoord2(0, 1)
		GL.Vertex3(0, 1, 0)
		GL.TexCoord2(0, 0)
		GL.Vertex3(0, 0, 0)
		GL.End()				
		GL.DepthMask(true)
				
			
		MatrixStacks.MatrixMode(MatrixMode.Projection)
		MatrixStacks.Pop()
		
		MatrixStacks.MatrixMode(MatrixMode.Modelview)
		MatrixStacks.Pop()		

		GL.Disable(EnableCap.Blend)		