({
    doInit : function(component, event, helper) {
        var valueAttr = component.get("v.graphcount")!== undefined ? component.get("v.graphcount") : 0;
        var gg1 = new JustGage({
            id: "GuageId",
            value : valueAttr,
            min: 0,
            max: 100,
            pointer: true,
            decimals: 0,
            gaugeWidthScale: 0.6,
            customSectors: [{
                color : "#0AFA1E",
                lo : 0,
                hi : 15
            },{
                color : "#F3FA0A",
                lo : 15,
                hi : 30
            },{
                color : "#931E11",
                lo : 30,
                hi : 100
            }],
            counter: true
        });
    }
})