
/**
* @author Bayani Cruz[JS]
* @date 12-Dec-18
* @group OCH
* @description OCH Object wrapper
*/
public class OCHSchema {
	public class OCHException extends Exception{}
	/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for Dedup Search 
	*/
	public class DedupRequest {
		public String brand {get;set;}
		public String userId {get;set;}
		public Integer minMatchThreshold {get;set;}
		public List<DedupAttribute> searchAttributes{get;set;}
	}
	/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for Dedup Request Attribute 
	*/
	public class DedupAttribute{
		public String key {get;set;}
		public String value {get;set;}
		public DedupAttribute(String k, String v){
			key = k;
			value = v;
		}
	}
	/**
	* @author Bayani Cruz[JS]
	* @date 14-Dec-18
	* @group OCH
	* @description Object for Dedup Search Response
	*/
	public class DedupResult {
		public List<Duplicate> individuals {get;set;} 
		public List<Duplicate> organisations {get;set;} 
	}/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for Duplicate records 
	*/
	public class Duplicate {
		public String cgid {get;set;}
		public String matchScore {get;set;} 
	}
	public static DedupResult parseCustomer(String json) {
		return (DedupResult) System.JSON.deserialize(json, DedupResult.class);
	}
	/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for prospect creation request
	*/
	public class CustomerDetails {
		public String customerType;	//IND
		public String customerState;	//Prospect
		public String shareInfo;	//Y
		public String brand;	//Y	
		public String secondaryPurpose;	//Y
		public String userId;	//22771234
		public String businessUnit;	//22771234
		public CustomerName name;
		public List<Map<String,String>> address = new List<Map<String,String>>();
		public ContactPointDetails contactPoints = new ContactPointDetails();
	}
	
	public virtual class CustomerName{}
	/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for OCH Customer Name - Individual Tyoe
	*/
	public class PersonName extends CustomerName{
		public String title;	//Mr.
		public String firstName;	//Tony
		public String middleName;	//Tony
		public String lastName;	//Stark
		public String gender;	//M
		public String dob;
		public String maritalStatus;

		public PersonName(String title, String firstName, String middlename, String lastName, Date dob, String gender, String maritalStatus){
			this.title = title;
			this.firstName = firstName;
			this.middleName  = middlename;
			this.lastName = lastName;
			if (dob != null) this.dob = String.valueOf(dob);
			this.gender = gender;
			this.maritalStatus = maritalStatus;
		}
	}
	/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for OCH Customer Name - Org Tyoe
	*/
	public class Organisation extends CustomerName{
		public String organisationName;
		//public String mailingName;
		public String website;
		public Organisation(String organisationName, String mailingName, String website){
			this.organisationName = organisationName;
			//this.mailingName = mailingName; //placeholder until OCH confirm the field name
			this.website = website;
		}
	}
	/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for OCH Contact Points
	*/
	public class ContactPointDetails{
		public PhoneDetails phone = new PhoneDetails();
		public EmailDetails email = new EmailDetails();
	}
	/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for OCH Phone Details
	*/
	public class PhoneDetails{
		public PhoneNumberDetails[] workPhone = new  PhoneNumberDetails[0];
		public PhoneNumberDetails[] homePhone = new  PhoneNumberDetails[0];
		public PhoneNumberDetails[] personalMobile = new  PhoneNumberDetails[0];
		public PhoneNumberDetails[] workMobile = new  PhoneNumberDetails[0];
		public PhoneNumberDetails[] internationalPhone = new  PhoneNumberDetails[0];
	}
	/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for OCH Phone Number Details
	*/
	public class PhoneNumberDetails{
		public String countryCode;
		public String phoneNumber;
		public String areaCode;
		public String startDate;
		public PhoneNumberDetails (String countryCode, String phoneNumber){
			this.phoneNumber = phoneNumber.deleteWhitespace();
			this.countryCode = countryCode;
			this.startDate = String.valueOf(Date.today());
			if (countryCode == '61' && !phoneNumber.startsWith('04')){
				this.areaCode = phoneNumber.subString(0,2);
				this.phoneNumber = phoneNumber.subString(2);
			}
		}
	}
	/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for OCH Email Details
	*/
	public class EmailDetails{
		public EmailAddressDetails[] personal = new EmailAddressDetails[0];
		public EmailAddressDetails[] work = new EmailAddressDetails[0];
	}
	/**
	* @author David Browaeys[JS]
	* @date 23-Dec-18
	* @group OCH
	* @description Wrapper class for OCH Email Address Details
	*/
	public class EmailAddressDetails{
		public String emailAddress;
		public String startDate;
		public EmailAddressDetails (String emailAddress){
			this.emailAddress = emailAddress;
			this.startDate = String.valueOf(Date.today());
		}
	}
	/**
	* @author Bayani Cruz[JS]
	* @date 14-Dec-18
	* @group OCH
	* @description Object for OCH Auth
	*/
	public class OCHAuth {
		public String access_token;
		public String bearerToken;
		public String expires_in;
		public Datetime expireTime;
	}
	public static OCHAuth parseAuth(String json) {
		return (OCHAuth) System.JSON.deserialize(json, OCHAuth.class);
	}
	/**
	* @author Bayani Cruz[JS]
	* @date 14-Dec-18
	* @group OCH
	* @description Objects for Errors
	*/
	public class ErrorResponse{
        public List<Error> errors; //this is for och errors 
        public String message; //this is for ESG error
    }
    public class Error{
        public String errorId;
        public String message;
    }

	/**
	* @author Bayani Cruz[JS]
	* @date 22-Feb-19
	* @group OCH
	* @description Objects for DAF JWT
	*/
	public class DAF {
		public String client_id;
		public String client_assertion_type;
		public String client_assertion;
		public String grant_type;
		public String scope;
	}

	
}
