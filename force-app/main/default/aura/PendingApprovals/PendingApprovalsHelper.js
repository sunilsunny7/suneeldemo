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
                typeAttributes : {label:{fieldName:'recordName'},target:'_blank'},//To show name of the record as URL
                
                cellAttributes: {
                    class: {
                        fieldName: 'showClass'
                    },
                    iconName: {
                        fieldName: 'displayIconName'
                    }
                }
            },
            {
                label : 'Kontonamn',
                fieldName : 'relatedTo',
                type : 'text',
                sortable : true,
                 cellAttributes: {
                    class: {
                        fieldName: 'showClass'
                    }},

            },
            {
                label : 'Inskickat av',
                fieldName : 'SubmittedBy',
                type : 'text',
                sortable : true,
                cellAttributes: {
                    class: {
                        fieldName: 'showClass'
                    }},
                
            },
            {
                label : 'Inskickat Datum',
                fieldName : 'SubmittedDate',
                type : 'date',
                typeAttributes : {year:"2-digit",month:"short",day:"2-digit"},
                sortable : true,
                cellAttributes: {
                    class: {
                        fieldName: 'showClass'
                    }},
            },
            {
                label : 'Rollbaserad godkännare',
                fieldName : 'SubmitterManager',
                type : 'text',
                sortable : true,
                cellAttributes: {
                    class: {
                        fieldName: 'showClass'
                    }},
                
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
       // var action = component.get('c.getSubmittedRecords');//Call server side method to get records for the data table 
        var selectview = component.find("InputSelectSingle");
        var approvalview = selectview.get("v.value");
        //var path = $A.get("$Resource.ApprovalRecordLevelIcon");
       
        var action;
        if(approvalview == "myapp"){
           var action = component.get('c.getSubmittedRecords');//Call server side method to get records for the data table 
            var pageSize = component.get("v.pageSize").toString();
            
        var pageNumber = component.get("v.pageNumber").toString();
         // set the parameters to method  
        action.setParams({
            'pageSize' : pageSize,
            'pageNumber' : pageNumber
        });
        }else{
            var action = component.get('c.getSubmittedRecordsAll');
            var pageSize = component.get("v.pageSize").toString();            
        var pageNumber = component.get("v.pageNumber").toString();
         // set the parameters to method  
        action.setParams({
            'pageSize' : pageSize,
            'pageNumber' : pageNumber
        });
        } 
       
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var records = response.getReturnValue();
                                
                var heightcount = 70 + (25*(records.length));
                if(records.length < component.get("v.pageSize") || component.get("v.pageNumber") == (component.get("v.recordcount")/component.get("v.pageSize"))){
                    component.set("v.isLastPage", true);
                } else{
                    component.set("v.isLastPage", false);
                }
                component.set("v.dataSize", records.length);
            //component.set("v.recordcount",records.length);    
			component.set("v.dynamicheight",heightcount);
                records.forEach(function(record){
                   
                   record.recordId = '/'+record.recordId;//storing record id so that when name(url) is clicked, record is opened in new tab
                   var today = new Date();
                    var subdate = new Date(record.SubmittedDate);
                    var todaydate = new Date(today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate());
                    //var diffDays =  todaydate.getDate() - subdate.getDate();
                    var diffDays =    todaydate.getDate() - subdate.getDate();
                    var diffMonth =  todaydate.getMonth() - subdate.getMonth();
                    var diffYear =  todaydate.getYear() - subdate.getYear();
                    //var img_path = '{!JSENCODE($Resource.ApprovalRecordLevelIcon)}';
                    //alert("Diff Year :" + diffYear);
                    if((diffMonth == 0 && diffDays > 2) || diffMonth > 0 || diffYear > 0){
                            record.showClass = 'redcolor';
                           // record.displayIconName = 'utility:alert'; 
                        record.displayIconName = 'utility:warning'; 
                             component.set("v.warningView",true);
                            //record.displayIconName = path;
                  
                    }/*else{
                         //record.showClass = 'blackcolor';
                            record.displayIconName = 'utility:alert';
                    }*/
                    
                });
                $A.util.toggleClass(spinner, "slds-hide");
                if(records.length == 0){
                  component.set("v.dataView",false);
                  component.set("v.warningView",false);
                    /*toastRef.setParams({
                        'type' : 'error',
                        'title' : 'Error',
                        'message' : 'No records to approve/reject',
                        'mode' : 'sticky'
                    });
					toastRef.fire();*/
                }else{
                  component.set("v.dataView",true);  
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