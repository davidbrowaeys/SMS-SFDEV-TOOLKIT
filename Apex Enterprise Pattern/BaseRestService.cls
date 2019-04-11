
/**
* @author Jon Snow
* @date 7-Dec-18
* @group Integration
* @description Parent class for Rest callouts.
*/
public virtual class BaseRestService{
    public HttpRequest req {get;set;}
    public HttpResponse res {get;set;}
    public SystemLog syslog {get; set;}
    public Webservice_Settings__mdt[]  setttings;
    public String processName;
    public String functionName;
    public String method;

    public BaseRestService(String processName, String functionName){
        this(processName,functionName,null);
    }
    public BaseRestService(String processName, String functionName, String method){
        this.processName = processName;
        this.functionName = functionName;
        this.syslog = new SystemLog(processName, functionName);
        this.method = method == null ? 'GET' : method;
    }
    public void execute(){
        handleRequest();
        send();
        handleResponse();
    }
    private void handleRequest(){
        //removed named credentials due to jwt requirement
        //jwt not available in named creds https://success.salesforce.com/ideaView?id=0873A0000003apqQAA
        this.req = new HttpRequest();
        this.req.setEndpoint('callout:'+this.processName);
        
        this.req.setHeader('Content-Type','application/json');
        this.req.setMethod(this.method);
        this.req.setTimeout(120000);

        this.setttings = NabSettingService.getSettingsByFeature(processName);
        for (NAB_Settings__mdt s : this.setttings){
            this.req.setHeader(s.Property__c, s.Value__c);
        }
        request();
    }
    /**
    * @author Bayani Cruz[JS]
    * @date 7-Dec-18
    * @group Integration
    * @description request virtual method
    */
    public virtual void request(){}

    /**
    * @author Bayani Cruz[JS]
    * @date 7-Dec-18
    * @group Integration
    * @description send virtual method
    */
    public void send(){
        Http http = new Http();
        this.res = http.send(req);
    }
    /**
    * @author Bayani Cruz[JS]
    * @date 7-Dec-18
    * @group Integration
    * @description response virtual method
    */
    private void handleResponse(){
        if (this.res.getStatusCode() >= 200 && this.res.getStatusCode() <= 230) handleSuccess();
        else handleError();
    }
    public virtual void handleSuccess(){}
    public virtual void handleError(){}
}
