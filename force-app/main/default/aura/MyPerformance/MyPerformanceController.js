({
    doInit : function(component, event, helper) {
        var getYps = component.get("c.getYps");
        getYps.setParams({ ypsId : component.get("v.ypsId")});
        getYps.setCallback(this, function(response){
            var yps = response.getReturnValue();
            if(yps != null){
                component.set("v.yps", yps); 
                var evt = $A.get("e.c:loadYearlyPerformanceScore");
                evt.setParams({
                    "yearlyPerformanceScore": yps
                });
                evt.fire();
            }else{
                component.set("v.dataMissing", true); 
            }
            
        });
        $A.enqueueAction(getYps);
    },
    
    
    showSpinner : function (component, event, helper) {
        
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-show');      
    },
    
    hideSpinner  : function (component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-show');
        $A.util.addClass(spinner,  'slds-hide');    
    },
    close : function (component, event, helper) {
        component.set("v.dataMissing", false);
         
    },
    destroyComponent  : function (component, event, helper) {
        component.destroy();   
    },
    
})