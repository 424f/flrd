/*
 * Created by SharpDevelop.
 * User: bo
 * Date: 12.08.2009
 * Time: 21:25
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
using System;
using OpenTK;
using OpenTK.Graphics;
using OpenTK.Math;
using System.Drawing;
using Core.Graphics.Md3;
using Core.Graphics;
using System.Windows.Forms;

namespace MD3Viewer
{
	/// <summary>
	/// Description of Renderer.
	/// </summary>
	public class Renderer
	{
		protected GLControl Control;
		protected CharacterInstance Character;
		protected CharacterModel Model;
		protected Shader VertexShader;
		protected Shader FragmentShader;
		protected ShaderProgram Program;
		
		public Light Light {
			get { return _Light; }
			set { _Light = value; }
		}
		private Light _Light;
		
		
		protected Model Weapon;
		
		protected Vector3 Eye = new Vector3(0, 0, -200);
		protected float Rotation = 0.0f;
		protected float Distance = 200.0f;
		protected float CameraRotation = 0.0f;
		protected bool Dragging = false;
		protected Point OldMouse;
		
		public void UpdateView()
		{
			Eye = Distance*new Vector3((float)Math.Cos(Rotation), 0.0f, (float)Math.Sin(Rotation));
		}
		
		public Renderer(GLControl control)
		{
			this.Control = control;
			VertexShader = new Shader(ShaderType.VertexShader, "E:/Dev/BooLandscape/Data/Shaders/md3_vertex.glsl");
			FragmentShader = new Shader(ShaderType.FragmentShader, "E:/Dev/BooLandscape/Data/Shaders/md3_fragment.glsl");
			
			Program = new ShaderProgram();
			Program.Attach(VertexShader);
			Program.Attach(FragmentShader);
			Program.Link();
			
			Light = new Light(0);
			
			// Set up event handlers
			Control.MouseWheel += delegate(object sender, MouseEventArgs e)
			{
				System.Console.WriteLine(e.Delta);
				Distance -= e.Delta / 2.0f;
				UpdateView();
			};
			
			Control.MouseDown += delegate(object sender, MouseEventArgs e) { 
				OldMouse = new Point(e.X, e.Y);
				Dragging = true;
			};
			
			Control.MouseUp += delegate(object sender, MouseEventArgs e) { 
				Dragging = false;
			};
			
			Control.MouseMove += delegate(object sender, MouseEventArgs e)
			{
				if(Dragging) {
					Rotation += (e.X - OldMouse.X) / 200.0f;
					UpdateView();
					OldMouse = new Point(e.X, e.Y);
				}
			};
		}
		
		public void Render(float dt)
		{
			CameraRotation += dt;
			
			GL.Viewport(0, 0, Control.Width, Control.Height);
			GL.MatrixMode(MatrixMode.Projection);
			GL.LoadIdentity();
			Glu.Perspective(45.0, Control.Width / (double)(Control.Height), 1.0, 10000.0);
			
			
			GL.ClearColor(Color.SkyBlue);
			GL.Clear(ClearBufferMask.ColorBufferBit | ClearBufferMask.DepthBufferBit | ClearBufferMask.StencilBufferBit);
			GL.MatrixMode(MatrixMode.Modelview);
			GL.Disable(EnableCap.Texture2D);
			GL.Enable(EnableCap.DepthTest);
			GL.Enable(EnableCap.Blend);
			GL.BlendFunc(BlendingFactorSrc.SrcAlpha, BlendingFactorDest.OneMinusSrcAlpha);
			GL.LoadIdentity();
			Glu.LookAt(Eye,
			           new Vector3(0, 0, 0),
			           new Vector3(0, 1, 0));
			
			
			Vector3 lightPosition = new Vector3((float)Math.Cos(CameraRotation), 1.0f, (float)Math.Sin(CameraRotation));
			lightPosition.Normalize();
			Light.Position = new float[] {lightPosition.X, lightPosition.Y, lightPosition.Z, 0.0f};
			Light.Apply();
			Light.Enable();
			
			// Draw light
			IntPtr quadric = Glu.NewQuadric();
			GL.PushMatrix();
			GL.Color3(Color.Yellow);
			GL.Translate(lightPosition * 50.0f);
			Glu.Sphere(quadric, 5.0, 10, 10);
			GL.PopMatrix();
			Glu.DeleteQuadric(quadric);
			
			// Draw character
			Program.Apply();
			if(Character != null)
			{
				Character.Tick(dt);
				Character.Render();
			}
			Program.Remove();
			Control.SwapBuffers();
			
		}
		
		public void LoadModel(CharacterModel model)
		{
			Model = model;
			Character = Model.Skins["default"].GetInstance();
		}
		
		public void PlayLowerAnimation(AnimationId animation)
		{
			if(Character != null)
				Character.LowerAnimation = Model.GetAnimation(animation);			
		}
		
		public void PlayUpperAnimation(AnimationId animation)
		{
			if(Character != null)
				Character.UpperAnimation = Model.GetAnimation(animation);			
		}
		
		public void SelectSkin(string skin) {
			if(Model != null)
				Character = Model.Skins[skin].GetInstance();
		}
		
		public void SetWeapon(Model weapon) {
			Weapon = weapon;
			if(Character != null)
				Character.WeaponModel = weapon;
		}
	}
}
