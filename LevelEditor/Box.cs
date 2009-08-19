using System;
using System.Drawing;
using OpenTK.Graphics;
using OpenTK.Math;

namespace LevelEditor
{
	public class Box
	{
		public Vector3 Center;
		public Vector3 Dim;
		public bool Selected = false;
		
		static void RenderQuad(Vector3[] vs) {
			GL.Vertex3(vs[0]);
			GL.Vertex3(vs[1]);
			GL.Vertex3(vs[2]);
			
			GL.Vertex3(vs[2]);
			GL.Vertex3(vs[3]);
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
		
		static void RenderBox(Vector3 center, Vector3 dim, bool selected) {
			int i = 0;
			Color[] colors = new Color[]{ Color.Red, Color.Blue, Color.Green, Color.Yellow, Color.Purple, Color.Orange };
			if(selected) {
				colors = new Color[]{ Color.Red, Color.Red, Color.Red, Color.Red, Color.Red, Color.Red };
			}
			
			GL.Begin(BeginMode.Triangles);	
			foreach(float y in new float[]{center.Y + dim.Y, center.Y - dim.Y}) {
				GL.Color4(colors[i++]);
				RenderQuad(new Vector3[]{ new Vector3(center.X - dim.X, y, center.Z - dim.Z),
				           	              new Vector3(center.X + dim.X, y, center.Z - dim.Z),
				           	              new Vector3(center.X + dim.X, y, center.Z + dim.Z),
				           	              new Vector3(center.X - dim.X, y, center.Z + dim.Z)
				           });
			}
			
			foreach(float x in new float[]{center.X + dim.X, center.X - dim.X}) {
				GL.Color4(colors[i++]);
				RenderQuad(new Vector3[]{ new Vector3(x, center.Y - dim.Y, center.Z - dim.Z),
				           	              new Vector3(x, center.Y + dim.Y, center.Z - dim.Z),
				           	              new Vector3(x, center.Y + dim.Y, center.Z + dim.Z),
				           	              new Vector3(x, center.Y - dim.Y, center.Z + dim.Z)
				           });
			}	
			
			
			foreach(float z in new float[]{center.Z + dim.Z, center.Z - dim.Z}) {
				GL.Color4(colors[i++]);
				RenderQuad(new Vector3[]{ new Vector3(center.X - dim.X, center.Y - dim.Y, z),
				           	              new Vector3(center.X + dim.X, center.Y - dim.Y, z),
				           	              new Vector3(center.X + dim.X, center.Y + dim.Y, z),
				           	              new Vector3(center.X - dim.X, center.Y + dim.Y, z)
				           });
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
