({

    doInit: function(component, event, helper) {
        //helper.doInitHelper(component,event);
        component.set('v.columns', [{
                label: 'Produkt',
                fieldName: 'ProductName',
                type: 'text',
                sortable: false,
            },
            {
                label: 'Antal',
                fieldName: 'Quantity',
                type: 'text',
                sortable: false,
            },
            {
                label: 'Engångsavgift',
                fieldName: 'OneTimeCharge',
                type: 'text',
                sortable: false,
            },
            {
                label: 'Listpris',
                fieldName: 'RecurringCharge',
                type: 'text',
                sortable: false,
            },
            {
                label: 'Önskat pris',
                fieldName: 'CustomerRequestedPrice',
                type: 'text',
                sortable: false,
            },
            {
                label: 'Rabatt %',
                fieldName: 'FiberRabatt',
                type: 'text',
                sortable: false,
            }
        ]);

        component.set('v.columns2', [{
                label: 'EBIT %',
                fieldName: 'Fiber_EBIT_Percentage',
                type: 'text',
                sortable: false,
            },
            {
                label: 'Intäkter',
                fieldName: 'Fiber_Revenues',
                type: 'text',
                sortable: false,

            },
            {
                label: 'Opex',
                fieldName: 'Fiber_OPEX',
                type: 'text',
                sortable: false,


            },
            {
                label: 'Capex',
                fieldName: 'Fiber_Capex_Infra',
                type: 'text',
                sortable: false,


            },
            {
                label: 'Avtalstid',
                fieldName: 'Fiber_Contract_Term_Y',
                type: 'text',
                sortable: false,


            },
            {
                label: 'Payback år',
                fieldName: 'Fiber_Payback_Y',
                type: 'text',
                sortable: false,

            },
            {
                label: 'Engångsavgift totalpris',
                fieldName: 'Fiber_OneTimeTotal',
                type: 'text',
                sortable: false,
            },
            {
                label: 'Månadsavgift',
                fieldName: 'Fiber_RecurringTotal',
                type: 'text',
                sortable: false,
            },
                                     
            {
                label: '3Play Pris As is',
                fieldName: 'Play_Pris_exkl_moms',
                type: 'text',
                sortable: false,
            },
                                     
            {
                label: 'Månadsavgift per hushåll',
                fieldName: 'Fiber_Number_of_Households',
                type: 'text',
                sortable: false,
            }
             
        ]);

        var action = component.get('c.getQuoteLineItem');
        action.setParams({
            "ProcessInstanceStepId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {

                var records = response.getReturnValue();
                //alert(records.length);
                component.set("v.data", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);

        var action = component.get('c.getQuoteEbit');
        action.setParams({
            "ProcessInstanceStepId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state2 = response.getState();
            if (state2 == 'SUCCESS') {

                //var records = response.getReturnValue();
                //alert(records.length);
                component.set("v.data2", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})