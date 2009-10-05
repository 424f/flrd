namespace Core.Graphics

import System
import OpenTK
import OpenTK.Graphics
import OpenTK.Graphics.OpenGL

class RenderBufferObject(IDisposable):
	public Id as int
	
	public def constructor(target as OpenTK.Graphics.OpenGL.RenderbufferStorage, width as int, height as int):
		OpenTK.Graphics.OpenGL.GL.GenRenderbuffers(1, Id)
		BeginUsage()
		OpenTK.Graphics.OpenGL.GL.RenderbufferStorage(OpenTK.Graphics.OpenGL.RenderbufferTarget.RenderbufferExt, target, width, height)
		EndUsage()
		
	public def BeginUsage():
		OpenTK.Graphics.OpenGL.GL.BindRenderbuffer(OpenTK.Graphics.OpenGL.RenderbufferTarget.RenderbufferExt, Id)

	public def EndUsage():
		OpenTK.Graphics.OpenGL.GL.BindRenderbuffer(OpenTK.Graphics.OpenGL.RenderbufferTarget.RenderbufferExt, 0)

class FrameBufferObject(IDisposable):
	public Id as int
	
	public def constructor():
		OpenTK.Graphics.OpenGL.GL.GenFramebuffers(1, Id)
		CheckStatus()
	
	public def BeginUsage():
		OpenTK.Graphics.OpenGL.GL.BindFramebuffer(OpenTK.Graphics.OpenGL.FramebufferTarget.FramebufferExt, Id)
		CheckStatus()
		
	public def EndUsage():
		OpenTK.Graphics.OpenGL.GL.BindFramebuffer(OpenTK.Graphics.OpenGL.FramebufferTarget.FramebufferExt, 0)
		CheckStatus()
	
	public def Attach(texture as Texture, attachment as OpenTK.Graphics.OpenGL.FramebufferAttachment):
		OpenTK.Graphics.OpenGL.GL.FramebufferTexture2D(OpenTK.Graphics.OpenGL.FramebufferTarget.FramebufferExt, attachment, TextureTarget.Texture2D, texture.Id, 0)
		CheckStatus()

	public def Attach(rbo as RenderBufferObject, attachment as OpenTK.Graphics.OpenGL.FramebufferAttachment):
		OpenTK.Graphics.OpenGL.GL.FramebufferRenderbuffer(OpenTK.Graphics.OpenGL.FramebufferTarget.FramebufferExt, attachment, OpenTK.Graphics.OpenGL.RenderbufferTarget.RenderbufferExt, rbo.Id)
		CheckStatus()
	
	public def Dispose():
		OpenTK.Graphics.OpenGL.GL.DeleteFramebuffers(1, Id)
		CheckStatus()
		
	private def CheckStatus():
		fbec = OpenTK.Graphics.OpenGL.GL.CheckFramebufferStatus(OpenTK.Graphics.OpenGL.FramebufferTarget.FramebufferExt)
		