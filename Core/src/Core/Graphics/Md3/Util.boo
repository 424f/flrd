namespace Core.Graphics.Md3

import System

class Util:
	static def DecodeVector(v as Vec3f):
	"""Decodes a vector from the coordinate system of MD3 to the one we'll be using (x right, y up, -z into the screen)"""
		r as Vec3f
		r.X = -v.Y
		r.Y = v.Z
		r.Z = -v.X
		return r
