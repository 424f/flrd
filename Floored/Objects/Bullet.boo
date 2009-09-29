namespace Floored.Objects

import Floored
import Core.Util.Ext
import OpenTK
import Box2DX.Common
import Box2DX.Dynamics

class Bullet(GameObject):
	World as World
	Destroyed = false
	static BulletHitSound as Core.Sound.Buffer
	static Source as Core.Sound.Source
	static BulletMissSource as Core.Sound.Source
	TimeToLife = 5.0f
	
	public def constructor(world as World):
		World = world
		box = Shapes.Box(Vector3(0.05f, 0.05f, 0.05f))
		bodyDef = BodyDef()
		bodyDef.Position = Vec2(0, 0)
		body = world.CreateBodyFromShape(bodyDef, box.CreatePhysicalRepresentation(), 0.3f, 0.3f, 0.1f)
		//body.SetBullet(true)
		body.GetShapeList().FilterData.CategoryBits = cast(ushort, CollisionGroups.Projectiles)
		body.GetShapeList().FilterData.MaskBits = cast(ushort, CollisionGroups.Player | CollisionGroups.Background)
		
		if BulletHitSound == null:
			BulletHitSound = Core.Sound.Buffer("../Data/Sound/Weapons/bullet_hit.wav")
			Source = Core.Sound.Source(BulletHitSound)
			
			BulletMissSound = Core.Sound.Buffer("../Data/Sound/Weapons/bullet_miss.wav")
			BulletMissSource = Core.Sound.Source(BulletMissSound)
		
		super(box, body)
		
	public override def Tick(dt as single):
		pass
		/*TimeToLife -= dt
		if TimeToLife < 0f:
			print "Destroying bullet!"
			Destroy()
			Destroyed = true*/
			
	public override def Render():
		super.Render()
		
	public override def Collide(other as GameObject, contact as ContactResult):
		return if Destroyed

		particles = Game.Instance.Particles
		
		if other isa IDamageable:
			(other as IDamageable).Damage(25f, self)
			print "HIT ${other}"
			Source.Position = Position
			Source.Play()
			particles.Add(Vector3(Position.X, Position.Y, 0.0f), Vector3.Normalize(self.Body.GetLinearVelocity().AsVector3())*5f, Vector4(1.0f, 0.0f, 0.0f, 1.0f))	
		else:
			BulletMissSource.Position = Position
			BulletMissSource.Play()
		
		for i in range(1):
			//randomDir = Vector3(r.NextDouble() - 0.5f, r.NextDouble() - 0.5f, r.NextDouble() - 0.5f) * 10.0f
			Box2DX.Dynamics.ContactResult()
			refl = contact.Normal * contact.NormalImpulse + Vec2(contact.Normal.Y, contact.Normal.X) * contact.TangentImpulse
			randomDir = Vector3(refl.X, refl.Y, 0f) //r.NextDouble() - 0.5f)
			randomDir.Normalize()
			randomDir *= 10.0f
			particles.Add(Vector3(Position.X, Position.Y, 0.0f), randomDir, Vector4(0.6, 0.3, 0.1, 1))		
		Destroy()
		Destroyed = true