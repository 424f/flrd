namespace Core.Util

import System
import OpenTK.Math

abstract class Vector:
	static def ToSingle(v as Vector4) as (single):
		return (v.X, v.Y, v.Z, v.W)

