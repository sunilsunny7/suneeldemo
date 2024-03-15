({
	
    UpdateContractRec: function(component, event, helper){
        var recordId = component.get('v.recordId');   
                        console.log("recordId");
        var rcvddate = component.find('rcvddate').get('v.value');
         				
        var signdate = component.find('signdate').get('v.value');
         				
		 var action = component.get("c.updateContract");
        var toastRef = $A.get('e.force:showToast');
        action.setParams({"contractId" : recordId,
                          "rcvddate": rcvddate,
                          "signdate": signdate }); 
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('response '+response.getState());
            if(state === "SUCCESS"){
               		var conId = component.get("v.recordId");
                	var resultId = response.getReturnValue();
                   var url = "/apex/scrive__scrivedocumentfromtemplate?Id=a2j7a000007O78pAAC&sourceRecordId="+resultId;
				alert(url);	
                var urlEvent = $A.get("e.force:navigateToURL");
					urlEvent.setParams({
					"url": url
                });
                $A.get("e.force:closeQuickAction").fire();              
                	urlEvent.fire();
                               

                //Update the UI: closePanel, show toast, refresh page
            }else if(state === "ERROR"){
                   $A.get("e.force:closeQuickAction").fire();    
                var message = '"Manually Signed Document Received for Fiber" kan endast användas i status: Utkast';
                //alert(message);
                toastRef.setParams({
                    'type': 'Error',
                    'title': 'Error',
                    'message': message,
                    'mode': 'dismissible'
                    //'mode' : 'sticky'
                });
                toastRef.fire();
              
                console.log('Problem updating call, response state '+state);
            }
        });
        //send the request to updateCall
        $A.enqueueAction(action); 
	}
})