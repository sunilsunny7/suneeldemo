/**
 * Description:
 * Aura component implements a list of the Top 10 most valuable recently closed Cygate Opportunities, 
 * displayed on the Cygate Home page.
 * Component:
 *  - displays the list
 *  - allows Users to like an Opportunity
 *  - allows Users to examine the list of Users that have liked an Opportunity
 *  - allows Users to filter Opportunities
 * 
 * Modifications:
 * 02.12.2022 [Tomass Brazovskis] SALEF-7566 - Modified. Added a 'Like' button. Solution copied from LatestVunnenOpportunities.
 * 26.06.2023 [Tomass Brazovskis] LTAT-10218 - Modified. Component adapted to extend LatestClosedOpportunitiesUtility
 *            component and use its functions. handleFilterChanges introduced to retrieve Opportunities upon filter value changes.
 **/
({

    /**
     * Description:
     * Retrieve the Top 10 (or fewer) most valuable recently won Opportunities,
     * adjust the display height and display the list
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Refactored to allow filtering and use
     *              c:LatestClosedOpportunitiesUtility functions.
     **/
    doInit : function(component, event, helper) {
        helper.helperRetrieveOpportunities( component, 
            "c.getlistoftopclosedopportunitycygate",
            {"doFilterByRegion": false});
    },

    /**
     * Description:
     * Add or remove a User's Like for a listed Opportunity 
     * Modifications:
     * 02.12.2022 [TB] SALEF-7566 - Introduced/Copied from LastVunnenOpportunitiesController.js
     */
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
    
    /**
     * Description:
     * Display a list of all Users that have Liked an Opportunity 
     * Modifications:
     * 02.12.2022 [TB] SALEF-7566 - Introduced/Copied from LastVunnenOpportunitiesController.js
     */
    handleLikeView: function(cmp, event, helper) {
        var OppId = event.getSource().get("v.title");
        cmp.set('v.OppId', OppId);
        cmp.set('v.modalView', true);
    },
    
    /**
     * Description:
     * Refresh the Opportunities list upon changes in filter values
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Introduced.
     **/
    handleFilterChanges: function(cmp, event, helper) {
        var doFilterByRegion = event.getParam('filterByRegion');
        helper.helperRetrieveOpportunities( cmp, 
            "c.getlistoftopclosedopportunitycygate",
            {"doFilterByRegion": doFilterByRegion});
    }
})