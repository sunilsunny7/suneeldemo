({
	doinit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
		var redirectURL = component.get("v.gourl")+recordId;
       // alert(component.find("customTab__item").get("v.HTMLAttributes").name);
      
        component.set("v.gourl", redirectURL);

	}
})