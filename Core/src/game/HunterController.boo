namespace Game

import System
import Core.Common
import Core.Input
import Game.Objects

class HunterController(Controller):
"""A pseudo-controller that follows another GameObject"""
	_obj as Character
	"""The object we're controlling"""
	
	_target as Character
	"""The object we're following"""

	_lXAxis = DummyValue()
	_lYAxis = DummyValue()
	_rXAxis = DummyValue()
	_rYAxis = DummyValue()
	_fireButton = DummyValue()
	_punchButton = DummyValue()
	_reloadButton = DummyValue()

	def constructor(obj as Character, target as Character):
		_obj = obj
		_target = target

		self.Bind(_lXAxis, "l_x")
		self.Bind(_lYAxis, "l_y")
		self.Bind(_rXAxis, "r_x")
		self.Bind(_rYAxis, "r_y")
		self.Bind(_fireButton, "fire")
		self.Bind(_reloadButton, "reload")
		self.Bind(_punchButton, "punch")
		
		absoluteMode = true
		
		# [TODO] move "AI" into separate class
		obj.OnDamage += DamageHandler

	def DamageHandler(o as object, e as DamageEvent):
		if e.source isa Character:
			self._target = e.source
		else:
			pass

	def Tick():
		# Invalid target?
		if _target is null or _target.Health <= 0 or _target == _obj:
			_target = Game.Instance.Objects.Find(
				{o as GameObject | o isa Character and
				                   o != _obj and
				                   o.Health > 0 and
				                   _obj.Faction.Relations.ContainsKey((o as Character).Faction) and
				                   _obj.Faction.Relations[(o as Character).Faction] == Relation.Hostile})
			return
			
		diff = _target.Position - _obj.Position
		_rXAxis.Value = diff.X
		_rYAxis.Value = diff.Z

		# We might need to reload
		if _obj.Weapon is not null and  _obj.Weapon.AmmoInGun == 0:
			self._reloadButton.Fired = true
		# We still have some bullets left
		else:
			self._reloadButton.Fired = false
			if self._fireButton.Fired:
				self._fireButton.Value = 1.0
				if Game.Instance.Random.NextDouble() > 0.9:
					self._fireButton.Fired = false
					self._fireButton.Value = 0.0
			else:
				if diff.Length < 225.0f and Game.Instance.Random.NextDouble() > 0.990:
					self._fireButton.Fired = true
					self._fireButton.Value = 1.0
				else:
					self._fireButton.Fired = false
		
		if (diff.Length > 225.0f or (diff.Length > 220.0f and _lXAxis.Value > 0)):
			diff.Normalize()
			diff *= 200.5f
			_lXAxis.Value = diff.X
			_lYAxis.Value = diff.Z
		else:
			_lXAxis.Value = 0
			_lYAxis.Value = 0
