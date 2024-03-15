({
    openClick : function(component, event, helper) {
        if(component.get('v.IsOpen')){
            component.set('v.IsOpen', false);
        }else{
            if(!component.get('v.IsLoaded')){
            
                var action;
                var methodType = component.get("v.MethodType");
                    //console.log(methodType);
                if(methodType === 'mobile'){
                    action = component.get("c.getMobSubOffering");
                }else if(methodType === 'broadband'){
                     action = component.get("c.getBroadbandOffering");
                }else if(methodType === 'function'){
                      action = component.get("c.getFunctionOffering");
                }
                
                action.setParams({ orgnumber : component.get('v.OrgNumber'), category: component.get('v.Category')});   
                action.setCallback(this, function(response){
                    //console.log(response.getReturnValue());
                    component.set("v.DataList", response.getReturnValue()); 
                    component.set('v.IsOpen', true);
                    component.set('v.IsLoaded', true);
                });
                $A.enqueueAction(action);
            }else{
                component.set('v.IsOpen', true);
            }
        }
        
    }
})