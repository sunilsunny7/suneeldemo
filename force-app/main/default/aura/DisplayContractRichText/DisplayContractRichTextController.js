({
    doInit : function(component, event, helper) { 
        helper.displayConditionalBox(component, event);      
        var channel = '/event/ContractEvent__e';
        const replayId = -1;        
        const empApi = component.find("empApi");        
        const callback = function (message) {
            helper.displayConditionalBox(component, event);
        };
        empApi.subscribe(channel, replayId, callback).then(function(newSubscription) {
        });
        const errorHandler = function (message) {
            console.error("Received error ", JSON.stringify(message));
        };
        empApi.onError(errorHandler);         
    }
})