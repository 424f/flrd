namespace Core.Graphics

import System
import Tao.OpenGl.Gl
import OpenTK
import Core.Math

class Ortho:
"""Static helper methods for 2d drawing"""
	static def RenderRect(pos as Rect, color as Vector4):
		glBegin(GL_QUADS)
		glColor4f(color.X, color.Y, color.Z, color.W)
		glTexCoord2f(0, 0); glVertex3f(pos.Left, pos.Bottom, 0)
		glTexCoord2f(0, 1.0f); glVertex3f(pos.Left, pos.Top, 0)
		glTexCoord2f(1.0f, 1.0f); glVertex3f(pos.Right, pos.Top, 0)
		glTexCoord2f(1.0f, 0); glVertex3f(pos.Right, pos.Bottom, 0)
		glEnd()
		glColor4f(1, 1, 1, 1)
		
