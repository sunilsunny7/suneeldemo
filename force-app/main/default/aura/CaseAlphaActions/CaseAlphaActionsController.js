({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');     
        var action = component.get("c.getCase");
        console.log("init");
        action.setParams({ caseId : recordId }); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            if (state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                  console.log(result);
               	component.set("v.EnableSend", result['EnableSend']);
               	component.set("v.EnableRefresh", result['EnableRefresh']);
                component.set("v.FieldValidations", result['FieldValidations']);
            }
        });
        $A.enqueueAction(action);  
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
    
    sendCaseClick : function (component, event, helper) {
        console.log("sending case...");
        
        var recordId = component.get('v.recordId');     
        var action = component.get("c.sendToAlphaL");
        
        action.setParams({ caseId : recordId }); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                console.log(result);
                
                if(result['IsSuccess']){
                    resultsToast.setParams({
                        "title": "Succes",
                        "message": result['SuccessMessage'],
                        "type": "success"
                    });
                    
                   resultsToast.fire();
                }else{                   
                    resultsToast.setParams({
                        "title": "Something went wrong...",
                        "message": result['ErrorMessages'],
                        "type": "error"
                    });
                    resultsToast.fire();
                }
               
               component.set("v.EnableSend", result['EnableSend']);
               component.set("v.EnableRefresh", result['EnableRefresh']);
                
                 $A.get('e.force:refreshView').fire();
            }
            console.log("sending complete");
        });
        $A.enqueueAction(action);   
    },
    
    refreshCaseClick  : function (component, event, helper) {
        var recordId = component.get('v.recordId');     
        var action = component.get("c.refreshFromAlphaL");
        
        console.log("refreshing case...");        
        action.setParams({ caseId : recordId}); 
        
        action.setCallback(this, function(response){      
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            if (state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());                
                console.log(result); 
                
                if(result['IsSuccess']){
                    resultsToast.setParams({
                        "title": "Succes",
                        "message": result['SuccessMessage'],
                        "type": "success"
                    });
                    resultsToast.fire();
                    $A.get('e.force:refreshView').fire();
                }else{                   
                    resultsToast.setParams({
                        "title": "Something went wrong...",
                        "message": result['ErrorMessages'],
                        "type": "error"
                    });
                    resultsToast.fire();
                }   
            }
            console.log("refreshing complete");
        });
        $A.enqueueAction(action);   
    } 
})