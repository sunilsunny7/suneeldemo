({
    doInit : function(component, event, helper) {
          console.log(recordId);
        helper.loadTables();
        var recordId = component.get('v.recordId');
        console.log(recordId);
        if(recordId != ''){
            var action = component.get('c.getCampaignData');
            action.setParams({ callActivityId : recordId}); 
            action.setCallback(this, function(response){      
                var state = response.getState();
                if (state === 'SUCCESS'){
                    console.log(response.getReturnValue());
                    $('#campaign-data-table').dataTable().fnAddData(response.getReturnValue());
                }
            });
            $A.enqueueAction(action); 
        }
    },
    
    onCancelClick: function(component, event, helper){
        var dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire();
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