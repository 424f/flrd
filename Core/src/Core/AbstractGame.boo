namespace Core

import System
import Core
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL
import OpenTK.Input
import Tao.DevIl

import Core.Graphics

import AwesomiumDotNet

abstract class AbstractGame(OpenTK.GameWindow):	
	public FPSDialog as Ui.Dialog
	public LoadingDialog as Ui.Dialog

	public def constructor():
		super(1280, 720, OpenTK.Graphics.GraphicsMode(ColorFormat(32), 32, 32, 0, ColorFormat(32)), "FLOORED")
		VSync = VSyncMode.Off	

	public override def OnLoad(e as EventArgs):		
		Il.ilInit()
		Ilut.ilutInit()
		Ilut.ilutRenderer(Ilut.ILUT_OPENGL)		
		
		Core.Sound.Sound.Init()
				
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
		
		UpdateViewport()
		
		FPSDialog = Ui.Dialog(64, 64)
		path = IO.Path.Combine(IO.Directory.GetCurrentDirectory(), "../Data/UI/FPSDialog.htm")
		FPSDialog.LoadUrl(path)
		
		LoadingDialog = Ui.Dialog(512, 512)
		LoadingDialog.Position = Drawing.Point(0, 200)
		path = IO.Path.Combine(IO.Directory.GetCurrentDirectory(), "../Data/UI/loading.htm")
		LoadingDialog.LoadUrl(path)

		def findWebViewAt(x as int, y as int):
			for dialog in Ui.Dialog.Dialogs:
				if dialog.Position.X <= x and dialog.Position.Y <= y and dialog.Position.X + dialog.Width >= x and dialog.Position.Y + dialog.Height >= y:
				   	return dialog
			return null
			
		def convert(mb as OpenTK.Input.MouseButton) as AwesomiumDotNet.MouseButton:
			if mb == OpenTK.Input.MouseButton.Left:
				return AwesomiumDotNet.MouseButton.Left
			elif mb == OpenTK.Input.MouseButton.Middle:
				return AwesomiumDotNet.MouseButton.Middle
			elif mb == OpenTK.Input.MouseButton.Right:
				return AwesomiumDotNet.MouseButton.Right			
		
		Mouse.Move += def(sender as object, e as OpenTK.Input.MouseMoveEventArgs):
			webView = findWebViewAt(e.X, e.Y)
			if webView != null:
				webView.WebView.InjectMouseMove(e.X - webView.Position.X, e.Y - webView.Position.Y)
		
		Mouse.ButtonDown += def(sender as object, e as OpenTK.Input.MouseButtonEventArgs):
			webView = findWebViewAt(e.X, e.Y)
			if webView != null:			
				webView.WebView.InjectMouseDown(convert(e.Button))
		
		Mouse.ButtonUp += def(sender as object, e as OpenTK.Input.MouseButtonEventArgs):
			webView = findWebViewAt(e.X, e.Y)
			if webView != null:			
				webView.WebView.InjectMouseUp(convert(e.Button))

	protected def UpdateViewport():
		GL.Viewport(0, 0, self.Width, self.Height)
		MatrixStacks.MatrixMode(MatrixMode.Projection)
		Core.Graphics.MatrixStacks.LoadIdentity()
		MatrixStacks.Perspective(25.0, Width / cast(double, Height), 1.0, 1000.0)

	protected override def OnResize(e as EventArgs):
		UpdateViewport()
		
	protected def UpdateGui():
		Ui.Dialog.Update()

	protected def RenderGui():
		MatrixStacks.MatrixMode(MatrixMode.Projection)
		MatrixStacks.Push()
		Core.Graphics.MatrixStacks.LoadIdentity()
		MatrixStacks.Ortho2D(0, Width, Height, 0)
		
		MatrixStacks.MatrixMode(MatrixMode.Modelview)
		MatrixStacks.Push()
		Core.Graphics.MatrixStacks.LoadIdentity()
		GL.Color4(Drawing.Color.White)
		
		GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha)
		GL.Enable(EnableCap.Blend)
		GL.Enable(EnableCap.Texture2D)
		
		// Center Loading Dialog
		if LoadingDialog != null:
			LoadingDialog.Position = Drawing.Point(Width / 2 - LoadingDialog.Width / 2, Height / 2 - LoadingDialog.Height / 2)
		
		for dialog in Ui.Dialog.Dialogs:
			dialog.Render()
			
		MatrixStacks.MatrixMode(MatrixMode.Projection)
		MatrixStacks.Pop()
		
		MatrixStacks.MatrixMode(MatrixMode.Modelview)
		MatrixStacks.Pop()		

		GL.Disable(EnableCap.Blend)