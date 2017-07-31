({
    /**
     * Handler for receiving the updateLookupIdEvent event
     */
    handleObjectIdUpdate : function(cmp, event, helper) {
        // Get the Id from the Event
        var fieldValue = event.getParam("fieldValue");
		var fieldAPIName = event.getParam("fieldAPIName");
        var sObjectAPIName = event.getParam("sObjectAPIName");
 
        // Set the Id bound to the View
        cmp.set('v.recordId', fieldValue);
        
        var callback = cmp.get('v.callback');
        if(callback) callback(fieldValue, fieldAPIName, sObjectAPIName);
    }
})