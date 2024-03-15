({
    showMessage: function(message, type, component) {
        var messageContainer = component.find('campaign-message');

        if (this.timerId !== null) {
            clearTimeout(this.timerId);
            this.timerId = null;
        }

        component.set("v.type", type);
        component.set("v.title", type.charAt(0).toUpperCase() + type.slice(1));
        component.set("v.message", message);

        $A.util.removeClass(messageContainer, 'slds-hide');

        this.timerId = setTimeout($A.getCallback(function() {
            if (component.isValid()) {
                $A.util.addClass(messageContainer, 'slds-hide');
            }
        }), 7000);
    },
    showApexErrorToast: function(errors, component) {
        for (var i=0; i < errors.length; ++i) {
            if (errors[i].message) {
                this.showMessage(errors[i].message, 'error', component);
                return;
            }

            if (errors[i].pageErrors && errors[i].pageErrors.length) {
                for (var j = 0; j < errors[i].pageErrors.length; ++j) {
                    this.showMessage(errors[i].pageErrors[j].message, 'error', component);
                    return;
                }
            }
        }
    },
    closeMessage: function (component) {
        var messageContainer = component.find('campaign-message');

        $A.util.addClass(messageContainer, 'slds-hide');
    }
})