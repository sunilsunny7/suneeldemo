({
    doInit : function(component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Contract",
            "panelOnDestroyCallback": function(event) {
                if(window.location.href.indexOf("view") > -1) {
                    console.log("no action");
                }else{
                    window.location.href = '/lightning/o/Contract/home';
                }
            }
        });
        createRecordEvent.fire();
    }
})