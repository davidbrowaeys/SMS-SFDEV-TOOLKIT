/**
* @author David Browaeys[JS]
* @date 17-Dec-18
* @group QAS
* @description This class offers methods to utilise NAB address lookup
*/
public class QASService{
    /**
    * @author David Browaeys[JS]
    * @date 17-Dec-18
    * @group QAS
    * @description This inner class extends BaseRestService and perform callout for address predective search
    */
    public class PredectiveSearch extends BaseRestService{
        private String query;
        private String countryCode;
        public String result;
        public PredectiveSearch(String countryCode, String query){
            super(Constants.QAS, Constants.QAS_SEARCH);
            this.query = query;
            this.countryCode = countryCode;
        }
        /**
        * @author David Browaeys[JS]
        * @date 17-Dec-18
        * @description This method handle callout request for predective search
        */
        public override void request(){
            if (String.isBlank(this.countryCode) == true || String.isBlank(this.query) == true){
                throw new SystemException('Country code and query are mandatory attributes in order to use predictive search api.');
            }
            this.req.setEndpoint('callout:'+Constants.QAS+ '/info/address/suggest/'+countryCode+ '/'+EncodingUtil.urlEncode(query,'UTF-8').replace('+', '%20')+'?v=1');
        }
        /**
        * @author David Browaeys[JS]
        * @date 17-Dec-18
        * @description This method handle callout response for predective search
        */
        public override void handleSuccess(){
            result = res.getBody(); //no need wrapper class here, UI will do the parsing
        }
        public override void handleError(){
            QASError error = (QASError) JSON.deserialize(res.getBody(), QASError.class);
            if(error.status.message != 'No search results found for this query') {
                throw new SystemException(Error.status.message);
            }
        }
    }
    /**
    * @author David Browaeys[JS]
    * @date 17-Dec-18
    * @group QAS
    * @description This inner class extends BaseRestService and perform callout for address details
    */
    public class AddressDetails extends BaseRestService{
        private String addressId;
        public String address;
        public AddressDetails(String addressId){
            super(Constants.QAS, Constants.QAS_ADDR_DETAILS);
            this.addressId = addressId;
        }
        /**
        * @author David Browaeys[JS]
        * @date 17-Dec-18
        * @description This method handle callout request for address details
        */
        public override void request(){
            if (this.addressId == null){
                throw new SystemException('Address ID is a mandatory attribute in order to retrieve address details.');
            }
            this.req.setEndpoint('callout:'+Constants.QAS+'/info/address/addressId/'+EncodingUtil.urlEncode(addressId,'UTF-8')+'?v=1');

            System.debug(this.req);
        }
        /**
        * @author David Browaeys[JS]
        * @date 17-Dec-18
        * @description This method handle callout response for address details
        */
        public override void handleSuccess(){
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> addr = (Map<String, Object>) response.get('addressResponse');
            
            //add address id prop
            addr.put('addressId', this.addressId);
            response.put('addressResponse', addr);

            this.address = JSON.serialize(response);
        }
        public override void handleError(){
            QASError error = (QASError) JSON.deserialize(res.getBody(), QASError.class);
            throw new SystemException(Error.status.message);
        }
    }
    public class QASError{
        public QASErrorMessage status;
    }
    public class QASErrorMessage{
        public String code;
        public String message;
    }
}
