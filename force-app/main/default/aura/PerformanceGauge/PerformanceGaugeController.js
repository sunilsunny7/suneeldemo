({
	handleLoadYearlyPerformanceScoreEvent : function(component, event, helper) {
        var yps = event.getParam("yearlyPerformanceScore");
        var title = component.get("v.title");
       var prop = component.get("v.prop");
		helper.loadGauge(yps, title, prop);
	}
})