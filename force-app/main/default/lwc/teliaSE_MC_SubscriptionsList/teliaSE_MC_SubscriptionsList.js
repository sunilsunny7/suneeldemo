import { api, LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class TeliaSE_MC_SubscriptionsList extends OmniscriptBaseMixin(LightningElement) {
    @track subscriptions = [];
    @track selectedSubscriptionsCount = 0;
    @track totalSubs = 0;
    @track selectedSubscriptions = [];
    @track data = [];
    @track data2 = [];
    @track newSubs = [];
    @track CLISubs = {};

    @api
    get listOfSubs() {
        return this.data;
    }
    set listOfSubs(value) {
        if (value === undefined) {
            this.data = false;
        } else {
            this.data = value;
        }
    }
    connectedCallback() {
        if (this.data) {
            if (this.data.length > 0) {
                this.subscriptions = this.data;
                this.totalSubs = this.subscriptions.length;
                this.selectedSubscriptionsCount = 0;

                this.subscriptions.forEach(ele => {
                    this.newSubs.push({
                        'Name': ele.SubscriptionName,
                        'Id': ele.SubscriptionId,
                        'Code': ele.Subscriptioncode,
                        'Price': ele.SubscriptionPrice
                    })
                });
            } else {
                const evt = new ShowToastEvent({
                    title: 'Error Occured',
                    message: 'No Subscriptions available for this opportunity',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        } else {
            const evt = new ShowToastEvent({
                    title: 'Error Occured',
                    message: 'Error occured, please contact salesforce administrator',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
        }
    }

    renderedCallback() {
        if (this.omniJsonData.NumberOfSelectedSubscription > 0) {
            this.selectedSubscriptionsCount = JSON.parse(JSON.stringify(this.omniJsonData.NumberOfSelectedSubscription));
            this.selectedSubscriptions = JSON.parse(JSON.stringify(this.omniJsonData.SubscriptionList));
            const boxes = this.template.querySelectorAll('lightning-input');
            boxes.forEach(element => {
                if (this.selectedSubscriptions.findIndex(ele => ele.Id === element.name) !== -1) {
                    element.checked = true;
                } else {
                    element.checked = false;
                }
            });
        }
    }

    handleChange(event) {
        if (event.detail.checked) {
            var index = this.newSubs.findIndex(ele => ele.Id === event.target.name);
            this.selectedSubscriptions.push(this.newSubs[index]);
            this.selectedSubscriptionsCount++;
        } else {
            var index = this.selectedSubscriptions.findIndex(ele => ele.Id === event.target.name);
            this.selectedSubscriptions.splice(index, 1);
            this.selectedSubscriptionsCount--;
        }
    }

    nextStep() {

        if (this.selectedSubscriptionsCount > 3 || this.selectedSubscriptionsCount === 0) {
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Välj minst ett abonnemang för att fortsätta (Max 3)',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } else if (this.omniJsonData) {
          //  let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
          //  updateOmniJsonData.SubscriptionList = this.selectedSubscriptions;
          //  updateOmniJsonData.NumberOfSelectedSubscription = this.selectedSubscriptionsCount;
           // this.omniApplyCallResp(updateOmniJsonData);
           
           this.CLISubs['SubscriptionList'] = this.selectedSubscriptions;
           this.CLISubs['NumberOfSelectedSubscription'] = this.selectedSubscriptionsCount;
           this.omniApplyCallResp(this.CLISubs);
           this.omniNextStep();
        }

    }

    previousStep() {
        this.omniPrevStep();
    }
}