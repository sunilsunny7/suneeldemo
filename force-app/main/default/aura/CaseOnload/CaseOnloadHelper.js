({
    removeFiles : function(component, event, helper) { 
        var deleteAction= component.get("c.deleteFiles");
        deleteAction.setParams({
            caseIds: component.get('v.recordId')
        });
       // alert(caseIds);
        
        deleteAction.setCallback(this, function(response) {
            // Getting the state from response
            var state = response.getState();
   
            if(state === 'SUCCESS') {
                // Getting the response from server
                var dataMap = response.getReturnValue();
                // Checking if the status is success
                if(dataMap.status=='success') {
                    //if(dataMap.message=='done'){
                   window.location.reload();
                   //alert('success');
                   $A.get('e.force:refreshView').fire();
                }
                // Checking if the status is error 
                else if(dataMap.status=='error') {
                   alert('error');              
                }
            }
            else {
                // Show an alert if the state is incomplete or error
                alert('Error in getting data');
            }            
        });
        $A.enqueueAction(deleteAction);
    }
})