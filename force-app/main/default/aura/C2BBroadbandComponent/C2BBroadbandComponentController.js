({
    doInit : function(component, event, helper) {   
        var orgNumber = event.getParam("OrgNumber");
        component.set("v.OrgNumber", orgNumber); 
        var action = component.get("c.getBroadbandCategory");
        action.setParams({ orgnumber : orgNumber});   
        action.setCallback(this, function(response){
            component.set("v.DataList", response.getReturnValue()); 
            if(response.getReturnValue().length > 0){
                component.set("v.HasData", true);
            }
                component.set("v.IsLoaded", true);
               
        });
        $A.enqueueAction(action);    
    }
})