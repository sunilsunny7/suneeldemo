({
    
    UpdateContractRec: function(component, event, helper){
        var recordId = component.get('v.recordId');   
        var rcvddate = component.find('rcvddate').get('v.value');        
        var signdate = component.find('signdate').get('v.value');        
        var action = component.get("c.updateContract");
        var toastRef = $A.get('e.force:showToast');
        var scriveId = $A.get("$Label.c.MCScriveId");
        var errorMsgnull = $A.get("$Label.c.eSignErrormsg");
        if(rcvddate == null || signdate == null){
            toastRef.setParams({
                        'type': 'Error',
                        'title': 'Error',
                        'message': errorMsgnull,
                        'mode' : 'sticky'                        
                    });
            toastRef.fire();
        }
        else{           
            action.setParams({"contractId" : recordId,
                              "rcvddate": rcvddate,
                              "signdate": signdate }); 
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    var conId = component.get("v.recordId");
                    var resultId = response.getReturnValue();
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({                      
                        "url": "/apex/scrive__scrivedocumentfromtemplate?Id="+scriveId+"&sourceRecordId="+resultId                        
                    });
                    $A.get("e.force:closeQuickAction").fire();              
                    urlEvent.fire();                    
                    //Update the UI: closePanel, show toast, refresh page
                }else if(state === "ERROR"){
                    $A.get("e.force:closeQuickAction").fire();    
                    var message = 'Knappen "Manuellt signerat dokument mottaget" kan endast användas i statusarna Avtal godkänt eller Skickat för signering.Är statusen sedan tidigare uppdaterad till signerat, fyll då i fälten Kundsignatur datum och Mottaget datum i avtalet så kommer statusen även uppdateras till Tupp.';
                    //alert(message);
                    toastRef.setParams({
                        'type': 'Error',
                        'title': 'Error',
                        'message': message,
                        'mode' : 'sticky'                        
                    });
                    toastRef.fire();
                    console.log('Problem updating call, response state '+state);
                }
            });
            //send the request to updateCall
            $A.enqueueAction(action); 
        }
    }
})