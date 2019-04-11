/**
* @author davidbrowaeys[js]
* @date 01-Feb-18
* @group System
* @description Base class aiding in the implementation of a Domain Model around SObject collections
* Domain (software engineering). “a set of common requirements, terminology, and functionality 
* for any software program constructed to solve a problem in that field”,
* http://en.wikipedia.org/wiki/Domain_(software_engineering)
*
* Domain Model, “An object model of the domain that incorporates both behavior and data.”, 
* “At its worst business logic can be very complex. Rules and logic describe many different "
* "cases and slants of behavior, and it's this complexity that objects were designed to work with...” 
* Martin Fowler, EAA Patterns
* http://martinfowler.com/eaaCatalog/domainModel.html
**/
public virtual with sharing class SObjectHandler 
{
    /**
    * @description Provides access to the data represented by this domain class
    **/
    public SObject[] records { get; private set;}
    /**
    * @description Derived from the records provided during construction, provides the native describe for the standard or custom object
    **/
    public Schema.DescribeSObjectResult objectDescribe {get; private set;}
    /**
    * @description Returns the SObjectType this Domain class represents
    **/
    public SObjectType objectType {get; private set;}
    /** 
    * @description Returns the record type represented by this domain class
    **/
    public Map <String, Schema.RecordTypeInfo> objectRecordtypes {get; private set;}

    /**
    * @description Returns the new record map 
    **/ 
    public Map<Id, SObject> newMap {get; private set;}
    
    /**
    * @description Returns the old record map 
    **/ 
    public Map<Id, SObject> oldMap {get; private set;}
    
    /**
    * @description System Log for SObject Layer
    */
    public SystemLog log {get; private set;}
    /**
    * @description Constructs the domain class with the data on which to apply the behaviour implemented within the sObject including Record Type
    * @usage : 
    * public with sharing class ContactTriggerHandler extends SObjectHandler{
    *   public ContactTriggerHandler() {
    *    super();
    *   }
    *   public override void onBeforeInsert(){
    *
    *   }
    * }
    **/
    public SObjectHandler()
    {
        if(Trigger.IsUpdate || Trigger.IsInsert) {
            records = Trigger.new;
        }
        else {
            records = Trigger.old; 
        }
        
        newMap = Trigger.newMap; 
		
        oldMap = Trigger.oldMap;
        
        objectType = records.getSObjectType();

        objectDescribe = objectType.getDescribe();

        log = new SystemLog(objectDescribe.getName());

        objectRecordtypes = objectDescribe.getRecordTypeInfosByName();
        
        try{
            if(!Disable_System_Features__c.getInstance().Disable_Triggers__c) 
                execute();     
        }catch(Exception e){//handle any unexpected error
            log.addLogEvent(null,null,'UNEXPECTED_ERROR',e.getMessage(), SystemLog.Severity.ERROR, e.getStackTraceString());
            log.insertLogEvents();
            throw new SystemException(e);
        }       
    }

    /**
    * @description Calls the applicable override methods such as beforeInsert, beforeUpdate etc. based on a Trigger context
    **/
    public void execute(){ 
        if(Trigger.isBefore){
            if(Trigger.isInsert) handleBeforeInsert();
            else if(Trigger.isUpdate) handleBeforeUpdate(Trigger.oldMap);
            //else if(Trigger.isDelete) handleBeforeDelete(Trigger.old);
        }
        else{
            if(Trigger.isInsert) handleAfterInsert();
            else if(Trigger.isUpdate) handleAfterUpdate(Trigger.oldMap);
            else if(Trigger.isDelete) handleAfterDelete(Trigger.old);
        }     
    }

    /**
    * @description Base handler for the Apex Trigger event Before Insert, calls the onApplyDefaults method, followed by onBeforeInsert
    **/
    public void handleBeforeInsert(){ 
        onValidate();
        //onApplyDefaults();
        log.functionName = 'BeforeInsert';
        onBeforeInsert();
    }
    /**
    * @description Base handler for the Apex Trigger event Before Update, calls the onBeforeUpdate method
    **/
    public void handleBeforeUpdate(Map<Id,SObject> oldMap) {
        log.functionName = 'BeforeUpdate';
        onValidate();
        onBeforeUpdate(oldMap);
    }
    
    /**
    * @description Base handler for the Apex Trigger event Before Delete, calls the onBeforeDelete method
    **/
     /*
    public void handleBeforeDelete(SObject[] old) {
        log.functionName = 'BeforeDelete';
        onBeforeDelete(old);
    }*/
    /**
    * @description Base handler for the Apex Trigger event After Insert, calls the onValidate and onAfterInsert methods
    **/
    public void handleAfterInsert(){
        if(!objectDescribe.isCreateable())
           throw new SystemException('Permission to create an ' + objectDescribe.getName() + ' denied.');
        
        log.functionName = 'AfterInsert';
        onAfterInsert(); 
    }
    /**
    * @description Base handler for the Apex Trigger event After Update, checks object security and calls the onValidate, onValidate(Map<Id,SObject>) and onAfterUpdate methods
    **/     
    public void handleAfterUpdate(Map<Id,SObject> oldMap) {    
        if(!objectDescribe.isUpdateable())
           throw new SystemException('Permission to udpate an ' + objectDescribe.getName() + ' denied.');

        onValidate(oldMap);
        log.functionName = 'AfterUpdate';
        onAfterUpdate(oldMap); 
    }
    /**
     * Base handler for the Apex Trigger event After Delete, checks object security and calls the onAfterDelete method
     **/
     
    public void handleAfterDelete(SObject[] old) 
    {
        if(!objectDescribe.isDeletable())
           throw new SystemException('Permission to delete an ' + objectDescribe.getName() + ' denied.');
        log.functionName = 'AfterDelete';
        onAfterDelete(old);
    }
    /**
    * @description Override this to apply defaults to the records, this is called by the handleBeforeInsert method
    **/
    //public virtual void onApplyDefaults() { }
    /**
    * @description Override this to apply general validation to be performed during insert or update, called by the handleAfterInsert and handleAfterUpdate methods
    **/
    public virtual void onValidate() {  }
    /**
    * @description Override this to apply validation to be performed during update, called by the handleAfterUpdate method
    **/
    public virtual void onValidate(Map<Id,SObject> oldMap)  { }
    /**
    * @description Override this to perform processing during the before insert phase, this is called by the handleBeforeInsert method
    **/
    public virtual void onBeforeInsert() { 
    } 
    /**
    * @description Override this to perform processing during the before update phase, this is called by the handleBeforeUpdate method
    **/
    public virtual void onBeforeUpdate(Map<Id,SObject> oldMap) { }
    /**
    * @description Override this to perform processing during the before delete phase, this is called by the handleBeforeDelete method
    **/
    //public virtual void onBeforeDelete(SObject[] old) { }
    /**
    * @description Override this to perform processing during the after insert phase, this is called by the handleAfterInsert method
    **/
    public virtual void onAfterInsert() { }
    /**
    * @description Override this to perform processing during the after update phase, this is called by the handleAfterUpdate method
    **/    
    public virtual void onAfterUpdate(Map<Id,SObject> oldMap) { }
    /**
    * @description Override this to perform processing during the after delete phase, this is called by the handleAfterDelete method
    **/    
    public virtual void onAfterDelete(SObject[] old) { }  
}
