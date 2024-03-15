({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
		if(recordId !== undefined){
            var action = component.get("c.getOrgNumber");
            action.setParams({ accountId : recordId});   
            action.setCallback(this, function(response){
                component.set("v.OrgNumber", response.getReturnValue()); 
                var evt = $A.get("e.c:C2BLoadEvent");
                evt.setParams({
                    "OrgNumber": response.getReturnValue()
                });
                evt.fire();
            });
            $A.enqueueAction(action);
        }
    },
    
    showSpinner : function (component, event, helper) {        
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-show');      
    },
    
    hideSpinner  : function (component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-show');
        $A.util.addClass(spinner,  'slds-hide');    
    }
})