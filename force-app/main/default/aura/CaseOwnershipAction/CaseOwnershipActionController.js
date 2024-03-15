({
    doInit : function(component, event, helper) {
        
    },
    
    showSpinner : function (component, event, helper) {        
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-show');      
    },
    
    hideSpinner  : function (component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-show');
        $A.util.addClass(spinner, 'slds-hide');    
    },
    
    submitClick  : function (component, event, helper) {
        component.set('v.status',$A.get("$Label.c.Case_Assigning_Owner"));
        
        var recordId = component.get('v.recordId');     
        var action = component.get("c.getResult");
        
        action.setParams({ caseId : recordId}); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                component.set("v.isSuccess", result['IsSuccess']);
                if(result['IsSuccess']){
                    component.set('v.status',$A.get("$Label.c.Case_Owner_Assigned"));
                    component.set("v.directedTo", result['DirectedTo']);
                    resultsToast.setParams({
                        "title": "Succes",
                        "message": $A.get("$Label.c.Case_Success_Message"),
                        "type": "success"
                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();
                }else{                   
                    resultsToast.setParams({
                        "title": $A.get("$Label.c.Case_Error_Message"),
                        "message": result['ErrorMessages'],
                        "type": "error"
                    });
                    resultsToast.fire();
                } 
            }
        });
        $A.enqueueAction(action);   
    } 
})