namespace Floored.Objects.Weapons

import Floored
import Floored.Objects
import Core.Graphics

interface IWeapon(IRenderable):	
	def PrimaryFire()
	"""Called when a player presses the primary fire button"""
	def SecondaryFire()
	"""Called when a player presses the secondary fire button"""
	Carrier as Player:
	"""The player that is carrying this weapon, if any"""		
		get
		set

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
	public def constructor():
		Model = Md3.Model("../Data/Models/Weapons/machinegun/machinegun.md3")
		EnableRendering = false
		
	public def PrimaryFire():
		pass
		
	public def SecondaryFire():
		pass