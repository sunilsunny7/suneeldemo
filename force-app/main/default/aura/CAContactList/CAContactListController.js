({
    doInit : function(component, event, helper) {        
        var recordId = component.get("v.recordId");
            var contactAction = component.get("c.getAccountContacts");
            contactAction.setParams({ callActivityId : recordId});   
            contactAction.setCallback(this, function(response){
                component.set("v.ContactStatus", response.getReturnValue()); 
            });
            $A.enqueueAction(contactAction);
            
            var campaignAction = component.get("c.getCallActivity");
            campaignAction.setParams({ callActivityId : recordId});   
            campaignAction.setCallback(this, function(response){
                component.set("v.CallActivity", response.getReturnValue()); 
            });
            $A.enqueueAction(campaignAction);
        
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