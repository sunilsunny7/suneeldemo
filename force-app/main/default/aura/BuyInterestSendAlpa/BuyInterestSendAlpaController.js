({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId'); 
        var action = component.get("c.getRecord");
        action.setParams({ BuyId : recordId }); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            var result = JSON.parse(response.getReturnValue());
            console.log(result);
            var resultsToast = $A.get("e.force:showToast");
            if (state === 'SUCCESS'){
                var resultsToast = $A.get("e.force:showToast");
                //  $A.get('e.force:refreshView').fire();
                component.set("v.EnableSend",result['isBtnActive']);
            }
        });
        $A.enqueueAction(action); 
    },
    sendData : function(component, event, helper) {
        var recordId = component.get('v.recordId');     
        var action = component.get("c.SendAlpha");
        action.setParams({ recordId : recordId }); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            var result = JSON.parse(response.getReturnValue());
            console.log(result);
            var resultsToast = $A.get("e.force:showToast");
            if (state === 'SUCCESS'){
                var resultsToast = $A.get("e.force:showToast");
                if(result['isSuccess']){
                    resultsToast.setParams({
                        "title": "Success",
                        "message": result['SuccessMsg'],
                        "type": "success"
                    });
                    resultsToast.fire();
                }else{
                    resultsToast.setParams({
                        "title": "Error",
                        "message": result['ErrorMsg'],
                        "type": "error"
                    });
                    resultsToast.fire();
                }
                $A.get('e.force:refreshView').fire();
                component.set("v.EnableSend",result['isBtnActive']);
            }
        });
        $A.enqueueAction(action); 
    }
    ,
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