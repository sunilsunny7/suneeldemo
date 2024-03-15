({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var record = component.get("v.Quote");
        console.log('recordId..'+recordId);
        console.log('record..'+record);
        var action = component.get("c.getPathStatus");
        action.setParams({
            "quoteId": recordId
        });

        action.setCallback(this, function(response){
        var state = response.getState();
        if (component.isValid() && state === "SUCCESS") {
            var status = response.getReturnValue();
            console.log('status..'+status);
            if(status === 'Approved') {
                var message = 'Ändringar av kvantitet i offerten görs inne i varukorgen – klicka på knappen Konfigurera för att komma dit';
                component.set("v.Status", message);
            }
            helper.getStatus(component, event, helper);
        }
    });
        
        $A.enqueueAction(action);
           
}
})