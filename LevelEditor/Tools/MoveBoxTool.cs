using System;
using System.Windows.Forms;
using System.Drawing;

namespace LevelEditor.Tools
{
	/// <summary>
	/// Description of MoveBoxTool.
	/// </summary>
	public class MoveBoxTool : ITool
	{
		EditorRenderer Editor;
		Point LastMousePosition = Point.Empty;
		Box SelectedBox;
		
		public MoveBoxTool(EditorRenderer editor) {
			Editor = editor;
			SelectedBox = Editor.SelectedBox;
		}
		
		public void Enable() {		
			Editor.GLControl.MouseMove += MouseMove;
			Editor.GLControl.MouseUp += MouseUp;
		}
		
		public void Disable() {
			Editor.GLControl.MouseMove -= MouseMove;
		}
		
		protected void MouseMove(object sender, MouseEventArgs e) {
			Point pos = new Point(e.X, e.Y);
			if(LastMousePosition != Point.Empty) {
				Point delta = new Point(pos.X - LastMousePosition.X, pos.Y - LastMousePosition.Y);
				//System.Diagnostics.Debug.WriteLine("" + delta.X + ", " + delta.Y);
				if(SelectedBox != null) {
					SelectedBox.Center = SelectedBox.Center + new OpenTK.Math.Vector3(delta.X / 10.0f, -delta.Y / 10.0f, 0.0f);
				}
			}
			LastMousePosition = pos;			
		}

		protected void MouseUp(object sender, MouseEventArgs e) {
			Disable();
		}
		
		
	}
}
