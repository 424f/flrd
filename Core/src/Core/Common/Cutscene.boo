namespace Core.Common
import System
import Boo.Lang.Extensions
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Ast.Visitors

class CutSceneTimerMacro(AbstractAstMacro):
	pass

class WaitMacro(AbstractAstMacro):
	override def Expand(m as MacroStatement) as Statement:
		args = m.Arguments
		assert m.ParentNode.ParentNode.NodeType == NodeType.Method
		b as Block = m.Block
		return [|
			block:
				_actions += [($(args[0]), {$(b)})]
		|].Block	

class Scene:
"""Hohoho"""
	
	public _actions = []
	public _current
	
	[Property(Waiting)] _waiting = false
	
	player as int = 0
	
	def Script():
		wait 20s:
			print "Now 20 seconds have passed"
/*		waitUntil player == 1:
			print "Player now is one"*/
		wait 25s:
			print "Wowow, another 25 seconds"

	def Tick():
		return if waiting
		_current = _actions.Pop()
		_waiting = true
		print "Taking new from the stack.."
		for i in _current:
			print i

s = Scene()
s.script()
s.Tick(0.2)
s.Tick(0.2)
for action in s._actions:
	print action
