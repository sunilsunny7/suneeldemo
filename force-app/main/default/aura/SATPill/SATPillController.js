({
    removeAccountClick  : function (component, event, helper) {
        console.log("SATPill Event fired");
        var evt = $A.get("e.c:SATEvent");

        evt.setParams({
            "KeyAccountId": component.get("v.AccountRow").Id
        });
        evt.fire();
        

    }
})