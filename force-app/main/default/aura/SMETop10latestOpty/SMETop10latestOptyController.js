({
    doInit: function(component, event, helper) {
        var action = component.get("c.getlistoftop10latestclosedSMESOHOopportunity");
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.opportunity', result);
                //alert(result);
                if (result != null || result != '') {
                    var heightcount = 145 + (25 * (result.length));
                    component.set("v.dynamicheight", heightcount);
                }
            }

        });
        $A.enqueueAction(action);
    },
    handleClick: function(cmp, event, helper) {
        var buttonstate = cmp.get('v.buttonstate');
        var index = event.getSource().get("v.tabindex");
        var toastRef = $A.get('e.force:showToast');
        //alert(event.getSource().get("v.state"));
        //alert(event.currentTarget.dataset.id);	
        cmp.set("v.IsSpinner", true);
        cmp.set('v.buttonstate', !buttonstate);
        var action = cmp.get("c.numberofLikesonOpty");
        action.setParams({
            "OppId": index
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var state = response.getState();
            if (state === 'SUCCESS') {
                if (!(result.includes('failed'))) {
                    $A.get('e.force:refreshView').fire();
                } else {
                    //alert(result);

                    toastRef.setParams({
                        'type': 'Error',
                        'title': 'Error',
                        'message': result,
                        'mode': 'dismissible'
                    });
                    toastRef.fire();
                    $A.get('e.force:refreshView').fire();

                }
            }

            //alert(result);
        });
        $A.enqueueAction(action);
        //$A.get("event.force:refreshView").fire();
    },

    handleLikeView: function(cmp, event, helper) {
        var OppId = event.getSource().get("v.title");
        cmp.set('v.OppId', OppId);
        //  alert(OppId);
        cmp.set('v.modalView', true);
    },
})