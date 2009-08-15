namespace Game.Objects

import System
import Tao.OpenGl.Gl
import OpenTK.Math
import Core

class Decoration(Common.GameObject):
"""
An object that has no other purpose than to be rendered
"""
	Renderable as Graphics.IRenderable
	"""The renderable being used when this object is rendered"""

	# [TODO] move out of here.. why does importing extensions not work? *sigh*
	[Extension]
	static def Push(m as Matrix4):
	"""Pushes the old matrix and then applies `m` to it"""
		glPushMatrix()
		glMultMatrixf((m.Row0.X, m.Row0.Y, m.Row0.Z, m.Row0.W,
					   m.Row1.X, m.Row1.Y, m.Row1.Z, m.Row1.W,
					   m.Row2.X, m.Row2.Y, m.Row2.Z, m.Row2.W,
					   m.Row3.X, m.Row3.Y, m.Row3.Z, m.Row3.W))
					   
	[Extension]
	static def Pop(m as Matrix4):
		glPopMatrix()

	public rotation = Matrix4.Identity

	def constructor(renderable as Graphics.IRenderable):
		self.Renderable = renderable
		
	def Render():
		glPushMatrix()
		glTranslatef(self.Position.X, self.Position.Y, self.Position.Z)
		rotation.Push()
		Renderable.Render()
		glPopMatrix()
		glPopMatrix()
		
	def Tick():
		pass

