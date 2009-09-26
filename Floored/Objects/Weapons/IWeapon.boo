namespace Floored.Objects.Weapons

import Floored
import Floored.Objects
import Core.Graphics
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
	FireInterval = 2f
	LastFired = FireInterval
	
	public def constructor():
		Model = Md3.Model("../Data/Models/Weapons/machinegun/machinegun.md3")
		EnableRendering = false
		
	public def PrimaryFire():
		if LastFired >= FireInterval:
			world = Game.Instance.World
			bullet = Bullet(world)
			look = Carrier.LookDirection
			look2 = Box2DX.Common.Vec2(look.X, look.Y) 
			bullet.Position = Carrier.Position + Vector3(look.X, look.Y, 0)
			bullet.Body.SetLinearVelocity(look2 * 100f)
			world.Add(bullet)
			LastFired = 0f
		
	public def SecondaryFire():
		pass
		
	public def Tick(dt as single):
		LastFired += dt
		