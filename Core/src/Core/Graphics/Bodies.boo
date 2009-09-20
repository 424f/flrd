namespace Core.Graphics

import System
import System.Collections
import Tao.OpenGl.Gl
import OpenTK.Math

class Bodies:
	private static _displayLists = Generic.Dictionary[of callable, int]()
	"""Caches the display lists created for the different bodies"""

	static def RenderCuboid(a as Vector3, b as Vector3):
		glPushMatrix()
		# Replace with real vector functions
		scale = Vector3((a.X - b.X) / 2, (a.Y - b.Y) / 2, (a.Z - b.Z) / 2)
		trans = Vector3(a.X - b.X, a.Y - b.Y, a.Z - b.Z)
		glTranslatef(trans.X, trans.Y, trans.Z)
		glScalef(scale.X, scale.Y, scale.Z)
		RenderCuboid()
		glPopMatrix()

	static def RenderCuboid():
		# TODO: improve (static instead of rotating, add normals)
		if RenderCuboid not in _displayLists.Keys:
			index = glGenLists(1)
			_displayLists[RenderCuboid] = index
			glNewList(index, GL_COMPILE)

			cz = -0.0f
			cx = 1.0f;

			glBegin(GL_QUADS);	
			glTexCoord2f(cx, cz); glVertex3f(-1.0f, 1.0f, -1.0f);
			glTexCoord2f(cx, cx); glVertex3f(-1.0f, 1.0f, 1.0f);
			glTexCoord2f(cz, cx); glVertex3f(1.0f, 1.0f, 1.0f); 
			glTexCoord2f(cz, cz); glVertex3f(1.0f, 1.0f, -1.0f);
			glEnd();
		 
			// Y- - BOTTOM
			glBegin(GL_QUADS)	
			glTexCoord2f(cz, cz);  glVertex3f(1.0f, -1.0f, -1.0f)
			glTexCoord2f(cz, cx);  glVertex3f(1.0f, -1.0f, 1.0f) 
			glTexCoord2f(cx, cx);  glVertex3f(-1.0f, -1.0f, 1.0f)
			glTexCoord2f(cx, cz);  glVertex3f(-1.0f, -1.0f, -1.0f)
			glEnd()
		 
			// Common Axis X - Left side
			glBegin(GL_QUADS);		
			glTexCoord2f(cz, cx); glVertex3f(-1.0f, 1.0f, 1.0f);	
			glTexCoord2f(cx, cx); glVertex3f(-1.0f, 1.0f, -1.0f); 
			glTexCoord2f(cx, cz); glVertex3f(-1.0f, -1.0f, -1.0f);
			glTexCoord2f(cz, cz); glVertex3f(-1.0f, -1.0f, 1.0f);		
			glEnd();
		 
			// Common Axis X - Right side
			glBegin(GL_QUADS);		
			glTexCoord2f(cx, cz); glVertex3f(1.0f, -1.0f, 1.0f);
			glTexCoord2f(cz, cz); glVertex3f(1.0f, -1.0f,-1.0f);
			glTexCoord2f(cz, cx); glVertex3f(1.0f, 1.0f, -1.0f); 
			glTexCoord2f(cx, cx); glVertex3f(1.0f, 1.0f, 1.0f);	
			glEnd();
		 
			// FRONT
			glBegin(GL_QUADS);		
			glTexCoord2f(cx, cz); glVertex3f(-1.0f, -1.0f, 1.0f);
			glTexCoord2f(cz, cz); glVertex3f(1.0f, -1.0f, 1.0f); 
			glTexCoord2f(cz, cx); glVertex3f(1.0f, 1.0f, 1.0f);
			glTexCoord2f(cx, cx); glVertex3f(-1.0f, 1.0f, 1.0f);
			glEnd();
		 
			// BACK
			glBegin(GL_QUADS);		
			glTexCoord2f(cz, cx); glVertex3f(-1.0f, 1.0f, -1.0f);
			glTexCoord2f(cx, cx); glVertex3f(1.0f, 1.0f, -1.0f);
			glTexCoord2f(cx, cz); glVertex3f(1.0f, -1.0f, -1.0f);
			glTexCoord2f(cz, cz);  glVertex3f(-1.0f, -1.0f, -1.0f);
			glEnd()

			glEndList()
		glCallList(_displayLists[RenderCuboid])
