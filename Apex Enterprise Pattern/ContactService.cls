/**
* @author davidbrowaeys[SMS]
* @description Encapsulates all contact service layer logic for a given function or module in the application
*/
public class ContactService{
	public class ContactServiceException extends Exception{}

	public static void upgradeContacts(Contact[] records){
		if (records == null || records.size() == 0)
            throw new ContactServiceException('Contacts not specified.');

		for (Contact c : records){
			//do something here
		}
	}
	public static void createStudentMemberCards(Contact[] records){
		if (records == null || records.size() == 0)
            throw new ContactServiceException('Contacts not specified.');
            
		for (Contact c : records){
			//do something here
		}
	}
}