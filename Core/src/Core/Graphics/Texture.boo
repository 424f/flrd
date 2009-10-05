namespace Core.Graphics

import System
import System.IO
import System.Collections

import Tao.OpenGl.Gl
import Tao.DevIl.Il
import Tao.DevIl.Ilut
import OpenTK.Graphics.OpenGL

import Core.Math

class Texture(ITexture, IDisposable):
"""Wraps an OpenGL texture"""

	[Property(Id)] _id as int
	"""The internal OpenGL texture identifier"""
	
	[Getter(Width)] _width as int
	[Getter(Height)] _height as int
	
	private static _cachedImages = Generic.Dictionary[of string, Texture]()
	"""Used to make sure textures aren't loaded more than once"""

	static public def Load(path as string):
	"""Loads a texture located at the given path"""
		fullPath = Path.GetFullPath(path)
		if not _cachedImages.ContainsKey(fullPath):
			_cachedImages[fullPath] = Texture(fullPath)
		return _cachedImages[fullPath]

	private def constructor(filename as string):
		ilOriginFunc(IL_ORIGIN_LOWER_LEFT)	
		ilEnable(IL_ORIGIN_SET)
		
		#_id = ilutGLLoadImage(filename)
		if not File.Exists(filename):
			raise FileNotFoundException("The texture '${filename}' couldn't be found.")
		
		# Load the image using DevIl
		id as int
		ilGenImages(1, id)	
		ilBindImage(id)
		
		if not ilLoadImage(filename):
			raise Exception("Could not load texture ${filename}")
		_width = ilGetInteger(IL_IMAGE_WIDTH)
		_height = ilGetInteger(IL_IMAGE_HEIGHT)	
		
		# Load image into OpenGL
		_id = ilutGLBindMipmaps()
		# Remove DevIl texture
		ilDeleteImages(1, id)
	
	public def constructor(width as int, height as int, pixelInternalFormat as PixelInternalFormat, pixelFormat as PixelFormat, pixelType as PixelType):
		Id = GL.GenTexture()
		Bind()
		GL.TexImage2D(TextureTarget.Texture2D, 0, pixelInternalFormat, width, height, 0, pixelFormat, pixelType, IntPtr.Zero)
		GL.TexParameter(TextureTarget.Texture2D, TextureParameterName.TextureMinFilter, cast(int, TextureMinFilter.Nearest))
	
	def Bind():
		glBindTexture(GL_TEXTURE_2D, _id)

	def Render(pos as Rect):
	"""Renders the texture. You probably need to set up a 2D projection first"""
		Bind()
		glBegin(GL_QUADS)
		glTexCoord2f(0, 0); glVertex3f(pos.Left, pos.Bottom, 0)
		glTexCoord2f(0, 1); glVertex3f(pos.Left, pos.Top, 0)
		glTexCoord2f(1, 1);	glVertex3f(pos.Right, pos.Top, 0)
		glTexCoord2f(1, 0); glVertex3f(pos.Right, pos.Bottom, 0)
		glEnd()
		
	def Render(source as Rect, dest as Rect):
		Bind()
		glBegin(GL_QUADS)
		
		oX = source.Left / cast(single, _width)
		oY = source.Bottom / cast(single, _height)
		dX = source.Right / cast(single, _width)
		dY = source.Top / cast(single, _height)
		
		glTexCoord2f(oX, oY); glVertex3f(dest.Left, dest.Bottom, 0)
		glTexCoord2f(oX, dY); glVertex3f(dest.Left, dest.Top, 0)
		glTexCoord2f(dX, dY); glVertex3f(dest.Right, dest.Top, 0)
		glTexCoord2f(dX, oY); glVertex3f(dest.Right, dest.Bottom, 0)
		glEnd()		

	public def Dispose():
		GL.DeleteTexture(Id)