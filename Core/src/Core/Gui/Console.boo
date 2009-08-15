namespace Core.Gui

import Core.Script

class Console(Widget):
	[Getter(ScriptEnvironment)]
	_scriptEnvironment as ScriptEnvironment
	
	def constructor(scriptEnvironment as ScriptEnvironment):
		_scriptEnvironment = scriptEnvironment
		
