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
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	* @description Perform SOQL and retrieve records with specified object fields list for a certain set of object id's. 
	* @usage 	SObject[] accounts = GlobalUtils.getRecordTypeByIds('Account', new String[]{'Id','Name','Industry','AccountRevenue'},accountIds);
	*/
	public Map <Id, SObject> selectMapObject(String objectName, String[] selectFields, Set <Id> idSet)
	{
		String objectQuery = 
			String.format('select {0} from {1} where id in :idSet', 
				new List<String> { 
			    String.join(selectFields, ','), objectName });

		return new Map <Id, SObject>(Database.query(objectQuery));	
	}
	/**
	* @description Perform SOQL and retrieve child records of specified parent ids, with specified object fields list
	* @usage 	Map<Id,SObject[]> contacts = GlobalUtils.getRecordTypeByIds('Contact', new String[]{'Id','Name','Email','Phone'},accountIds);
	*/
	public Map <Id, SObject[]> selectMapChildObject(String objectName, String[] selectFields, String parentFieldName, Set <Id> idSet)
	{
		String objectQuery = 
			String.format('select {0} from {1} where {2} in :idSet', 
				new List<String> { 
			    String.join(selectFields, ','), objectName, parentFieldName });

		Map <Id, SObject[]> tmp = new Map <Id, SObject[]>();
		for (SObject o : Database.query(objectQuery)){
			if (tmp.get((ID)o.get(parentFieldName)) == null){
				tmp.put((ID)o.get(parentFieldName), new SObject[0]);
			}
			tmp.get((ID)o.get(parentFieldName)).add(o);
		}
		return tmp;
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	* @description Perform a SOSL quick search, this doesn't count against QUERY_ROW governor limit. 
	* However it will always return a maximum of 2000 records and a maximum of 20 SOSL queries per transaction. 
	* @usage GlobalUtils.quickSearch('Account', new String[]{'hello','world','foo'});
	*/
	public SObject[] quickSearch(String objectName, String[] keywords){
		return quickSearch(objectName, String.join(keywords,' '),null);
	}
	public SObject[] quickSearch(String objectName, String[] keywords, Integer iLimit){
		return quickSearch(objectName, String.join(keywords,' '),iLimit);
	}
	public SObject[] quickSearch(String objectName, String keyword){
		return quickSearch(objectName, keyword, null);
	}
	public SObject[] quickSearch(String objectName, String keyword, Integer iLimit){
		SObject[] buffer = new SObject[0];
		Search.SuggestionOption option = new Search.SuggestionOption();
		if (iLimit != null) option.setLimit(iLimit);
		Search.SuggestionResults suggestionResults  = Search.suggest(keyword,objectName,option);
		for (Search.SuggestionResult searchResult : suggestionResults.getSuggestionResults()) {     
			buffer.add(searchResult.getSObject());
		}
		return buffer;
	}
}