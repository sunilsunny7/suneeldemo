({
    
    doInit: function(component, event, helper){
        	var recordId = component.get("v.recordId");
    		var accId = component.get("v.AccId");
            var action = component.get("c.getAccountId");
            action.setParams({
            	"oppId": recordId
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                var AccountId = response.getReturnValue();
                component.set("v.AccId", AccountId);
                }
            });
            $A.enqueueAction(action);
         },

    guidedSelling: function(component, event, helper) {
        var oppId = component.get("v.recordId");
        window.open('/lightning/cmp/vlocity_cmt__vlocityLWCOmniWrapper?c__target=c:guidedSellingEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__ContextId=' + oppId, '_self');
    },
    
    precheck:function(component, event, helper) {
        var oppId = component.get("v.recordId");
        var accId = component.get("v.AccId");
        window.open('/lightning/cmp/vlocity_cmt__vlocityLWCOmniWrapper?c__target=c:preCheckValidationEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__ContextId=' + oppId + '&c__AccountId=' + accId, '_self');
    },
    
    precheckView:function(component, event, helper) {
        var oppId = component.get("v.recordId");
        var accId = component.get("v.AccId");
        window.open('/lightning/cmp/vlocity_cmt__vlocityLWCOmniWrapper?c__target=c:preCheckViewEnglish&c__layout=lightning&c__tabIcon=custom:custom18&c__ContextId=' + oppId + '&c__AccountId=' + accId, '_self');
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    }
})