/**
* @author David Browaeys[JS]
* @date 23-Jul-18
* @description This class handle Exception log and can be use for trigger batch or anything in the code that need to handle proper errors.
* @example
*    SystemLog log = new SystemLog('ContactService','syncContactWithOCH');
*    Database.SaveResult[] results = Database.update(contactToUpdate, false);
*    log.addDBSaveResult(results, 'Contact', contactToUpdate);
*    log.insert();
*/
global with sharing class SystemLog
{
	public enum Severity {INFO, WARNING, ERROR, FATAL}

	public String functionName 			{get; set;}
	public String processName 			{get; set;}
	public String batchID  				{get; set;}
    
    public ApplicationLog__c[] log 		{get; set;}
	public Log_Event__e[] logevents 	{get; set;}

    public SystemLog(String proccessName) 
    {
		this(proccessName,null,null);
	}

	public SystemLog(String processName, String functionName) 
    {
		this(processName,functionName,null);
	}

	public SystemLog(String processName, String functionName, String batchId) 
	{
		this.log = new ApplicationLog__c[0];
		this.logevents = new Log_Event__e[0];
		this.processName = processName;
		this.functionName = functionName;
		this.batchID = batchID;
	}

	public void addMessage(String errorNo, String errorDescription, Severity errorSeverity, String stackTrace)
	{
        this.add(new ApplicationLog__c(
			Process_Name__c = processName,
	        Batch_ID__c = batchId,
	        Function_Name__c = functionName,
	        Error_No__c = errorNo,
	        Error_Description__c = errorDescription,
			StackTrace__c = stackTrace,
	        Severity__c = errorSeverity.name()));
	}

	public void addObjectMessage(String objectName, String recordId, String errorNo, String errorDescription, Severity errorSeverity, String stackTrace)
	{
        this.add(new ApplicationLog__c(
			Process_Name__c = processName,
	        Record_Id__c = recordId,
	        Object_Name__c = objectName,
	        Batch_ID__c = batchId,
	        Function_Name__c = functionName,
	        Error_No__c = errorNo,
	        Error_Description__c = errorDescription,
			StackTrace__c = stackTrace,
	        Severity__c = errorSeverity.name()));
	}

	public void addHttpMessage(String httpRequest, String httpResponse, String errorNo, String errorDescription, Severity errorSeverity, String stackTrace)
	{
        this.add(new ApplicationLog__c(
			Process_Name__c = processName,
	        Batch_ID__c = batchId,
	        Function_Name__c = functionName,
	        Error_No__c = errorNo,
	        Error_Description__c = errorDescription,
	        Request_Body__c = httpRequest,
        	Response_Body__c = httpResponse,
			StackTrace__c = stackTrace,
	        Severity__c = errorSeverity.name()));
	}

	public void addLogEvent(String httpRequest, String httpResponse, String errorNo, String errorDescription, Severity errorSeverity, String stackTrace)
	{
        this.logevents.add(new Log_Event__e(
			Process_Name__c = processName,
	        Batch_ID__c = batchId,
	        Function_Name__c = functionName,
	        Error_No__c = errorNo,
	        Error_Description__c = errorDescription,
	        Request_Body__c = httpRequest,
        	Response_Body__c = httpResponse,
			StackTrace__c = stackTrace,
	        Severity__c = errorSeverity.name()));
	}

	public void addDBSaveResult(String objectName, Database.SaveResult[] results, SObject[] records)
	{	
		for (Integer i = 0  ; i < records.size() ; i++) { 
		    if (results[i].isSuccess() == false) {
		        // Operation failed, so get all errors                
		        for(Database.Error err : results[i].getErrors()) {                    
		            String errNo = String.valueof(err.getStatusCode());
		            if (errNo.length() > 50) errNo = errNo.substring(0,50);
		            addObjectMessage(objectName, records[i].id, errNo,'id=' + records[i].id + ',Message:' +  err.getMessage() + 'Fields:' + err.getFields(), Severity.ERROR, null);
		        }
		    }
		}
	}
	/*
	* @description adds a DB upsert result
	*/ 
	public void addDBUpsertResult(String objectName, Database.UpsertResult[] results, SObject[] records)
	{
		for (Integer i = 0  ; i < records.size() ; i++) { 
		    if (results[i].isSuccess() == false) {
		        // Operation failed, so get all errors                
		        for(Database.Error err : results[i].getErrors()) {                    
		            String errNo = String.valueof(err.getStatusCode());
		            if (errNo.length() > 50) errNo = errNo.substring(0,50);
		            addObjectMessage(objectName, records[i].id, errNo,'id=' + records[i].id + ',Message:' +  err.getMessage() + 'Fields:' + err.getFields(), Severity.ERROR, null);
		        }
		    }
		}
	}
	/**
	* @description add lead conversion error
	*/
	public void addDBLeadConvertResult(String objectName, Database.LeadConvertResult result, SObject record)
	{
		if (result.isSuccess() == false) {
			// Operation failed, so get all errors                
			for(Database.Error err : result.getErrors()) {                    
				String errNo = String.valueof(err.getStatusCode());
				if (errNo.length() > 50) errNo = errNo.substring(0,50);
				addObjectMessage(objectName, record.id, errNo,'id=' + record.id + ',Message:' +  err.getMessage() + 'Fields:' + err.getFields(), Severity.ERROR, null);
			}
		}
	}

	public void addDBDeleteResult(String objectName, Database.DeleteResult[] results, SObject[] records)
	{             
		for (Integer i = 0  ; i < records.size() ; i++) {
			if (results[i].isSuccess() == false) {
				// Operation failed, so get all errors                
				for(Database.Error err : results[i].getErrors()) {                   
					String errNo = String.valueof(err.getStatusCode());
					if (errNo.length() > 50) errNo = errNo.substring(0,50);
					addObjectMessage(objectName, records[i].id, errNo,'id=' + records[i].id + ',Message:' +  err.getMessage() + 'Fields:' + err.getFields(), Severity.ERROR, null);
				}
			}
		}
	}

	public void add(ApplicationLog__c exc){
		log.add(exc);
	}

	public void insertLog(){
		if (log.isEmpty() == false) {
			insert log;	
		}	
	}

	public void insertLogEvents(){
		EventBus.publish(logevents);
	}

	public static ApplicationLog__c[] convertLogEventToApplicationLog(Log_Event__e[] records){
		Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('ApplicationLog__c').getDescribe().fields.getMap();
		ApplicationLog__c[] tmp = new ApplicationLog__c[0];
		for (Log_Event__e r : records){
			ApplicationLog__c a = new ApplicationLog__c();
			for (String f : fieldMap.keySet()){
				if (f.endsWith('__c') == true) a.put(f,r.get(f));
			}
			tmp.add(a);
		}
		return tmp;
	}
}
