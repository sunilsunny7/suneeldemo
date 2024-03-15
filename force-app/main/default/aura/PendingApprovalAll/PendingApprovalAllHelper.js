({
    doInitHelper : function(component,event){
        var actions = [
            { label: 'Approve', name: 'approve' },
            { label: 'Reject', name: 'reject' }
        ];
        //Initialize the columns for data table
        component.set('v.columns',[
            {
                label : 'Namn',
                fieldName : 'recordId',
                type : 'url',
                typeAttributes : {label:{fieldName:'recordName'},target:'_blank'}//To show name of the record as URL
            },
            {
                label : 'Kontonamn',
                fieldName : 'relatedTo',
                type : 'text',
                sortable : true
            },
            {
                label : 'Inskickat av',
                fieldName : 'submittedBy',
                type : 'text',
                sortable : true
            },
            {
                label : 'Inskickat Datum',
                fieldName : 'submittedDate',
                type : 'date',
                typeAttributes : {year:"2-digit",month:"short",day:"2-digit"},
                sortable : true
            },
            
             { type: 'action', typeAttributes: { rowActions: actions } }
        ]);
        this.getData(component,event);
    },
    
    getData : function(component,event){
        //display spinner till data is loaded from server
        var spinner = component.find("spinnerId");
        $A.util.toggleClass(spinner, "slds-hide");
        var toastRef = $A.get('e.force:showToast');
        var action = component.get('c.getSubmittedRecordsAll');//Call server side method to get records for the data table
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var records = response.getReturnValue();
                var heightcount = 60 + (15*(records.length));
			component.set("v.dynamicheight",heightcount);
                records.forEach(function(record){
                   record.recordId = '/'+record.recordId;//storing record id so that when name(url) is clicked, record is opened in new tab
                });
                $A.util.toggleClass(spinner, "slds-hide");
                if(records.length == 0){
                  component.set("v.dataView",false);
                    /*toastRef.setParams({
                        'type' : 'error',
                        'title' : 'Error',
                        'message' : 'No records to approve/reject',
                        'mode' : 'sticky'
                    });
					toastRef.fire();*/
                }
                component.set('v.data',records);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSort : function(component,event,helper){
        //Set field name and direction of sorting
        var sortedBy = event.getParam('fieldName');
        var sortedDirection = event.getParam('sortDirection');
        component.set('v.sortedBy',sortedBy);
        component.set('v.sortedDirection',sortedDirection);
        this.sortRecords(component,event,helper,sortedBy,sortedDirection);
    },
    
    sortRecords : function(component,event,helper,sortedBy,sortedDirection){
        var records = component.get('v.data');
        var direction = sortedDirection == 'asc' ? 1 : -1;
        var fieldValue = function(record){ return record[sortedBy]; }//returns the field value(field used for sorting) for each record
        records.sort(function(record1,record2){
            var fieldValue1 = fieldValue(record1);
            var fieldValue2 = fieldValue(record2);
            return direction * (fieldValue1 > fieldValue2) - (fieldValue2 > fieldValue1);//For asc,return value of -1 sorts the record,1 or 0 keeps the order intact.
        });
        component.set('v.data',records);
    },
    
    
})