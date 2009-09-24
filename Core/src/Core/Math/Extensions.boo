namespace Core.Math

import OpenTK.Math

class Ext:
	[Boo.Lang.ExtensionAttribute]
	static def IsEmpty(val as object) as bool:
		if val isa System.Collections.ICollection:
			return cast(System.Collections.ICollection,val).Count == 0
		return true
		