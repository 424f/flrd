namespace BooLandscape

import System
import Tao.OpenGl.Gl
import OpenTK.Math

class Skybox:
"""A skybox consisting of 6 faces pointed inwards"""
	
	[Getter(textures)] _textures as (Texture)
	[Property(position)] _position as Vector3
	[Property(width)] _width as single
	
	
	public def constructor(filenames as (string)):
	"""filenames: contains exactly 6 paths to image files"""
		assert filenames.Length == 6
		initTextureFunc = def(path): return Texture.load(path)
		_textures = array(Texture, map(filenames, initTextureFunc))
		_width = 400
		_position = Vector3(0, 0, 0)
		
	public def render():
		glEnable(GL_TEXTURE_2D)
		glPushAttrib(GL_DEPTH_BUFFER_BIT | GL_LIGHTING_BIT | GL_ENABLE_BIT | GL_POLYGON_BIT | GL_TEXTURE_BIT)
		glDisable(GL_LIGHTING)
		glDisable(GL_CULL_FACE) // TODO: remove in favor of right vertex order
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP)

		glColor4f(1.0, 1.0, 1.0, 1.0f)
		
		glPushMatrix()

		glTranslated(position.X, position.Y, position.Z)
		glScalef(_width, _width, _width)
	 
		
		cz = -0.0f
		cx = 1.0f;
		r = 1.005f;
		
		_textures[1].bind()
		glBegin(GL_QUADS);	
		glTexCoord2f(cz, cz); glVertex3f( r ,1.0f,-r);
		glTexCoord2f(cz, cx); glVertex3f( r,1.0f,r); 
		glTexCoord2f(cx, cx); glVertex3f(-r,1.0f,r);
		glTexCoord2f(cx, cz); glVertex3f(-r ,1.0f,-r);
		glEnd();
	 
		// Y- - BOTTOM
		_textures[0].bind()
		glBegin(GL_QUADS)	
		glTexCoord2f(cx, cz);  glVertex3f(-r, -1.0f ,-r)
		glTexCoord2f(cx, cx);  glVertex3f(-r, -1.0f, r)
		glTexCoord2f(cz, cx);  glVertex3f( r, -1.0f, r) 
		glTexCoord2f(cz, cz);  glVertex3f( r, -1.0f,-r)
		glEnd()
	 
		// Common Axis X - Left side
		_textures[2].bind()
		glBegin(GL_QUADS);		
		glTexCoord2f(cz,cz); glVertex3f(-1.0f,  -r,r);		
		glTexCoord2f(cx,cz); glVertex3f(-1.0f,  -r,-r);
		glTexCoord2f(cx,cx); glVertex3f(-1.0f,  r, -r); 
		glTexCoord2f(cz,cx); glVertex3f(-1.0f,  r, r);	
		glEnd();
	 
		// Common Axis X - Right side
		_textures[3].bind()
		glBegin(GL_QUADS);		
		glTexCoord2f( cx,cx); glVertex3f(1.0f, r, r);	
		glTexCoord2f(cz, cx); glVertex3f(1.0f,  r, -r); 
		glTexCoord2f(cz, cz); glVertex3f(1.0f,  -r,-r);
		glTexCoord2f(cx, cz); glVertex3f(1.0f, -r,r);
		glEnd();
	 
		// FRONT
		_textures[4].bind()
		glBegin(GL_QUADS);		
		glTexCoord2f(cx, cx); glVertex3f(-r, r,1.0f);
		glTexCoord2f(cz, cx); glVertex3f(r,  r,1.0f);
		glTexCoord2f(cz, cz); glVertex3f( r,  -r,1.0f); 
		glTexCoord2f(cx, cz); glVertex3f( -r, -r,1.0f);
		glEnd();
	 
		// BACK
		_textures[5].bind()
		glBegin(GL_QUADS);		
		glTexCoord2f(cz,cz);  glVertex3f( -r, -r,-1.0f);
		glTexCoord2f( cx,cz); glVertex3f( r,  -r,-1.0f); 
		glTexCoord2f( cx,cx); glVertex3f(r,  r,-1.0f);
		glTexCoord2f(cz, cx); glVertex3f(-r, r,-1.0f);
		glEnd()
		
		glPopMatrix();
		glPopAttrib();
		
		glEnable(GL_LIGHTING)
		
