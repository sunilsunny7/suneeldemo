({
    doInit: function(component, event, helper) {
        // get the fields API name and pass it to helper function  
        var controllingFieldAPI = component.get("v.controllingFieldAPI");
        var dependingFieldAPI = component.get("v.dependingFieldAPI");
        var objDetails = component.get("v.objInfo");
        // console.log('****' +component.get("v.objInfo"));
        // call the helper function
        helper.fetchPicklistValues(component, objDetails, controllingFieldAPI, dependingFieldAPI);

    },
    onPicklistChange: function(component, event, helper) {
        // get the value of select option
        //  alert(event.getSource().get("v.value"));
        var recordId = component.get('v.opprecordId');
        component.set("v.RevenueInstance.Category__c", event.getSource().get("v.value"));
        component.set("v.RevenueInstance.Opportunity__c", recordId);
    },

    AddNewRow: function(component, event, helper) {
        // fire the AddNewRowEvt Lightning Event 
        component.getEvent("AddRowEvt").fire();
    },

    removeRow: function(component, event, helper) {
        // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
        component.getEvent("DeleteRowEvt").setParams({
            "indexVar": component.get("v.rowIndex")
        }).fire();
    },
    onControllerFieldChange: function(component, event, helper) {
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        var recordId = component.get('v.opprecordId');
        component.set("v.RevenueInstance.Category__c", event.getSource().get("v.value"));
        component.set("v.RevenueInstance.Opportunity__c", recordId);

        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];

            if (ListOfDependentFields.length > 0) {
                component.set("v.bDisabledDependentFld", false);
                helper.fetchDepValues(component, ListOfDependentFields);

            } else {
                component.set("v.bDisabledDependentFld", true);
                component.set("v.listDependingValues", ['--- None ---']);
            }

        } else {
            component.set("v.listDependingValues", ['--- None ---']);
            component.set("v.bDisabledDependentFld", true);
        }
    },
    ondepPicklistChange: function(component, event, helper) {

        component.set("v.RevenueInstance.Sub_Category__c", event.getSource().get("v.value"));

    },
    calculateTotalNew: function(component, event,  helper){
        var newAntal = component.find("NewAntal").get("v.value");
        var newMonth = component.find("NewMonthlyCost").get("v.value");
        if(newAntal!=undefined && newAntal!=null && newAntal!=''&& newMonth!=null && newMonth!=null && newMonth!=''){
            var totalNew=newAntal*newMonth*12;
            component.set("v.IsTotalNew",true);
            var setTotalNew = component.find("newTotalCal").set("v.value",totalNew)
         }
        else
            return;
    },
    calculateTotalOld: function(component, event,  helper){
        var oldAntal = component.find("OldAntal").get("v.value");
        var oldMonth = component.find("OldMonthlyCost").get("v.value");
        var oldAntalId = component.find("OldAntal");
        var oldMonthId = component.find("OldMonthlyCost");
        var errorText = $A.get("$Label.c.Revenue_Impact_error");
        if (oldAntal=== '0' && oldMonth !== '0') {
            oldAntalId.set("v.errors", [{message:errorText}]);
            $A.util.addClass(oldAntalId, 'errorRed');
            $A.util.removeClass(oldMonthId, 'errorRed');
            oldMonthId.set("v.errors", null);
        }
        else if (oldMonth=== '0' && oldAntal!== '0') {
            oldMonthId.set("v.errors", [{message:errorText}]);
            $A.util.addClass(oldMonthId, 'errorRed');
            $A.util.removeClass(oldAntalId, 'errorRed');
            oldAntalId.set("v.errors", null);
        }
        else if (oldMonth=== '0' && oldAntal=== '0') {
            oldAntalId.set("v.errors", [{message:errorText}]);
            oldMonthId.set("v.errors", [{message:errorText}]);
            $A.util.addClass(oldMonthId, 'errorRed');
            $A.util.addClass(oldAntalId, 'errorRed');
        }
        else {
            $A.util.removeClass(oldAntalId, 'errorRed');
            $A.util.removeClass(oldMonthId, 'errorRed');
            oldAntalId.set("v.errors", null);
            oldMonthId.set("v.errors", null);
        }
        if(oldAntal!=undefined && oldAntal!=null && oldAntal!=''&& oldMonth!=null && oldMonth!=null && oldMonth!=''){
            var totalOld=oldAntal*oldMonth*12;
            component.set("v.IsTotalOld",true);
            var setTotalOld = component.find("oldTotalCal").set("v.value",totalOld);
        }
        else
            return;
    },
})