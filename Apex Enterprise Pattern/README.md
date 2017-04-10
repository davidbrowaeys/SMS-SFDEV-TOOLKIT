![alt text](http://www.smsmt.com/hs-fs/hubfs/SMS_Logo-1.png?t=1490163156935&width=300&name=SMS_Logo-1.png "SMS Management & Technology")

# Apex Enterprise Pattern #
This is providing a further, but more granular, level of code encapsulation and reuse within your application, such as complex validation, defaulting and other logic relating to complex calculation and manipulation. This code aims to provide guidelines as to how you can clearly associate Domain layer code to each of your Custom Objects. Enabling you to further manage effective layering and separation of concerns within your application code base and the benefits that brings. The code below is an example of how to use this domain layer with the contact object. 
```java
public with sharing class ContactTriggerHandler extends SObjectHandler{

	public ContactTriggerHandler() {
		super();   
	}

	public override void onBeforeInsert(){
		//add code here, ideally this will call the contact service layer
	}
}
```
The trigger code should be as simple as calling the domain layer for the Contact layer. 
```java
trigger ContactTrigger on Case (before insert) {
	ContactTriggerHandler handler = new ContactTriggerHandler();
}
```

A log system has also been implemented in the domain layer to handle exceptions within trigger. At the end of the operation for the running domain class, the trigger will insert the log. 
```java
Database.SaveResult[] results = Database.update(contactToUpdate,false);
SystemLogger log = new SystemLogger('ContactService','Contact','upgradeContact');
log.addDatabaseSaveResult(results, 'Contact', contactToUpdate);
```

[Click here](https://github.com/davidbrowaeys/SMS-SFDEV-TOOLKIT/tree/master/Apex%20Enterprise%20Pattern)


