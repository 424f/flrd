using System;
using System.IO;

namespace MD3Viewer
{
	/// <summary>
	/// Description of StringWriterDelegator.
	/// </summary>
	public class StringWriterDelegator : StringWriter
	{
		public delegate void WriteLineHandler(object sender, string line);
		public event WriteLineHandler WriteLineEvent;
		
		public StringWriterDelegator()
		{
		}
		
		public override void WriteLine(string text) {
			WriteLineEvent(this, text);
		}
	}
}
