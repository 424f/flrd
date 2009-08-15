namespace Game.Objects

import System
import Core.Common
import Game

abstract class AbstractWeapon(GameObject):
	[Property(Carrier)] _carrier as Character
	[Getter(IsFiring)] _isFiring = false
	
	[Property(AmmoInGun)] _AmmoInGun as int
	"""Amount of ammo left in the gun"""
	
	[Property(MagSize)] _MagSize as int
	"""Amount of ammo a magazine for this particular gun can hold"""
	
	[Property(Ammo)] _ammo as int
	
	virtual def StartFiring():
		_isFiring = true

	virtual def Firing():
		pass
	
	virtual def EndFiring():
		_isFiring = false
		
	virtual def Reload():
		currentAmmoInGun = AmmoInGun
		toFill = MagSize - currentAmmoInGun	
		if Ammo >= toFill:
			AmmoInGun = currentAmmoInGun + toFill
			Ammo = Ammo - toFill
		else: // ammo < toFill
			AmmoInGun = currentAmmoInGun + Ammo
			Ammo = 0

	virtual def Collect(target as GameObject):
		if target isa Character:
			w = (target as Character).Weapons.Find({w as AbstractWeapon | w.GetType() == self.GetType()})
			if w is not null:
				print 'Refilling old weapon'
				w.Ammo += Ammo + AmmoInGun
				Game.Instance.Objects.Remove(self)
			else:
				print "Adding new weapon != ${self.GetType()}"
				c = target as Character
				c.Weapons.Add(self)
				if c.Weapon is null:
					c.Weapon = self
			
			
