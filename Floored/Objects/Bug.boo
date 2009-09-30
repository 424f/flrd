namespace Floored.Objects

import Floored
import Core.Graphics
import OpenTK
import Box2DX.Common
import Box2DX.Collision
import Box2DX.Dynamics

class Bug(Player):
"""A stupid monster that attacks players who come to close"""
		
	Hunt = false
	AttackDelay = 1.0f
	LastAttack = AttackDelay

	public def constructor():
		model = Md3.CharacterModel.Load("../Data/Models/Players/bug/")
		super(model.Skins["default"])
		Sounds = SoundCollection.Load("../Data/Sound/Players/bug/")
		
	public override def Tick(dt as single):
		if Health > 0f:
			// Compute primitive AI
			player = Game.Instance.Player
			diff = player.Position - Position
			if diff.Length < 5f:
				Hunt = true
			
			LastAttack += dt
			
			if player.Health < 0f:
				Hunt = false
			
			if Hunt:
				if diff.Length > 0.5f and LastAttack >= AttackDelay:
					WalkDirection = Vector2(diff.X, diff.Y)
					LookDirection = WalkDirection
				else:
					WalkDirection = Vector2.Zero
					if LastAttack >= AttackDelay:
						Character.UpperAnimation = Character.Model.GetAnimation(Md3.AnimationId.TORSO_ATTACK_2)
						player.Damage(10f, self)
						phy = Game.Instance.World.Physics
						diff.Normalize()
						player.Body.ApplyImpulse(Vec2(diff.X, diff.Y)*10f*Body.GetMass(), Vec2.Zero)
						LastAttack = 0f
		
		// Perform timestep
		super(dt)				

	public def Damage(amount as single, inflictedBy as GameObject):
		Hunt = true
		super(amount, inflictedBy) 