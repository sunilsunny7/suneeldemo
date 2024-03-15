({
	doInit : function(component, event, helper) {
		var action = component.get("c.getListOfLatestClosedOpportunityFiber");
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
			var result = response.getReturnValue();
            component.set('v.opportunity', result);
                if(result != null || result != ''){
            var heightcount = 110 + (25*(result.length));
			component.set("v.dynamicheight",heightcount);
			}
			}
        });
        $A.enqueueAction(action);
},
    handleClick: function(cmp, event, helper) {
        var index = event.getSource().get("v.tabindex");
        var toastRef = $A.get('e.force:showToast');
        cmp.set("v.IsSpinner", true);
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
        });
        $A.enqueueAction(action);
    },

    handleLikeView: function(cmp, event, helper) {
        var OppId = event.getSource().get("v.title");
        cmp.set('v.OppId', OppId);
        cmp.set('v.modalView', true);
    },
})