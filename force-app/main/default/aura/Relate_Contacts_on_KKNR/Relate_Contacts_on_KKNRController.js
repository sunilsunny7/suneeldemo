({
	doinit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
		
		//var redirectURL = "/lightning/r/Report/00O5E000000c6qjUAA/view?fv0="+recordId+"&fv1=false";
        var redirectURL = component.get("v.gourl")+recordId+"&fv1=true";
        var redirectURLActive = component.get("v.gourl")+recordId+"&fv1=false";

        component.set("v.gourl", redirectURL);
        component.set("v.gourlactive", redirectURLActive);

	}
})