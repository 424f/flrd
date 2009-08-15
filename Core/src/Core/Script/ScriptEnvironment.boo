namespace Core.Script

import Boo.Lang.Compiler
import Boo.Lang.Compiler.IO
import Boo.Lang.Compiler.Pipelines

class ScriptEnvironment:
	def constructor():
		pass
		
	def Run(script as string):
		compiler = BooCompiler()
		compiler.Parameters.Input.Add(StringInput("<stdin>", script))
		compiler.Parameters.Pipeline = CompileToMemory()
		result = compiler.Run()
		
		if result.Errors.Count > 0:
			for error in result.Errors:
				print "***ERROR***", error
			return
		
		result.GeneratedAssembly.EntryPoint.Invoke(null, array(object, 1))
		#var as duck = result.GeneratedAssembly.GetType("Module")
		#print '..'
		#print var.run()
