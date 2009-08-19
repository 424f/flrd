using OpenTK.Math;
using OpenTK.Graphics;
using Tao.DevIl;
using Tao.OpenGl;
using System.Drawing;
using System.Diagnostics;
using System.Windows;
using System.Windows.Forms;

namespace LevelEditor
{
	partial class MainForm
	{
		/// <summary>
		/// Designer variable used to keep track of non-visual components.
		/// </summary>
		private System.ComponentModel.IContainer components = null;
		
		/// <summary>
		/// Disposes resources used by the form.
		/// </summary>
		/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
		protected override void Dispose(bool disposing)
		{
			if (disposing) {
				if (components != null) {
					components.Dispose();
				}
			}
			base.Dispose(disposing);
		}
		
		/// <summary>
		/// This method is required for Windows Forms designer support.
		/// Do not change the method contents inside the source code editor. The Forms designer might
		/// not be able to load this method if it was changed manually.
		/// </summary>
		private void InitializeComponent()
		{
			this.components = new System.ComponentModel.Container();
			this.GLControl = new OpenTK.GLControl();
			this.RenderTimer = new System.Windows.Forms.Timer(this.components);
			this.ReloadShadersButton = new System.Windows.Forms.Button();
			this.SuspendLayout();
			// 
			// GLControl
			// 
			this.GLControl.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
									| System.Windows.Forms.AnchorStyles.Left) 
									| System.Windows.Forms.AnchorStyles.Right)));
			this.GLControl.BackColor = System.Drawing.Color.Black;
			this.GLControl.Location = new System.Drawing.Point(144, 12);
			this.GLControl.Name = "GLControl";
			this.GLControl.Size = new System.Drawing.Size(640, 455);
			this.GLControl.TabIndex = 2;
			this.GLControl.VSync = true;
			this.GLControl.Load += new System.EventHandler(this.GLControlLoad);
			this.GLControl.Paint += new System.Windows.Forms.PaintEventHandler(this.GLControlPaint);
			this.GLControl.Scroll += new System.Windows.Forms.ScrollEventHandler(this.GLControlScroll);
			this.GLControl.MouseDown += new System.Windows.Forms.MouseEventHandler(this.GLControlMouseDown);
			// 
			// RenderTimer
			// 
			this.RenderTimer.Tick += new System.EventHandler(this.RenderTimerTick);
			// 
			// ReloadShadersButton
			// 
			this.ReloadShadersButton.Location = new System.Drawing.Point(13, 13);
			this.ReloadShadersButton.Name = "ReloadShadersButton";
			this.ReloadShadersButton.Size = new System.Drawing.Size(125, 31);
			this.ReloadShadersButton.TabIndex = 3;
			this.ReloadShadersButton.Text = "Reload shaders";
			this.ReloadShadersButton.UseVisualStyleBackColor = true;
			this.ReloadShadersButton.Click += new System.EventHandler(this.ReloadShadersButtonClick);
			// 
			// MainForm
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(796, 488);
			this.Controls.Add(this.ReloadShadersButton);
			this.Controls.Add(this.GLControl);
			this.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.Name = "MainForm";
			this.Text = "LevelEditor";
			this.Load += new System.EventHandler(this.MainFormLoad);
			this.ResumeLayout(false);
		}
		private System.Windows.Forms.Button ReloadShadersButton;
		private System.Windows.Forms.Timer RenderTimer;
		public OpenTK.GLControl GLControl;
		private bool Loaded = false;
		
		void GLControlLoad(object sender, System.EventArgs e)
		{
			if(Loaded)
				return;
			Il.ilInit();
			Ilut.ilutInit();
			Ilut.ilutRenderer(Ilut.ILUT_OPENGL);			
			
			GL.Viewport(0, 0, GLControl.Width, GLControl.Height);
			GL.MatrixMode(MatrixMode.Projection);
			GL.LoadIdentity();
			OpenTK.Graphics.Glu.Perspective(45.0, GLControl.Width / (double)(GLControl.Height), 1.0, 1000.0);
			
			Loaded = true;
			RenderTimer.Start();
			MouseWheel += delegate(object mSender, MouseEventArgs me) { 
				renderer.ZoomTarget += me.Delta / 40.0f;
				
			};
			
			renderer = new EditorRenderer(this);
		}
		
		void GLControlPaint(object sender, System.Windows.Forms.PaintEventArgs e)
		{
			if(!Loaded)
				GLControlLoad(sender, null);
		}
		
		void RenderTimerTick(object sender, System.EventArgs e)
		{
			renderer.Render();
			
			/*
			RenderQuad(new Vector3[]{ new Vector3(0, 0, 0),
			           	              new Vector3(0, 10, 0),
			           	              new Vector3(10, 10, 0),
			           	              new Vector3(10, 0, 0)
			           });
			  */
			
			GLControl.SwapBuffers();			
		}
		
		void GLControlScroll(object sender, System.Windows.Forms.ScrollEventArgs e)
		{
			Debug.Write("hello");
		}
		
		void GLControlMouseDown(object sender, System.Windows.Forms.MouseEventArgs e)
		{
			double[] modelView = Core.Util.Matrices.RawModelViewd;
			double[] projection = Core.Util.Matrices.RawProjectiond;
			int[] viewport = new int[4];
			Gl.glGetIntegerv(Gl.GL_VIEWPORT, viewport);
			Vector3d near;
			Vector3d far;
			
			Tao.OpenGl.Glu.gluUnProject(e.X, viewport[3] - e.Y, 0.0, modelView, projection, viewport, out near.X, out near.Y, out near.Z);
			Tao.OpenGl.Glu.gluUnProject(e.X, viewport[3] - e.Y, 1.0, modelView, projection, viewport, out far.X, out far.Y, out far.Z);
			Vector3 ray = (Vector3)(far - near);
			renderer.Pick(renderer.Camera.Eye, ray);
			
			Debug.Write("Click");
		}
		
		
		void MainFormLoad(object sender, System.EventArgs e)
		{
				
		}
		
		void ReloadShadersButtonClick(object sender, System.EventArgs e)
		{
			renderer.Program.Reload();
		}
	}
}
