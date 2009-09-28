namespace Core.Ui

import System
import System.Collections.Generic
import AwesomiumDotNet

class ConfigProperty:
	public Name as string
	public Value as JSValue
	
	public event Updated as EventHandler
	
	public def constructor(name as string, value as string):
		self(name, JSValue(value))
	
	public def constructor(name as string, value as JSValue):
		Name = name
		Value = value
		
	public def Update(value as JSValue):
		Value = value
		print Value
		Updated(self, null)

class ConfigDialog(Dialog):
	protected Properties = List[of ConfigProperty]()
	protected FinishedLoading = false
	
	public def constructor():
		super(512, 512)
		WebView.OnFinishLoading += AddProperties
		WebView.SetCallback("UpdateProperty")
		LoadUrl(IO.Path.Combine(IO.Directory.GetCurrentDirectory(), "../Data/UI/ConfigWindow.htm"))

	public override def Callback(sender as object, e as Args.CallbackEventArgs):
		if e.Name == "UpdateProperty":
			args = e.args
			name, val = args[0].ToString(), args[1]
			p = Properties.Find({ p as ConfigProperty | p.Name == name })
			if p == null:
				print "Unknown property '${name}'"
				return
			p.Update(val)
		else:
			super(sender, e)
	
	protected def AddProperties():
		FinishedLoading = true
		for property in Properties:
			DisplayProperty(property)
	
	public def AddProperty(property as ConfigProperty):
		Properties.Add(property)
		if FinishedLoading:
			DisplayProperty(property)
	
	public def DisplayProperty(property as ConfigProperty):
		type = JSValue("string")
		if property.Value.IsBoolean():
			type = JSValue("bool")
		CallJavascriptMethod("ConfigWindow_Add", (JSValue(property.Name), property.Value, type))			
		
		