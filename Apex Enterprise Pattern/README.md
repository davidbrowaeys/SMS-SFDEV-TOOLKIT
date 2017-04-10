<div style="text-align:right;top: 10px;position: absolute;right: 10px;" markdown="1">
	<img align="right" src="http://www.smsmt.com/hs-fs/hubfs/SMS_Logo-1.png?t=1490163156935&amp;width=300&amp;name=SMS_Logo-1.png"/>
</div>

# Apex Enterprise Pattern #
This is providing a further, but more granular, level of code encapsulation and reuse within your application, such as complex validation, defaulting and other logic relating to complex calculation and manipulation. This code aims to provide guidelines as to how you can clearly associate Domain layer code to each of your Custom Objects. Enabling you to further manage effective layering and separation of concerns within your application code base and the benefits that brings. The parent layer is defined in the [SObjectHandler](https://github.com/davidbrowaeys/SMS-SFDEV-TOOLKIT/blob/master/Apex%20Enterprise%20Pattern/SObjectHandler.cls) class and contains the main logic of the trigger operations. The code below is an example of how to use this domain layer with the contact object. 
```java
public with sharing class ContactTriggerHandler extends SObjectHandler{

	public ContactTriggerHandler() {
		super();   
	}

	public override void onBeforeInsert(){
		//add code here, ideally this will call the contact service layer
		ContactService.createStudentMemberCards((Contact[]) records);
	}
	public override void onBeforeUpdate(Map <Id,SObject> oldMap) 
		//add code here, ideally this will call the contact service layer
		ContactService.upgradeContacts((Contact[]) records);
	}
}
```
The trigger code should be as simple as calling the domain layer for the Contact layer. 
```java
trigger ContactTrigger on Case (before insert) {
	ContactTriggerHandler handler = new ContactTriggerHandler();
}
```

A Service Layer will help you form a clear and strict encapsulation of code implementing business tasks, calculations and processes. All method in the service layer should be static and can be call from any sources (Batch, Javascript Remoting, Apex Rest, Visualforce Controller, ...). 

A log system has also been implemented in the domain layer to handle exceptions within trigger. At the end of the operation for the running domain class, the trigger will insert the log. 
```java
Database.SaveResult[] results = Database.update(contactToUpdate,false);
SystemLogger log = new SystemLogger('ContactService','Contact','upgradeContact');
log.addDatabaseSaveResult(results, 'Contact', contactToUpdate);
```


