/**
 * Created by kwn687 on 2021-10-21.
 */

({
	doInit : function(component, event, helper) {
        // Grab search query from URL
        var searchQuery = component.get("v.search");

        // Convert search query into SF expected format
        var stringToEncode = '{"componentDef":"forceSearch:search","attributes":{"term":"'+ searchQuery + '","scopeMap":{"type":"TOP_RESULTS"},"context":{"disableSpellCorrection":false,"searchSource":"ASSISTANT_DIALOG","SEARCH_ACTIVITY":{"term":"'+ searchQuery + '"}}}}';
        var encodedString = btoa(stringToEncode);

        // Redirect user (this only works from Lightning App, won't work from components)
        window.location = "/one/one.app?source=alohaHeader#" + encodedString;

	}
})