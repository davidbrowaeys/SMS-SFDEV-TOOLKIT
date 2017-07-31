@isTest
public class LookupController_TEST {

	@testSetup static void setup(){

	}

	@isTest static void getSobjectNameField(){
		String accNameField = LookupController.getSobjectNameField(Account.SObjectType);
		String caseNameField = LookupController.getSobjectNameField(Case.SObjectType);

		System.assertEquals('Name', accNameField);
		System.assertEquals('CaseNumber', caseNameField);
	}

	@isTest static void getCurrentValue(){
		Account acc = new Account(Name = 'Test');
		insert acc;

		Test.startTest();

		String currentAccName = LookupController.getCurrentValue('Account', acc.Id);

		acc.Name = 'UpdatedAccountName';
		update acc;

		String updatedAccName = LookupController.getCurrentValue('Account', acc.Id);

		String blankType = LookupController.getCurrentValue('', acc.Id);
		String invalidType = LookupController.getCurrentValue('InvalidObjectTypeName', acc.Id);

		String blankId = LookupController.getCurrentValue('Account', '');
		String nullId = LookupController.getCurrentValue('Account', null);
		String invalidId = LookupController.getCurrentValue('Account', '658686789689234876');


		Test.stopTest();

		System.assertEquals('CurrentAccountName', currentAccName);
		System.assertEquals('UpdatedAccountName', updatedAccName);

		System.assertEquals(null, blankType);
		System.assertEquals(null, invalidType);
		System.assertEquals(null, blankId);
		System.assertEquals(null, nullId);
		System.assertEquals(null, invalidId);
	}

	@isTest static void lookup(){
		Account acc = new Account(Name = 'Test');
		insert acc;

		Test.startTest();

		LookupController.Result[] emptySearch = LookupController.lookup('', '', '');
		LookupController.Result[] invalidObjectSearch = LookupController.lookup('InvalidType', 'Search String', '');

		Test.setFixedSearchResults(new List<Id>{acc.Id});
		LookupController.Result[] accSearch = LookupController.lookup('Account', 'Account', 'WHERE Name = \'Account\'');

		Test.stopTest();

		System.assert(emptySearch.isEmpty(), 'Should return null when empty search');
		System.assert(invalidObjectSearch.isEmpty(), 'Should return null when invalid object type');

		System.assertEquals(1, accSearch.size(), 'Should return one fixed result');

	}

}