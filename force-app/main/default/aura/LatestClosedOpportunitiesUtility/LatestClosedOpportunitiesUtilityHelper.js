/**
 * Description:
 * Common JS functions used by the '...LatestVunnen...' Components 
 * (that are using LatestClosedOpportunities server side controller).
 * Currently used in:
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
     * Retrieve the Top N (or fewer) Opportunities (retrieved records determined by
     * the method and the User-selected filter criteria values), adjust the display
     * height and display the list.
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Introduced.
     **/
    helperRetrieveOpportunities : function(cmp, method, params) {
        cmp.set("v.IsSpinner", true);
		var action = cmp.get(method);
        if(params){
            action.setParams(params);
        }
        action.setCallback(this, function(response){ 
            var result = response.getReturnValue();
            if(response.getState() === "SUCCESS"){
                cmp.set('v.opportunity', result);
                if(result != null || result != ''){
					var heightcount = 60 + (25*(result.length));
					cmp.set("v.dynamicheight",heightcount);
				}
            }
			cmp.set("v.IsSpinner", false);
        });
        $A.enqueueAction(action);
    }
})