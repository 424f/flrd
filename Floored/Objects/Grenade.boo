namespace Floored.Objects

import Floored
import Core.Util.Ext
import OpenTK
import OpenTK.Graphics.OpenGL
import Box2DX.Common
import Box2DX.Dynamics

class Grenade(GameObject):
	ExplosionTimer = 3f
	World as World
	static BulletHitSound as Core.Sound.Buffer
	static Source as Core.Sound.Source
				
	public def constructor(world as World):
		World = world
		box = Shapes.Box(Vector3(0.1f, 0.1f, 0.1f))
		bodyDef = BodyDef()
		bodyDef.Position = Vec2(0, 0)
		body = world.CreateBodyFromShape(bodyDef, box.CreatePhysicalRepresentation(), 0.3f, 0.3f, 0.1f)
		/*body.GetShapeList().FilterData.CategoryBits = cast(ushort, CollisionGroups.Projectiles)
		body.GetShapeList().FilterData.MaskBits = cast(ushort, CollisionGroups.Player | CollisionGroups.Background)*/

		if BulletHitSound == null:
			BulletHitSound = Core.Sound.Buffer("../Data/Sound/Weapons/hgrenb1a.wav")
			Source = Core.Sound.Source(BulletHitSound)
		
		super(box, body)	
	
	public override def Tick(dt as single):
		ExplosionTimer -= dt
		if ExplosionTimer < 0f:
			r = System.Random()
			particles = Game.Instance.Particles
			for i in range(10):
				randomDir = Vector3(r.NextDouble() - 0.5f, r.NextDouble() - 0.5f, r.NextDouble() - 0.5f) * 10.0f
				particles.Add(Vector3(Position.X, Position.Y, 0.0f), randomDir, Vector4(1.0f, 0.0f, 0.0f, 1.0f))
			Destroy()
			
	public override def Render():
		t = 2f * System.Math.Log(ExplosionTimer)
		if t - System.Math.Floor(t) < 0.5f:
			GL.Color4(System.Drawing.Color.Red)
		else:
			GL.Color4(System.Drawing.Color.White)
		super.Render()
		
	public override def Collide(other as GameObject, c as ContactResult):
		print c.NormalImpulse
		return if c.NormalImpulse < 0.01f
		Source.Position = Position
		Source.Velocity = Body.GetLinearVelocity().AsVector3(Position.Z)
		Source.Play()