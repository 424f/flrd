using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;
using Core.Graphics.Md3;

namespace MD3Viewer
{
	/// <summary>
	/// Description of MainForm.
	/// </summary>
	public partial class MainForm : Form
	{
		protected Renderer Renderer;
		
		public MainForm()
		{
			//
			// The InitializeComponent() call is required for Windows Forms designer support.
			//
			InitializeComponent();
			
			// Add all available animations
			foreach(string name in AnimationId.GetNames(typeof(AnimationId)))
			{
				if(name.StartsWith("TORSO"))
				{
					upperAnimationSelection.Items.Add(name);
				} else if(name.StartsWith("LEGS")) {
					lowerAnimationSelection.Items.Add(name);
				} else if(name.StartsWith("BOTH")) {
					lowerAnimationSelection.Items.Add(name);
					upperAnimationSelection.Items.Add(name);
				}
			}
			
			// Select first animations
			upperAnimationSelection.SelectedIndex = 0;
			lowerAnimationSelection.SelectedIndex = 0;
			
			// Redirect standard out
			StringWriterDelegator delegator = new StringWriterDelegator();
			delegator.WriteLineEvent += delegate(object sender, string line) { 
				LogText.Text += line + "\r\n";
			};
			Console.SetOut(delegator);
		}
	}
}
