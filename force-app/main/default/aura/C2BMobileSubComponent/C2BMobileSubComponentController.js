({
    doInit : function(component, event, helper) {   
        var orgNumber = event.getParam("OrgNumber");
        component.set("v.OrgNumber", orgNumber); 
        var msaAction = component.get("c.getMobSubCategory");
        
        msaAction.setParams({ orgnumber : orgNumber});   
        msaAction.setCallback(this, function(response){
            //console.log(response.getReturnValue());
            component.set("v.DataList", response.getReturnValue()); 
            if(response.getReturnValue().length > 0){
                component.set("v.HasData", true);
            }
            component.set("v.IsLoaded", true);
                      
        });
        $A.enqueueAction(msaAction);
        
    }
})