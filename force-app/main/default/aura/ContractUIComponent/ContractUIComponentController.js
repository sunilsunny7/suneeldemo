({
    doInit : function(component, event, helper) {        
        var getContracts = component.get("c.getContracts");
        getContracts.setParams({ AccountId : component.get("v.AccountId")});               
        getContracts.setCallback(this, function(response){
            //console.log(response.getReturnValue());
            component.set("v.Contracts", response.getReturnValue()); 
            component.set("v.Size", response.getReturnValue().length); 
        });
        $A.enqueueAction(getContracts);
    },
    actionClick : function(component, event, helper){
        var target = event.target || event.srcElement;
        var parent = target.parentElement || target.parentNode;
        //console.log(parent);
        if(parent !== undefined){
                $A.util.toggleClass (parent, "slds-is-open");
        }
    },
    editContractClick : function(component, event, helper) {    
        var target = event.target || event.srcElement;       
        if(target !== undefined) {              
            var newWindow = window.open('../'+ target.dataset.id + '/e?&isdtp=vw&retURL=apex/ContractClose&saveURL=apex/ContractClose', 'Popup Name' ,"width=800, height=550, scrollbars=yes,toolbar=no,status=no");
            newWindow.focus();
            
        } 
    },
    newContractClick : function(component, event, helper) {               
        var newWindow = window.open('../setup/ui/recordtypeselect.jsp?ent=Contract&retURL=/apex/ContractClose&isdtp=vw&save_new_url=/800/e?retURL=apex/ContractClose&saveURL=apex/ContractClose&accid=' + component.get("v.AccountId"), 'Popup Name' ,"width=800, height=550, scrollbars=yes,toolbar=no,status=no");
        newWindow.focus();            
        
    },
    deleteContractClick : function(component, event, helper) {
        if (confirm($A.get("$Label.c.conConfirmDelete"))) {
            var deleteContract = component.get("c.deleteContract");
            var target = event.target || event.srcElement; 
            if(target !== undefined) {  
                deleteContract.setParams({ ContractId : target.dataset.id});
                deleteContract.setCallback(this, function(response){
                    var contracts = component.get("v.Contracts");
                    //console.log(target.dataset.index);
                    contracts.splice(target.dataset.index, 1);
                    component.set("v.Contracts", contracts);
                    component.set("v.Size", contracts.length); 
                });
                $A.enqueueAction(deleteContract);            
            } 
        } else {
            // Do nothing!
        }
        
    },
    newProspectClick : function(component, event, helper) {    

        if (confirm($A.get("$Label.c.conConfirmCreateProspect"))) {
            var createProspect = component.get("c.createProspect");
            var target = event.target || event.srcElement;       
            if(target !== undefined) {              
                createProspect.setParams({ ContractId : target.dataset.id});
                createProspect.setCallback(this, function(response){
                    var data = JSON.parse(response.getReturnValue());
                      //console.log(data.IsSuccess);
                    if(data.IsSuccess){
                        sforce.one.editRecord(data.ReturnData);
                    }else{
                        component.set("v.ShowError", true);
                        component.set("v.ErrorMessage", data.ReturnData);
                    }                                        
                });
                $A.enqueueAction(createProspect);            
            }  
        }    
    },
    newOpportunityClick : function(component, event, helper) {    
        if (confirm($A.get("$Label.c.conConfirmCreateOpportunity"))) {
            var createOpportunity = component.get("c.createOpportunity");
            var target = event.target || event.srcElement;       
            if(target !== undefined) {              
                createOpportunity.setParams({ ContractId : target.dataset.id});
                createOpportunity.setCallback(this, function(response){
                      var data = JSON.parse(response.getReturnValue());
                    //console.log(data.IsSuccess);
                    if(data.IsSuccess){
                        sforce.one.editRecord(data.ReturnData);
                    }else{
                        component.set("v.ShowError", true);
                        component.set("v.ErrorMessage", data.ReturnData);
                    }
                });
                $A.enqueueAction(createOpportunity);            
            } 
        }  
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
    
    hideError : function(component, event, helper) {
        component.set("v.ShowError", false);
    }
    
})