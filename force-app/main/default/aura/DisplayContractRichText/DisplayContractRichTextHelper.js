({
    displayConditionalBox : function(component, event) {
        if(component.get("v.recordId")!=undefined){
            component.set("v.isLoading", true);         
            var action = component.get("c.getRichContext");
            action.setParams({ recordId: component.get("v.recordId")}); 
            action.setCallback(this, function(response){       
                var state = response.getState();
                if (state === 'SUCCESS'){
                    var result = response.getReturnValue();
                    component.set("v.IsShowTextArea",result.showRichContext);
                    component.set("v.LanguageLocalKey",result.LanguageLocaleKey);
                    component.set("v.isLoading", false);            
                }else {
                    component.set("v.isLoading", false);            
                }            
            });
            $A.enqueueAction(action);        
        }
    }
})