/*
 * Created by SharpDevelop.
 * User: Bo
 * Date: 19.08.2009
 * Time: 00:59
 * 
 * To change this template use Tools | Options | Coding | Edit Standard Headers.
 */
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace LevelEditor
{
	/// <summary>
	/// Description of MainForm.
	/// </summary>
	public partial class MainForm : Form
	{
		EditorRenderer renderer;
		
		public MainForm()
		{
			//
			// The InitializeComponent() call is required for Windows Forms designer support.
			//
			InitializeComponent();
			

			renderer = new EditorRenderer(this);
		}
	}
}
