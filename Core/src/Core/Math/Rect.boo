namespace Core.Math

import OpenTK

struct Rect:
	Left as single
	Top as single
	Width as single
	Height as single
	
	Right as single:
		get: return Left + Width
	Bottom as single:
		get: return Top + Height
		
	def constructor(left as single, top as single, width as single, height as single):
		self.Left = left
		self.Top = top
		self.Width = width
		self.Height = height
		
	def Overlaps(other as Rect):
		if other.Left > self.Right: return false
		if other.Right < self.Left: return false
		if other.Bottom > self.Top: return false
		if other.Top < self.Bottom: return false
		return true
		
	def Contains(pos as Vector2):
		return pos.X > self.Left and pos.X <= self.Right and pos.Y > self.Top and pos.Y <= self.Bottom
		
	def ToString() as string:
		return "(${Left}, ${Top}, ${Right}, ${Bottom})"
