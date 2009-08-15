using System;
using System.Windows.Forms;
using Tao.DevIl;
using Core.Graphics.Md3;
 
namespace MD3Viewer
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
			this.glControl = new OpenTK.GLControl();
			this.openFileDialog = new System.Windows.Forms.OpenFileDialog();
			this.button2 = new System.Windows.Forms.Button();
			this.LowerAnimationSelection = new System.Windows.Forms.ComboBox();
			this.label1 = new System.Windows.Forms.Label();
			this.renderTimer = new System.Windows.Forms.Timer(this.components);
			this.label2 = new System.Windows.Forms.Label();
			this.UpperAnimationSelection = new System.Windows.Forms.ComboBox();
			this.label3 = new System.Windows.Forms.Label();
			this.skinSelection = new System.Windows.Forms.ComboBox();
			this.loadWeaponButton = new System.Windows.Forms.Button();
			this.LogText = new System.Windows.Forms.TextBox();
			this.label4 = new System.Windows.Forms.Label();
			this.label5 = new System.Windows.Forms.Label();
			this.lightingProperties = new System.Windows.Forms.PropertyGrid();
			this.label6 = new System.Windows.Forms.Label();
			this.label7 = new System.Windows.Forms.Label();
			this.button1 = new System.Windows.Forms.Button();
			this.button3 = new System.Windows.Forms.Button();
			this.menuStrip1 = new System.Windows.Forms.MenuStrip();
			this.helpToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.aboutToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
			this.label8 = new System.Windows.Forms.Label();
			this.menuStrip1.SuspendLayout();
			this.SuspendLayout();
			// 
			// glControl
			// 
			this.glControl.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
									| System.Windows.Forms.AnchorStyles.Left) 
									| System.Windows.Forms.AnchorStyles.Right)));
			this.glControl.BackColor = System.Drawing.Color.Black;
			this.glControl.Location = new System.Drawing.Point(214, 29);
			this.glControl.Name = "glControl";
			this.glControl.Size = new System.Drawing.Size(640, 534);
			this.glControl.TabIndex = 1;
			this.glControl.VSync = true;
			this.glControl.Load += new System.EventHandler(this.GlControl1Load);
			this.glControl.Paint += new System.Windows.Forms.PaintEventHandler(this.GlControlPaint);
			// 
			// openFileDialog
			// 
			this.openFileDialog.FileName = "openFileDialog";
			// 
			// button2
			// 
			this.button2.Location = new System.Drawing.Point(12, 55);
			this.button2.Name = "button2";
			this.button2.Size = new System.Drawing.Size(196, 23);
			this.button2.TabIndex = 3;
			this.button2.Text = "(None)";
			this.button2.UseVisualStyleBackColor = true;
			this.button2.Click += new System.EventHandler(this.Button2Click);
			// 
			// lowerAnimationSelection
			// 
			this.LowerAnimationSelection.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			this.LowerAnimationSelection.FormattingEnabled = true;
			this.LowerAnimationSelection.Location = new System.Drawing.Point(13, 158);
			this.LowerAnimationSelection.Name = "lowerAnimationSelection";
			this.LowerAnimationSelection.Size = new System.Drawing.Size(195, 21);
			this.LowerAnimationSelection.TabIndex = 4;
			this.LowerAnimationSelection.SelectedIndexChanged += new System.EventHandler(this.AnimationSelectionSelectedIndexChanged);
			// 
			// label1
			// 
			this.label1.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label1.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
			this.label1.Location = new System.Drawing.Point(13, 135);
			this.label1.Name = "label1";
			this.label1.Size = new System.Drawing.Size(195, 17);
			this.label1.TabIndex = 5;
			this.label1.Text = "Lower animation";
			// 
			// renderTimer
			// 
			this.renderTimer.Interval = 30;
			this.renderTimer.Tick += new System.EventHandler(this.RenderTimerTick);
			// 
			// label2
			// 
			this.label2.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label2.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
			this.label2.Location = new System.Drawing.Point(13, 187);
			this.label2.Name = "label2";
			this.label2.Size = new System.Drawing.Size(195, 21);
			this.label2.TabIndex = 7;
			this.label2.Text = "Upper animation";
			// 
			// upperAnimationSelection
			// 
			this.UpperAnimationSelection.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			this.UpperAnimationSelection.FormattingEnabled = true;
			this.UpperAnimationSelection.Location = new System.Drawing.Point(13, 209);
			this.UpperAnimationSelection.Name = "upperAnimationSelection";
			this.UpperAnimationSelection.Size = new System.Drawing.Size(195, 21);
			this.UpperAnimationSelection.TabIndex = 6;
			this.UpperAnimationSelection.SelectedIndexChanged += new System.EventHandler(this.UpperAnimationSelectionSelectedIndexChanged);
			// 
			// label3
			// 
			this.label3.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label3.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
			this.label3.Location = new System.Drawing.Point(13, 85);
			this.label3.Name = "label3";
			this.label3.Size = new System.Drawing.Size(195, 23);
			this.label3.TabIndex = 8;
			this.label3.Text = "Skin";
			// 
			// skinSelection
			// 
			this.skinSelection.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
			this.skinSelection.FormattingEnabled = true;
			this.skinSelection.Location = new System.Drawing.Point(13, 104);
			this.skinSelection.Name = "skinSelection";
			this.skinSelection.Size = new System.Drawing.Size(195, 21);
			this.skinSelection.TabIndex = 9;
			this.skinSelection.SelectedIndexChanged += new System.EventHandler(this.SkinSelectionSelectedIndexChanged);
			// 
			// loadWeaponButton
			// 
			this.loadWeaponButton.Location = new System.Drawing.Point(11, 267);
			this.loadWeaponButton.Name = "loadWeaponButton";
			this.loadWeaponButton.Size = new System.Drawing.Size(196, 23);
			this.loadWeaponButton.TabIndex = 10;
			this.loadWeaponButton.Text = "(None)";
			this.loadWeaponButton.UseVisualStyleBackColor = true;
			this.loadWeaponButton.Click += new System.EventHandler(this.LoadWeaponButtonClick);
			// 
			// LogText
			// 
			this.LogText.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left) 
									| System.Windows.Forms.AnchorStyles.Right)));
			this.LogText.Location = new System.Drawing.Point(-2, 569);
			this.LogText.Multiline = true;
			this.LogText.Name = "LogText";
			this.LogText.ScrollBars = System.Windows.Forms.ScrollBars.Vertical;
			this.LogText.Size = new System.Drawing.Size(868, 80);
			this.LogText.TabIndex = 11;
			// 
			// label4
			// 
			this.label4.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label4.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
			this.label4.Location = new System.Drawing.Point(12, 29);
			this.label4.Name = "label4";
			this.label4.Size = new System.Drawing.Size(195, 23);
			this.label4.TabIndex = 12;
			this.label4.Text = "Character model";
			// 
			// label5
			// 
			this.label5.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label5.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
			this.label5.Location = new System.Drawing.Point(13, 243);
			this.label5.Name = "label5";
			this.label5.Size = new System.Drawing.Size(195, 21);
			this.label5.TabIndex = 13;
			this.label5.Text = "Weapon model";
			// 
			// lightingProperties
			// 
			this.lightingProperties.HelpVisible = false;
			this.lightingProperties.Location = new System.Drawing.Point(11, 326);
			this.lightingProperties.Name = "lightingProperties";
			this.lightingProperties.PropertySort = System.Windows.Forms.PropertySort.NoSort;
			this.lightingProperties.Size = new System.Drawing.Size(196, 130);
			this.lightingProperties.TabIndex = 14;
			this.lightingProperties.ToolbarVisible = false;
			// 
			// label6
			// 
			this.label6.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label6.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
			this.label6.Location = new System.Drawing.Point(11, 302);
			this.label6.Name = "label6";
			this.label6.Size = new System.Drawing.Size(195, 21);
			this.label6.TabIndex = 15;
			this.label6.Text = "Lighting";
			// 
			// label7
			// 
			this.label7.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label7.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
			this.label7.Location = new System.Drawing.Point(11, 459);
			this.label7.Name = "label7";
			this.label7.Size = new System.Drawing.Size(195, 21);
			this.label7.TabIndex = 16;
			this.label7.Text = "Shaders";
			// 
			// button1
			// 
			this.button1.Location = new System.Drawing.Point(13, 482);
			this.button1.Name = "button1";
			this.button1.Size = new System.Drawing.Size(196, 23);
			this.button1.TabIndex = 17;
			this.button1.Text = "md3_vertex.vert";
			this.button1.UseVisualStyleBackColor = true;
			// 
			// button3
			// 
			this.button3.Location = new System.Drawing.Point(12, 511);
			this.button3.Name = "button3";
			this.button3.Size = new System.Drawing.Size(196, 23);
			this.button3.TabIndex = 18;
			this.button3.Text = "md3_pixel.frag";
			this.button3.UseVisualStyleBackColor = true;
			// 
			// menuStrip1
			// 
			this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
									this.helpToolStripMenuItem});
			this.menuStrip1.Location = new System.Drawing.Point(0, 0);
			this.menuStrip1.Name = "menuStrip1";
			this.menuStrip1.Size = new System.Drawing.Size(866, 24);
			this.menuStrip1.TabIndex = 19;
			this.menuStrip1.Text = "menuStrip1";
			// 
			// helpToolStripMenuItem
			// 
			this.helpToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
									this.aboutToolStripMenuItem});
			this.helpToolStripMenuItem.Name = "helpToolStripMenuItem";
			this.helpToolStripMenuItem.Size = new System.Drawing.Size(44, 20);
			this.helpToolStripMenuItem.Text = "Help";
			// 
			// aboutToolStripMenuItem
			// 
			this.aboutToolStripMenuItem.Name = "aboutToolStripMenuItem";
			this.aboutToolStripMenuItem.Size = new System.Drawing.Size(152, 22);
			this.aboutToolStripMenuItem.Text = "About...";
			this.aboutToolStripMenuItem.Click += new System.EventHandler(this.AboutToolStripMenuItemClick);
			// 
			// label8
			// 
			this.label8.Font = new System.Drawing.Font("Segoe UI", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.label8.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(0)))), ((int)(((byte)(0)))), ((int)(((byte)(192)))));
			this.label8.Location = new System.Drawing.Point(12, 545);
			this.label8.Name = "label8";
			this.label8.Size = new System.Drawing.Size(195, 21);
			this.label8.TabIndex = 20;
			this.label8.Text = "Log";
			// 
			// MainForm
			// 
			this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
			this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
			this.BackColor = System.Drawing.Color.White;
			this.ClientSize = new System.Drawing.Size(866, 650);
			this.Controls.Add(this.label8);
			this.Controls.Add(this.button3);
			this.Controls.Add(this.button1);
			this.Controls.Add(this.label7);
			this.Controls.Add(this.label6);
			this.Controls.Add(this.lightingProperties);
			this.Controls.Add(this.label5);
			this.Controls.Add(this.label4);
			this.Controls.Add(this.LogText);
			this.Controls.Add(this.loadWeaponButton);
			this.Controls.Add(this.skinSelection);
			this.Controls.Add(this.label3);
			this.Controls.Add(this.label2);
			this.Controls.Add(this.UpperAnimationSelection);
			this.Controls.Add(this.label1);
			this.Controls.Add(this.LowerAnimationSelection);
			this.Controls.Add(this.button2);
			this.Controls.Add(this.glControl);
			this.Controls.Add(this.menuStrip1);
			this.Font = new System.Drawing.Font("Segoe UI", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
			this.MainMenuStrip = this.menuStrip1;
			this.Name = "MainForm";
			this.Text = "MD3Viewer";
			this.menuStrip1.ResumeLayout(false);
			this.menuStrip1.PerformLayout();
			this.ResumeLayout(false);
			this.PerformLayout();
		}
		private System.Windows.Forms.Label label8;
		private System.Windows.Forms.ToolStripMenuItem aboutToolStripMenuItem;
		private System.Windows.Forms.ToolStripMenuItem helpToolStripMenuItem;
		private System.Windows.Forms.MenuStrip menuStrip1;
		private System.Windows.Forms.Button button3;
		private System.Windows.Forms.Button button1;
		private System.Windows.Forms.Label label7;
		private System.Windows.Forms.PropertyGrid lightingProperties;
		private System.Windows.Forms.Label label6;
		private System.Windows.Forms.Label label5;
		private System.Windows.Forms.Label label4;
		private OpenTK.GLControl glControl;
		private System.Windows.Forms.TextBox LogText;
		private System.Windows.Forms.Button loadWeaponButton;
		private System.Windows.Forms.ComboBox skinSelection;
		private System.Windows.Forms.Label label3;
		private System.Windows.Forms.ComboBox UpperAnimationSelection;
		private System.Windows.Forms.Label label2;
		private System.Windows.Forms.ComboBox LowerAnimationSelection;
		private System.Windows.Forms.Timer renderTimer;
		private System.Windows.Forms.Label label1;
		private System.Windows.Forms.OpenFileDialog openFileDialog;
		private System.Windows.Forms.Button button2;
		
		void GlControl1Load(object sender, System.EventArgs e)
		{
			Il.ilInit();
			Ilut.ilutInit();
			Ilut.ilutRenderer(Ilut.ILUT_OPENGL);			
			System.Console.Out.WriteLine("Load");
			Renderer = new Renderer(glControl);
			Renderer.Render(0.0f);
			renderTimer.Start();
			lightingProperties.SelectedObject = Renderer.Light;
		}
		
		void GlControl1Paint(object sender, System.Windows.Forms.PaintEventArgs e)
		{
			System.Console.Out.WriteLine("Paint");
		}
		
		void Button1Click(object sender, System.EventArgs e)
		{
		}
		
		void Button2Click(object sender, System.EventArgs e)
		{
			openFileDialog.ShowDialog();
			string file = openFileDialog.FileName;
			file = System.IO.Path.GetDirectoryName(file);
			
			try 
			{
				Core.Graphics.Md3.CharacterModel model = new CharacterModel(file);
				Renderer.LoadModel(model);
				skinSelection.Items.Clear();
				foreach(string skin in model.Skins.Keys)
				{
					skinSelection.Items.Add(skin);
				}
				skinSelection.SelectedIndex = 0;	
				button2.Text = System.IO.Path.GetFileNameWithoutExtension(file);
			}
			catch(Exception exc)
			{
				MessageBox.Show(exc.ToString(), "Error loading character model", MessageBoxButtons.OK, MessageBoxIcon.Error);
			}

				
			Renderer.Render(0.0f);
		}
		
		void RenderTimerTick(object sender, EventArgs e)
		{
			Renderer.Render(renderTimer.Interval / 1000.0f);
		}
		
		void AnimationSelectionSelectedIndexChanged(object sender, EventArgs e)
		{
			string val = (string)LowerAnimationSelection.SelectedItem;
			AnimationId animation = (AnimationId)AnimationId.Parse(typeof(AnimationId), val);
			if(Renderer != null)
				Renderer.PlayLowerAnimation(animation);
		}
		
		void UpperAnimationSelectionSelectedIndexChanged(object sender, EventArgs e)
		{
			string val = (string)UpperAnimationSelection.SelectedItem;
			AnimationId animation = (AnimationId)AnimationId.Parse(typeof(AnimationId), val);
			if(Renderer != null)
				Renderer.PlayUpperAnimation(animation);			
		}
		
		void SkinSelectionSelectedIndexChanged(object sender, EventArgs e)
		{
			Renderer.SelectSkin((string)skinSelection.SelectedItem);
			AnimationSelectionSelectedIndexChanged(null, null);
			UpperAnimationSelectionSelectedIndexChanged(null, null);
		}
		
		void LoadWeaponButtonClick(object sender, EventArgs e)
		{
			try
			{
				openFileDialog.ShowDialog();
				string file = openFileDialog.FileName;			
				Core.Graphics.Md3.Model weapon = new Model(file);
				Renderer.SetWeapon(weapon);
				loadWeaponButton.Text = System.IO.Path.GetFileNameWithoutExtension(file);
			}
			catch(Exception exc)
			{
				MessageBox.Show(exc.ToString(), "Error loading weapon model", MessageBoxButtons.OK, MessageBoxIcon.Error);				
			}
		}
		
		void GlControlPaint(object sender, PaintEventArgs e)
		{
			if(Renderer == null)
				GlControl1Load(sender, null);
		}
		
		void AboutToolStripMenuItemClick(object sender, EventArgs e)
		{
			MessageBox.Show(@"(c) 2009 Boris Bluntschli
			");
		}
	}
}
