using System;

namespace LevelEditor.Tools
{
	/// <summary>
	/// A tool that can be used by the user to change certain entities or properties in a map
	/// </summary>
	public interface ITool
	{
		void Enable();
		void Disable();
	}
}
