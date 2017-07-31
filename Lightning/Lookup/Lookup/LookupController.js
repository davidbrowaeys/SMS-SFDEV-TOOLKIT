({
    /**
     * Search an SObject for a match
     */
    search : function(cmp, event, helper) {
        helper.doSearch(cmp);
    },

    /**
     * Select an SObject from a list
     */
    select: function(cmp, event, helper) {

        helper.handleSelection(cmp, event);
    },

    /**
     * Clear the currently selected SObject
     */
    clear: function(cmp, event, helper) {

        helper.clearSelection(cmp);
        event.preventDefault();
        return false;
    },

    /**
     * If the input is requred, check if there is a value on blur
     * and mark the input as error if no value
     */
     handleBlur: function (cmp, event, helper) {

         helper.handleBlur(cmp);
     },

    init : function(cmp, event, helper){
      try{
        //first load the current value of the lookup field
        helper.init(cmp);
        helper.loadFirstValue(cmp);

        }catch(ex){
          console.log(ex);
        }
      }
})