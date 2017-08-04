({

  handleDateChange: function(component, event, helper) {

    var callback = component.get("v.callback");
    if (callback){
      callback(event.getParam("value"));
    }
  },

  handleSubmit: function (component, event, helper){
    event.preventDefault();
    return false;
  }
})