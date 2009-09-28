namespace Floored

import System
import System.Collections.Generic
import OpenTK
import OpenTK.Graphics.OpenGL
import Core
import Core.Graphics
import Core.Util.Ext


abstract class State:
	virtual def Update(dt as single) as State:
		pass

	virtual def Render():
		pass

class GameState(State):
	Game as Game
	Frustum = Frustum()
	ConfigDialog as Ui.Dialog
	
	def constructor(game as Game):
		Game = game
		Game.FPSDialog.LoadUrl(IO.Path.Combine(IO.Directory.GetCurrentDirectory(), """../Data/UI/FPSDialog.htm"""))			
		ConfigDialog = Ui.Dialog(512, 512)
		ConfigDialog.LoadUrl(IO.Path.Combine(IO.Directory.GetCurrentDirectory(), """../Data/UI/ConfigWindow.htm"""))
		ConfigDialog.Position.X = Game.Width - ConfigDialog.Width
		ConfigDialog.Position.Y = Game.Height - ConfigDialog.Height
	
	override def Update(dt as single) as State:
		Game.FpsCounter.Frame(dt)
		if Game.FpsCounter.Updated:		
			Game.FPSDialog.WebView.ExecuteJavaScript("updateFPS(${Game.FpsCounter.FramesPerSecond})")			
		
		if Game.LoadingDialog != null:
			Game.LoadingDialog.Opacity -= dt * 0.3f
			if Game.LoadingDialog.Opacity <= 0f:
				Game.LoadingDialog.Dispose()
				Game.LoadingDialog = null
		
		# We ignore big steps
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
		if Game.UpdateFrustum:
			Game.Camera.Eye = Game.Player.Position + Vector3(0f, 1f, 20f)
		else:
			if Game.Camera.Eye.Y < 50f:
				Game.Camera.Eye.Y += Game.RenderTime * 10f
				Game.Camera.Eye.Z = Game.Camera.Eye.Y * 3f
		
		Game.Camera.LookAt = Game.Player.Position + Vector3(0f, 1f, 0f)
	
		// Set up scene
		GL.ClearColor(System.Drawing.Color.SkyBlue)
		GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit | ClearBufferMask.StencilBufferBit)
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
			
		if not Game.UpdateFrustum:
			Frustum.Render()
		
		if Game.ShowPhysics:		
			Game.World.Visualize()

		
		Game.Camera.Pop()