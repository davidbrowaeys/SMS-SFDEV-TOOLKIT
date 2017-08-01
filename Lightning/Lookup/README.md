<div style="text-align:right;top: 10px;position: absolute;right: 10px;" markdown="1">
    <img align="right" src="http://www.smsmt.com/hs-fs/hubfs/SMS_Logo-1.png?t=1490163156935&amp;width=300&amp;name=SMS_Logo-1.png"/>
</div>

# Lightning Lookup #
This is a fully working lighning LOOKUP component that you can reuse in VISUALFORCE or LIGHTNING COMPONENT! 

## Installation ##
1. <b>Create Event</b><br/>
This is required to communicate change between components. 
2. <b>Create Apex Class</b><br/>
Allow component to communicate with data and perform SOSL
3. <b>Create Lookup Component</b><br/>
Our beautiful main lookup component, this include controller.js and helper.js
4. <b>Create Lightning App (VisualforceLightningApp)</b><br/>
Only applicable to embed lightning component in visualforce)

## Use in Visualforce ##
```javascript
var initLookup=function (){
    $Lightning.use("c:VisualforceLightningApp", function () {
        $Lightning.createComponent(
            "c:Lookup", {
                "label":"Account", 
                "pluralLabel":"Accounts",
                "sObjectAPIName":"Account",
                "listIconSVGPath":"standard:account",
                "listIconClass":"slds-icon-standard-account",
                "callback": function(fieldValue, fieldAPIName, sObjectAPIName){
                    console.log(fieldValue);
                    //update hidden field
                    document.getElementById('lkp_accountId').value = fieldValue;
                }
            },"customLookup",function (cmp) {}
       );
  });       
}
initLookup();
```
## Use in Lightning ##
1. Create Component
```xml
<c:Lookup 
	label="Account" 
	pluralLabel="Accounts" 
	sObjectAPIName="Account" 
	listIconSVGPath="standard:account" 
	listIconClass="slds-icon-standard-account" 
	lookupChangeEvent="{!c.handleObjectIdUpdate}"/>
```
2. Create Controller
```javascript
({
    /**
     * Handler for receiving the lookupchange event
     */
	handleObjectIdUpdate : function(cmp, event, helper) {
		// Get the Id from the Event
		var fieldValue = event.getParam("fieldValue");
		var fieldAPIName = event.getParam("fieldAPIName");
		var sObjectAPIName = event.getParam("sObjectAPIName");

			//display record id
		console.log(fieldValue);

		// Set the Id bound to the View
		cmp.set('v.recordId', fieldValue);
	}
})
```
<img src="https://github.com/davidbrowaeys/SMS-SFDEV-TOOLKIT/blob/master/Lightning/Lookup/sms_lightning_lookup.gif"/>




