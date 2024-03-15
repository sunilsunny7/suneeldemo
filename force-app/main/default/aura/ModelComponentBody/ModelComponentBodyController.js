({
    cancelops: function(component, event, helper) {
        // $A.get("e.force:closeQuickAction").fire();
        //  window.parent.close();    
        component.set("v.isOpen", false);
        component.set("v.IsSpinner",false);
       // var spinner = component.find("spinnerId");
        //$A.util.toggleClass(spinner, "slds-hide");
        //$A.get('e.force:refreshView').fire();
    },
    handleAction: function(component, event, helper) {
        component.set("v.isOpen", false);
        //var spinner = component.find("spinnerId");
        //$A.util.toggleClass(spinner, "slds-hide");
        component.set("v.IsSpinner",true);
        var workitemId = component.get("v.workId");
        var processType = component.get("v.secondbtn");
        var comment = component.find("comments1").get("v.value");
        var action = component.get("c.processRecords1"); //Calling server side method with selected records


        action.setParams({
            workItemIds: workitemId,
            processType: processType,
            comments: comment
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();

            var state = response.getState();
            //alert('state'+state);
            var toastRef = $A.get('e.force:showToast');
            if (state == 'SUCCESS') {
                var message = response.getReturnValue();
                if (message.includes(' Approve')) {
                    //component.set("v.IsSpinner",false);
                    toastRef.setParams({
                        'type': 'success',
                        'title': 'Success',
                        'message': message,
                        'mode': 'dismissible'
                    });
                } else {
                    toastRef.setParams({
                         
                        'type': 'error',
                        'title': 'Error',
                        'message': message,
                        'mode': 'dismissible'
                    });
                }
                toastRef.fire();
                $A.get('e.force:refreshView').fire();
            }
        });

        $A.enqueueAction(action);

    }
})