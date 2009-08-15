namespace Core.Math

import OpenTK.Math

struct Sphere:
	Center as Vector3
	Radius as single
	
	def constructor(center as Vector3, radius as single):
		self.Center = center
		self.Radius = radius
