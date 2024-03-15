({
    handleScannedEvent: function(component, event, helper) {
        component.set('v.member', null);
        component.set('v.contact', null);

        var barcodeComponent = component.find('barcodeScanner');
        barcodeComponent.set('v.isLoading', true);

        var result = event.getParam("result");
        var success = event.getParam("success");
        var code = success ? result[0].data : null;
        var campaignId = component.get("v.recordId");
        if (!success || !code) {
            barcodeComponent.set('v.isLoading', false);

            return helper.showMessage("Did not find any data in the code, please try again", 'error', component);
        }

        var action = component.get("c.processContact");

        action.setParams({
            barcodeId: code.trim(),
            campaignId: campaignId
        });

        action.setCallback(self, function(response) {
            barcodeComponent.set('v.isLoading', false);

            var state = response.getState();

            if (state === 'SUCCESS') {
                var resp = response.getReturnValue();
                var data = resp.Status;

                barcodeComponent.set('v.isLoading', false);

                component.set('v.member', resp.Member);
                component.set('v.contact', resp.Contact);

                $A.get('e.force:refreshView').fire();

                if (data === 'added') {
                    return helper.showMessage('Added contact ' + resp.Contact.Name + ' to campaign ' + resp.Member.Campaign.Name, 'success', component);
                } else if (data === 'updated') {
                    return helper.showMessage('Marked contact ' + resp.Contact.Name + ' as attended', 'success', component);
                } else if (data === 'notfound') {
                    return helper.showMessage('Contact with Barcode Id ' + code + ' not found', 'error', component);
                } else if (data === 'statusalreadyset') {
                    return helper.showMessage('Contact ' + resp.Contact.Name + ' has already been marked as attended', 'info', component);
                } else {
                    return helper.showMessage("Couldn't add campaign member. Details: " + data, "error", component);
                }


            } else if (state === 'ERROR') {
                return helper.showApexErrorToast(response.getError(), component);
            }
        });

        $A.enqueueAction(action);
    },
    handleCloseClick: function(component, event, helper) {
        helper.closeMessage(component);
    },
    navigateToRecord: function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.member').Id
        });
        navEvt.fire();
    }
})