namespace Core.Graphics

import System
import Tao.OpenGl.Gl
import OpenTK

class Skybox:
"""A skybox consisting of 6 faces pointed inwards"""
	
	[Getter(Textures)] _textures as (Texture)
	[Property(Position)] _Position as Vector3
	[Property(Width)] _width as single
	
	
	def constructor(filenames as (string)):
	"""filenames: contains exactly 6 paths to image files"""
		assert filenames.Length == 6
		initTextureFunc = def(path): return Texture.Load(path)
		_textures = array(Texture, map(filenames, initTextureFunc))
		_width = 400
		_Position = Vector3(0, 0, 0)
		
	def Render():
		glEnable(GL_TEXTURE_2D)
		glPushAttrib(GL_DEPTH_BUFFER_BIT | GL_LIGHTING_BIT | GL_ENABLE_BIT | GL_POLYGON_BIT | GL_TEXTURE_BIT)
		glDisable(GL_LIGHTING)
		glDisable(GL_CULL_FACE) // TODO: remove in favor of right vertex order
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)

		glColor4f(1.0, 1.0, 1.0, 1.0f)
		
		glPushMatrix()

		glTranslated(Position.X, Position.Y, Position.Z)
		glScalef(_width, _width, _width)
	 
		
		cz = -0.0f
		cx = 1.0f;
		r = 1.005f;
		
		_textures[1].Bind()
		glBegin(GL_QUADS);	
		glTexCoord2f(cz, cz); glVertex3f( r ,1.0f,-r);
		glTexCoord2f(cz, cx); glVertex3f( r,1.0f,r); 
		glTexCoord2f(cx, cx); glVertex3f(-r,1.0f,r);
		glTexCoord2f(cx, cz); glVertex3f(-r ,1.0f,-r);
		glEnd();
	 
		// Y- - BOTTOM
		_textures[0].Bind()
		glBegin(GL_QUADS)	
		glTexCoord2f(cx, cz);  glVertex3f(-r, -1.0f ,-r)
		glTexCoord2f(cx, cx);  glVertex3f(-r, -1.0f, r)
		glTexCoord2f(cz, cx);  glVertex3f( r, -1.0f, r) 
		glTexCoord2f(cz, cz);  glVertex3f( r, -1.0f,-r)
		glEnd()
	 
		// Common Axis X - Left side
		_textures[2].Bind()
		glBegin(GL_QUADS);		
		glTexCoord2f(cz,cz); glVertex3f(-1.0f,  -r,r);		
		glTexCoord2f(cx,cz); glVertex3f(-1.0f,  -r,-r);
		glTexCoord2f(cx,cx); glVertex3f(-1.0f,  r, -r); 
		glTexCoord2f(cz,cx); glVertex3f(-1.0f,  r, r);	
		glEnd();
	 
		// Common Axis X - Right side
		_textures[3].Bind()
		glBegin(GL_QUADS);		
		glTexCoord2f( cx,cx); glVertex3f(1.0f, r, r);	
		glTexCoord2f(cz, cx); glVertex3f(1.0f,  r, -r); 
		glTexCoord2f(cz, cz); glVertex3f(1.0f,  -r,-r);
		glTexCoord2f(cx, cz); glVertex3f(1.0f, -r,r);
		glEnd();
	 
		// FRONT
		_textures[4].Bind()
		glBegin(GL_QUADS);		
		glTexCoord2f(cx, cx); glVertex3f(-r, r,1.0f);
		glTexCoord2f(cz, cx); glVertex3f(r,  r,1.0f);
		glTexCoord2f(cz, cz); glVertex3f( r,  -r,1.0f); 
		glTexCoord2f(cx, cz); glVertex3f( -r, -r,1.0f);
		glEnd();
	 
		// BACK
		_textures[5].Bind()
		glBegin(GL_QUADS);		
		glTexCoord2f(cz,cz);  glVertex3f( -r, -r,-1.0f);
		glTexCoord2f( cx,cz); glVertex3f( r,  -r,-1.0f); 
		glTexCoord2f( cx,cx); glVertex3f(r,  r,-1.0f);
		glTexCoord2f(cz, cx); glVertex3f(-r, r,-1.0f);
		glEnd()
		
		glPopMatrix();
		glPopAttrib();
		
		glEnable(GL_LIGHTING)
		
