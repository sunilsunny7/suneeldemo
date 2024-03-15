({
    doInit : function(component, event, helper){

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
    
    submitClick : function(component, event, helper){
     //   var selectedReqs = component.get("v.Table").rows({selected: true}).data();
     var selectedReqs = $('#req-table').DataTable().rows({selected: true}).data();
        var reqIds = [];
        
        for(var i = 0; i < selectedReqs.length; i++){
            reqIds.push(selectedReqs[i].Id);
        }
        
        var json = JSON.stringify(reqIds); 
        
        var action = component.get("c.connect");
        var recordId = component.get('v.recordId');
        action.setParams({ reqIds : json, 
                          solutionVerId : recordId}); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            var result = JSON.parse(response.getReturnValue());
            if (state === 'SUCCESS'){
                if(result.IsSuccess){
                    $A.get("e.force:showToast").setParams({
                        "title": $A.get("$Label.c.SV_Success"),
                        "message": $A.get("$Label.c.SV_Success_Message"),
                        "type": "success"
                    }).fire();
                    
                    if(result.HasApproval){
                        component.set("v.ApprovalID", result.ApprovalID);
                        component.set("v.HasApproval", result.HasApproval);
                    }
                    
                }else{
                    $A.get("e.force:showToast").setParams({
                        "title": "Error",
                        "message": result.ErrorMessage,
                        "type": "error"
                    }).fire();
                }                  
            }
        });
        $A.enqueueAction(action); 
        
    },
    
    update : function (component, event, helper) {
        $('#req-table').DataTable().destroy(true);
    },
    
    onOpportunityChange: function (component, event, helper){ 
        var oppId = component.get('v.SV.SV_Opportunity__c');
        var recordId = component.get('v.recordId');
        helper.loadTables();
        if(oppId !== ''){
            var action = component.get("c.getOppRequirements");
            action.setParams({ opportunityId : oppId, 
                              solutionVerId : recordId}); 
            action.setCallback(this, function(response){      
                var state = response.getState();
                if (state === 'SUCCESS'){
                    if(response.getReturnValue().length > 0){
                        component.set("v.Requirements", response.getReturnValue());
                        $('#req-table').dataTable().fnAddData(response.getReturnValue());
                    }
                }
            });
            $A.enqueueAction(action); 
        }
    },
    openApproval: function (component, event, helper){ 
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.ApprovalID")
        });
        navEvt.fire();
    }
})