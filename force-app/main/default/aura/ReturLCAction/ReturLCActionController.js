({
    doInit : function(component, event, helper) {
        var picklistAction = component.get("c.getPickListValues");
        picklistAction.setCallback(this, function(response){      
            var state = response.getState();
            if (state === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.picklist", result);
                component.find("closeReason").set("v.value", result[0].Value);
            }
        });
        
        $A.enqueueAction(picklistAction); 
    },
    onSelectChange : function(component, event, helper){
        var reason = component.find("closeReason").get("v.value");
        if(reason === "Annat"){
            component.set("v.ShowSubField", true);
        }else{
            component.set("v.ShowSubField", false);
        }
    },
    
    submitClick : function(component, event, helper){
        
        var closeReason = component.find("closeReason");
        var otherReason = component.find("otherReason");
       if(closeReason.get("v.value") === "Annat" && otherReason.get("v.value") === undefined){
            otherReason.set("v.errors", [{message: $A.get("$Label.c.RLC_ReqError")}]);
        }else{
            var recordId = component.get('v.recordId');
            if(recordId !== undefined){
                
                var picklistAction = component.get("c.sendLeadToLC");
                picklistAction.setParams({ leadId : recordId,  
                                          closeReason : closeReason.get("v.value"), 
                                          otherReason : otherReason.get("v.value")}); 
                picklistAction.setCallback(this, function(response){ 
               
                    var state = response.getState();
                    if (state === 'SUCCESS'){
                        var result = response.getReturnValue();
                        if(result === "Success"){
                           $A.get("e.force:showToast").setParams({
                                "title": "Succes",
                                "message": $A.get("$Label.c.RLC_Success")
                            }).fire();
                            $A.get('e.force:refreshView').fire();
                            $A.get("e.force:closeQuickAction").fire();
                        }else{
                            component.set("v.HasError", true);
                            component.set("v.ErrorMsg", result);
                        }
                    }
                });
                
                $A.enqueueAction(picklistAction);
            }
        }
    },
   cancelClick : function (component, event, helper) { 
      $A.get("e.force:closeQuickAction").fire();
    },
    hideError : function (component, event, helper) { 
        component.set("v.HasError", false);
        component.set("v.IsSuccess", false);
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