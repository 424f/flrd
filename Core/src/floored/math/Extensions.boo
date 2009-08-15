namespace Core.Math

import OpenTK.Math

class Ext:
	[Boo.Lang.ExtensionAttribute]
	static def IsEmpty(val as object) as bool:
		if val isa System.Collections.ICollection:
			return cast(System.Collections.ICollection,val).Count == 0
		return true
		
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
