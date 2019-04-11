/**
* @author Jon Snow
* @date 7-Dec-18
* @group OCH
* @description Container class for OCH integration callout.
*/
public class OCHService{
    /**
    * @author Jon Snow
    * @date 7-Dec-18
    * @group OCH
    * @description Updates OCH_Integration_Settings__c to store token and expiration for reference 
    */
    public static String bearerToken {
        get{
            OCHSchema.OCHAuth daf = (OCHSchema.OCHAuth) Cache.Org.get('local.daf.token');
            if(daf == null || daf.bearerToken == NULL || Datetime.now() >= daf.expireTime) {
                Authentication handler = new Authentication();
                handler.execute();
                daf = handler.oauth;
            }
            return daf.bearerToken;
        }
    }
    /**
    * @author Jon Snow
    * @date 7-Dec-18
    * @group OCH
    * @description Dedup Search callout
    */
    public class DedupSearch extends BaseRestService {
        private Account acc;
        public Map<String, Object> results;
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description Constructor for Dedup Search via super
        */
        public DedupSearch(Account acc){
            super(Constants.OCH_API,Constants.OCH_DEDUP_API,'POST');
            this.acc = acc;
            this.results = new Map<String, Object>();
        }
        
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @group OCH
        * @description Overrides BaseRestService request method
        */
        public override void request(){
            //build json payload
            OCHSchema.DedupRequest payload = new OCHSchema.DedupRequest();
            payload.brand = 'NAB'; //TBC
            payload.userId = this.acc.Owner.Employee_Number__c;
            payload.minMatchThreshold = Integer.valueOf(Label.MatchScoreThreshold);
            //set attribute specific to each customer type
            List<OCHSchema.DedupAttribute> d_attr = acc.isPersonAccount ? setIndividualRequestAttr() : setOrganisationRequestAttr();
            //set common attributes
            d_attr.add(new OCHSchema.DedupAttribute('Name',acc.Name));
            if (String.isNotBlank(acc.BillingStreet)) d_attr.add(new OCHSchema.DedupAttribute('AddressLine1', acc.BillingStreet));
            if (String.isNotBlank(acc.BillingPostalCode)) d_attr.add(new OCHSchema.DedupAttribute('AddressLine2', acc.BillingCity + acc.BillingState + acc.BillingPostalCode + acc.BillingCountry));
            if (String.isNotBlank(acc.BillingPostalCode)) d_attr.add(new OCHSchema.DedupAttribute('PostalCode', acc.BillingPostalCode));
            d_attr.add(new OCHSchema.DedupAttribute('IsBrandAgnostic','Y'));
            d_attr.add(new OCHSchema.DedupAttribute('IsSearch','N'));
            payload.searchAttributes = d_attr;

            this.req.setEndpoint('callout:'+Constants.OCH_API+'/customers/dedup?v=1');
            this.req.setHeader('Authorization',(Test.isRunningTest() == false ? bearerToken : '12345677'));
            this.req.setHeader('x-int-requestdatetime',String.valueOf(Datetime.now()));
            this.req.setHeader('x-int-clientapplication','NABCRM');
            this.req.setHeader('x-request-origin','NABCRM');

            //remove debug and set as request body
            this.req.setBody(JSON.serialize(payload));


            System.debug('Request Body :');
            System.debug(this.req.getBody());
        }
        //set attributes specific to individual
        private List<OCHSchema.DedupAttribute> setIndividualRequestAttr(){
            List<OCHSchema.DedupAttribute> attr = new List<OCHSchema.DedupAttribute>();
            attr.add(new OCHSchema.DedupAttribute('CustomerType','IND'));
            if (acc.PersonBirthdate != null) attr.add(new OCHSchema.DedupAttribute('BirthDate',acc.PersonBirthdate.month() +'/'+ acc.PersonBirthdate.day() +'/'+acc.PersonBirthdate.year()));
            if (String.isNotBlank(acc.PersonEmail)) attr.add(new OCHSchema.DedupAttribute('EmailAddress', acc.PersonEmail));
            if (this.acc.Home_Phone_Country__pc == 'Australia' && String.isNotBlank(acc.PersonHomePhone)) attr.add(new OCHSchema.DedupAttribute('HomePhone', '61' + acc.PersonHomePhone.deleteWhitespace().substring(1)));
            if (this.acc.Phone_Country__pc == 'Australia' && String.isNotBlank(acc.PersonOtherPhone)) attr.add(new OCHSchema.DedupAttribute('WorkPhone', '61' + acc.PersonOtherPhone.deleteWhitespace().substring(1)));
            if (this.acc.Mobile_Country__pc == 'Australia' && String.isNotBlank(acc.PersonMobilePhone)) attr.add(new OCHSchema.DedupAttribute('MobilePhone','61' + acc.PersonMobilePhone.deleteWhitespace().substring(1)));
            return attr;
        }
        //set attributes specific to organisation
        private List<OCHSchema.DedupAttribute> setOrganisationRequestAttr(){
            List<OCHSchema.DedupAttribute> attr = new List<OCHSchema.DedupAttribute>();
            attr.add(new OCHSchema.DedupAttribute('CustomerType','ORG'));
            if (this.acc.Phone_Country__c == 'Australia' && String.isNotBlank(acc.Phone)) attr.add(new OCHSchema.DedupAttribute('WorkPhone', '61' + acc.Phone.deleteWhitespace().substring(1)));
            if (this.acc.Phone_Country__c == 'Australia' && String.isNotBlank(acc.Phone)) attr.add(new OCHSchema.DedupAttribute('HomePhone', '61' + acc.Phone.deleteWhitespace().substring(1)));
            if (String.isNotBlank(acc.Email__c)) attr.add(new OCHSchema.DedupAttribute('EmailAddress', acc.Email__c));
            if (String.isNotBlank(acc.ABN__c)) attr.add(new OCHSchema.DedupAttribute('ABN', acc.ABN__c));
            if (String.isNotBlank(acc.ACN__c)) attr.add(new OCHSchema.DedupAttribute('ACN', acc.ACN__c));
            return attr;
        }
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description This method handle success response for dedup search. 
        */
        public override void handleSuccess(){
            //String response = '{"individuals":[{"cgid":"600321756738","matchScore":"98"},{"cgid":"600321728745","matchScore":"99"}],"organisations":[{"cgid":"609584815734","matchScore":"90"}]}';
            String response = this.res.getBody();
            System.debug(response);
            //parse customer response
            OCHSchema.DedupResult och_matches = OCHSchema.parseCustomer(response);
            Map<String,List<FieldSetMember>> fields = new Map<String,List<FieldSetMember>>();
            fields.put('matching',FieldSetService.getFieldSetMember('Account', Constants.OCH_DEDUP_API + '_' + this.acc.RecordType.DeveloperName));  
            fields.put('comparison',FieldSetService.getFieldSetMember('Account', Constants.OCH_COMPARISON + '_' + this.acc.RecordType.DeveloperName)); 
            List<Account> duplicateAccounts = getSalesforceAccounts(this.acc.isPersonAccount == true ? och_matches.individuals : och_matches.organisations,fields);

            Map<String, Object> schema = new Map<String, Object>();
            schema.put('fields',fields);
            schema.put('icon',this.acc.IsPersonAccount ? 'standard:person_account':'standard:account');
            schema.put('label',this.acc.IsPersonAccount ? 'Individual':'Organisation');
            this.results.put('schema',schema);
            this.results.put('response', duplicateAccounts);
        }
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description This method handle error response for dedup search by throwing a AuraHandledException. 
        */
        public override void handleError(){
            handleException(this.syslog, this.req, this.res);
        }
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description This method retrieve SF accounts based on CGID of dedup search result 
        */
        private List<Account> getSalesforceAccounts(List<OCHSchema.Duplicate> matches, Map<String,List<FieldSetMember>> fields){
            Map<String, String> cgidScore = new Map<String, String>();
            for(OCHSchema.Duplicate ind : matches) {
                cgidScore.put(ind.cgid, ind.matchScore);
            }
            Set<String> cgidSet = cgidScore.keySet();
            String recordType = this.acc.RecordType.DeveloperName;

            FieldSetMember[] tmp = fields.get('matching').clone();
            if (fields.get('comparison') != null) tmp.addAll(fields.get('comparison'));

            String query =  'SELECT id, '+ FieldSetService.toString(tmp) + ',Match_Score__c, External_Unique_ID__c from Account' +
                            ' WHERE External_Unique_ID__c IN :cgidSet AND RecordType.DeveloperName = :recordType';
            
            //adds match score to the account 
            List<Account> duplicateAccounts = Database.query(query);
            for(Account acc : duplicateAccounts) {
                acc.Match_Score__c = Decimal.valueOf(cgidScore.get(acc.External_Unique_ID__c));
            }
            return duplicateAccounts;
        }
    }
    /**
    * @author Jon Snow
    * @date 7-Dec-18
    * @group OCH
    * @description Create Prospoect callout
    */
    public class CreateProspect extends BaseRestService {
        private Account acc;
        private Map<String,String> address;
        public Map <String, Object> results;
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description Constructor for Create Prospect via super
        */
        public CreateProspect(Account acc, String address){
            super(Constants.OCH_API, Constants.OCH_CREATE_API,'POST');
            if (String.isBlank(address) == true){
                throw new OCHSchema.OCHException('A valid address is required in order to submit a prospect to OCH.');
            }
            this.acc = acc;
            this.address = (Map<String,String>)JSON.deserialize(address, Map<String,String>.class);
            this.address.put('startDate',String.valueOf(Date.today()));
            this.results = new Map <String, Object>();
        }
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description Overrides BaseRestService request method
        */
        public override void request(){
            //define payload
            OCHSchema.CustomerDetails payload = new OCHSchema.CustomerDetails();
            payload = this.acc.isPersonAccount ? setIndividualDetails() : setOrganisationDetails();
            payload.customerState = 'Prospect';
            payload.brand = 'NAB';
            payload.businessUnit = this.acc.Managed_By__c;
            payload.userId = this.acc.Owner.Employee_Number__c;
            payload.shareInfo = this.acc.Share_Information__c == 'Yes' ? 'Y' : 'N';
            payload.secondaryPurpose = this.acc.Secondary_Purpose__c == 'Yes' ? 'Y' : 'N';
            if (this.address != null) payload.address.add(this.address);

            this.req.setEndpoint('callout:'+Constants.OCH_API+'/customers?v=1');
            this.req.setHeader('Authorization',(Test.isRunningTest() == false ? bearerToken : '12345677'));
            this.req.setHeader('x-int-requestdatetime',String.valueOf(Datetime.now()));
            this.req.setHeader('x-int-clientapplication','NABCRM');
            this.req.setHeader('x-request-origin','NABCRM');

            //remove debug and set as request body
            this.req.setBody(JSON.serialize(payload));
            System.debug('Request Body :');
            System.debug(this.req.getBody());
        }
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description This method defines attributes specific for individual creation request 
        */
        private OCHSchema.CustomerDetails setIndividualDetails(){
            OCHSchema.CustomerDetails customer = new OCHSchema.CustomerDetails();
            customer.customerType = 'Individual';
            customer.Name = new OCHSchema.PersonName(
                this.acc.Salutation, 
                this.acc.FirstName,
                this.acc.MiddleName,
                this.acc.LastName,
                this.acc.PersonBirthdate,
                this.acc.FinServ__Gender__pc,
                this.acc.FinServ__MaritalStatus__pc);

            if (String.isNotBlank(this.acc.PersonEmail) == true) 
                customer.contactPoints.email.personal.add(new OCHSchema.EmailAddressDetails(this.acc.PersonEmail));

            if (String.isNotBlank(this.acc.PersonMobilePhone) == true && this.acc.Mobile_Country__pc == 'Australia') 
                customer.contactPoints.phone.personalMobile.add(new OCHSchema.PhoneNumberDetails('61',this.acc.PersonMobilePhone));

            if (String.isNotBlank(this.acc.PersonOtherPhone) == true && this.acc.Phone_Country__pc == 'Australia') 
                customer.contactPoints.phone.workPhone.add(new OCHSchema.PhoneNumberDetails('61',this.acc.PersonOtherPhone));

            if (String.isNotBlank(this.acc.PersonHomePhone) == true && this.acc.Home_Phone_Country__pc == 'Australia') 
                customer.contactPoints.phone.homePhone.add(new OCHSchema.PhoneNumberDetails('61',this.acc.PersonHomePhone));

            this.address.put('type','Home');
            return customer;
        }
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description This method defines attributes specific for organisation creation request 
        */
        private OCHSchema.CustomerDetails setOrganisationDetails(){
            OCHSchema.CustomerDetails customer = new OCHSchema.CustomerDetails();
            customer.customerType = 'Corporate';
            customer.Name = new OCHSchema.Organisation(this.acc.Name, this.acc.Mailing_Name__c, this.acc.Website);
            if (String.isNotBlank(this.acc.Email__c) == true) customer.contactPoints.email.work.add(new OCHSchema.EmailAddressDetails(this.acc.Email__c));
            if (String.isNotBlank(this.acc.Phone) == true && this.acc.Phone_Country__c == 'Australia') 
                customer.contactPoints.phone.workPhone.add(new OCHSchema.PhoneNumberDetails('61',this.acc.Phone));
            this.address.put('type','Registered');
            return customer;
        }
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description This method handle success response for prospect creation.
        */
        public override void handleSuccess(){
            Map<String,Object> customerResult = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            if (customerResult.get('id') != null) this.acc.External_Unique_ID__c = String.valueOf(customerResult.get('id'));
            this.acc.BillingCountry = this.address.get('countryCode');
            this.acc.BillingState = this.address.get('stateName');
            this.acc.BillingCity = this.address.get('cityName');
            this.acc.BillingPostalCode = this.address.get('postalCode');
            this.acc.BillingStreet = 
                (this.address.get('longPostalCode') != null ? (this.address.get('longPostalCode') + ' '):'')+
                (this.address.get('flatUnitType') != null ? (this.address.get('flatUnitType') + ' '):'')+
                (this.address.get('flatUnitNumber') != null ? (this.address.get('flatUnitNumber') + ' '):'')+
                (this.address.get('streetNumber') != null ? (this.address.get('streetNumber') + ' '):'')+
                (this.address.get('streetName') != null ? (this.address.get('streetName') + ' '):'')+
                (this.address.get('streetType') != null ? (this.address.get('streetType') + ' ') : '')+
                (this.address.get('streetTypeSuffix') != null ? this.address.get('streetTypeSuffix') : '');
            update this.acc;
            this.results.put('customer',this.acc);
        }
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description This method handle error response for prospect creation by throwing a AuraHandledException. 
        */
        public override void handleError(){
            handleException(this.syslog, this.req, this.res);
        }
    }
    /**
    * @author Jon Snow
    * @date 7-Dec-18
    * @group OCH
    * @description Authentication callout
    */
    public class Authentication extends BaseRestService {
        OCHSchema.OCHAuth oauth;
        public Authentication(){    
            super(Constants.OCH_AUTH_API,'Authentication','POST');
        }

        public override void request(){
            JWTService jwt = new JWTService(Constants.OCH_AUTH_API, 'dafcert');
            OCHSchema.DAF payload = new OCHSchema.DAF();

            payload.client_id = jwt.setting.iss__c;
            payload.client_assertion_type = jwt.setting.assertion_type__c;
            payload.client_assertion = jwt.generateAssertion();
            payload.scope = jwt.setting.scope__c;
            payload.grant_type = jwt.setting.grant_type__c;         

            this.req.setBody(JSON.serialize(payload));   
        }

        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @group OCH
        * @description This method handle success response, gets access token and expiration
        */
        public override void handleSuccess(){
            String response = this.res.getBody();
            oauth = OCHSchema.parseAuth(response);
            oauth.expireTime = Datetime.now().addSeconds(Integer.valueOf(oauth.expires_in));
            Cache.Org.put('local.daf.token', oauth);
        }
        /**
        * @author Jon Snow
        * @date 7-Dec-18
        * @description This method handle error response for DAF auth by throwing a AuraHandledException. 
        */
        public override void handleError(){
            handleException(this.syslog, this.req, this.res);
        }
    }

    /**
    * @author Jon Snow
    * @date 14-Mar-19
    * @description static method to handle exceptions for OCH
    */
    private static void handleException(SystemLog sysLog, HttpRequest req, HttpResponse res) {
        //throw and log any other excption in apex
        sysLog.addLogEvent(
            req.toString()+'\n'+ String.valueOf(req.getBody()),
            String.valueOf(res.getBody()),
            String.valueOf(res.getStatusCode()),
            res.toString(),
            SystemLog.Severity.ERROR, null);
        sysLog.insertLogEvents();
        OCHSchema.ErrorResponse errResponse;
        try{
            errResponse = (OCHSchema.ErrorResponse) JSON.deserialize(res.getBody(), OCHSchema.ErrorResponse.class);
        }catch(Exception e){    //handle unexpected schema
            System.debug('Malformed JSON');
        }
        if(errResponse != NULL && errResponse.errors != NULL && errResponse.errors[0].errorId.startsWith('CM_05')) {
            throw new OCHSchema.OCHException(errResponse.errors[0].message);
        }
        //Any other error not CM_05 throw System Exception
        throw new SystemException('System Exception');   
    }
}
