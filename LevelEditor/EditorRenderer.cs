using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows;
using System.Windows.Forms;
using Core.Util;
using Core.Graphics;
using OpenTK.Math;
using OpenTK.Graphics;

namespace LevelEditor
{
	/// <summary>
	/// Description of EditorRenderer.
	/// </summary>
	public class EditorRenderer
	{
		MainForm Form;
		
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
		
		public EditorRenderer(MainForm form)
		{
			Form = form;
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
			
			// Set up event handlers
			Form.GLControl.MouseMove += delegate(object sender, MouseEventArgs e) {  
				Point pos = new Point(e.X, e.Y);
				Point delta = new Point(pos.X - LastMousePosition.X, pos.Y - LastMousePosition.Y);
				//System.Diagnostics.Debug.WriteLine("" + delta.X + ", " + delta.Y);
				if(SelectedBox != null) {
					SelectedBox.Center.X += delta.X / 10.0f;
					SelectedBox.Center.Y += delta.Y / 10.0f;
				}
				LastMousePosition = pos;
			};
		}
		
		public void Render() {
			// Calculate scene
			Tweeners.RemoveAll(delegate (ITweener t) { return t.Finished; });
			foreach(ITweener tweener in Tweeners) {
				tweener.Update(0.100f);
			}
			if(Tweeners.Count == 0) {
				 /*Delegate<Object, Vector3, Vector3, float> del = delegate(Object target, Vector3 a, Vector3 b, float m) {
					
				};
				Tweeners.Add(new Tweener<float>(Camera, new Vector3(0, 0, 0), new Vector3(0, 0, 50), del, 2.0f));*/
			}
			if(Math.Abs(ZoomTarget) >= 1.0f) {
				float d = ZoomTarget / 3.0f;
				Camera.Eye += new Vector3(0, 0, d);
				Camera.LookAt += new Vector3(0, 0, d);
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
			
			// Draw elements
			foreach(Box b in Boxes) {
				b.Render();
			}
			
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
						return;
					}
				}
			}
		}
	}
}
