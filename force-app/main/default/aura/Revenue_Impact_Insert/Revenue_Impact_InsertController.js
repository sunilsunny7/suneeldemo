({

    // function call on component Load
    doInit: function(component, event, helper) {
        var actions = [{
            label: 'Delete',
            name: 'Delete'
        }, ];
        //new
        component.set('v.columns', [{
                label: 'Kategori',
                fieldName: 'Category__c',
                editable: true,
                type: 'text',
                wrapText: true
            },
            // {label: 'SUB CATEGORY', fieldName: 'Sub_Category__c', editable:'true', type: 'text'},
            {
                label: 'Nuvarande antal',
                fieldName: 'Old_Antal__c',
                editable: true,
                type: 'text'
            },
            {
                label: 'Nuvarande månadskostnad',
                fieldName: 'Old_Monthly_Cost__c',
                editable: true,
                type: 'text'
            },
            {
                label: 'Nuvarande Total intäkt 12 mån',
                fieldName: 'Old_Total_Revenue_12_Months__c',
                editable: false,
                type:'text'
                
            },
            {
                label: 'Nytt antal',
                fieldName: 'New_Antal__c',
                editable: true,
                type: 'text'
            },
            {
                label: 'Ny månadskostnad',
                fieldName: 'New_Monthly_Cost__c',
                editable: true,
                type: 'text'
            },
          {
                label: 'Ny Total intäkt 12 mån',
                fieldName: 'New_Total_Revenue_12_Months__c',
                editable: false,
                type:'text'
                       
            },  
            {
                label: 'Kommentar',
                fieldName: 'Comments__c',
                editable: 'true',
                type: 'text',
                wrapText: true
            },
            
            {
                type: 'action',
                typeAttributes: {
                    rowActions: actions
                }
            }
        ]);
        // create a Default RowItem [Contact Instance] on first time Component Load
        // by call this helper function  
        helper.createObjectData(component, event);
        helper.getRIRecord(component, event, helper);
        helper.getCalculatedamt(component, event, helper);

     

    },
    // function for save the Records 
    Save: function(component, event, helper) {
        // first call the helper function in if block which will return true or false.
        // this helper function check the "first Name" will not be blank on each row.
        if (helper.validateRequired(component, event)) {
            // call the apex class method for save the Contact List
            // with pass the contact List attribute to method param.  

            component.set("v.IsSpinner", true);
            var action = component.get("c.saveRevenueImpact");
            action.setParams({
                "ListRI": component.get("v.RIList")
            });
            // set call back 
            action.setCallback(this, function(response) {
                var state = response.getState();
                var toastRef = $A.get('e.force:showToast');
                if (state === "SUCCESS") {
                    // if response if success then reset/blank
                    // and call the common helper method for create a default Object Data to  List 
                    component.set("v.RIList", []);
                    helper.createObjectData(component, event);
                    //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    // dismissActionPanel.fire();
                    // alert('record Save');

                    var message = response.getReturnValue();
                    toastRef.setParams({
                        'type': 'success',
                        'title': 'Success',
                        'message': message,
                        'mode': 'dismissible'
                    });
                    toastRef.fire();
                    //var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    //dismissActionPanel.fire();
					helper.getRIRecord(component, event, helper);
        			helper.getCalculatedamt(component, event, helper);

                }
                $A.get("e.force:refreshView").fire();
            });
            // enqueue the server side action  
            $A.enqueueAction(action);
        }
    },

    // function for create new object Row in Contact List 
    addNewRow: function(component, event, helper) {
        // call the comman "createObjectData" helper method for add new Object Row to List  
        helper.createObjectData(component, event);
    },

    // function for delete the row 
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        var index = event.getParam("indexVar");

        // get the all List and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.RIList");
        //***new
        if(AllRowsList.length > 1){
            
       //alert(AllRowsList.length);
        AllRowsList.splice(index, 1);
        // after remove selected row element  
        component.set("v.RIList", AllRowsList);
             }
        else{
            alert("Mininum 1 record should be present to process");
        }
        
    },
    handleRowAction: function(component, event, helper) {
        /*var row = event.getParam('row');
         alert(row); 
        var rows = component.get('v.manageView');
        var rowIndex = rows.indexOf(row);
        var rec = rows[rowIndex];*/
        var action = event.getParam('action');
        var row = event.getParam('row');
        var recId = row.Id;


        //alert(recId);

        var action = component.get("c.deleteRecord");
        var toastRef = $A.get('e.force:showToast');
        action.setParams({
            "RIid": recId
        });
        component.set("v.IsSpinner", true);
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                var message = a.getReturnValue();
                toastRef.setParams({
                    'type': 'success',
                    'title': 'Success',
                    'message': message,
                    'mode': 'dismissible'
                });
                toastRef.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }

            $A.get("e.force:refreshView").fire();
        });
        $A.enqueueAction(action);
        $A.get("e.force:refreshView").fire();
    },

    addadditionalnewRow: function(component, event, helper) {
        component.set("v.tableView", true);
    },
    onSave: function(component, event, helper) {
        helper.saveDataTable(component, event, helper);
        helper.getRIRecord(component, event, helper);
        helper.getCalculatedamt(component, event, helper);
    },
    
    AddNewRowParent : function(component, event, helper) {
        var childCmp = component.find('childComp');
       childCmp.AddNewRowMethod();
    },

})