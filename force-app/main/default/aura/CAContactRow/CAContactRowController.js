({
    addToCampaignClick  : function (component, event, helper) {   
        if(component.get("v.IsLocked") === false){
            component.set("v.IsLocked", true);
            var action  = component.get("c.addToCampagin");
            action.setParams({ contactId : component.get("v.Contact").Id, campaignId : component.get("v.Campaign") });          
            action.setCallback(this, function(response){
                component.set("v.IsCampaignMember", true);
                component.set("v.IsLocked", false);
            });
            $A.enqueueAction(action); 
        }
    },
    removeFromCampaignClick  : function (component, event, helper) {
        if(component.get("v.IsLocked") === false){
            component.set("v.IsLocked", true);
            var action  = component.get("c.removeFromCampagin");
            action.setParams({ contactId : component.get("v.Contact").Id, campaignId : component.get("v.Campaign") });          
            action.setCallback(this, function(response){
                component.set("v.IsCampaignMember", false);
                component.set("v.IsLocked", false);
            });
            $A.enqueueAction(action);   
        }
    },
        goToContact  : function (component, event, helper) {
          var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": component.get("v.Contact").Id
            });
            navEvt.fire(); 
        
    }
})