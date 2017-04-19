public class GlobalUtils{
	/**
	* @description This methods add messages to current apex page with specific types(ERROR, WARNING, INFO)
	* @usage 	GlobalUtils.addError('This is an error');
	*/
	public static void addError(Object message)
	{
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, String.valueOf(message)));
	}
	public static void addInfo(Object message)
	{
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, String.valueOf(message)));
	}
	public static void addWarning(Object message)
	{
		Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING, String.valueOf(message)));
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	* @description Retrieve recordtype information for specified object. 
	* This method use the schema and doesn't count against governor limit
	* @usage 	Map <ID, Schema.RecordTypeInfo> recordTypes = GlobalUtils.getRecordTypeByIds('Account');
	* 			System.debug(recordTypes.get(acct.RecordTypeId) == 'Student');
	*/
	public static Map <ID, Schema.RecordTypeInfo> getRecordTypeByIds(String objectName)
	{
		return getRecordTypeByIds(Schema.getGlobalDescribe().get(objectName));
	}
	public static Map <ID, Schema.RecordTypeInfo> getRecordTypeByIds(Schema.sObjectType entity)
	{
		return entity.getDescribe().getRecordTypeInfosById();
	}
	/**
	* @description Retrieve recordtype information for specified object. 
	* This method use the schema and doesn't count against governor limit
	* @usage 	Map <String, Schema.RecordTypeInfo> recordTypes = GlobalUtils.getRecordTypeByIds('Account');
	* 			System.debug(acct.RecordTypeId == recordTypes.get('Student'));
	*/
	public static Map <String, Schema.RecordTypeInfo> getRecordTypeIdByNames(String objectName)
	{
		return getRecordTypeIdByNames(Schema.getGlobalDescribe().get(objectName));
	}
	public static Map <String, Schema.RecordTypeInfo> getRecordTypeIdByNames(Schema.sObjectType entity)
	{
		return entity.getDescribe().getRecordTypeInfosByName();
	}
	/**
	* @description Retrieve object fields map for specified object. 
	* @usage 	Map<String, Schema.SObjectField> recordTypes = GlobalUtils.getRecordTypeByIds('Account');
	*/
	public static Map<String, Schema.SObjectField> getSObjectFields(String objectName)
	{
		return getSObjectFields(Schema.getGlobalDescribe().get(objectName));
	}
	public static Map<String, Schema.SObjectField> getSObjectFields(Schema.sObjectType entity)
	{
		return entity.getDescribe().fields.getMap();
	}
	/**
	* @description Retrieve picklist values for specific object and field
	* @usage 	Map<String, Schema.SObjectField> recordTypes = GlobalUtils.getRecordTypeByIds('Account','Industry');
	*/
	public static String[] getPicklistValues(String objectName, String fieldName)
	{
		String[] tmp = new String[0];
		for (Schema.PicklistEntry p : getSObjectFields(objectName).get(fieldName).getDescribe().getPicklistValues()){
			tmp.add(p.getValue());
		}
		return tmp;
	}
}