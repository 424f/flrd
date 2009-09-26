namespace Core.Ui

import System
import OpenTK
import OpenTK.Graphics.OpenGL
import AwesomiumDotNet

class Dialog:
	static protected WebCore as WebCore
	static public def Update():
		WebCore.Update()
	
	protected _Texture as int
	protected Buffer as (byte)
	
	public Position as Drawing.Point
	public Opacity as single = 1.0f

	[Getter(WebView)] _WebView as WebView
	[Getter(Width)] _Width as int
	[Getter(Height)] _Height as int
	

	public def constructor(width as int, height as int):
		if WebCore == null:
			WebCore = AwesomiumDotNet.WebCore()
	
		_Width = width
		_Height = height
		
		webView = WebCore.CreateWebView(width, height, true, true, 5)
		webView.OnBeginLoading += { print "Loading!!" }
		
		webView.OnBeginNavigation += { print "begin navigation" }
		webView.OnCallback += { print "Callback" }
		webView.OnChangeCursor += { print "cursor" }
		webView.OnChangeKeyboardFocus += { print "keyboard focus" }
		webView.OnChangeTargetUrl += { print "target url" }
		webView.OnChangeTooltip += { print "Tooltip" }
		webView.OnReceiveTitle += { print "Receive title" }
		webView.SetCallback("Eval")		

		def convert(mb as OpenTK.Input.MouseButton) as AwesomiumDotNet.MouseButton:
			if mb == OpenTK.Input.MouseButton.Left:
				return AwesomiumDotNet.MouseButton.Left
			elif mb == OpenTK.Input.MouseButton.Middle:
				return AwesomiumDotNet.MouseButton.Middle
			elif mb == OpenTK.Input.MouseButton.Right:
				return AwesomiumDotNet.MouseButton.Right
		
				
		/*self.Mouse.Move += { sender as object, e as OpenTK.Input.MouseMoveEventArgs | webView.InjectMouseMove(e.X, e.Y) }
		self.Mouse.ButtonDown += { sender as object, mbe as OpenTK.Input.MouseButtonEventArgs | webView.InjectMouseDown(convert(mbe.Button)) }
		self.Mouse.ButtonUp += { sender as object, mbe as OpenTK.Input.MouseButtonEventArgs | webView.InjectMouseUp(convert(mbe.Button)) }*/
		
		/*def MapKey(k as OpenTK.Input.Key):
			i = 0
			try:
				i = cast(int, System.Windows.Forms.Keys.Parse(System.Windows.Forms.Keys, k.ToString()))
			except:
				pass
			return i*/
		
		_WebView = webView
		
		//self.Keyboard.KeyDown += { sender as object, e as KeyboardKeyEventArgs | webView.InjectKeyboardEvent(IntPtr.Zero, AwesomiumDotNet.WM.Char, MapKey(e.Key), 0); 
		//                                                                         webView.InjectKeyboardEvent(IntPtr.Zero, AwesomiumDotNet.WM.KeyDown, MapKey(e.Key), 0)}
		//self.Keyboard.KeyUp += { sender as object, e as KeyboardKeyEventArgs | webView.InjectKeyboardEvent(IntPtr.Zero, AwesomiumDotNet.WM.KeyUp, MapKey(e.Key), 0) }
		//self.KeyPress += { sender as object, e as OpenTK.KeyPressEventArgs | print "lawl" }
		_Texture = GL.GenTexture()

		GL.ActiveTexture(TextureUnit.Texture0)
		GL.BindTexture(TextureTarget.Texture2D, _Texture)
		GL.TexImage2D[of byte](TextureTarget.Texture2D, 0,PixelInternalFormat.Rgba, width, height, 0, OpenTK.Graphics.OpenGL.PixelFormat.Rgba, PixelType.UnsignedByte, null as (byte))
		GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMinFilter, cast(int, TextureMinFilter.Linear))
		GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMagFilter, cast(int, TextureMagFilter.Linear))		
		
		Buffer = array(byte, Width*Height*4)
	
	public def LoadUrl(url as string):
		WebView.LoadUrl(url)			
		
	Created = false
	
	public def UpdateTexture():
	"""Call Core.Ui.Dialog.Update() before calling this method on every dialog"""
		if WebView.IsDirty():
			bytesPerRow = 4*Width
			rect = System.Drawing.Rectangle(0, 0, Width, Height)
			WebView.Render(Buffer, bytesPerRow, 4, rect)
			
			/*if rect.Width != width or rect.Height != height:
				needed = array(byte, rect.Width*rect.Height*4)
				for i in range(rect.Top, rect.Bottom):
					Buffer.BlockCopy(buffer, bytesPerRow*i + rect.Left*4, needed, rect.Width*4*(i - rect.Top), rect.Width*4)
				buffer = needed*/
			GL.ActiveTexture(TextureUnit.Texture0)
			GL.BindTexture(TextureTarget.Texture2D, _Texture)
			OpenTK.Graphics.OpenGL.GL.TexSubImage2D(TextureTarget.Texture2D, 0, 0, 0, Width, Height, OpenTK.Graphics.OpenGL.PixelFormat.Rgba, PixelType.UnsignedByte, Buffer)		
	
	public def Render():
		GL.BindTexture(TextureTarget.Texture2D, _Texture)
		GL.Color4(Vector4(1, 1, 1, Opacity))
		GL.Begin(BeginMode.Triangles)
		GL.TexCoord2(0, 0)
		GL.Vertex3(Position.X, Position.Y, 0)
		GL.TexCoord2(1, 0)
		GL.Vertex3(Position.X + Width, Position.Y, 0)
		GL.TexCoord2(1, 1)
		GL.Vertex3(Position.X + Width, Position.Y + Height, 0)

		GL.TexCoord2(1, 1)
		GL.Vertex3(Position.X + Width, Position.Y + Height, 0)
		GL.TexCoord2(0, 1)
		GL.Vertex3(Position.X, Position.Y +Height, 0)
		GL.TexCoord2(0, 0)
		GL.Vertex3(Position.X, Position.Y, 0)
		GL.End()				