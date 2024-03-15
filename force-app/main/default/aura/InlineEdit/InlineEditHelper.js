({
    helperfunction : function(component,event,secId) {
        var acc = component.find(secId);
        $A.util.toggleClass(acc, 'slds-is-open');  
    }
})