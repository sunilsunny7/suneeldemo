({
    doInit : function(component, event, helper) {
        var action = component.get("c.getQuote");
        action.setParams({
            "ProcessInstanceStepId": component.get("v.recordId")
        });
        
        // Register the callback function
        action.setCallback(this, function(response) {
            if(response.getReturnValue() !=null ) {
                var data = response.getReturnValue();
                // Set the component attributes using values returned by the API call
                    component.set("v.Quote", data);
            }
        });
		
        // Invoke the service
        $A.enqueueAction(action);
        
		var action2 = component.get("c.getQuoteLineItem");
        action2.setParams({
            "ProcessInstanceStepId": component.get("v.recordId")
        });
        
        // Register the callback function
        action2.setCallback(this, function(response) {
            console.log('response : '+response);
            debugger;
            if(response.getReturnValue() !=null ) {
                var data2 = response.getReturnValue();
                debugger;
                // Set the component attributes using values returned by the API call
                console.log('data2 : '+data2);
                component.set("v.wrapper", data2);
            }
        });
        
		$A.enqueueAction(action2);
    }
})