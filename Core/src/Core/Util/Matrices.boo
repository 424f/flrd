namespace Core.Util

import System
import OpenTK
import Tao.OpenGl.Gl

class Matrices:
"""Utility methods that allow for easy retrieval of certain matrices from the current OpenGL context"""
	static def FromArray(m as (single)):
		return Matrix4(Vector4(m[0], m[1], m[2], m[3]),
        	           Vector4(m[4], m[5], m[6], m[7]),
            	       Vector4(m[8], m[9], m[10], m[11]),
                	   Vector4(m[12], m[13], m[14], m[15]))

	static RawModelViewd as (double):
		get:
			m = array(double, 16)
			glGetDoublev(GL_MODELVIEW_MATRIX, m)			
			return m

	static RawModelView as (single):
		get:
			m = array(single, 16)
			glGetFloatv(GL_MODELVIEW_MATRIX, m)			
			return m

	static ModelView as Matrix4:
		get:
			return FromArray(RawModelView)

	static RawProjectiond as (double):
		get:
			m = array(double, 16)
			glGetDoublev(GL_PROJECTION_MATRIX, m)			
			return m

	static RawProjection as (single):
		get:
			m = array(single, 16)
			glGetFloatv(GL_PROJECTION_MATRIX, m)			
			return m

	static Projection as Matrix4:
		get:
			return FromArray(RawProjection)	