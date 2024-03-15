({
    doinit: function(component, event, helper) {      
        // Fetch the account list from the Apex controller   
        var recordId = component.get('v.recordId'); 
        var action = component.get("c.getOpportunity");
        action.setParams({ caserecordId : recordId}); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            var result = response.getReturnValue();
            if(result != null){
                if (state === 'SUCCESS' && result.length != 0){
                    component.set("v.viewOpptyId",result);
                    component.set("v.showpannel",true);
                }
            }
            if (state === 'SUCCESS' && result == null){
                component.set("v.viewOpptyId",null);
                component.set("v.showpannel",false);
            } 
        });
        $A.enqueueAction(action);
    },
    showSpinner : function (component, event, helper) {        
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-show');  
    }
    ,
    hideSpinner  : function (component, event, helper) { 
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-show');
        $A.util.addClass(spinner, 'slds-hide');    
    }
})