namespace Core.Util

import System
import OpenTK
import Tao.OpenGl.Gl

class Matrices:
"""Utility methods that allow for easy retrieval of certain matrices from the current OpenGL context"""

	protected static _ModelView as Matrix4
	protected static _Projection as Matrix4
	protected static _Cached = false
	static def BeginCache():
		_ModelView = ModelView
		_Projection = Projection
		_Cached = true
	
	static def EndCache():
		_Cached = false

	static def FromArray(m as (single)):
		return Matrix4(Vector4(m[0], m[4], m[8], m[12]),
        	           Vector4(m[1], m[5], m[9], m[13]),
            	       Vector4(m[2], m[6], m[10], m[14]),
                	   Vector4(m[3], m[7], m[11], m[15]))

	protected static RawModelViewd as (double):
		get:
			m = array(double, 16)
			glGetDoublev(GL_MODELVIEW_MATRIX, m)			
			return m

	protected static RawModelView as (single):
		get:
			m = array(single, 16)
			glGetFloatv(GL_MODELVIEW_MATRIX, m)			
			return m

	static ModelView as Matrix4:
		get:
			return _ModelView if _Cached
			return FromArray(RawModelView)

	protected static RawProjectiond as (double):
		get:
			m = array(double, 16)
			glGetDoublev(GL_PROJECTION_MATRIX, m)			
			return m

	protected static RawProjection as (single):
		get:
			m = array(single, 16)
			glGetFloatv(GL_PROJECTION_MATRIX, m)			
			return m

	static Projection as Matrix4:
		get:
			return _Projection if _Cached
			return FromArray(RawProjection)	