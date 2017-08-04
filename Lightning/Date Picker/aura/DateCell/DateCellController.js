({
    handleClick : function(component, event, helper) {
	var click = component.getEvent("dateCellClick");
        console.log('Datecell controller click' + click);
        try{
            click.fire();
        }catch(err){
            console.log(err.message);
            console.log(err.name);
            console.log(err.stack);
        }
    }
})