using System;
using System.Drawing;
using Tao.OpenGl;
using OpenTK.Graphics;
using OpenTK.Math;

namespace LevelEditor
{
	public class Vertex {
		public Vector3 Position;
		public Vector3 Normal;
		public Vector3 Tangent;
		public Vector2 TexCoord;
		
		public void Render() {
			GL.Normal3(Normal);
			GL.MultiTexCoord3(TextureUnit.Texture1, ref Tangent);
			GL.Vertex3(Position);
		}
	}
	
	public class Triangle {
		public Vertex V0, V1, V2;
		public Vector2 TexCoord0, TexCoord1, TexCoord2;

		public Triangle(Vertex v0, Vertex v1, Vertex v2, Vector2 texCoord0, Vector2 texCoord1, Vector2 texCoord2) : this(v0, v1, v2) {
			TexCoord0 = texCoord0;
			TexCoord1 = texCoord1;
			TexCoord2 = texCoord2;
		}
		
		public Triangle(Vertex v0, Vertex v1, Vertex v2) {
			V0 = v0;
			V1 = v1;
			V2 = v2;
		}
		
		public void Render() {
			GL.TexCoord2(TexCoord0);
			V0.Render();
			GL.TexCoord2(TexCoord1);
			V1.Render();
			GL.TexCoord2(TexCoord2);
			V2.Render();
		}
	}
	
	public class Box : Core.Graphics.IRenderable
	{
		Triangle[] Triangles;
		Vertex[] Vertices;
		
		public Material Material;
		public bool IsStatic = true;
		public bool OnGameLayer = true;
		
		public Vector3 Center { 
			get { return _Center; }
			set { _Center = value; }
		}
		private Vector3 _Center;

		public float TextureSpan { 
			get { return _TextureSpan; }
			set { _TextureSpan = value; IsDirty = true; }
		}
		private float _TextureSpan;		
		
		public Vector3 Dim { get; set; }
		public bool Selected = false;
		public float Rotation = 0.0f;

		public int displayList = 0;
		protected bool IsDirty = true;	
		
		public Triangle[] GetTriangles() {
			return Triangles;
		}
		
		void CreateQuad(ref int i, int i0, int i1, int i2, int i3, float tu, float tv) {
			Triangles[i++] = new Triangle(Vertices[i0], Vertices[i1], Vertices[i2], 
			                              new Vector2(0.0f, 0.0f),
			                              new Vector2(tu, 0.0f),
			                              new Vector2(tu, tv));
			Triangles[i++] = new Triangle(Vertices[i0], Vertices[i2], Vertices[i3],
			                              new Vector2(0.0f, 0.0f),
			                              new Vector2(tu, tv),
			                              new Vector2(0.0f, tv));
		}
		
		void CreateMesh(Vector3 dim) {
			Triangles = new Triangle[12];
			Vertices = new Vertex[24];
			
			// Create all vertices
			int i = 0;
			for(int j = 0; j < 3; ++j) {
				foreach(float x in new float[]{ dim.X, -dim.X }) {
					foreach(float y in new float[]{ dim.Y, -dim.Y }) {
						foreach(float z in new float[]{ dim.Z, -dim.Z }) {
							Vertex v = new Vertex();
							v.Position = new Vector3(x, y, z);
							Vertices[i++] = v;
						}
					}
				}
			}
			
			// Create all triangles
			i = 0;
			CreateQuad(ref i, 0, 4, 6, 2, Dim.X / TextureSpan, Dim.Y / TextureSpan);
			CreateQuad(ref i, 3, 7, 5, 1, Dim.X / TextureSpan, Dim.Y / TextureSpan);
			CreateQuad(ref i, 4+8, 5+8, 7+8, 6+8, Dim.Z / TextureSpan, Dim.Y / TextureSpan);
			CreateQuad(ref i, 1+8, 0+8, 2+8, 3+8, Dim.Z / TextureSpan, Dim.Y / TextureSpan);
			CreateQuad(ref i, 1+16, 5+16, 4+16, 0+16, Dim.X / TextureSpan, Dim.Z / TextureSpan);
			CreateQuad(ref i, 7+16, 3+16, 2+16, 6+16, Dim.X / TextureSpan, Dim.Z / TextureSpan);			
		}
		
		void RenderBox(Vector3 dim, bool selected) {
			CreateMesh(dim);

			// Calculate all normals and tangents
			foreach(Triangle triangle in Triangles) {
				// Normals
				Vector3 v1 = Vector3.Normalize(triangle.V0.Position - triangle.V2.Position);
				Vector3 v2 = Vector3.Normalize(triangle.V1.Position - triangle.V2.Position);
				Vector3 normal = Vector3.Cross(v1, v2);
				triangle.V0.Normal += normal;
				triangle.V1.Normal += normal;
				triangle.V2.Normal += normal;
				
				// Tangent
				Vector2 st1 = Vector2.Normalize(triangle.TexCoord0 - triangle.TexCoord2);
				Vector2 st2 = Vector2.Normalize(triangle.TexCoord1 - triangle.TexCoord2);
				float coef = 1.0f / (st1.X * st2.Y - st2.X * st1.Y);
				Vector3 tangent;
				tangent.X = v1.X * st2.Y - v2.X * st1.Y;
				tangent.Y = v1.Y * st2.Y - v2.Y * st1.Y;
				tangent.Z = v1.Z * st2.Y - v2.Z * st1.Y;
				tangent *= coef;
				triangle.V0.Tangent += tangent;
				triangle.V1.Tangent += tangent;
				triangle.V2.Tangent += tangent;
			}
			foreach(Vertex v in Vertices) {
				v.Normal.Normalize();
				v.Tangent.Normalize();
			}
			
			// Render all triangles			
			GL.FrontFace(FrontFaceDirection.Ccw);
			GL.CullFace(CullFaceMode.Back);
			//GL.Enable(EnableCap.CullFace);
			GL.Begin(BeginMode.Triangles);
			foreach(Triangle triangle in Triangles) {
				triangle.Render();
			}
			GL.End();
			
			/*
			// Render normals
			GL.Begin(BeginMode.Lines);
			GL.Color4(Color.Red);
			foreach(Vertex v in Vertices) {
				GL.Vertex3(v.Position);
				GL.Vertex3(v.Position + 2.0f * v.Normal);
			}
			GL.End();

			// Render tangents
			GL.Begin(BeginMode.Lines);
			GL.Color4(Color.Blue);
			foreach(Vertex v in Vertices) {
				GL.Vertex3(v.Position);
				GL.Vertex3(v.Position + 2.0f * v.Tangent);
			}
			GL.End();			
			*/
		}				
		
		public Box(Material material, Vector3 center, Vector3 dim) {
			Center = center;
			Dim = dim;
			Material = material;
			TextureSpan = 1.0f;
			displayList = GL.GenLists(1);
		}
		
		public void Render() {
			if(Selected)
				GL.Color4(Color.Red);
			else
				GL.Color4(Color.White);			
			if(IsDirty) {
				GL.NewList(displayList, ListMode.Compile);
				RenderBox(Dim, Selected);
				IsDirty = false;
				GL.EndList();
			}
			GL.PushMatrix();
			GL.Translate(Center.X, Center.Y, Center.Z);
			GL.Rotate(Rotation, 0, 0, 1.0);
			GL.CallList(displayList);
			GL.PopMatrix();
		}
	}
}
