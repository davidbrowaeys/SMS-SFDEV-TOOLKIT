/**
* @author davidbrowaeys[SMS]
* @description Base class aiding in the implementation of a Domain Model around SObject collections
 * 
 * Domain (software engineering). “a set of common requirements, terminology, and functionality 
 * for any software program constructed to solve a problem in that field”,
 * http://en.wikipedia.org/wiki/Domain_(software_engineering)
 *
 * Domain Model, “An object model of the domain that incorporates both behavior and data.”, 
 * “At its worst business logic can be very complex. Rules and logic describe many different "
 * "cases and slants of behavior, and it's this complexity that objects were designed to work with...” 
 * Martin Fowler, EAA Patterns
 * http://martinfowler.com/eaaCatalog/domainModel.html
 * @usage:  public with sharing class ContactTriggerHandler extends SObjectHandler{
 *
 *              public ContactTriggerHandler() {
 *                  super();   
 *              }
 *
 *              public override void onBeforeInsert(){
 *              }
 *          }
 **/
public virtual with sharing class SObjectHandler 
{
    /**
     * Provides access to the data represented by this domain class
     **/
    public SObject[] records { get; private set;}
    /**
     * Derived from the records provided during construction, provides the native describe for the standard or custom object
     **/
    public Schema.DescribeSObjectResult objectDescribe {get; private set;}
    /**
     * Returns the SObjectType this Domain class represents
     **/
    public SObjectType objectType {get; private set;}
    /**
     * Returns the record type represented by this domain class
     **/
    public Map <String, Schema.RecordTypeInfo> objectRecordtypes {get; private set;}
    /**
    * Return the System log represented by this domain class
    **/
    public SystemLogger log {get; set;}
    /**
     * Constructs the domain class with the data on which to apply the behaviour implemented within the sObject including Record Type
     *
     **/
    public SObjectHandler()
    {
        records = Trigger.isDelete == false ? Trigger.new.clone() : Trigger.old.clone(); 
        
        objectType = records.getSObjectType();

        objectDescribe = objectType.getDescribe();

        objectRecordtypes = objectDescribe.getRecordTypeInfosByName();

        log = new SystemLogger(objectType+'Trigger');
        
        triggerHandler();

        log.insert();
    }
    /**
     * Calls the applicable override methods such as beforeInsert, beforeUpdate etc. based on a Trigger context
     **/
    private void triggerHandler()
    {   
        // Invoke the applicable handler
        if(Trigger.isBefore == true)
        {
            if(Trigger.isInsert == true)        handleBeforeInsert();
            else if(Trigger.isUpdate == true)   handleBeforeUpdate(Trigger.oldMap);
            else if(Trigger.isDelete == true)   handleBeforeDelete(Trigger.old);
        }
        else
        {
            if(Trigger.isInsert == true)        handleAfterInsert();
            else if(Trigger.isUpdate == true)   handleAfterUpdate(Trigger.oldMap);
            else if(Trigger.isDelete == true)   handleAfterDelete(Trigger.old);
            else if(Trigger.isUndelete == true) handleAfterUndelete();
        }               
    }
    /**
     * Base handler for the Apex Trigger event Before Insert, calls the onApplyDefaults method, followed by onBeforeInsert
     **/
    public virtual void handleBeforeInsert() 
    { 
        onApplyDefaults(); 
        onBeforeInsert();
    }
    /**
     * Base handler for the Apex Trigger event Before Update, calls the onBeforeUpdate method
     **/
    public virtual void handleBeforeUpdate(Map<Id,SObject> oldMap) 
    {
        onBeforeUpdate(oldMap);
    }
    
    /**
     * Base handler for the Apex Trigger event Before Delete, calls the onBeforeDelete method
     **/
    public virtual void handleBeforeDelete(SObject[] old) 
    {
        onBeforeDelete(old);
    }
    /**
     * Base handler for the Apex Trigger event After Insert, calls the onValidate and onAfterInsert methods
     **/
    public virtual void handleAfterInsert()
    {
        onValidate();
        onAfterInsert(); 
    }
    /**
     * Base handler for the Apex Trigger event After Update, checks object security and calls the onValidate, onValidate(Map<Id,SObject>) and onAfterUpdate methods
     **/
    public virtual void handleAfterUpdate(Map<Id,SObject> oldMap) 
    {    
        onValidate(oldMap);
        onAfterUpdate(oldMap); 
    }
    /**
     * Base handler for the Apex Trigger event After Delete, checks object security and calls the onAfterDelete method
     **/
    public virtual void handleAfterDelete(SObject[] old) 
    {
        onAfterDelete(old);
    }
    /**
     * Base handler for the Apex Trigger event After Undelete, checks object security and calls the onAfterUndelete method
     **/
    public virtual void handleAfterUndelete() 
    {
        onAfterUndelete();
    }   
    /**
     * Override this to apply defaults to the records, this is called by the handleBeforeInsert method
     **/

    public virtual void onApplyDefaults() { }
    /**
     * Override this to apply general validation to be performed during insert or update, called by the handleAfterInsert and handleAfterUpdate methods
     **/
    public virtual void onValidate() {  }
    
    /**
     * Override this to apply validation to be performed during update, called by the handleAfterUpdate method
     **/
    public virtual void onValidate(Map<Id,SObject> oldMap)  { }
    /**
     * Override this to perform processing during the before insert phase, this is called by the handleBeforeInsert method
     **/
    public virtual void onBeforeInsert() { }
    
    /**
     * Override this to perform processing during the before update phase, this is called by the handleBeforeUpdate method
     **/
    public virtual void onBeforeUpdate(Map<Id,SObject> oldMap) { }
    
    /**
     * Override this to perform processing during the before delete phase, this is called by the handleBeforeDelete method
     **/
    public virtual void onBeforeDelete(SObject[] old) { }
    
    /**
     * Override this to perform processing during the after insert phase, this is called by the handleAfterInsert method
     **/
    public virtual void onAfterInsert() { }
    
    /**
     * Override this to perform processing during the after update phase, this is called by the handleAfterUpdate method
     **/    
    public virtual void onAfterUpdate(Map<Id,SObject> oldMap) { }
    
    /**
     * Override this to perform processing during the after delete phase, this is called by the handleAfterDelete method
     **/    
    public virtual void onAfterDelete(SObject[] old) { }    
    
    /**
     * Override this to perform processing during the after undelete phase, this is called by the handleAfterDelete method
     **/    
    public virtual void onAfterUndelete() { }   
}