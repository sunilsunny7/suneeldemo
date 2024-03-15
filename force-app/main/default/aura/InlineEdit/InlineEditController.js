({
    editbtn : function(component, event, helper) {
        component.set("v.EditMode", true);
        var savebtn = component.find("SavebtnId");
        var editbtn = component.find("editbtnId");
        var cancelbtn = component.find("cancelbtnId");
        $A.util.addClass(savebtn, 'slds-show');
        $A.util.removeClass(savebtn, 'slds-hide');
        $A.util.addClass(cancelbtn, 'slds-show');
        $A.util.removeClass(cancelbtn, 'slds-hide');
        $A.util.addClass(editbtn, 'slds-hide');
    },
    
    btncancel : function(component, event, helper) {
        component.set("v.EditMode", false);
        var savebtn = component.find("SavebtnId");
        var editbtn = component.find("editbtnId");
        var cancelbtn = component.find("cancelbtnId");
        $A.util.removeClass(savebtn, 'slds-show');
        $A.util.addClass(savebtn, 'slds-hide');
        $A.util.removeClass(cancelbtn, 'slds-show');
        $A.util.addClass(cancelbtn, 'slds-hide');
        $A.util.addClass(editbtn, 'slds-show');
        $A.util.removeClass(editbtn, 'slds-hide'); 
    },
    
    doInit  : function(component, event, helper) {
        var acc1 = component.find('div-id1');
        var acc2 = component.find('div-id2');
        $A.util.addClass(acc1, 'slds-is-open');
        $A.util.addClass(acc2, 'slds-is-open');
    },
    
    sectionOne : function(component, event, helper) {
        helper.helperfunction(component,event,'div-id1');
    },
    
    sectionTwo : function(component, event, helper) {
        helper.helperfunction(component,event,'div-id2');
    },
    SaveAccount : function(component, event, helper) {
        event.preventDefault();
        component.find("editForm1").submit();
        component.find("editForm2").submit();
        component.set("v.showSpinner", true);
    },
    
    handleOnSuccess : function(component, event, helper) {
        //alert('hi');
        var savebtn1 = component.find("SavebtnId");
        var editbtn1 = component.find("editbtnId");
        var cancelbtn1 = component.find("cancelbtnId");
        $A.util.removeClass(savebtn1, 'slds-show');
        $A.util.addClass(savebtn1, 'slds-hide');
        $A.util.removeClass(cancelbtn1, 'slds-show');
        $A.util.addClass(cancelbtn1, 'slds-hide');
        $A.util.addClass(editbtn1, 'slds-show');
        $A.util.removeClass(editbtn1, 'slds-hide');
        component.set("v.EditMode", false);
        var record = event.getParam("response");
        component.set("v.showSpinner", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "The record has been updated successfully."
        });
        toastEvent.fire();
    },
    
    handleOnError : function(component, event, helper) {
        component.set("v.showSpinner", false);
    }
})