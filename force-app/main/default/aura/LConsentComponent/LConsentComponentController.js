({
    doInit : function(component, event, helper) {
        var ERROR_MSG = $A.get("$Label.c.CM_C2B_ERRORLOG");
        var ERROR_NO_ORG_MSG = $A.get("$Label.c.CM_NO_ORG_Nr_ERROR");
        if(component.get("v.recordId") != undefined){
            //Get C2b data through HTTP GET Method
            var getc2bdata = component.get("c.getc2bData");
            getc2bdata.setParams({ "recId": component.get("v.recordId")});
            getc2bdata.setCallback(this, function(response){      
                var state = response.getState();
                if (state === 'SUCCESS'){
                    console.log('Response:-'+response.getReturnValue());
                    if(response.getReturnValue() !=null){
                        component.set("v.datacontainer",response.getReturnValue());
                        component.set("v.Olddatacontainer", JSON.parse(JSON.stringify(component.get("v.datacontainer"))));
                    }else{
                        component.set("v.HasError", true);
                        component.set("v.ErrorMsg", ERROR_MSG);
                    }
                }
            });
            $A.enqueueAction(getc2bdata);
            
            
            // Get Salesforce Account Consent Data
            var getaccountdata = component.get("c.getAccount");
            getaccountdata.setParams({ "Id": component.get("v.recordId")});
            getaccountdata.setCallback(this, function(response){      
                var state = response.getState();
                if (state === 'SUCCESS'){
                    component.set("v.Account",response.getReturnValue());
                    //  component.set("v.ContactRole",response.getReturnValue().Customer_Role__c);
                    var AccOwnrId = response.getReturnValue().OwnerId !=null ? response.getReturnValue().OwnerId.substring(0,15):'';
                    var TeliaMgrId = response.getReturnValue().Telia_Service_Manager__c !=null ? response.getReturnValue().Telia_Service_Manager__c.substring(0,15):'';
                    var userEmail = $A.get("$SObjectType.CurrentUser.Email").toUpperCase();
                    if(!userEmail.includes("CYGATE")){
                        component.set("v.edit", true);
                    }
                    if(response.getReturnValue().Org_Nr__c == null || response.getReturnValue().Org_Nr__c == ''){
                        component.set("v.ErrorMsg", ERROR_NO_ORG_MSG);
                    }
                }
            });
            $A.enqueueAction(getaccountdata);
        }
    },
    
    handleEdit : function(component, event, helper) {
        //Set button visibility matrix
        component.set("v.HasError", false);
        component.set("v.isSuccess", false);
        component.set("v.edit", false);
        component.set("v.save", true);
        component.set("v.cancel", true);
    },
    handleSave : function(component, event, helper) {
        
        //Button visibility set up
        component.set("v.save", false);
        component.set("v.cancel", false);
        component.set("v.edit", true); 
        
        //Get Custom Label Value
        var RES_MSG = $A.get("$Label.c.CM_C2B_ERRORLOG");
        var VAL_MSG = $A.get("$Label.c.CM_VALIDATIONMSG");
        
        // Component Attributes
        var customerName = component.get("v.consentGiven");
        var role = component.get("v.ContactRole");
        var accId = component.get("v.recordId");
        var org_nr = component.get("v.Account.Org_Nr__c");
        
        //Null Error Check
        if(($.trim(customerName) !='' && customerName != undefined) && ($.trim(role) !='' && role != undefined) && (org_nr !=undefined && org_nr !='')){
            
            // New Value container for request
            var businessValue = component.get("v.datacontainer");
            // Old Value container for request
            var oldValue = component.get("v.Olddatacontainer");
            console.log('OldValue'+JSON.stringify(oldValue.purposes));
            console.log('NewValue'+JSON.stringify(businessValue.purposes));
            
            //Callout to c2b for UdpateConsent 
            var setConsent = component.get("c.setConsenttoC2b");
            setConsent.setParams({ 
                "container" : JSON.stringify(businessValue),
                "oldcontainer" : JSON.stringify(oldValue),
                "CustomerProxy":customerName,
                "CustomerRole":role,
                "OrgId":org_nr });
            setConsent.setCallback(this, function(response){      
                var state = response.getState();
                if (state === 'SUCCESS'){
                    component.set("v.HasError", false);
                    var result = JSON.parse(response.getReturnValue());
                    console.log(result['status']);
                    if(result['status'] == 'SUCCESS'){
                        //Set success Message to screen
                        component.set("v.isSuccess", true);
                        //Update the Consent Collector details 
                        var updateconsent = component.get("c.updateconsent");
                        updateconsent.setParams({ "CustName" : customerName,"Id":accId ,"CustRole":role });
                        updateconsent.setCallback(this, function(response){      
                            var state = response.getState();
                            if (state === 'SUCCESS'){
                                //  Update the values from the response JSON
                                component.set("v.Account.Consent_Updated__c",response.getReturnValue().Consent_Updated__c);
                                component.set("v.Account.Consent_Updated_By__c",response.getReturnValue().Consent_Updated_By__c);
                                component.set("v.Account.Consent_Provided_by_Customer__c",response.getReturnValue().Consent_Provided_by_Customer__c);
                                component.set("v.Olddatacontainer",JSON.parse(JSON.stringify(component.get("v.datacontainer"))));
                                // component.set("v.ContactRole",response.getReturnValue().Customer_Role__c);
                            }
                        }); 
                        $A.enqueueAction(updateconsent);
                        
                    }else{
                        component.set("v.HasError", true);
                        component.set("v.ErrorMsg", RES_MSG);
                    }
                }
            });
            $A.enqueueAction(setConsent);
        }else{
            // No Org nr set up
            component.set("v.HasError", true);
            component.set("v.ErrorMsg", VAL_MSG);
            component.set("v.edit", false);
            component.set("v.save", true);
            component.set("v.cancel", true);
        }
    },
    
    handleCancel : function(component, event, helper) {
        
        // Set button visibility matrix 
        component.set("v.cancel", false);
        component.set("v.save", false);
        component.set("v.edit", true);
        //  component.set("v.HasError", false);
    },
    
    showSpinner : function (component, event, helper) {
        // Show loading spinner icon        
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-show');  
    },
    
    hideSpinner  : function (component, event, helper) { 
        // Hide loading spinner icon 
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-show');
        $A.util.addClass(spinner, 'slds-hide');    
    },
    handleUnchangedConsent : function (component, event, helper) { 
        // Update timestamp when no change in consent response
        var custName = component.get("v.Account.Consent_Provided_by_Customer__c");
        var custrole = component.get("v.ContactRole");
        var recordAccId = component.get("v.recordId");
        var updatetimestamp = component.get("c.updateconsent");
        // Set the Method Param
        updatetimestamp.setParams({ "CustName" : custName,
                                   "Id":recordAccId ,
                                   "CustRole":custrole });
        updatetimestamp.setCallback(this, function(response){      
            var state = response.getState();
            if (state === 'SUCCESS'){
                //  Update the values from the response JSON
                component.set("v.Account.Consent_Updated__c",response.getReturnValue().Consent_Updated__c);
                component.set("v.Account.Consent_Updated_By__c",response.getReturnValue().Consent_Updated_By__c);
            }
        }); 
        $A.enqueueAction(updatetimestamp);   
    }
})