namespace Floored.Objects.Weapons

import Floored
import Floored.Objects
import Core.Util.Ext
import Core.Graphics
import Box2DX.Common
import OpenTK

interface IWeapon(IRenderable):	
	def PrimaryFire()
	"""Called when a player presses the primary fire button"""
	def SecondaryFire()
	"""Called when a player presses the secondary fire button"""
	Carrier as Player:
	"""The player that is carrying this weapon, if any"""		
		get
		set
	def Tick(dt as single)
	
abstract class AbstractWeapon(IWeapon, GameObject):
	Model as IRenderable

	public def constructor():
		pass

	public override def Render():
		Model.Render()

	public Carrier as Player:
		get: return _Carrier
		set: _Carrier = value
	_Carrier as Player
	
class MachineGun(AbstractWeapon):
	FireInterval = 0.2f
	LastFired = FireInterval
	static FireSource as Core.Sound.Source
	
	public def constructor():
		Model = Md3.Model("../Data/Models/Weapons/machinegun/machinegun.md3")
		EnableRendering = false
		
		if FireSource == null:
			sound = Core.Sound.Buffer("../Data/Sound/Weapons/machgf1b.wav")
			FireSource = Core.Sound.Source(sound)
		
	public def PrimaryFire():
		if LastFired >= FireInterval:
			world = Game.Instance.World
			bullet = Bullet(world)
			look = Carrier.LookDirection
			look2 = Box2DX.Common.Vec2(look.X, look.Y) 
			bullet.Position = Carrier.Position + Carrier.CalculateWeaponOffset() + 0.7f*Vector3(look.X, look.Y, 0)
			bullet.Body.SetLinearVelocity(look2*50)
			world.Add(bullet)
			LastFired = 0f
			
			FireSource.Position = bullet.Position
			FireSource.Play()
		
	public def SecondaryFire():
		if LastFired >= FireInterval:		
			world = Game.Instance.World
			o = Objects.Grenade(world)
			look = Vector3(Vector2.Normalize(Carrier.LookDirection))
			o.Body.SetXForm(((Carrier.Position) + (look * 0.7f)).AsVec2(), 0.0f)
			o.Body.ApplyImpulse(o.Body.GetMass() * look.AsVec2() * 30.0f, Vec2.Zero)
			world.Add(o)
			LastFired = 0f
		
	public def Tick(dt as single):
		LastFired += dt
		