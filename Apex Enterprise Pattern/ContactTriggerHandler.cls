/**
* @author davidbrowaeys[SMS]
* @description 
*/
public with sharing class ContactTriggerHandler extends SObjectHandler{

    public ContactTriggerHandler() {
        super();   
    }
    /**
     * @description Apply defaults to the records, this is always executed before insert
     */
    public override void onApplyDefaults(){
        for (Contact c :(Contact[]) records) {
            if (c.RecordtypeId == objectRecordtypes.get('Student').getRecordTypeId() && String.isBlank(c.Email) == true){
                c.Email = 'undefined@undefined.com';
            }
        }
    }
    /**
     * @description Validate records, this is always executed after insert & after update
     */
    public override void onValidate(){
        for (Contact c :(Contact[]) records) {
            if (c.AccountId == null){
                c.addError(Label.ContactWithoutAccount);
            }
        }
    }
    /**
    * @description This method trigger on before insert
    */
    public override void onBeforeInsert(){
        ContactService.createStudentMemberCards((Contact[]) records);
    }
    /**
     * This method trigger on before update
     * @param  oldMap map of old records
     */
    public override void onBeforeUpdate(Map<Id,SObject> oldMap){
        ContactService.upgradeContacts((Contact[]) records);
    }
}