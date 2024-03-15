({
    doInit: function(component, event, helper) { 
        // Fetch the account list from the Apex controller   
        var recordId = component.get('v.recordId'); 
        var action = component.get("c.getRecord");
        action.setParams({ caseinputId : recordId}); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            var result = response.getReturnValue();
            console.log(result);
            if (state === 'SUCCESS' && result.length != 0){
                component.set("v.product",result);
                component.set("v.displayBlock",true);
                var heightcount = 70*result.length;
                if(heightcount > 370){
                    component.set("v.dynamicheight",380); 
                }else if (heightcount < 150){
                    component.set("v.dynamicheight",150); 
                }else
                    component.set("v.dynamicheight",heightcount); 
            }
            if (state === 'SUCCESS' && result.length == 0){
                component.set("v.displayBlock",false);
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