/**
* @author: davidbrowaeys[SMS]
* @description: This class allow to mass update records
* @usage: Database.executeBatch(new SystemMassUpdateRecordsBatch('SELECT Id, MyField__c FROM Account', new Map<String,Object>{'MyField__c','MyValue'}));
*/
global class SystemMassUpdateRecordsBatch implements Database.Batchable<sObject> {

	String query;
	Map<String, Object> fieldValues;

	/**
	 * @description Batch Constructor
	 * @param query 	sql query for the mass update
	 * @param fieldValues	map of field to update with the respective values
	 */
	global SystemMassUpdateRecordsBatch(String query, Map<String, Object> fieldValues) {
		this.query = query;
		this.fieldValues = fieldValues;
	}
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	/**
	 * @description Execure batch which loops over each sObject returned in previous query,
	 * then loops over each field returned, and finally places the corresponding value inside the previous Map to each the corresponding field.
	 */
   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		for(sObject obj : scope){
   			for(String fieldName : fieldValues.keySet()){
   				obj.put(fieldName, fieldValues.get(fieldName));
   			}
   		}

   		if(!Test.isRunningTest()) update scope;
	}
	
	global void finish(Database.BatchableContext BC) {}
}