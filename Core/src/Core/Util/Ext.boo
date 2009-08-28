namespace Core.Util

import System
import OpenTK.Math
import Box2DX.Common
import Boo.Lang.Useful.Attributes

class Ext:
"""Extension methods for different types to improve interoperability between utilized libraries"""
	[Extension]
	public static def AsVec2(v as Vector3) as Vec2:
		return Vec2(v.X, v.Y)

	[Extension]
	public static def AsArray(v as Vector3) as (single):
		return (v.X, v.Y, v.Z)

	[Extension]
	public static def AsArray(v as Vector4) as (single):
		return (v.X, v.Y, v.Z, v.W)

	[Extension]
	public static def AsVector3(v as Vec2) as Vector3:
		return Vector3(v.X, v.Y, 0.0f)
		
	[Extension]
	public static def AsVector3(v as Vec2, z as single) as Vector3:
		return Vector3(v.X, v.Y, z)		