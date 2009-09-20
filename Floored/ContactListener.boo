namespace Floored

import System
import Box2DX.Collision
import Box2DX.Dynamics

class ContactInfo:
	pass

class SensorInformation:
"""Used as UserData for sensors to collect information about their state"""
	public Contacts = List[of Shape]()
	public __LastContact = 0.0f

class ContactListener(Box2DX.Dynamics.ContactListener):
"""Description of ContactListener"""
	public def constructor():
		pass

	public override def Add(point as ContactPoint):
		if point.Shape1.IsSensor:
			si = point.Shape1.UserData as SensorInformation
			si.Contacts.Add(point.Shape2)
			si.__LastContact = 0.0f
		if point.Shape2.IsSensor:
			si = point.Shape2.UserData as SensorInformation
			si.Contacts.Add(point.Shape1)		
			si.__LastContact = 0.0f
		
	public override def Remove(point as ContactPoint):
		if point.Shape1.IsSensor:
			si = point.Shape1.UserData as SensorInformation
			si.Contacts.Remove(point.Shape2)
		if point.Shape2.IsSensor:
			si = point.Shape2.UserData as SensorInformation
			si.Contacts.Remove(point.Shape1)		

	public override def Result(point as ContactResult):
		o1 as GameObject = point.Shape1.GetBody().GetUserData()
		o2 as GameObject = point.Shape2.GetBody().GetUserData()
		
		/*if point.Shape1.IsSensor or point.Shape2.IsSensor:
			print "IS SENSOR"*/
		
		if o1 != null and o1.ReportCollisions:
			o1.Collide(o2, point)
		if o2 != null and o2.ReportCollisions:
			o2.Collide(o1, point)
		
		
		