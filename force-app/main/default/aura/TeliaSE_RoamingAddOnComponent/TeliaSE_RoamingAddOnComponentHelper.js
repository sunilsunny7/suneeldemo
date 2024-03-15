({
	getStatus : function(component,event,helper) {
         var recordId = component.get("v.recordId");
          var record = component.get("v.Quote");
		  console.log('recordId..'+recordId);
          var action2 = component.get("c.getQuotecartVal");
          action2.setParams({
         "quoteId": recordId
    });
	
	
	action2.setCallback(this, function(response) {
        var state = response.getState();
        if (component.isValid() && state == "SUCCESS") {
            var Confirm = response.getReturnValue();
			
			if(Confirm == "Success"){
                console.log('Confirm..'+Confirm);

			var message = 'Validera varukorgen innan du fortsätter - det gör du genom att gå in i varukorgen och klicka på Validera varukorgen';

			component.set("v.Confirm", message);
            component.set("v.isConfirmed",true);
                
			}
            
        }
    });
    
    $A.enqueueAction(action2);
		
	}
})