namespace Game.Objects

//import Boo.Lang.Useful.Attributes
import System
import System.Collections.Generic
import Core.Common
import Core.Graphics
import OpenTK.Math
import Core.Input
import Game.Sound

class DamageEvent(EventArgs):
	public source as GameObject
	public amount as int
	
	def constructor(source as GameObject, amount as int):
		self.source = source
		self.amount = amount

class Character(GameObject):
	Skin:
		set:
			_skin = value
			_instance = Skin.GetInstance()
			_instance.LowerAnimation = Skin.Model.GetAnimation(Md3.AnimationId.LEGS_IDLE)
			_instance.UpperAnimation = Skin.Model.GetAnimation(Md3.AnimationId.TORSO_GESTURE)
		get:
			return _skin
	_skin as Md3.CharacterSkin
	
	[Getter(Instance)] _instance as Md3.CharacterInstance
	
	enum State:
		IDLE
		WALKING
		WALKING_BACK
		RUNNING
		DEAD
	
	_state as State
	
	Name as string:
		override get:
			return Skin.Name
	
	Health:
		override set:
			_health = value
		override get:
			return _health
	_health = 0
	
	Weapon:
		get: return _weapon
		set:
			_weapon = value
			if value is null:
				return
			if not Weapons.Contains(value):
				Weapons.Add(value)
			_weapon.Carrier = self
	_weapon as AbstractWeapon
	"""The active weapon"""
	
	public Faction = Game.Faction.Instance("No faction")
	[Property(Weapons)] _weapons = List[of AbstractWeapon]()
	
	LookDirection:
		get: return Instance.LookDirection
	WalkDirection:
		get: return Instance.WalkDirection
	
	#line = Vector3(0, 1, 0)
	
	#region Sounds
	_hurtSounds = ( Core.Sound.Source(ResourceManager.LoadSound("data/sound/player/sergei/Pain25_1.Wav")),
					Core.Sound.Source(ResourceManager.LoadSound("data/sound/player/sergei/Pain50_1.Wav")),
					Core.Sound.Source(ResourceManager.LoadSound("data/sound/player/sergei/Pain75_1.Wav")),
					Core.Sound.Source(ResourceManager.LoadSound("data/sound/player/sergei/Pain100_1.Wav")))
	_deathSound = Core.Sound.Source(ResourceManager.LoadSound("data/sound/player/sergei/death1.Wav"))
	_footSound = Core.Sound.Source(ResourceManager.LoadSound("data/sound/footsteps/wood.Wav"))
	_punchSound = Core.Sound.Source(ResourceManager.LoadSound("data/sound/weapon/punch.wav"))
	_punchHitSound = Core.Sound.Source(ResourceManager.LoadSound("data/sound/weapon/punch_hit.wav"))
	_collectSound = Core.Sound.Source(ResourceManager.LoadSound("data/sound/collect.wav"))
	_reloadSound = Core.Sound.Source(ResourceManager.LoadSound("data/sound/weapon/reload.wav"))
	_soundSet = Game.Sound.SoundSet("data/sound/speech/set/female")
	
	#endregion
	
	_distance = 0.0f

	_controller as Game.Controller = Game.Controller()
	_fireButton as AbstractValue = DummyValue()
	_reloadButton as AbstractValue = DummyValue()
	_punchButton as AbstractValue = DummyValue()
	_l_x_axis as AbstractValue = DummyValue()
	_l_y_axis as AbstractValue = DummyValue()
	_r_x_axis as AbstractValue = DummyValue()
	_r_y_axis as AbstractValue = DummyValue()
	
	def constructor():
		_state = State.IDLE
		self.Weapon = MachineGun()
		self.Health = 100
	
	def SetController(controller as Game.Controller):
		_controller = controller
		_fireButton = controller.GetBinding("fire")
		_reloadButton = controller.GetBinding("reload")
		_punchButton = controller.GetBinding("punch")
		_l_x_axis = controller.GetBinding("l_x")
		_l_y_axis = controller.GetBinding("l_y")
		_r_x_axis = controller.GetBinding("r_x")
		_r_y_axis = controller.GetBinding("r_y")
	
	def Tick():		
		_instance.Tick(Game.Game.Instance.Dt)
		if _state == State.DEAD:
			return
		THRESHOLD = 0.2f
		RUN_THRESHOLD = 0.6f

		g = Game.Game.Instance
		def Randvec():
			result = OpenTK.Math.Vector3((g.Random.NextDouble() - 0.5), (g.Random.NextDouble() - 0.5), (g.Random.NextDouble() - 0.5))
			return result
			
		# reloading
		if Weapon is not null and _reloadButton.Value > 0.0:
			_instance.UpperAnimation = _instance.Model.GetAnimation(Md3.AnimationId.TORSO_GESTURE)
			_reloadSound.Stop(); _reloadSound.Play()
			if _weapon.IsFiring:
				_weapon.EndFiring()
			_weapon.Reload()

		# Looking
		if _controller.AbsoluteMode:			
			lookDir = Vector3(_r_x_axis.Value, 0, _r_y_axis.Value)
			if lookDir.Length < THRESHOLD:
				pass #lookDir = walkDir
			lookDir.Normalize()
			_instance.LookDirection = lookDir
		else:
			if _r_x_axis.Value != 0.0:
				_instance.LookAngle += _r_x_axis.Value / 10.0f			

		# Walking
		//walkDir = Vector3(_l_x_axis.Value, 0, _l_y_axis.Value)
		if _controller.AbsoluteMode:
			walkDir = Vector3(_l_x_axis.Value, 0, _l_y_axis.Value)
		else:
			sidestep = Vector3(-_instance.LookDirection.Z, 0, _instance.LookDirection.X)
			walkDir = -_l_y_axis.Value * _instance.LookDirection + \
			          _l_x_axis.Value * sidestep
		if walkDir.Length >= THRESHOLD:
			_instance.WalkDirection = walkDir

		# Firing
		if Weapon is not null and _fireButton.Value > 0.0:
			_instance.UpperAnimation = _instance.Model.GetAnimation(Md3.AnimationId.TORSO_ATTACK)
			if not _weapon.IsFiring:
				_weapon.StartFiring()
				_soundSet.Play("greeting", Position)
			_weapon.Firing()				

		elif _punchButton.Fired:
			_instance.UpperAnimation = _instance.Model.GetAnimation(Md3.AnimationId.TORSO_ATTACK_2)
			_punchButton.Fired = false
			target = Game.Game.Instance.RayIntersect(Position, Instance.LookDirection, [self], {obj as GameObject | obj isa Character and obj.Health > 0})	
			_punchSound.Stop(); _punchSound.Play()
			if target is not null and (Vector3(target.Position) - Vector3(self.Position)).LengthFast < 30:
				(target as Character).Damage(self, 20)
				_punchHitSound.Stop(); _punchHitSound.Play()
					
				ldir = LookDirection
				ldir.NormalizeFast()
				for i in range(1):
					Game.Game.Instance.Particles.Add(target.Position + Randvec()*20.0f, Randvec()*40.0f + ldir*50.0f + OpenTK.Math.Vector3(0, 20, 0), Vector4(1, 0, 0, 1))				
	
		if Weapon is not null and _fireButton.Value == 0.0 and _weapon.IsFiring:
			_weapon.EndFiring()

		# Choose animation
		if walkDir.Length < 0.3f:
			if _state != State.IDLE:
				_state = State.IDLE
				_instance.LowerAnimation = _instance.Model.GetAnimation(Md3.AnimationId.LEGS_IDLE)
		else:			
			state = (State.WALKING if walkDir.Length < RUN_THRESHOLD else State.RUNNING)
			anim = (Md3.AnimationId.LEGS_WALK if state == State.WALKING else Md3.AnimationId.LEGS_RUN)
			if _state != state and (Math.Abs(_instance.LookAngle - _instance.WalkAngle) % 360 < 90 ):
				_state = state
				_instance.LowerAnimation = _instance.Model.GetAnimation(anim)
			elif _state != State.WALKING_BACK and (Math.Abs(_instance.LookAngle - _instance.WalkAngle) % 360 >= 90 ):
				_state = State.WALKING_BACK
				if walkDir.Length > RUN_THRESHOLD:
					walkDir.Normalize()
					walkDir *= RUN_THRESHOLD
				_instance.LowerAnimation = _instance.Model.GetAnimation(Md3.AnimationId.LEGS_BACK)

		# Move
		if walkDir.Length > 1.0f:
			walkDir.Normalize()
		if walkDir.Length >= THRESHOLD:
			velocity = walkDir * 200.0f * Game.Game.Instance.Dt
			Position += velocity
			_distance += velocity.Length
			if _distance > 60.0f:
				_distance -= 60.0f
				_footSound.Position = self.Position
				_footSound.Stop()
				_footSound.Play()
			# Anything to collect?
			weapon as Collectable = Game.Game.Instance.RayIntersect(Position - Instance.LookDirection, 2*Instance.LookDirection, [self], {obj as GameObject | obj isa Collectable})	
			if weapon is not null and (weapon.Position - Position).LengthFast <= 20.0f:
				_collectSound.Position = Position
				_collectSound.Stop(); _collectSound.Play()
				weapon.Obj.Collect(self)
				Game.Game.Instance.Objects.Remove(weapon)
			
		# Propagate
		if _state == State.WALKING_BACK:
			_instance.WalkDirection = -_instance.WalkDirection				
		_instance.WeaponModel = self.Weapon
		if self.Weapon is not null:
			self.Weapon.Carrier = self
		_instance.Position = self.Position
		
	def Render():
		_instance.Position = Position
		_instance.Render()		
		
		/*glBegin(GL_LINES)
		glVertex3f(Position.X, Position.Y + 20.0f, Position.Z)
		glVertex3f(Position.X + line.X, Position.Y + line.Y + 20.0f, Position.Z + line.Z)
		glEnd()*/
		
	override def Kill():
		_state = State.DEAD
		health = 0
		anim = Md3.AnimationId.BOTH_DEATH_1 + (Random().Next() % 3)*2
		_instance.LowerAnimation = Skin.Model.GetAnimation(anim)
		_instance.UpperAnimation = Skin.Model.GetAnimation(anim)
		_deathSound.Stop()
		_deathSound.Position = Position
		_deathSound.Play()
		
		# Place the weapon in the world
		if self.Weapon is not null:
			c = Collectable(self.Weapon)
			self.Weapon.Carrier = null
			c.Position = self.Position
			Game.Game.Instance.Objects.Add(c)
			self.Weapon = null
			self.Weapons.Clear()
			self._instance.WeaponModel = null

	override def Revive():
		_state = State.IDLE
		_instance.LowerAnimation = Skin.Model.GetAnimation(Md3.AnimationId.LEGS_IDLE)
		_instance.UpperAnimation = Skin.Model.GetAnimation(Md3.AnimationId.TORSO_STAND_2)
		health = 100
	
	def Damage(source as GameObject, amount as int):
		_health -= amount
		OnDamage(self, DamageEvent(source, amount))
		if Health <= 0:
			Kill()
		else:
			i = Random(System.DateTime.Now.Millisecond).Next() % _hurtSounds.Length
			_hurtSounds[i].Stop()
			_hurtSounds[i].Position = Position
			_hurtSounds[i].Play()
			
	# Events
	public event OnDamage as EventHandler[of DamageEvent]
