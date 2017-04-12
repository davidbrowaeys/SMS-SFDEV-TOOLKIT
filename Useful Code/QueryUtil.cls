/**
* @author davidbrowaeys[SMS]
* @description Utility class that deals with data fetch
*/
public abstract class QueryUtil {
	
	/**
	 * @description Query selected fields of sObject in a collection
	 * @usage List<Account> accList = QueryUtil.selectMapObject('Account',new List<String>{'Name','Phone'},new Set<Id>{'001N000001AvY5n'});
	*/	
	public Map<Id,SObject> selectMapObject(String objectName, List<String> selectFields, Set<Id> idSet){
		String objectQuery = String.format('SELECT {0} FROM {1} WHERE Id IN: idSet', 
											new List<String> { String.join(selectFields, ','),objectName });

		return new Map <Id,SObject>(Database.query(objectQuery));	
	}
	
	/**
	 * @description Query selected fields of child records of sobject in a collection
	 * @usage List<Account> accList = QueryUtil.selectMapChildObject('Contact',new List<String>{'FirstName','LastName'},
																		'AccountId',new Set<Id>{'003N0000012oPOM'});
	*/	
	public Map<Id,List<SObject>> selectMapChildObject(String objectName, List<String> selectFields, String parentFieldName, Set<Id> idSet){
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
}