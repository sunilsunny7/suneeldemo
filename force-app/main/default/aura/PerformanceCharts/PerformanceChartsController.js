({	   
    handleLoadYearlyPerformanceScoreEvent : function(component, event, helper) {      
        var yps = event.getParam("yearlyPerformanceScore");
        component.set("v.yearlyPerformanceScore", yps);
        helper.loadCharts(component, yps);
        
    },
    destroyAll : function(component){
        if(component.get("v.compChart") != null){
            component.get("v.compChart").destroy();
        }
        if(component.get("v.contChart") != null){
            component.get("v.contChart").destroy();
        }

        component.destroy();
        
    },
    destroyCharts : function(component){
        if(component.get("v.compChart") != null){
            component.get("v.compChart").destroy();
        }
        if(component.get("v.contChart") != null){
            component.get("v.contChart").destroy();
        }
    }
})