using System;
using System.Drawing;
using Tao.OpenGl;
using OpenTK.Graphics;
using OpenTK.Math;

namespace LevelEditor
{
	public class Vertex {
		Vector3 Position;
		Vector3 Normal;
		Vector3 Tangent;
	}
	
	public class Triangle {
		Vertex v0, v1, v2;
	}
	
	public class Box
	{
		public Vector3 Center;
		public Vector3 Dim;
		public bool Selected = false;
		public float TextureSpan = 20.0f;
		
		static void RenderQuad(Vector3[] vs, float tu, float tv) {
			tu = Math.Max(1.0f, (float)Math.Round(tu));
			tv = Math.Max(1.0f, (float)Math.Round(tv));
			
			// TODO: real normals calculation
			Vector3 normal = Vector3.Cross(vs[0] - vs[2], vs[1] - vs[2]);
			normal.Normalize();
			GL.Normal3(normal);
			
			GL.TexCoord2(0.0, 0.0);
			Gl.glMultiTexCoord3f(Gl.GL_TEXTURE1, 0.0f, 0.0f, 1.0f);
			GL.Vertex3(vs[0]);
			// ----------------------------------------------------
			GL.TexCoord2(tu, 0.0);
			Gl.glMultiTexCoord3f(Gl.GL_TEXTURE1, 0.0f, 0.0f, 1.0f);
			GL.Vertex3(vs[1]);
			// ----------------------------------------------------
			GL.TexCoord2(tu, tv);
			Gl.glMultiTexCoord3f(Gl.GL_TEXTURE1, 0.0f, 0.0f, 1.0f);
			GL.Vertex3(vs[2]);

			
			normal = Vector3.Cross(vs[3] - vs[2], vs[0] - vs[2]);
			normal.Normalize();
			GL.Normal3(normal);			
			
			GL.TexCoord2(tu, tv);
			Gl.glMultiTexCoord3f(Gl.GL_TEXTURE1, 1.0f, 0.0f, 0.0f);
			GL.Vertex3(vs[2]);
			// ----------------------------------------------------
			GL.TexCoord2(0.0, tv);
			Gl.glMultiTexCoord3f(Gl.GL_TEXTURE1, 1.0f, 0.0f, 0.0f);
			GL.Vertex3(vs[3]);
			// ----------------------------------------------------
			GL.TexCoord2(0.0, 0.0);
			Gl.glMultiTexCoord3f(Gl.GL_TEXTURE1, 1.0f, 0.0f, 0.0f);
			GL.Vertex3(vs[0]);
		}
		
		
		public Vector3[] GetTriangles() {
			Vector3[] result = new Vector3[36];
			int i = 0;
			
			foreach(float y in new float[]{Center.Y + Dim.Y, Center.Y - Dim.Y}) {
				result[i++] = new Vector3(Center.X - Dim.X, y, Center.Z - Dim.Z);
				result[i++] = new Vector3(Center.X + Dim.X, y, Center.Z - Dim.Z);
				result[i++] = new Vector3(Center.X + Dim.X, y, Center.Z + Dim.Z);
				result[i++] = result[i-1];
				result[i++] = new Vector3(Center.X - Dim.X, y, Center.Z + Dim.Z);
				result[i++] = result[i-5];
			}
			
			foreach(float x in new float[]{Center.X + Dim.X, Center.X - Dim.X}) {
				result[i++] = new Vector3(x, Center.Y - Dim.Y, Center.Z - Dim.Z);
				result[i++] = new Vector3(x, Center.Y + Dim.Y, Center.Z - Dim.Z);
				result[i++] = new Vector3(x, Center.Y + Dim.Y, Center.Z + Dim.Z);
				result[i++] = result[i-1];
				result[i++] = new Vector3(x, Center.Y - Dim.Y, Center.Z + Dim.Z);
				result[i++] = result[i-5];
			}	
			
			
			foreach(float z in new float[]{Center.Z + Dim.Z, Center.Z - Dim.Z}) {
				result[i++] = new Vector3(Center.X - Dim.X, Center.Y - Dim.Y, z);
				result[i++] = new Vector3(Center.X + Dim.X, Center.Y - Dim.Y, z);
				result[i++] = new Vector3(Center.X + Dim.X, Center.Y + Dim.Y, z);
				result[i++] = result[i-1];
				result[i++] = new Vector3(Center.X - Dim.X, Center.Y + Dim.Y, z);
				result[i++] = result[i-5];           
			}			
			return result;
		}
		
		void RenderBox(Vector3 center, Vector3 dim, bool selected) {
			int i = 0;
			//Color[] colors = new Color[]{ Color.Red, Color.Blue, Color.Green, Color.Yellow, Color.Purple, Color.Orange };
			Color[] colors = new Color[]{ Color.White, Color.White, Color.White, Color.White, Color.White, Color.White };
			if(selected) {
				colors = new Color[]{ Color.Orange, Color.Red, Color.Blue, Color.Green, Color.Yellow, Color.Purple };
			}
			
			GL.Begin(BeginMode.Triangles);	
			foreach(float y in new float[]{center.Y + dim.Y, center.Y - dim.Y}) {
				GL.Color4(colors[i++]);
				RenderQuad(new Vector3[]{ new Vector3(center.X - dim.X, y, center.Z - dim.Z),
				           	              new Vector3(center.X + dim.X, y, center.Z - dim.Z),
				           	              new Vector3(center.X + dim.X, y, center.Z + dim.Z),
				           	              new Vector3(center.X - dim.X, y, center.Z + dim.Z)
				           }, dim.X / TextureSpan, dim.Z / TextureSpan);
			}
			
			foreach(float x in new float[]{center.X + dim.X, center.X - dim.X}) {
				GL.Color4(colors[i++]);
				RenderQuad(new Vector3[]{ new Vector3(x, center.Y - dim.Y, center.Z - dim.Z),
				           	              new Vector3(x, center.Y + dim.Y, center.Z - dim.Z),
				           	              new Vector3(x, center.Y + dim.Y, center.Z + dim.Z),
				           	              new Vector3(x, center.Y - dim.Y, center.Z + dim.Z)
				           }, dim.Y / TextureSpan, dim.Z / TextureSpan);
			}	
			
			
			foreach(float z in new float[]{center.Z + dim.Z, center.Z - dim.Z}) {
				GL.Color4(colors[i++]);
				RenderQuad(new Vector3[]{ new Vector3(center.X - dim.X, center.Y - dim.Y, z),
				           	              new Vector3(center.X + dim.X, center.Y - dim.Y, z),
				           	              new Vector3(center.X + dim.X, center.Y + dim.Y, z),
				           	              new Vector3(center.X - dim.X, center.Y + dim.Y, z)
				           }, dim.X / TextureSpan, dim.Y / TextureSpan);
			}				
			/*RenderQuad(new Vector3[]{ new Vector3(center.X - dim.X, center.Y - dim.Y, center.Z + dim.Z),
			           	              new Vector3(center.X + dim.X, center.Y - dim.Y, center.Z + dim.Z),
			           	              new Vector3(center.X + dim.X, center.Y + dim.Y, center.Z + dim.Z),
			           	              new Vector3(center.X - dim.X, center.Y + dim.Y, center.Z + dim.Z)
			           });			*/
			GL.End();
		}				
		
		public Box(Vector3 center, Vector3 dim) {
			Center = center;
			Dim = dim;
		}
		
		public void Render() {
			RenderBox(Center, Dim, Selected);
		}
	}
}
