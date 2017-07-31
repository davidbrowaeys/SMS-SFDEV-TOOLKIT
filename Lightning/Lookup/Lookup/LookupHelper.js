({

  //lookup already initialized
  initStatus: {},
  init: function(cmp) {
    var required = cmp.get('v.required');
    if (required) {
      var cmpTarget = cmp.find('lookup-form-element');
      $A.util.addClass(cmpTarget, 'slds-is-required');
    }
  },

  /**
   * Perform the SObject search via an Apex Controller
   */
  doSearch: function(cmp) {
    // Get the search string, input element and the selection container
    var searchString = cmp.get('v.searchString');
    var inputElement = cmp.find('lookup');

    var lookupList = cmp.find('lookuplist');
    var mainLookupDiv = cmp.find('lookup-div');
    //var lookupListItems = cmp.find('lookuplist-items');
    //var lookupInfo = cmp.find('lookupinfo');

    // Clear any errors and destroy the old lookup items container
    inputElement.set('v.errors', null);

    // We need at least 2 characters for an effective search
    if (typeof searchString === 'undefined' || searchString.length < 2) {
      // Hide the lookuplist
      $A.util.removeClass(mainLookupDiv, 'slds-is-open');
      return;
    }

    // Show the lookuplist
    $A.util.addClass(mainLookupDiv, 'slds-is-open');

    // Get the API Name
    var sObjectAPIName = cmp.get('v.sObjectAPIName');
    // Get the filter value, if any
    var filter = cmp.get('v.filter');

    // Create an Apex action
    var action = cmp.get('c.lookup');

    // Mark the action as abortable, this is to prevent multiple events from the keyup executing
    action.setAbortable();

    // Set the parameters
    action.setParams({ "searchString": searchString, "sObjectAPIName": sObjectAPIName, "filter": filter });

    // Define the callback
    action.setCallback(this, function(response) {
      var state = response.getState();

      // Callback succeeded
      if (cmp.isValid() && state === "SUCCESS") {
        // Get the search matches
        var matches = response.getReturnValue();

        // If we have no matches, return nothing
        if (matches.length == 0) {
          cmp.set('v.matches', null);
          return;
        }

        // Store the results
        cmp.set('v.matches', matches);
      } else if (state === "ERROR") // Handle any error by reporting it
      {
        var errors = response.getError();

        // if (errors) {
        //   if (errors[0] && errors[0].message) {
        //     this.displayToast('Error', errors[0].message);
        //   }
        // } else {
        //   this.displayToast('Error', 'Unknown error.');
        // }

      }
    });

    // Enqueue the action
    $A.enqueueAction(action);
  },

  /**
   * Handle the Selection of an Item
   */
  handleSelection: function(cmp, event) {
    // Resolve the Object Id from the events Element Id (this will be the <a> tag)
    var objectId = this.resolveId(event.currentTarget.id);
    // Set the Id bound to the View
    cmp.set('v.recordId', objectId);

    // The Object label is the inner text)
    var objectLabel = event.currentTarget.innerText;

    // Update the Searchstring with the Label
    cmp.set("v.searchString", objectLabel);

    // Log the Object Id and Label to the console
    console.log('objectId=' + objectId);
    console.log('objectLabel=' + objectLabel);

    var compEvent = cmp.getEvent("lookupChangeEvent");
    compEvent.setParams({ "fieldAPIName": cmp.get('v.lookupAPIName'),  "sObjectAPIName": cmp.get('v.sObjectAPIName'),  "fieldValue": objectId });
	console.log('Fire selection...');
    compEvent.fire();

    var mainLookupDiv = cmp.find('lookup-div');
    $A.util.removeClass(mainLookupDiv, 'slds-is-open');
    console.log('remove slds-is-open...');

    // Hide the Input Element
    var inputElement = cmp.find('lookup');
    $A.util.addClass(inputElement, 'slds-hide');
    console.log('add slds-hide...');

    // Show the Lookup pill
    var lookupPill = cmp.find("lookup-pill");
    $A.util.removeClass(lookupPill, 'slds-hide');

    // Lookup Div has selection
    var inputElement = cmp.find('lookup-div');
    $A.util.addClass(inputElement, 'slds-has-selection');

    // Clear any error css
    var cmpTarget = cmp.find('lookup-form-element');
    $A.util.removeClass(cmpTarget, 'slds-has-error');

  },

  /**
   * Clear the Selection
   */
  clearSelection: function(cmp) {


    // Clear the Searchstring
    cmp.set("v.searchString", '');
    cmp.set('v.recordId', null);

    //use events, not a callback
    var compEvent = cmp.getEvent("lookupChangeEvent");
    compEvent.setParams({ "fieldAPIName": cmp.get('v.lookupAPIName'),  "sObjectAPIName": cmp.get('v.sObjectAPIName'),  "fieldValue": "" });
    compEvent.fire();

    // Hide the Lookup pill
    var lookupPill = cmp.find("lookup-pill");
    $A.util.addClass(lookupPill, 'slds-hide');

    // Show the Input Element
    var inputElement = cmp.find('lookup');
    $A.util.removeClass(inputElement, 'slds-hide');

    // Lookup Div has no selection
    var inputElement = cmp.find('lookup-div');
    $A.util.removeClass(inputElement, 'slds-has-selection');

    // If required, add error css
    var required = cmp.get('v.required');
    if (required) {
      var cmpTarget = cmp.find('lookup-form-element');
      $A.util.removeClass(cmpTarget, 'slds-has-error');
    }


  },

  handleBlur: function(cmp) {

    var required = cmp.get('v.required');
    if (required) {
      var cmpTarget = cmp.find('lookup-form-element');
      $A.util.addClass(cmpTarget, 'slds-has-error');
    }

  },

  /**
   * Resolve the Object Id from the Element Id by splitting the id at the _
   */
  resolveId: function(elmId) {
    var i = elmId.lastIndexOf('_');
    return elmId.substr(i + 1);
  },

  /**
   * Display a message
   */
  displayToast: function(title, message) {
    var toast = $A.get("e.force:showToast");

    // For lightning1 show the toast
    if (toast) {
      //fire the toast event in Salesforce1
      toast.setParams({
        "title": title,
        "message": message
      });

      toast.fire();
    } else // otherwise throw an alert
    {
      alert(title + ': ' + message);
    }
  },

  loadFirstValue: function(cmp) {

    var action = cmp.get('c.getCurrentValue');
    var self = this;
    action.setParams({
      'type': cmp.get('v.sObjectAPIName'),
      'value': cmp.get('v.recordId'),
    });

    action.setCallback(this, function(a) {
      if (a.error && a.error.length) {
        return $A.error('Unexpected error: ' + a.error[0].message);
      }
      var result = a.getReturnValue();
      cmp.set("v.searchString", result);

      if (null != result) {
        // Show the Lookup pill
        var lookupPill = cmp.find("lookup-pill");
        $A.util.removeClass(lookupPill, 'slds-hide');

        // Lookup Div has selection
        var inputElement = cmp.find('lookup-div');
        $A.util.addClass(inputElement, 'slds-has-selection');
      }
    });
    $A.enqueueAction(action);
  }
})