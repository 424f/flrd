using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows;
using System.Windows.Forms;
using Core.Util;
using Core.Graphics;
using OpenTK.Math;
using OpenTK.Graphics;
using OpenTK;
using LevelEditor.Tools;

namespace LevelEditor
{
	/// <summary>
	/// Description of EditorRenderer.
	/// </summary>
	public class EditorRenderer
	{
		public MainForm Form;
		public GLControl GLControl;
		public ITool ActiveTool = new NullTool();
		public Texture TextureRock;
		public Texture TextureBump;
		
		// Data
		public List<ITweener> Tweeners;	
		public List<Box> Boxes;
		
		// Camera
		public Camera Camera;
		public float ZoomTarget = 0.0f;
		
		// Picking
		public Vector3 Origin = Vector3.Zero;
		public Vector3 Direction = Vector3.Zero;
		public Box SelectedBox;
		public Point LastMousePosition;
		
		// Graphics
		public ShaderProgram Program;
		Light Light;
		
		public EditorRenderer(MainForm form)
		{
			Form = form;
			GLControl = form.GLControl;
			Tweeners = new List<ITweener>();
			Boxes = new List<Box>();
			
			// Set up camera
			Camera = new Camera(
				new Vector3(0, 20, 50),
				new Vector3(0, 0, 0),
				new Vector3(0, 1, 0)
			);
			
			//
			Boxes.Add(new Box(new Vector3(0, 0, 0), new Vector3(10.0f, 2.0f, 10.0f)));
			Boxes.Add(new Box(new Vector3(15.0f, 5.0f, 0), new Vector3(5.0f, 7.0f, 10.0f)));
			
			// Load textures
			TextureRock = Texture.Load("../Data/Textures/wall.jpg");
			TextureBump = Texture.Load("../Data/Textures/wall_n.jpg");
		
			// Load shaders
			Program = new ShaderProgram();
			Shader VertexShader = new Shader(ShaderType.VertexShader, "Shaders/bump.vert");
			Shader FragmentShader = new Shader(ShaderType.FragmentShader, "Shaders/bump.frag");
			Program.Attach(VertexShader);
			Program.Attach(FragmentShader);
			Program.Link();
			
			// Create a light
			Light = new Light(0);
			
		}
		
		public void Render() {
			// Calculate scene

			if(Math.Abs(ZoomTarget) >= 1.0f) {
				float d = ZoomTarget / 3.0f;
				Camera.Eye += new Vector3(0, 0, d);
				//Camera.LookAt += new Vector3(0, 0, d);
				ZoomTarget -= d;
				System.Diagnostics.Debug.WriteLine(ZoomTarget);
			} else {
				ZoomTarget = 0.0f;
			}
			
			// Render scene
			GL.ClearColor(Color.SkyBlue);
			GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit | ClearBufferMask.StencilBufferBit);
			
			GL.Disable(EnableCap.Texture2D);
			GL.Enable(EnableCap.DepthTest);
			GL.Enable(EnableCap.Blend);
			GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha);
			
			GL.MatrixMode(MatrixMode.Modelview);
			GL.LoadIdentity();
			Camera.Push();	
			
			// Set up light
			Light.Position = new float[]{ 1.0f, 40.0f, 40.0f, 1.0f };
			Light.Enable();
			
			// Draw elements
			Program.Apply();
			String[] names = new String[]{ "Texture", "BumpTexture" };
			Texture[] textures = new Texture[] { TextureRock, TextureBump };
			for(int i = 0; i < names.Length; ++i) {
				int loc = Program.GetUniformLocation(names[i]);
				GL.ActiveTexture((TextureUnit)TextureUnit.Parse(typeof(TextureUnit), "Texture" + i));
				textures[i].Bind();
				OpenTK.Graphics.GL.Uniform1(loc, i);
			}
			GL.ActiveTexture(TextureUnit.Texture0);
			foreach(Box b in Boxes) {
				b.Render();
			}
			Program.Remove();
			
			// Draw picking ray
			GL.Begin(BeginMode.Lines);
			GL.Vertex3(Origin);
			GL.Vertex3(Origin + Direction * 50.0f);
			GL.End();
			
			
			
			Camera.Pop();
		}

		static bool IntersectTriangle(Vector3 rayOrigin, Vector3 rayDirection, Vector3 p1, Vector3 p2, Vector3 p3) {
			// Should use matrix3 to increase performance
			Matrix4 A = new Matrix4(new Vector4(p1-p3),
			                        new Vector4(p2-p3),
			                        new Vector4(-rayDirection),
			                        new Vector4(0, 0, 0, 1));
			A.Invert();
			Vector4 res = Vector3.Transform(rayOrigin - p3, A);
			if(res.X >= 0 && res.Y >= 0 && res.X <= 1 && res.Y <= 1 && 1 - res.X - res.Y <= 1 && 1 - res.X - res.Y >= 0) {
				return true;
			}
			return false;
		}		
		
		public void Pick(Vector3 origin, Vector3 direction) {
			Origin = origin;
			Direction = Vector3.Normalize(direction);
			
			foreach(Box b in Boxes) {
				Vector3[] triangles = b.GetTriangles();
				for(int i = 0; i < triangles.Length; i += 3) {
					bool result = IntersectTriangle(Origin, Direction, triangles[i], triangles[i+1], triangles[i+2]);
					if(result) {
						if(SelectedBox != null)
							SelectedBox.Selected = false;
						b.Selected = true;
						SelectedBox = b;
						ActiveTool = new MoveBoxTool(this);
						ActiveTool.Enable();
						return;
					}
				}
			}
		}
	}
}
