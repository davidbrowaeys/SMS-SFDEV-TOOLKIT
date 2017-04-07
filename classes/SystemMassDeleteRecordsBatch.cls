/**
* @author: davidbrowaeys[SMS]
* @description: Generic class to mass delete and empty records from the recycle bin
* @usage: Database.executeBatch(new SystemMassUpdateRecordsBatch('SELECT Id FROM MyObject__c, true));
*/
global class SystemMassDeleteRecordsBatch implements Database.Batchable<sObject>{
	
	String query;
	Boolean emptyFromRecycleBin ;
	/**
	 * @description Batch Constructor
	 * @param query 	sql query for the mass delete
	 * @param empty		option to empty recyclebin
	 */
	global SystemMassDeleteRecordsBatch(String q, Boolean empty) {
		this.query = q;
		this.emptyFromRecycleBin = empty;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		delete scope;
		if (emptyFromRecycleBin == true) DataBase.emptyRecycleBin(scope);
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('EOB >> '+query);
	}
}