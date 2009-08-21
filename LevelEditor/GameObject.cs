using System;
using Core.Graphics;
using Box2DX.Collision;
using Box2DX.Common;
using Box2DX.Dynamics;
using OpenTK.Math;

namespace LevelEditor
{
	/// <summary>
	/// Description of GameObject.
	/// </summary>
	public class GameObject : IRenderable
	{
		public Body Body;
		public IRenderable Renderable;
		
		public GameObject(IRenderable renderable, Body body)
		{
			Renderable = renderable;
			Body = body;
		}
		
		/// <summary>
		/// Updates the object after a physics step has been performed
		/// </summary>
		public virtual void Update() {
			
		}
		
		public virtual void Render() {
			Renderable.Render();
		}
	}
	
	public class BoxObject : GameObject {
		public Box Box;
		public BoxObject(Box box, Body body) : base(box, body) {
			Box = box;
		}
		
		public override void Update() {
			if(Body == null)
				return;
			Vec2 v = Body.GetPosition();
			Box.Center = new Vector3(v.X, v.Y, Box.Center.Z);
		}
		
		public override void Render() {
			float angle = Body != null ? Body.GetAngle() : 0.0f;
			OpenTK.Graphics.GL.PushMatrix();
			OpenTK.Graphics.GL.Rotate(angle, 0, 0, 1);
			base.Render();
			OpenTK.Graphics.GL.PopMatrix();
		}
	}
}
