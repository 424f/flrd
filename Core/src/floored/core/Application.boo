namespace Core.Common

import System

import Core
import Core.Script
import Core.Graphics
import Core.Sound
import Core.Math

import OpenTK.Math
import Tao.OpenGl.Gl
import Tao.OpenGl.Glu
import Tao.Sdl.Sdl
import Tao.DevIl

abstract class Application:
"""
Inherit from FlooredApplication for your own application
"""
	_running = false
	"""Is the program still running?"""
	
	_scriptEnvironment as ScriptEnvironment
	"""Used to run scripts from the console"""
	
	_screen = Gui.Screen()
	"""The top-level widget"""
	
	[Getter(Camera)] _Camera as Camera
	"""The main Camera that is automatically activated on beginScene"""
	
	[Getter(Counter)] _counter = Common.FPSCounter()
	
	_listener as Listener
	"""The scene listener"""
	
	[Getter(Ticks)] _ticks as int
	"""The milliseconds passed since the game started"""
	
	[Getter(Dt)] _dt as double
	"""The number of seconds passed since the last frame"""
	
	_light as Light
	
	_monoFont as Font
	_serifFont as Font
	_fpsFont as Font
		
	def Construct():
		_scriptEnvironment = ScriptEnvironment()

	def Init():	
		SDL_Init(SDL_INIT_EVERYTHING)
		SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1)
		SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16)
		SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8)
		SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8)
		SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8)
		SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8)
		SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8)
		SDL_WM_SetCaption("FLOORED", "FLOORED")
		
		# add SDL_FULLSCREEEN for fullscreen
		SDL_SetVideoMode(1024, 768, 0, SDL_OPENGL)
		
		
		Reshape(1024, 768)
		
		# Set up input
		Input.Input.FindControllers()
		Input.Input.Mouse.Widget = _screen
		Input.Input.Keyboard.Widget = _screen

		# Set up DevIL	
		Il.ilInit()
		Ilut.ilutInit()
		Ilut.ilutRenderer(Ilut.ILUT_OPENGL)
		
		# Set up OpenAL
		Core.Sound.Sound.Init()
		_listener = Core.Sound.Sound.GetListener()
		
		_Camera = Camera(Vector3(200.0f, 200, 200), Vector3(0, 0, 0), Vector3(0, 1, 0))
		
		# Load basic fonts
		_monoFont = Font.Create("data/fonts/DejaVuMonoSans.ttf", 14)
		_serifFont = Font.Create("data/fonts/DejaVuSerif.ttf", 20)
		_fpsFont = Font.Create("data/fonts/DejaVuSerif.ttf", 40)

	def Reshape(w as int, h as int):
		glViewport(0, 0, w, h)
		glMatrixMode(GL_PROJECTION)
		glLoadIdentity()
		gluPerspective(45.0, cast(single, w) / cast(single, h), 1, 10000.0)
		glMatrixMode(GL_MODELVIEW)	  
		_screen.Position = Rect(0, 0, w, h)

	def BeginScene():
		_light = Light(GL_LIGHT0)
		
		glClearColor(0.3, 0.3, 0.3, 0.0)
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)
		
		glEnable(GL_CULL_FACE)
		glCullFace(GL_BACK)
		
		glEnable(GL_DEPTH_TEST)
		glDepthMask(true)

		glEnable(GL_LIGHTING)
		_light.Enable()		
		
		glLoadIdentity()

		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		
		Camera.Push()
		

	def EndScene():
		glFlush()
		SDL_GL_SwapBuffers()	  		

		Camera.Pop()

	def Begin2d():
		glMatrixMode(GL_PROJECTION)
		glPushMatrix()
		glLoadIdentity()
		gluOrtho2D(0, 1024, 768, 0)

		glMatrixMode(GL_MODELVIEW)
		glPushMatrix()
		glLoadIdentity()

		glDisable(GL_DEPTH_TEST)
		glDisable(GL_LIGHTING)
		glDisable(GL_LIGHTING)
		glDisable(GL_DEPTH_TEST)
		glEnable(GL_TEXTURE_2D)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST_MIPMAP_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)
		glBindTexture(GL_TEXTURE_2D, 0)
		glDisable(GL_CULL_FACE)
		glDepthMask(true)
		glFrontFace(GL_CCW)
		
		glEnable(GL_BLEND)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

		glColor4f(1, 1, 1, 1)
		
	def End2d():
		glEnable(GL_DEPTH_TEST)

		glMatrixMode(GL_PROJECTION)
		glPopMatrix()

		glMatrixMode(GL_MODELVIEW)
		glPopMatrix()

	def HandleEvents():
		Input.Input.HandleEvents()
	
	def Run():
		_ticks = SDL_GetTicks()
		_running = true
		while _running and not SDL_QuitRequested():

			HandleEvents()
			
			# Calculate time passed
			span = SDL_GetTicks() - _ticks
			_dt = span / 1000.0
			_ticks = SDL_GetTicks()			

			# Perform game logic (to be implemented in subclass)
			Tick()
			Camera.Tick()

			BeginScene()
			
			# Render scene (to be implemented in subclass)
			Render()
						
			# Render widgets
			Begin2d()
			_screen.Render()
			End2d()
			
			EndScene()
			
			Counter.Frame()
			
			# Print all OpenGL errors
			while (err = glGetError()) > 0:
				print "${gluErrorString(err)} (#${err})"			
			
	def Close():
		Core.Sound.Sound.Close()
		SDL_Quit()

	abstract def Tick():
		pass
		
	abstract def Render():
		pass
