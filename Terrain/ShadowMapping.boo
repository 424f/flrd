namespace BooLandscape

import System

import Tao.OpenGl.Gl
import Tao.OpenGl.Glu

import OpenTK.Graphics
import OpenTK.Math

import System.Drawing
import System.Drawing.Imaging

class ShadowMapping(IDisposable):
"""Description of ShadowMapping"""
	Fbo as int
	DepthBuffer as int
	Image as int
	Width = 512
	Height = 512

	public def constructor():

		
		// Create an FBO
		OpenTK.Graphics.GL.GenFramebuffers(1, Fbo)		
		OpenTK.Graphics.GL.BindFramebuffer(FramebufferTarget.FramebufferExt, Fbo)
		status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT)
		print "Status = ${status} (${status == GL_FRAMEBUFFER_COMPLETE_EXT})"	

		// Create an image buffer
		glGenTextures(1, Image)
		glBindTexture(GL_TEXTURE_2D, Image)
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, Width, Height, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0)
		glFramebufferTexture2DEXT(GL_FRAMEBUFFER_EXT, GL_COLOR_ATTACHMENT0_EXT, GL_TEXTURE_2D, Image, 0)
		status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT)
		print "Status = ${status} (${status == GL_FRAMEBUFFER_COMPLETE_EXT})"	
		
		// Create storage for depth buffer
		/*glGenRenderbuffersEXT(1, DepthBuffer)
		glBindRenderbufferEXT(GL_RENDERBUFFER_EXT, DepthBuffer)
		status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT)
		print "Status = ${status} (${status == GL_FRAMEBUFFER_COMPLETE_EXT})"		
		glRenderbufferStorageEXT(GL_RENDERBUFFER_EXT, GL_DEPTH_COMPONENT, Width, Height)
		glFramebufferRenderbufferEXT(GL_FRAMEBUFFER_EXT, GL_DEPTH_ATTACHMENT_EXT, GL_RENDERBUFFER_EXT, DepthBuffer)*/
		status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT)
		print "Status = ${status} (${status == GL_FRAMEBUFFER_COMPLETE_EXT})"
		

		
		// Verify FBO state
		status = glCheckFramebufferStatusEXT(GL_FRAMEBUFFER_EXT)
		print "Status = ${status} (${status == GL_FRAMEBUFFER_COMPLETE_EXT})"

	public def BeginRenderToTexture():
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, Fbo)
		glPushAttrib(GL_VIEWPORT_BIT)
		glViewport(0, 0, Width, Height)
	
	public def EndRenderToTexture():
		glPopAttrib()
		glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0)
		
	public def BeginRenderLight(Position as Vector3, LookAt as Vector3, Up as Vector3):
		glPushMatrix()
		glLoadIdentity()
		Glu.LookAt(Position, LookAt, Up)		
		
	public def EndRenderLight():
		glPopMatrix()
		
	public def Dispose():
		glDeleteRenderbuffersEXT(1, DepthBuffer)
		glDeleteFramebuffersEXT(1, Fbo)
	
	public def Run(Position as Vector3, LookAt as Vector3, Up as Vector3, drawShadowCasters as callable):
		BeginRenderToTexture()
		
		BeginRenderLight(Position, LookAt, Up)
		
		matProj = array(single, 16)
		glGetFloatv(GL_PROJECTION_MATRIX, matProj)

		matModelView = array(single, 16)
		glGetFloatv(GL_MODELVIEW_MATRIX, matModelView)

		/*
		 * Polygon offset is needed in order to avoid artifacts in the
		 * final image due to low precision of depth buffer values
		 */
		glEnable(GL_POLYGON_OFFSET_FILL);
		glPolygonOffset(2, 2);
		drawShadowCasters()
		glDisable(GL_POLYGON_OFFSET_FILL);
		
		EndRenderLight()
		
		EndRenderToTexture()
	
	public def SaveScreenshot():
		bmp = System.Drawing.Bitmap(Width, Height)
		data = bmp.LockBits(Rectangle(0, 0, Width, Height), ImageLockMode.WriteOnly, System.Drawing.Imaging.PixelFormat.Format24bppRgb)
		GL.ReadPixels(0, 0, Width, Height, OpenTK.Graphics.PixelFormat.Bgr, PixelType.UnsignedByte, data.Scan0)
		GL.Finish()
		bmp.UnlockBits(data)
		bmp.RotateFlip(RotateFlipType.RotateNoneFlipY);
		n = DateTime.Now
		def fill(a as int, i as int):
			return string.Format("{0:d${i}}", a)
		bmp.Save("Screenshots/Depth ${n.Year}-${fill(n.Month, 2)}-${fill(n.Day, 2)} - ${fill(n.Hour, 2)}${fill(n.Minute, 2)}${fill(n.Second, 2)}.png", ImageFormat.Png);
	
	
	static VertexShader = """
	varying vec4 shadowTexCoord;
	void main(void) {
		gl_Position = ftransform();
		shadowTexCoord = gl_TextureMatrix[0] * gl_ModelViewMatrix * gl_Vertex;
	}"""
	
	static FragmentShader = """
	uniform sampler2DShadow shadowMap;
	varying vec4 shadowTexCoord;
	void main(void) {
		gl_FragColor = shadow2DProj(shadowMap, shadowTexCoord).r * gl_Color;
	}"""
	
	