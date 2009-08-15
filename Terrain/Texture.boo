namespace BooLandscape

import System
import System.IO
import System.Collections

import Tao.OpenGl.Gl
import Tao.DevIl.Il
import Tao.DevIl.Ilut
import OpenTK.Math

struct Rect:
	public left as single
	public top as single
	public width as single
	public height as single
	
	public right as single:
		get: return left + width
	public bottom as single:
		get: return top + height
		
	public def constructor(left as single, top as single, width as single, height as single):
		self.left = left
		self.top = top
		self.width = width
		self.height = height
		
	public def overlaps(other as Rect):
		if other.left > self.right: return false
		if other.right < self.left: return false
		if other.bottom > self.top: return false
		if other.top < self.bottom: return false
		return true
		
	public def contains(pos as Vector2):
		return pos.X > self.left and pos.X <= self.right and pos.Y > self.top and pos.Y <= self.bottom
		
	public def ToString() as string:
		return "(${left}, ${top}, ${right}, ${bottom})"

interface ITexture:
	def bind()
	def render(pos as Rect)		
	def render(source as Rect, dest as Rect)

class Texture(ITexture):
"""Wraps an OpenGL texture"""

	[Property(id)] _id as int
	"""The internal OpenGL texture identifier"""
	
	[Getter(width)] _width as int
	[Getter(height)] _height as int
	
	private static _cachedImages = Generic.Dictionary[of string, Texture]()
	"""Used to make sure textures aren't loaded more than once"""

	static public def load(filename as string):
		fullPath = Path.GetFullPath(filename)
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
		
	public def bind():
		glBindTexture(GL_TEXTURE_2D, _id)

	public def render(pos as Rect):
	"""Renders the texture. You probably need to set up a 2D projection first"""
		bind()
		glBegin(GL_QUADS)
		glTexCoord2f(0, 0); glVertex3f(pos.left, pos.bottom, 0)
		glTexCoord2f(0, 1); glVertex3f(pos.left, pos.top, 0)
		glTexCoord2f(1, 1);	glVertex3f(pos.right, pos.top, 0)
		glTexCoord2f(1, 0); glVertex3f(pos.right, pos.bottom, 0)
		glEnd()
		
	public def render(source as Rect, dest as Rect):
		bind()
		glBegin(GL_QUADS)
		
		oX = source.left / cast(single, _width)
		oY = source.bottom / cast(single, _height)
		dX = source.right / cast(single, _width)
		dY = source.top / cast(single, _height)
		
		glTexCoord2f(oX, oY); glVertex3f(dest.left, dest.bottom, 0)
		glTexCoord2f(oX, dY); glVertex3f(dest.left, dest.top, 0)
		glTexCoord2f(dX, dY); glVertex3f(dest.right, dest.top, 0)
		glTexCoord2f(dX, oY); glVertex3f(dest.right, dest.bottom, 0)
		glEnd()		