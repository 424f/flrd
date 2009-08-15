namespace Game.Gui

import System
import Core.Gui
import Core.Math
import OpenTK.Math
import Game.Objects

class PlayerImage(Image):
"""
Widget that displays a player's icon and, in debug mode, allows you to perform certain operations on them
"""
	_clicked = false
	_inst as Character

	def constructor(inst as Character, Position as Rect):
		super(inst.Skin.Icon, Position)
		_inst = inst

	override def OnClick():
		if _inst.Health > 0:
			self.Color = Vector4(1, 0, 0, 1)			
			_inst.Kill()
		else:
			self.Color = Vector4(1, 1, 1, 1)
			_inst.Revive()
