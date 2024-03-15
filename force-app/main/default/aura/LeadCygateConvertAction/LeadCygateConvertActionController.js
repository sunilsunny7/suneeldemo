({
    doInit : function(component, event, helper) {
        var recordId = component.get('v.recordId');
        
        var action = component.get("c.getLead");
        action.setParams({ leadId : recordId}); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            if (state === 'SUCCESS'){
                var result = response.getReturnValue();
                if(!result.Account__c){
                    component.set("v.HasError", true);
                    component.set("v.ErrorMsg", "You need to select the Account first");
                }else{
                    var lead = {'sobjectType': 'Lead',
                                'Name': result.Name,
                                'Account__c': result.Account__c,
                                'Account__r.Name': result.Account__r.Name,
                                'Email': result.Email
                               }
                    
                    component.set("v.lead", lead);
                    component.set("v.oppName", result.Account__r.Name + ' - ' + result.Name);
                    
                    var duplucateAction = component.get("c.getDuplicateContacts");
                    duplucateAction.setParams({ email : lead.Email}); 
                    duplucateAction.setCallback(this, function(response){      
                        var state = response.getState();
                        if (state === 'SUCCESS'){
                            if(response.getReturnValue().length !== 0){
                                component.set("v.duplicateContacts", response.getReturnValue());
                                component.set("v.selectedDupeId", response.getReturnValue()[0].Id);
                            }
                        }
                    });
                    
                    $A.enqueueAction(duplucateAction);
                }
            }
        });
        $A.enqueueAction(action);        
        
  /*      var rtAction = component.get("c.getOpportunityRecordTypes");
        rtAction.setParams({ }); 
        rtAction.setCallback(this, function(response){      
            var state = response.getState();
            if (state === 'SUCCESS'){
                component.set("v.recordTypes", response.getReturnValue());
            }
        });
        $A.enqueueAction(rtAction);  */
        
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
        var recordId = component.get('v.recordId');
        
        if(recordId !== undefined){
            var action = component.get("c.convertLead");
            var buyInterestId = component.get("v.selectedBiId");
            var dupeId = component.get("v.selectedDupeId");
            var oppName = component.get("v.oppName");
            var recordType = component.get("v.selectedRecordType");
            var accId = component.get("v.lead").Account__c;
            var overwriteContact = component.get("v.overwriteContact");
            console.log(overwriteContact);
            action.setParams({ leadId : recordId,
                              accId : accId,
                              oppName : oppName,
                              buyInterestId : buyInterestId,
                              recordType: recordType,
                              contactId: dupeId,
                              overwrite: overwriteContact
                             }); 
            action.setCallback(this, function(response){ 
                
                var state = response.getState();
                if (state === 'SUCCESS'){
                    var result = JSON.parse(response.getReturnValue());
                    //console.log(result);
                    if(result.IsSuccess === true){
                        if( (typeof sforce != 'undefined') && (sforce != null) ) {
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": result.ReturnData.opportunityid
                            });
                            navEvt.fire();
                        }else{
                            if(result.ReturnData.opportunityid){
                                window.location.href = '/' + result.ReturnData.opportunityid;
                            }else{
                                window.location.href = '/' + result.ReturnData.contactid;
                            }
                            
                        }
                        
                    }else{
                        component.set("v.HasError", true);
                        component.set("v.ErrorMsg", result.ErrorMessage);
                    }
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    
    
    dupeSelected : function (component, event, helper) { 
        var target = event.target || event.srcElement; 
        if(target !== undefined) {  
            component.set("v.selectedDupeId", target.dataset.id);
        }   
        console.log(component.get("v.selectedDupeId"));
    },
    
    recordTypeSelected : function (component, event, helper) { 
        component.set("v.selectedRecordType", component.find("recordTypePicklist").get("v.value"));
    },
    
    cancelClick : function (component, event, helper) { 
        if( (typeof sforce != 'undefined') && (sforce != null) ) {
            $A.get("e.force:closeQuickAction").fire();
        }else{
            window.location.href = '/' + component.get("v.recordId");
        } 
    },

     onChange: function(cmp, evt) {
		 var checkCmp = cmp.find("overwriteCheckbox");
         cmp.set("v.overwriteContact", checkCmp.get("v.checked"));
	 }
})