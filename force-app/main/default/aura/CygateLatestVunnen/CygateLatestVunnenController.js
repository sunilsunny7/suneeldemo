/**
 * Description:
 * Aura component implements a list of the 10 most recently Won Cygate Opportunities, 
 * displayed on the Cygate Home page.
 * Component:
 *  - displays the list
 *  - allows Users to filter Opportunities
 * 
 * Modifications:
 * 26.06.2023 [Tomass Brazovskis] LTAT-10218 - Modified. Component adapted to extend LatestClosedOpportunitiesUtility
 *            component and use its functions. handleFilterChanges introduced to retrieve Opportunities upon filter value changes.
 **/
({
    /**
     * Description:
     * Retrieve the Top 10 (or fewer) most recently Won Opportunities,
     * adjust the display height and display the list.
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Refactored to allow filtering and use
     *            c:LatestClosedOpportunitiesUtility functions.
     **/
    doInit : function(component, event, helper) {
        helper.helperRetrieveOpportunities( component, 
            "c.getlistoflatestclosedopportunitycygate",
            {"doFilterByRegion": false});
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
            "c.getlistoflatestclosedopportunitycygate",
            {"doFilterByRegion": doFilterByRegion});
    }
})