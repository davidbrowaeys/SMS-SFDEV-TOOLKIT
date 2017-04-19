/**
* @author davidbrowaeys[SMS]
* @description Utility class that deals with data fetch
*/
public abstract class QueryUtils {
	/**
	 * @description Query selected fields of sObject in a collection
	 * @usage List<Account> accList = QueryUtils.selectMapObject('Account',new List<String>{'Name','Phone'},new Set<Id>{'001N000001AvY5n'});
	 * if selectFields is null, it will select ALL field of the select object, i.e.:
	 *	QueryUtils.selectMapObject('Account',new Set<Id>{'001N000001AvY5n'});
	*/	
	public static Map<Id,SObject> selectMapObject(String objectName, List<String> selectFields, Set<Id> idSet){
		if (selectFields == null){
			selectFields = new String[0];
			selectFields.addAll(GlobalUtils.getSObjectFields(objectName).keySet());
		}
		String objectQuery = String.format('SELECT {0} FROM {1} WHERE Id IN: idSet', 
											new List<String> { String.join(selectFields, ','),objectName });

		return new Map <Id,SObject>(Database.query(objectQuery));	
	}
	/**
	 * @description Query selected fields of child records of sobject in a collection
	 * @usage Map<Id,List<SObject>> rec = QueryUtils.selectMapChildObject('Contact',new List<String>{'FirstName','LastName'},
	 *																			'AccountId',new Set<Id>{'001N000001AvY5n'});
	 * if selectFields is null, it will select ALL field of the select object, i.e.:
	 *	QueryUtils.selectMapChildObject('Contact','AccountId',new Set<Id>{'001N000001AvY5n'});
	*/	
	public static Map<Id,List<SObject>> selectMapChildObject(String objectName, List<String> selectFields, String parentFieldName, Set<Id> idSet){
		if (selectFields == null){
			selectFields = new String[0];
			selectFields.addAll(GlobalUtils.getSObjectFields(objectName).keySet());
		}
		String objectQuery = String.format('SELECT {0} FROM {1} WHERE {2} IN: idSet', 
											new List<String> { String.join(selectFields, ','), 
																objectName, parentFieldName });

		Map<Id,List<SObject>> tmp = new Map<Id,List<SObject>>();
		for(SObject obj : Database.query(objectQuery)){
			if(tmp.get(obj.get(parentFieldName)) == null){
				tmp.put(obj.get(parentFieldName), new SObject[0])
			}
			tmp.get(obj.get(parentFieldName)).add(obj);
		}
		return tmp;
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	* @description Perform a SOSL quick search, this doesn't count against QUERY_ROW governor limit. 
	* However it will always return a maximum of 2000 records and a maximum of 20 SOSL queries per transaction. 
	* @usage QueryUtils.find('albert', new Map<String,String[]>{ 'Account' 	=> new String[]{'Id', 'Name'},
	*															 'Contact'  => new String[]{'Id', 'FirstName', 'LastName', 'AccountId'},
	*															 'Lead'  	=> new String[]{'Id', 'FirstName', 'LastName'}});
	*/
	public static List<List<SObject>> find(String searchTerm, Map <String,String[]> selectObjects){
		String[] objectQuery = new String[0];
		for (String s : selectObjects.keySet()){
			if (selectObjects.get(s) != null && selectObjects.get(s).isEmpty() == false){
				objectQuery.add(String.format('{0}({1})',new String[] {s, String.join(selectObjects.get(s),',')}));
			}else{
				objectQuery.add(s);
			}
		}
		return find(searchTerm, objectQuery);
	}
	public static List<List<SObject>> find(String searchTerm, String[] selectObjects){
		String searchquery = 'FIND \''+searchTerm+'\' IN ALL FIELDS RETURNING '+String.join(selectObjects, ','); 
		return find(searchquery);
	}
	public static List<List<SObject>> find(String searchquery){
		System.debug(searchquery);
		return Search.query(searchquery);
	}
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	* @description Perform a SOSL quick search, this doesn't count against QUERY_ROW governor limit. 
	* However it will always return a maximum of 2000 records and a maximum of 20 SOSL queries per transaction. 
	* This suggest method is mainly use for KnowledgeArcticle but can be use for any sobject. 
	* @usage QueryUtils.suggest('Account', new String[]{'hello','world','foo'});
	*/
	public static SObject[] suggest(String objectName, String[] searchTerms){
		return suggest(objectName, String.join(searchTerms,' '),null);
	}
	public static SObject[] suggest(String objectName, String[] searchTerms, Integer iLimit){
		return suggest(objectName, String.join(searchTerms,' '),iLimit);
	}
	public static SObject[] suggest(String objectName, String searchTerm){
		return suggest(objectName, searchTerm, null);
	}
	public static SObject[] suggest(String objectName, String searchTerm, Integer iLimit){
		SObject[] buffer = new SObject[0];
		Search.SuggestionOption option = new Search.SuggestionOption();
		if (iLimit != null) option.setLimit(iLimit);
		Search.SuggestionResults suggestionResults  = Search.suggest(searchTerm,objectName,option);
		for (Search.SuggestionResult searchResult : suggestionResults.getSuggestionResults()) {     
			buffer.add(searchResult.getSObject());
		}
		return buffer;
	}
}