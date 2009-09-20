namespace Core.Graphics

import System
import Tao.OpenGl.Gl

class PlaneReflection:
"""
Renders reflections of objects to a floor
TODO: more generic version
"""
	def constructor():
		pass
		
	def Render(callbackObjects as callable, callbackFloor as callable, y as single):	
		# Set up clipping plane 
		clipEqr = (0.0, -1.0, 0.0, y)
		
		# Render stencil func floor
		glDisable(GL_DEPTH_TEST)
		glEnable(GL_LIGHTING)
		glEnable(GL_STENCIL_TEST)
		glColorMask(false, false, false, false)
		glStencilFunc(GL_ALWAYS, 1, 1)
		glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE)
		callbackFloor()
		
		# Render reflected copy of objects
		glColorMask(true, true, true, true)
		glEnable(GL_DEPTH_TEST)
		glStencilFunc(GL_EQUAL, 1, 1)
		glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP)
		glPushMatrix()
		glEnable(GL_CLIP_PLANE0)
		glClipPlane(GL_CLIP_PLANE0, clipEqr)
		glTranslatef(0, -50.0f, 0)
		glScalef(1, -1, 1)
		glColor4f(1, 1, 1, 1)
		callbackObjects()
		glPopMatrix()
		glDisable(GL_CLIP_PLANE0)
		glDisable(GL_STENCIL_TEST)
		
		# Blend floor onto the screen
		glEnable(GL_BLEND)
		glDisable(GL_LIGHTING)
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glColor4f(1, 1, 1, 0.85f)
		callbackFloor()
		glEnable(GL_LIGHTING)
		glDisable(GL_BLEND)
		glColor4f(1, 1, 1, 1.0f)
		
		glEnable(GL_LIGHTING)


