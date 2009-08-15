namespace Game

import System
import System.Collections.Generic

enum Relation:
	Friendly
	Neutral
	Hostile

class Faction:
"""Description of Faction"""

	private static factions = Dictionary[of string, Faction]()
	"""The factions already created"""

	public static def Instance(name as string):
	"""Gets an existing faction or creates it, if it doesn't yet exist"""
		if not factions.ContainsKey(name):
			factions[name] = Faction(name)
		return factions[name]

	[Getter(Name)] _name as string
	[Getter(Relations)] _relations = Dictionary[of Faction, Relation]()
		
	private def constructor(name as string):
		_name = name
		
	public def SetRelation(target as Faction, relation as Relation):
		Relations[target] = relation
