using System;
using Core.Graphics;

namespace LevelEditor
{
	/// <summary>
	/// A material that can be assigned to an object and contains properties like
	/// the diffuse and normal texture or lighting properties
	/// </summary>
	public class Material
	{
		public String Name { get; set; }
		public Texture DiffuseTexture { get; set; }
		public Texture NormalTexture { get; set; }
		
		public Material(String name) {
			Name = name;
		}
		
		/// <summary>
		/// Applies the current material to a given shader program. It will look for uniform 
		/// variables 'NormalTexture' and 'DiffuseTexture' and load the according textures using
		/// texture units 0 and 1
		/// </summary>
		/// <param name="program"></param>d
		public void Apply(ShaderProgram program) {
			program.BindUniformTexture("DiffuseTexture", DiffuseTexture, 0);
			program.BindUniformTexture("NormalTexture", NormalTexture, 1);					
		}
	}
}
