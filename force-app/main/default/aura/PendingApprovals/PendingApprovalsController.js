({
    doInit : function(component,event,helper){
        helper.doInitHelper(component,event,helper);
        var selectview = component.find("InputSelectSingle");
        var approvalview = selectview.get("v.value");
        //To get total record count
 if(approvalview == "myapp"){
           var action = component.get("c.getRecordsCount");
             action.setParams({
            'operation' : approvalview   
        });
        }else{
            var action = component.get("c.getRecordsCount");
             action.setParams({
            'operation' : approvalview   
        });
         }
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var records = response.getReturnValue();
                component.set("v.recordcount",records);  
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSort : function(component,event,helper){
        helper.handleSort(component,event,helper);
    },
   
   //this function gets called on Approve/Reject row actions 
    handleRowAction : function(component,event,helper){
        component.set("v.isOpen", true);
        var action = event.getParam('action');
        console.log('event-getParam' + event.getParam('action'));
        var row = event.getParam('row');
        var rows = component.get('v.data');
        var rowIndex = rows.indexOf(row);
        var rec = rows[rowIndex];
        var workId = rows[rowIndex].workItemId;
        switch (action.name) {
            case 'approve':
                component.set('v.modalView',true);
                component.set('v.workItemId',workId);
 				component.set('v.pageheader','Approve');
                component.set('v.frstbtn','Cancel');
                component.set('v.secBtn','Approve');
                break;
            case 'reject':
                component.set('v.modalView',true);
                component.set('v.workItemId',workId);
                component.set('v.pageheader','Reject');
                component.set('v.frstbtn','Cancel');
                component.set('v.secBtn','Reject');
                break;
        }   
    },
    
    // this function call on click on the next page button 
    handleNext : function(component, event, helper) { 
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
       
        helper.doInitHelper(component, helper);
    },
    // this function call on click on the previous page button  
    handlePrev : function(component, event, helper) {        
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber-1);
        helper.doInitHelper(component, helper);
    },
    recordCount : function(component, event, helper) {  
         if(approvalview == "myapp"){
           var action = component.get('c.getRecordsCount');
             action.setParams({
            'operation' : approvalview   
        });
        }else{
            var action = component.get('c.getRecordsCount');
             action.setParams({
            'operation' : approvalview   
        });
         }
        action.setCallback(this,function(response){
            var state = response.getState();
            //alert("State"+state);
            if(state == 'SUCCESS'){
                var records = response.getReturnValue();
                component.set("v.recordcount",records);  
            }
        });
        $A.enqueueAction(action);
    },
})