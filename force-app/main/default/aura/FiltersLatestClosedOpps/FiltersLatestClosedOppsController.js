/**
 * Description:
 * Aura component implements the filters to apply when retrieving the Top N Opportunity lists.
 * Component used in:
 *  - c:CygateLatestVunnen
 *  - c:CygateLatestVunnenOpportunities
 *  - c:CygateTopTenPipelineOpportunity
 * 
 * Modifications:
 * 26.06.2023 [Tomass Brazovskis] LTAT-10218 - Introduced.
 **/
({
    /**
     * Description:
     * Fire Filter Change Event upon User input.
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Introduced.
     **/
    onFilterChange : function(component, event, helper) {
        helper.fireFilterChangeEvent(component);
    }
})