namespace Core.Graphics

import System
import Tao.FtGl.FtGl
import Tao.OpenGl.Gl
import OpenTK

class Font:
	private _font as FTFont
	
	public static def Create(fontFile as string, faceSize as int) as Font:
		return Font(fontFile, faceSize)
	
	private def constructor(fontFile as string, faceSize as int):
		_font = FTGLTextureFont(fontFile)
		_font.FaceSize(faceSize)
	
	def Render(text as string, x as int, y as int, color as Vector4):
		if text is null:
			text = "<null>"
		MatrixStacks.Push()
		glColor4f(color.X, color.Y, color.Z, color.W)
		MatrixStacks.Scale(1, -1, 1)
		MatrixStacks.Translate(x, -y, 0)
		_font.Render(text)
		MatrixStacks.Pop()
