/**
 * Description:
 * Aura component implements a modal window displaying a list of Users that have liked
 * an Opportunity whose Id has been passed as an argument.
 * 
 * Modifications:
 * 02.12.2022 [Tomass Brazovskis] SALEF-7566 - Modified. Commented out the invalid columns2 reference.
 **/
({
    cancelops: function(component, event, helper) {

        component.set('v.isOpen', false);
        $A.get('e.force:refreshView').fire();
    },
    doInit: function(component, event, helper) {
        var OppID = component.get("v.OppId1");
        // alert(component.get("v.OppId1"));
        var action = component.get("c.getLikedOppUser");
        action.setParams({
            'OppId': OppID
        });
        action.setCallback(this, function(response) {
            var result = response.getReturnValue();
            var heightcount = 110 + (25 * (result.length));
            component.set('v.Userlist', result);
            //alert(result);

        });
        $A.enqueueAction(action);
    },
})