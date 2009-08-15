namespace Game.Objects

import System
import Core
import Core.Common
import Core.Sound
import Tao.OpenGl.Gl
import Game

class MachineGun(AbstractWeapon):
	_model as Graphics.Md3.Model
	_fireSound as Source
	_shellSound as Source
	_clickSound = Core.Sound.Source(Common.ResourceManager.LoadSound("data/sound/weapon/click.wav"))
	_hitSound = Core.Sound.Source(Common.ResourceManager.LoadSound("data/sound/weapon/bullet_hit.wav"))
	_missSound = Core.Sound.Source(Common.ResourceManager.LoadSound("data/sound/weapon/bullet_miss.wav"))

	rKey = Input.Input.Keyboard
	_lastFired = 0
	
	_muzzle as Graphics.IRenderable

	def constructor():
		ammo = 0
		MagSize = 30
		AmmoInGun = 30
		_model = Common.ResourceManager.LoadMD3Model("data/models/weapons/machinegun/machinegun.Md3")
		_fireSound = Core.Sound.Source(Common.ResourceManager.LoadSound("data/sound/weapon/silenced.wav"))
		_shellSound = Core.Sound.Source(Common.ResourceManager.LoadSound("data/sound/weapon/shell.wav"))
		_muzzle = Graphics.Wavefront.Model.Load("data/models/fallout/muzzle.obj")
		
	override def Render():
		_model.Render()
		if self.IsFiring and (Game.Instance.Ticks & 64) < 32:
			_model.BeginTag("tag_flash", 0)
			glScalef(0.5, 0.5, 0.5)
			glEnable(GL_BLEND)
			glBlendFunc(GL_ONE, GL_ONE)
			_muzzle.Render()
			glDisable(GL_BLEND)
			_model.EndTag()
		
	def Firing():
		if (_lastFired == 0 or _lastFired + 150 <= Game.Instance.Ticks):
			if AmmoInGun > 0:
				AmmoInGun -= 1
				
				# Play according sounds
				_fireSound.Position = Carrier.Position + Carrier.LookDirection 
				_fireSound.Velocity = Carrier.LookDirection * 1000
				_fireSound.Stop()
				_fireSound.Play()
				
				#_shellSound.Position = carrier.Position
				#_shellSound.stop()
				#_shellSound.play()
				
				# Find target
				if _carrier is not null:
					target = Game.Instance.RayIntersect(Carrier.Position, Carrier.LookDirection, [Carrier], {obj as GameObject | obj isa Character and obj.Health > 0})
					if target is not null:
						print "TARGET: ${target}: ${target.Name}"						
						(target as Character).Damage(Carrier, 15)
						_hitSound.Stop()
						_hitSound.Position = Carrier.Position + Carrier.LookDirection
						_hitSound.Play()
						g = Game.Instance
						def Randvec():
							result = OpenTK.Math.Vector3((g.Random.NextDouble() - 0.5), (g.Random.NextDouble() - 0.5), (g.Random.NextDouble() - 0.5))
							return result
							
						for i in range(3):
							pos = target.Position + Randvec()*20.0f
							vel = Randvec()*40.0f + Carrier.LookDirection*50.0f + OpenTK.Math.Vector3(0, 20, 0)
							Game.Instance.Particles.Add(pos, vel, OpenTK.Math.Vector4(1, 0, 0, 1))
					else:
						_missSound.Stop()
						_missSound.Position = Carrier.Position + Carrier.LookDirection
						_missSound.Play()
				
				# Reset counter
				_lastFired = Game.Instance.Ticks
				
			else:
				_clickSound.Position = Carrier.Position
				_clickSound.Stop()
				_clickSound.Play()
				_isFiring = false
				
				# Reset counter
				_lastFired = Game.Instance.Ticks + 1000				

	def Tick():
		pass
