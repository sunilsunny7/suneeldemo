({
    doInit : function(component, event, helper) {
        helper.loadTables();
    },
    
    onAccountChange: function (component, event, helper){ 
        var accId = component.get('v.account.Account__c');       
        var sa = component.get("v.SelectedAccounts");
        
        var toast = $A.get("e.force:showToast").setParams({
            "title": "Error",
            "message": $A.get("$Label.c.SAT_Account_already_added"),
            "type": "error"
        });
        
        for(var i = 0; i < sa.length; i++){
            if(sa[i].KeyAccount.Id === accId){
                toast.fire();
                return;
            }
            for(var y = 0; y < sa[i].Accounts.length; y++){
                if(sa[i].Accounts[y].Id === accId){
                    toast.fire();
                    return;
                }
            }
        }
        
        if(accId != ''){
            var action = component.get("c.getSelectedAccounts");
            action.setParams({ accountId : accId}); 
            action.setCallback(this, function(response){      
                var state = response.getState();
                if (state === 'SUCCESS'){
                    $('#account-table').dataTable().fnAddData(response.getReturnValue().Accounts);
                    var sa = component.get("v.SelectedAccounts");
                    sa.push(response.getReturnValue());
                    component.set("v.SelectedAccounts", sa);
                }
            });
            $A.enqueueAction(action); 
        }
    },
    
    handleRemoveAccount: function (component, event){ 
        var keyId = event.getParam("KeyAccountId");
        $('#account-table').DataTable().rows(function (idx, data, node) { return data.ParentId === keyId || data.Id === keyId ? true : false;}).remove().draw();
        
        var sa = component.get("v.SelectedAccounts");
        for(var i = 0; i < sa.length; i++){
            if(sa[i].KeyAccount.Id == event.getParam("KeyAccountId")){
                sa.splice(i, 1);
            }
        }
        component.set("v.SelectedAccounts", sa);  
    },
    
    onCreateTargetsClick: function(component,event,helper){       
        var oppId = component.get("v.recordId");        
        var jsonExIds = helper.getJsonExcludedAccounts($('#account-table').DataTable().rows({selected: true}).data());       
        var jsonAccsIds = helper.getJsonKeyAccountIds(component.get("v.SelectedAccounts"));
        
        var accId = component.get('v.account.Account__c');
        if(accId != ''){
            var action = component.get("c.createTargetAccounts");
            action.setParams({ keyAccIds : jsonAccsIds, excludedAccIds: jsonExIds, opportunityId : oppId }); 
            action.setCallback(this, function(response){      
                var state = response.getState();
                var result = JSON.parse(response.getReturnValue());
                
                if (state === 'SUCCESS'){
                    if(result.IsSuccess){
                        
                        var label = result.Size + ": " + $A.get("$Label.c.SAT_Have_been_created");
                        if(result.AlreadyCreatedSize != "0"){
                            label += ", "  + result.AlreadyCreatedSize + ": " + $A.get("$Label.c.SAT_Had_already_been_created");
                        }
                        $A.get("e.force:showToast").setParams({
                            "title": "Success",
                            "message": label,
                            "type": "success"
                        }).fire();
                        $A.get('e.force:refreshView').fire();
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                    }else{
                        component.set("v.HasError", true);
                        component.set("v.ErrorMsg", result.ErrorMessage);
                    }  
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