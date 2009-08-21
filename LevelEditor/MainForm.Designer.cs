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
			this.ItemProperties = new System.Windows.Forms.PropertyGrid();
			this.CreateBoxButton = new System.Windows.Forms.Button();
			this.groupBox1 = new System.Windows.Forms.GroupBox();
			this.BoxDimZ = new System.Windows.Forms.TextBox();
			this.BoxDimY = new System.Windows.Forms.TextBox();
			this.BoxDimX = new System.Windows.Forms.TextBox();
			this.label2 = new System.Windows.Forms.Label();
			this.BoxZ = new System.Windows.Forms.TextBox();
			this.BoxY = new System.Windows.Forms.TextBox();
			this.BoxX = new System.Windows.Forms.TextBox();
			this.label1 = new System.Windows.Forms.Label();
			this.groupBox1.SuspendLayout();
			this.SuspendLayout();
			// 
			// GLControl
			// 
			this.GLControl.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
									| System.Windows.Forms.AnchorStyles.Left) 
									| System.Windows.Forms.AnchorStyles.Right)));
			this.GLControl.BackColor = System.Drawing.Color.Black;
			this.GLControl.Location = new System.Drawing.Point(308, 12);
			this.GLControl.Name = "GLControl";
			this.GLControl.Size = new System.Drawing.Size(857, 613);
			this.GLControl.TabIndex = 2;
			this.GLControl.VSync = true;
			this.GLControl.Load += new System.EventHandler(this.GLControlLoad);
			this.GLControl.Paint += new System.Windows.Forms.PaintEventHandler(this.GLControlPaint);
			this.GLControl.MouseMove += new System.Windows.Forms.MouseEventHandler(this.GLControlMouseMove);
			this.GLControl.Scroll += new System.Windows.Forms.ScrollEventHandler(this.GLControlScroll);
			this.GLControl.MouseDown += new System.Windows.Forms.MouseEventHandler(this.GLControlMouseDown);
			this.GLControl.Resize += new System.EventHandler(this.GLControlResize);
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
			// ItemProperties
			// 
			this.ItemProperties.HelpVisible = false;
			this.ItemProperties.Location = new System.Drawing.Point(13, 237);
			this.ItemProperties.Name = "ItemProperties";
			this.ItemProperties.Size = new System.Drawing.Size(289, 388);
			this.ItemProperties.TabIndex = 4;
			this.ItemProperties.ToolbarVisible = false;
			// 
			// CreateBoxButton
			// 
			this.CreateBoxButton.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.CreateBoxButton.ForeColor = System.Drawing.Color.Black;
			this.CreateBoxButton.Location = new System.Drawing.Point(158, 92);
			this.CreateBoxButton.Name = "CreateBoxButton";
			this.CreateBoxButton.Size = new System.Drawing.Size(125, 24);
			this.CreateBoxButton.TabIndex = 5;
			this.CreateBoxButton.Text = "Create";
			this.CreateBoxButton.UseVisualStyleBackColor = true;
			// 
			// groupBox1
			// 
			this.groupBox1.Controls.Add(this.BoxDimZ);
			this.groupBox1.Controls.Add(this.BoxDimY);
			this.groupBox1.Controls.Add(this.BoxDimX);
			this.groupBox1.Controls.Add(this.label2);
			this.groupBox1.Controls.Add(this.BoxZ);
			this.groupBox1.Controls.Add(this.BoxY);
			this.groupBox1.Controls.Add(this.BoxX);
			this.groupBox1.Controls.Add(this.label1);
			this.groupBox1.Controls.Add(this.CreateBoxButton);
			this.groupBox1.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.groupBox1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
			this.groupBox1.Location = new System.Drawing.Point(13, 99);
			this.groupBox1.Name = "groupBox1";
			this.groupBox1.Size = new System.Drawing.Size(289, 122);
			this.groupBox1.TabIndex = 6;
			this.groupBox1.TabStop = false;
			this.groupBox1.Text = "Create Box";
			// 
			// BoxDimZ
			// 
			this.BoxDimZ.Location = new System.Drawing.Point(230, 39);
			this.BoxDimZ.Name = "BoxDimZ";
			this.BoxDimZ.Size = new System.Drawing.Size(30, 25);
			this.BoxDimZ.TabIndex = 13;
			// 
			// BoxDimY
			// 
			this.BoxDimY.Location = new System.Drawing.Point(194, 39);
			this.BoxDimY.Name = "BoxDimY";
			this.BoxDimY.Size = new System.Drawing.Size(30, 25);
			this.BoxDimY.TabIndex = 12;
			// 
			// BoxDimX
			// 
			this.BoxDimX.Location = new System.Drawing.Point(158, 39);
			this.BoxDimX.Name = "BoxDimX";
			this.BoxDimX.Size = new System.Drawing.Size(30, 25);
			this.BoxDimX.TabIndex = 11;
			// 
			// label2
			// 
			this.label2.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label2.ForeColor = System.Drawing.Color.Black;
			this.label2.Location = new System.Drawing.Point(158, 22);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(102, 23);
			this.label2.TabIndex = 10;
			this.label2.Text = "Dimension";
			// 
			// BoxZ
			// 
			this.BoxZ.Location = new System.Drawing.Point(79, 39);
			this.BoxZ.Name = "BoxZ";
			this.BoxZ.Size = new System.Drawing.Size(30, 25);
			this.BoxZ.TabIndex = 9;
			// 
			// BoxY
			// 
			this.BoxY.Location = new System.Drawing.Point(43, 39);
			this.BoxY.Name = "BoxY";
			this.BoxY.Size = new System.Drawing.Size(30, 25);
			this.BoxY.TabIndex = 8;
			// 
			// BoxX
			// 
			this.BoxX.Location = new System.Drawing.Point(7, 39);
			this.BoxX.Name = "BoxX";
			this.BoxX.Size = new System.Drawing.Size(30, 25);
			this.BoxX.TabIndex = 7;
			// 
			// label1
			// 
			this.label1.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label1.ForeColor = System.Drawing.Color.Black;
			this.label1.Location = new System.Drawing.Point(7, 22);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(102, 23);
			this.label1.TabIndex = 6;
			this.label1.Text = "Position";
			// 
			// MainForm
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.ClientSize = new System.Drawing.Size(1177, 646);
			this.Controls.Add(this.groupBox1);
			this.Controls.Add(this.ItemProperties);
			this.Controls.Add(this.ReloadShadersButton);
			this.Controls.Add(this.GLControl);
			this.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.Name = "MainForm";
			this.Text = "LevelEditor";
			this.Load += new System.EventHandler(this.MainFormLoad);
			this.groupBox1.ResumeLayout(false);
			this.groupBox1.PerformLayout();
			this.ResumeLayout(false);
		}
		public System.Windows.Forms.Button CreateBoxButton;
		public System.Windows.Forms.TextBox BoxDimX;
		public System.Windows.Forms.TextBox BoxDimY;
		public System.Windows.Forms.TextBox BoxDimZ;
		private System.Windows.Forms.Label label2;
		public System.Windows.Forms.TextBox BoxX;
		public System.Windows.Forms.TextBox BoxY;
		public System.Windows.Forms.TextBox BoxZ;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.GroupBox groupBox1;
		public System.Windows.Forms.PropertyGrid ItemProperties;
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
			OpenTK.Graphics.Glu.Perspective(45.0, GLControl.Width / (double)(GLControl.Height), 1.0, 5000.0);			
			
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
			RenderTimer.Stop();
			renderer.Render();
			GLControl.SwapBuffers();			
			RenderTimer.Start();
		}
		
		void GLControlScroll(object sender, System.Windows.Forms.ScrollEventArgs e)
		{
			Debug.Write("hello");
		}
		
		void GLControlMouseDown(object sender, System.Windows.Forms.MouseEventArgs e)
		{

		}
		
		
		void MainFormLoad(object sender, System.EventArgs e)
		{
				
		}
		
		void ReloadShadersButtonClick(object sender, System.EventArgs e)
		{
			renderer.Program.Reload();
		}
		
		void GLControlMouseMove(object sender, MouseEventArgs e)
		{
			
		}
	}
}
