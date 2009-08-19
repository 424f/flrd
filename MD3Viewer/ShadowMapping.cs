using System;
using Core.Util;
using OpenTK.Graphics;
using Tao.OpenGl;
using OpenTK.Math;

namespace MD3Viewer
{
	public class ShadowMapping
	{
		public delegate void RenderCall();
		
		protected int _shadowMapTexture = 0;
		protected int _shadowMapSize = 512;
		
		Matrix4 lightProjectionMatrix;
		Matrix4 lightViewMatrix;
		public Matrix4 cameraProjectionMatrix;
		public Matrix4 cameraViewMatrix;
		public int windowWidth;
		public int windowHeight;
		
		public ShadowMapping(Vector3 light)
		{			
			// Create shadow map texture
			GL.GenTextures(1, out _shadowMapTexture);
			GL.BindTexture(TextureTarget.Texture2D, _shadowMapTexture);
			GL.TexImage2D(TextureTarget.Texture2D, 0, PixelInternalFormat.DepthComponent, _shadowMapSize, _shadowMapSize, 0, PixelFormat.DepthComponent, PixelType.UnsignedByte, IntPtr.Zero);
			Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_MIN_FILTER, Gl.GL_NEAREST);
			Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_MAG_FILTER, Gl.GL_NEAREST);
			Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_WRAP_S, Gl.GL_CLAMP);
			Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_WRAP_T, Gl.GL_CLAMP);
			
			// Calculate and save matrices
			GL.MatrixMode(MatrixMode.Modelview);
			GL.PushMatrix();
	
			GL.LoadIdentity();
			OpenTK.Graphics.Glu.Perspective(45.0f, 1.0f, 1.0f, 200.0f);
			lightProjectionMatrix = Matrices.ModelView;
			
			
			//(45.0, Control.Width / (double)(Control.Height), 1.0, 10000.0);
			
			GL.LoadIdentity();
			OpenTK.Graphics.Glu.LookAt(light.X, light.Y, light.Z,
			           0.0f, 0.0f, 0.0f,
			           0.0f, 1.0f, 0.0f);
			lightViewMatrix = Matrices.ModelView;
			
			GL.PopMatrix();
		}
		
		public void Run(RenderCall DrawScene)
		{
			Matrix4 biasMatrix = new Matrix4(
				new Vector4(0.5f, 0.0f, 0.0f, 0.0f),
			    new Vector4(0.0f, 0.5f, 0.0f, 0.0f),
				new Vector4(0.0f, 0.0f, 0.5f, 0.0f),
			    new Vector4(0.5f, 0.5f, 0.5f, 1.0f));			
			
			// 1. Pass -- Light's point of view
			GL.ClearColor(System.Drawing.Color.Red);
			Gl.glClear(Gl.GL_COLOR_BUFFER_BIT | Gl.GL_DEPTH_BUFFER_BIT);
			Gl.glMatrixMode(Gl.GL_PROJECTION);
			GL.LoadMatrix(ref lightProjectionMatrix);
			Gl.glMatrixMode(Gl.GL_MODELVIEW);
			GL.LoadMatrix(ref lightViewMatrix);
			
			Gl.glViewport(0, 0, _shadowMapSize, _shadowMapSize);
			Gl.glShadeModel(Gl.GL_FLAT);
			//Gl.glColorMask(false, false, false, false);
			
			DrawScene();
			
			// Copy shadow texture
			Gl.glBindTexture(Gl.GL_TEXTURE_2D, _shadowMapTexture);
			Gl.glCopyTexSubImage2D(Gl.GL_TEXTURE_2D, 0, 0, 0, 0, 0, _shadowMapSize, _shadowMapSize);
			
			Gl.glShadeModel(Gl.GL_SMOOTH);
			Gl.glColorMask(true, true, true, true);
			
			// 2. Pass -- Draw from camera's point of view
			Gl.glClear(Gl.GL_DEPTH_BUFFER_BIT);
			Gl.glMatrixMode(Gl.GL_PROJECTION);
			//GL.LoadIdentity();
			
			Gl.glDisable(Gl.GL_LIGHTING);
			Gl.glEnable(Gl.GL_TEXTURE_2D);
			Gl.glBindTexture(Gl.GL_TEXTURE_2D, _shadowMapTexture);
			Gl.glMatrixMode(Gl.GL_MODELVIEW);
			//GL.LoadIdentity();
			Gl.glBegin(Gl.GL_TRIANGLES);
			GL.Color4(System.Drawing.Color.White);
			Gl.glTexCoord2f(0, 0);
			Gl.glVertex3f(0, 0, 10);
			Gl.glTexCoord2f(1, 0);
			Gl.glVertex3f(100, 0, 10);
			Gl.glTexCoord2f(1, 1);
			Gl.glVertex3f(100, 100, 10);

			Gl.glTexCoord2f(0, 0);
			Gl.glVertex3f(0, 0, 10);
			Gl.glTexCoord2f(0, 1);
			Gl.glVertex3f(0, 100, 10);
			Gl.glTexCoord2f(1, 1);
			Gl.glVertex3f(100, 100, 10);
			
			
			Gl.glEnd();
			
			/*GL.LoadMatrix(ref cameraProjectionMatrix);
			
			Gl.glMatrixMode(Gl.GL_MODELVIEW);
			GL.LoadMatrix(ref cameraViewMatrix);
			
			Gl.glViewport(0, 0, windowWidth, windowHeight);

			Matrix4 textureMatrix = biasMatrix * lightProjectionMatrix * lightViewMatrix;
			
			//Set up texture coordinate generation.
			Gl.glTexGeni(Gl.GL_S, Gl.GL_TEXTURE_GEN_MODE, Gl.GL_EYE_LINEAR);
			Gl.glTexGenfv(Gl.GL_S, Gl.GL_EYE_PLANE, Vector.ToSingle(textureMatrix.Row0));
			Gl.glEnable(Gl.GL_TEXTURE_GEN_S);
			
			Gl.glTexGeni(Gl.GL_T, Gl.GL_TEXTURE_GEN_MODE, Gl.GL_EYE_LINEAR);
			Gl.glTexGenfv(Gl.GL_T, Gl.GL_EYE_PLANE, Vector.ToSingle(textureMatrix.Row1));
			Gl.glEnable(Gl.GL_TEXTURE_GEN_T);
			
			Gl.glTexGeni(Gl.GL_R, Gl.GL_TEXTURE_GEN_MODE, Gl.GL_EYE_LINEAR);
			Gl.glTexGenfv(Gl.GL_R, Gl.GL_EYE_PLANE, Vector.ToSingle(textureMatrix.Row2));
			Gl.glEnable(Gl.GL_TEXTURE_GEN_R);
			
			Gl.glTexGeni(Gl.GL_Q, Gl.GL_TEXTURE_GEN_MODE, Gl.GL_EYE_LINEAR);
			Gl.glTexGenfv(Gl.GL_Q, Gl.GL_EYE_PLANE, Vector.ToSingle(textureMatrix.Row3));
			Gl.glEnable(Gl.GL_TEXTURE_GEN_Q);
			
			// Bind & enable shadow map texture
			Gl.glBindTexture(Gl.GL_TEXTURE_2D, _shadowMapTexture);
			Gl.glEnable(Gl.GL_TEXTURE_2D);
			Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_COMPARE_MODE_ARB, Gl.GL_COMPARE_R_TO_TEXTURE);
			Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_TEXTURE_COMPARE_FUNC_ARB, Gl.GL_LEQUAL);
			Gl.glTexParameteri(Gl.GL_TEXTURE_2D, Gl.GL_DEPTH_TEXTURE_MODE_ARB, Gl.GL_INTENSITY);
			
			Gl.glAlphaFunc(Gl.GL_GEQUAL, 0.99f);
			Gl.glEnable(Gl.GL_ALPHA_TEST);
			
			DrawScene();
			
			//Disable textures and texgen
			Gl.glDisable(Gl.GL_TEXTURE_2D);
			
			Gl.glDisable(Gl.GL_TEXTURE_GEN_S);
			Gl.glDisable(Gl.GL_TEXTURE_GEN_T);
			Gl.glDisable(Gl.GL_TEXTURE_GEN_R);
			Gl.glDisable(Gl.GL_TEXTURE_GEN_Q);
			
			//Restore other states
			Gl.glDisable(Gl.GL_LIGHTING);
			Gl.glDisable(Gl.GL_ALPHA_TEST);		*/
		}
	}
}
