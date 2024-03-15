({
    doInit : function(component, event, helper) {
        var getScores = component.get("c.getLightningScores");
        var getResults = component.get("c.getLightningResults");
        getScores.setCallback(this, function(response){
            component.set("v.scores", response.getReturnValue());
        });
        getResults.setCallback(this, function(response){
            var returnValues = response.getReturnValue();
            for(var i = 0; i < returnValues.length; i++){
                returnValues[i].Result__c = Math.round(returnValues[i].Result__c);
            }            
            component.set("v.results", returnValues);
        });
        $A.enqueueAction(getResults);
        $A.enqueueAction(getScores);
    },
    
    showScores : function(component, event){
        var scoreTab = component.find('scoreTab');
        
        if(!$A.util.hasClass(scoreTab,  'slds-active')){
            var resultTab = component.find('resultTab');
            var scoreContent = component.find('scoreContent');
            var resultContent = component.find('resultContent');
            
            $A.util.addClass(scoreTab, 'slds-active');
            $A.util.removeClass(resultTab, 'slds-active');
            
            $A.util.addClass(scoreContent, 'slds-show');
            $A.util.removeClass(scoreContent, 'slds-hide');
            $A.util.removeClass(resultContent, 'slds-show');
            $A.util.addClass(resultContent, 'slds-hide');
        };               
    },
    
    showResults : function(component, event){      
        var resultTab = component.find('resultTab');
        
        if(!$A.util.hasClass(resultTab,  'slds-active')){
            var scoreTab = component.find('scoreTab');
            var scoreContent = component.find('scoreContent');
            var resultContent = component.find('resultContent');
            
            $A.util.addClass(resultTab, 'slds-active');
            $A.util.removeClass(scoreTab, 'slds-active');
            
            $A.util.addClass(resultContent, 'slds-show');
            $A.util.removeClass(resultContent, 'slds-hide');
            $A.util.removeClass(scoreContent, 'slds-show');
            $A.util.addClass(scoreContent, 'slds-hide');
        };
    },
    backButtonClicked : function(component, event){
        component.set("v.showList", true);       
	    var event1 = $A.get("e.c:destroyComponentEvent");
	    event1.fire();

    },
    navigateToView : function(component, event){
        component.set("v.showList", false);
         var target = event.target || event.srcElement;
        var ypsId;
        if(target !== undefined) { 
            ypsId = target.dataset.id;
        }

        $A.createComponent("c:MyPerformance", { ypsId: ypsId }, 
            function(view) {
               component.set("v.body", view);
        });                 
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
    }
})