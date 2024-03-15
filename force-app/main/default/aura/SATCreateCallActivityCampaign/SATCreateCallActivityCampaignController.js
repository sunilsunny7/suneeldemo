({
    doInit : function(component, event, helper) {
        var oppId = component.get("v.recordId");
        
        if(oppId != ''){
            var action = component.get("c.getViewData");
            action.setParams({ upsellOppId : oppId}); 
            action.setCallback(this, function(response){      
                var state = response.getState();
                if (state === 'SUCCESS'){
                    var result = JSON.parse(response.getReturnValue());
                    if(result.IsSuccess){
                        component.set("v.taSize", result.Size);
                        component.set("v.campaignName", result.UpsellName);
                    }else{
                        component.set("v.ErrorMsg", result.ErrorMessage);
                        component.set("v.HasError", true);
                        console.log(result)
                        
                    }
                }
                component.set("v.IsLoaded",true);
            });
            $A.enqueueAction(action); 
        }
    },
    
    
    onCreateCampaignClick: function(component,event,helper){       
        var oppId = component.get("v.recordId");   
        var campName = component.get('v.campaignName');
        
        if(oppId != ''){
            var action = component.get("c.createCallActivityCampaign");
            action.setParams({ upsellOppId : oppId,  campaignName : campName }); 
            action.setCallback(this, function(response){      
                var state = response.getState();
                if (state === 'SUCCESS'){
                    var result = JSON.parse(response.getReturnValue());
                    if(result.IsSuccess){
                        $A.get("e.force:showToast").setParams({
                            "title": "Success",
                            "message": result.Size + ": " + $A.get("$Label.c.SAT_Call_Activities_Created"),
                            "type": "success"
                        }).fire();
                        $A.get('e.force:refreshView').fire();  
                    }else{                         
                        $A.get("e.force:showToast").setParams({
                            "title": "Success",
                            "message": result.ErrorMessage,
                            "type": "success"
                        }).fire();                        
                    }
                    
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");   
                    dismissActionPanel.fire();
                }
            });
            $A.enqueueAction(action); 
        }
    },
    
    onCancelClick: function(component, event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");   
        dismissActionPanel.fire();
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
    
})