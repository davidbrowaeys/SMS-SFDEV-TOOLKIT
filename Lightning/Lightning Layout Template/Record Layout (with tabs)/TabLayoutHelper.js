({
    doInit : function(cmp) {
        var self=this;
        $('.slds-tabs--scoped__link').click(function (ev) {
            $(this).parent().parent().find(".slds-tabs--scoped__item").removeClass("slds-active");
            //hide all tab contents
            $(this).parent().parent().parent().find(".slds-tabs--scoped__content").removeClass("slds-show");
            $(this).parent().parent().parent().find(".slds-tabs--scoped__content").addClass("slds-hide");
            //activate selected tab item
            $(this).parent().addClass("slds-active");
			var tabContent = $(this).attr("aria-controls");
            //display selected tab content
            $('#'+tabContent).addClass("slds-show");
            $('#'+tabContent).removeClass("slds-hide");
        });
    }
})