({
    doInit : function(component,event,helper){
        helper.doInitHelper(component,event,helper);
    },
    
    handleSort : function(component,event,helper){
        helper.handleSort(component,event,helper);
    },
    
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
    }
})