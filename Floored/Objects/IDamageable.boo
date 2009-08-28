namespace Floored.Objects

import Floored

interface IDamageable:
"""Must be implemented by objects that can be destroyed or react to being damaged in any way"""
	def Damage(amount as single, inflictedBy as GameObject)

