({
    doInit : function(component, event, helper) {

        component.set('v.status',$A.get("$Label.c.AD_Redirecting"));
         if(component.get('v.recordId'))
                {
                     var recordId = component.get('v.recordId');
                 }
         else
                {
                     var recordId = JSON.stringify(component.get("v.pageReference").state.c__listOfLeads);
                }

        var action = component.get("c.getResult");
        action.setParams({ leadId : recordId});
        action.setCallback(this, function(response){
            var state = response.getState();
            var resultsToast = $A.get("e.force:showToast");
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            if (state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                component.set("v.isSuccess", result['IsSuccess']);
                if(result['IsSuccess']){
                    component.set('v.status',$A.get("$Label.c.AD_Success"));
                    resultsToast.setParams({
                        "title": "Success",
                        "message": $A.get("$Label.c.AD_Success_Message")
                    });

                    if(component.get('v.recordId'))
                                    {
                                         resultsToast.fire();
                                         dismissActionPanel.fire();
                                         $A.get('e.force:refreshView').fire();
                                     }
                             else
                                    {
                                     window.history.back();
                                    }
                }else{
                    component.set('v.status',$A.get("$Label.c.AD_Error_Message"));
                    component.set("v.errorMessages", result['ErrorMessages']);
                }
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
        $A.util.addClass(spinner,  'slds-hide');    
    },
    close : function (component, event, helper) {
     window.history.back();
     window.history.back();
    }
})