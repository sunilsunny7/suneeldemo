({
    createObjectData: function(component, event) {
        // get the List from component and add(push) New Object to List  
        var RowItemList = component.get("v.RIList");
        RowItemList.push({
            'sobjectType': 'Revenue_Effect__c',
            'Category__c': '',
            'New_Antal__c': '',
            'Old_Antal__c': '',
            'Old_Monthly_Cost__c':'',
            'New_Monthly_Cost__c':'',
            'Comments__c':''
            
        });
        component.set("v.tableView", true);
        // set the updated list to attribute again    
        component.set("v.RIList", RowItemList);

    },
    // helper function for check if first Name is not null/blank on save  
    validateRequired: function(component, event) {
        var isValid = true;
        var alldataRows = component.get("v.RIList");
         var errors = component.get("v.errors");
        for (var indexVar = 0; indexVar < alldataRows.length; indexVar++) {
            if (alldataRows[indexVar].Category__c == '' || alldataRows[indexVar].Old_Antal__c == '' || alldataRows[indexVar].Old_Monthly_Cost__c == '' || alldataRows[indexVar].New_Monthly_Cost__c == '' || alldataRows[indexVar].New_Antal__c == '') {
                isValid = false;
                alert('Value Can\'t be Blank on Row Number ' + (indexVar + 1));
            }
            if(alldataRows[indexVar].Old_Antal__c == '0' || alldataRows[indexVar].Old_Monthly_Cost__c == '0')
            {
               isValid = false;
             };
        }
        return isValid;
    },
    //New Changes
    getRIRecord: function(component, event, helper) {
        var action = component.get("c.getAllRecords");
        component.set("v.IsSpinner", true);
        action.setParams({
            "Oppid": component.get("v.recordId")

        });
        // alert("Record Id ",+component.get("v.recordId"));
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set('v.manageView', a.getReturnValue());
                var records = a.getReturnValue();
                if (records.length > 0) {
                    component.set("v.dataView", true);
                    component.set("v.tableView", false);
                    component.set("v.IsSpinner", false);
                }
            } else if (a.getState() === "ERROR") {
                console.log(a.getError());
            }
            component.set("v.IsSpinner", false);
        });
        $A.enqueueAction(action);
    },

    getCalculatedamt: function(component, event, helper) {
         
        //var recid = component.get("v.recordId");
        var action = component.get("c.getCalculatedAmt");
        action.setParams({
            "Oppid": component.get("v.recordId")

        });
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {

                var records = a.getReturnValue();
                if (records.length > 0) {
                    
                    component.set('v.newRITotal', records[0]);
                    component.set('v.oldRITotal', records[1]);

                    component.set('v.RiImpact', records[2]);
                    if (records[2] < 0)
                        component.set("v.perCheck", true);
                    //var per = Math.round(records[3]);
                    var per = parseFloat(records[3]).toFixed(2);
                    //var per2 = per.toFixed(2);
                    component.set('v.RiImpactPer', per + " %");
                    if (records[3] < 0)
                        component.set("v.krCheck", true);

                }
            } else if (a.getState() === "ERROR") {
                console.log(a.getError());
            }
        });
        $A.enqueueAction(action);
        
    },

    saveDataTable: function(component, event, helper) {
        var editedRecords = component.find("RIDataTable").get("v.draftValues");

        var totalRecordEdited = editedRecords.length;
        //alert(editedRecords);
        component.set("v.IsSpinner", true);
        var action = component.get("c.updateRi");
        action.setParams({
            'lstRi': editedRecords
        });
        action.setCallback(this, function(response) {
            var toastRef = $A.get('e.force:showToast');
            var state = response.getState();
            if (state === "SUCCESS") {
                //if update is successful
                if (response.getReturnValue() === true) {
                    helper.showToast({
                        "title": "Record Update",
                        "type": "success",
                        "message": totalRecordEdited + " Records Updated"
                    });
                    toastRef.fire();
                   // var dismissActionPanel = $A.get("e.force:closeQuickAction");
                   // dismissActionPanel.fire();

                } else { //if update got failed
                    helper.showToast({
                        "title": "Error!!",
                        "type": "error",
                        "message": "Error in update"
                    });
                }
            }
            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(action);
    },


    showToast: function(params) {
        var toastEvent = $A.get("e.force:showToast");
        if (toastEvent) {
            toastEvent.setParams(params);
            toastEvent.fire();
        } else {
            alert(params.message);
        }
    },

})