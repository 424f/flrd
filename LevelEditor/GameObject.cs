using System;
using Core.Graphics;
using Box2DX.Collision;
using Box2DX.Common;
using Box2DX.Dynamics;
using OpenTK.Graphics;
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
		
		public bool AutoTransform { get; set; }
		
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
			if(AutoTransform) {
				GL.PushMatrix();
				Vec2 position = Body.GetPosition();
				GL.Translate(position.X, position.Y, 0.0f);
				GL.Rotate(90.0f, 0.0f, 1.0f, 0.0f);
			}
			Renderable.Render();
			if(AutoTransform) {
				GL.PopMatrix();
			}
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
			Box.Rotation = Body.GetAngle() * 180 / (float)System.Math.PI;
		}
		
		public override void Render() {
			float angle = Body != null ? Body.GetAngle() : 0.0f;
			base.Render();
		}
	}
	
	public class RocketObject : GameObject {
		public RocketObject(IRenderable renderable, Body body) : base(renderable, body)
		{
			Renderable = renderable;
			Body = body;
		}
		
		/// <summary>
		/// Updates the object after a physics step has been performed
		/// </summary>
		public override void Update() {			
		}
		
		public override void Render() {
			GL.PushMatrix();
			Vec2 position = Body.GetPosition();
			GL.Translate(position.X, position.Y, 0.0f);

			Vec2 vel = Body.GetLinearVelocity();
			float angle = 90.0f + (float)System.Math.Atan2(vel.X, vel.Y) * 180 / (float)System.Math.PI;
			
			GL.Rotate(angle, 0.0f, 0.0f, -1.0f);
			GL.Rotate(90.0f, 0.0f, 1.0f, 0.0f);

			Renderable.Render();

			GL.PopMatrix();
		}
	}
}
