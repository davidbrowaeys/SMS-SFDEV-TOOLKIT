/**
 * @description This class handle Exception log and can be use for trigger batch or anything in the code that need to handle proper errors
 * @usage Database.SaveResult[] results = Database.update(contactToUpdate, false);
 * SystemUtils.contactLocker = false;
 * SystemLogger log = new SystemLogger('ContactService','Contact','upgradeContact');
 * log.addDatabaseSaveResult(results, 'Contact', contactToUpdate);
 * log.insertExceptionLogs();
 */
public with sharing class SystemLog
{
	public enum Severity {INFO, WARNING, ERROR, FATAL}

	public String functionName 			{get; set;}
	public String processName 			{get; set;}
	public String batchID  				{get; set;}
    
    ApplicationLog__c[] log;

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
		this.processName = processName;
		this.functionName = functionName;
		this.batchID = batchID;
	}

	public void addMessage(String errorNo, String errorDescription, Severity severity)
	{
        this.add(new ApplicationLog__c(
			Process_Name__c = processName,
	        Batch_ID__c = batchId,
	        Function_Name__c = functionName,
	        Error_No__c = errorNo,
	        Error_Description__c = errorDescription,
	        Severity__c = severity.name()));
	}

	public void addObjectMessage(String objectName, String recordId, String errorNo, String errorDescription, Severity severity)
	{
        this.add(new ApplicationLog__c(
			Process_Name__c = processName,
	        Record_Id__c = recordId,
	        Object_Name__c = objectName,
	        Batch_ID__c = batchId,
	        Function_Name__c = functionName,
	        Error_No__c = errorNo,
	        Error_Description__c = errorDescription,
	        Severity__c = severity.name()));
	}

	public void addHttpMessage(String httpRequest, String httpResponse, String errorNo, String errorDescription, Severity severity)
	{
        this.add(new ApplicationLog__c(
			Process_Name__c = processName,
	        Batch_ID__c = batchId,
	        Function_Name__c = functionName,
	        Error_No__c = errorNo,
	        Error_Description__c = errorDescription,
	        Request_Body__c = httpRequest,
        	Response_Body__c = httpResponse,
	        Severity__c = severity.name()));
	}

	public void addDatabaseSaveResult(String objectName, Database.SaveResult[] results, SObject[] records)
	{	
		for (Integer i = 0  ; i < records.size() ; i++) { 
			Database.SaveResult sr  =  results[i];
			SObject rec = records[i];
		    if (sr.isSuccess() == false) {
		        // Operation failed, so get all errors                
		        for(Database.Error err : sr.getErrors()) {                    
					String errNo = String.valueof(err.getStatusCode());
		            if (errNo.length() > 50) {
		            	errNo = errNo.substring(0,50);
		            }
		            this.addObjectMessage(objectName, rec.id, errNo,'id=' + rec.id + ',Message:' +  err.getMessage() + 'Fields:' + err.getFields(), Severity.ERROR);
		        }
		    }
		}
	}

	public void addDatabaseUpsertResult(String objectName, Database.UpsertResult[] results, SObject[] records)
	{
		for (Integer i = 0  ; i < records.size() ; i++) { 
			Database.UpsertResult sr  =  results[i];
			SObject rec = records[i];
		    if (sr.isSuccess() == false) {
		        // Operation failed, so get all errors                
		        for(Database.Error err : sr.getErrors()) {                    
		            String errNo = String.valueof(err.getStatusCode());
		            if (errNo.length() > 50) {
		            	errNo = errNo.substring(0,50);
		            }
		            addObjectMessage(objectName, rec.id, errNo,'id=' + rec.id + ',Message:' +  err.getMessage() + 'Fields:' + err.getFields(), Severity.ERROR);
		        }
		    }
		}
	}

	public void add(ApplicationLog__c exc)
	{
		log.add(exc);
	}

	public void insertLog()
	{
		if (log.isEmpty() == false) {
			insert log;	
		}	
	}

	public void insertLog(Boolean clearLog)
	{
		if (log.isEmpty() == false) {
			insert log;	
			if (clearLog == true) log.clear();
		}	
	}
}