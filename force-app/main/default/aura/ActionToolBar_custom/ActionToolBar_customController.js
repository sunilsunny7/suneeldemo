({
    doInit : function(cmp, event, helper) {
        helper.initHelper(cmp);
    },
    closeModel : function(cmp, event, helper) {
          // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
          cmp.set("v.isPopUp", false);
    },
    continueValidation : function(cmp, event, helper) {
         // and set the "isPopUp" attribute to False to close the model Box.
         cmp.set("v.isPopUp", false);
         var selectedAction = cmp.get('v.selectedAction');
         var recordId =  cmp.get('v.recordId');//Get the current Record Id
         var recordName =  cmp.get('v.sObjectName');
         var validationClassName = selectedAction.validationClassName;
         var input = {};
         var option = {};
         input.contextId = recordId;
         if(selectedAction.stateTransitionId)
         {
             input.stateTransitionId = selectedAction.stateTransitionId;
         }
         helper.invokeVOIMethod(cmp, recordId,selectedAction,input,option,false);
      },
    //Vlocity Action Handler
       handleAction : function(cmp, event,helper) {
           var selectedAction = {};
           if(event.getParam !== undefined) {
              selectedAction = event.getParam('item')
           } else {
               var slectedId = event.currentTarget.getAttribute("id");
                var vlocDropDown = cmp.get('v.vlocDropDown');
                for (var i = 0; i < vlocDropDown.length; i++) {
                    if(vlocDropDown[i].id == slectedId) {
                        selectedAction = vlocDropDown[i];
                    }
                }
           }
        var recordId =  cmp.get('v.recordId');//Get the current Record Id
        var recordName =  cmp.get('v.sObjectName');
        var validationClassName = selectedAction.validationClassName;
        cmp.set('v.loadActionToolBar', false);

        console.log('item.className' + selectedAction.className);
        console.log('recordId' + recordId);
        //var baseURL = cmp.get('v.baseURL');
        var input = {};
        var option = {};
        input.contextId = recordId;

        if(selectedAction.stateTransitionId)
        {
            input.stateTransitionId = selectedAction.stateTransitionId;
        }
        if(selectedAction.validationClassName && selectedAction.validationClassName)
        {
              helper.invokeVOIMethod(cmp, recordId,selectedAction,input,option,helper,true);
        }
        else{
             helper.invokeVOIMethod(cmp, recordId,selectedAction,input,option,helper,false);
        }

    }

})