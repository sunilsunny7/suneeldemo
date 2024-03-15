import { LightningElement, track } from 'lwc';

export default class ServiceAvtal extends LightningElement {

    @track theRecord = {};

    changeHandler(event) {
        this.theRecord[event.target.name] = event.target.value;
        this.dispatchEvent(new CustomEvent
            ('childevent2', { detail: this.theRecord })
        );
    }

    connectedCallback() {
        this.theRecord['service_ip1'] = '';
        this.theRecord['service_ip2'] = '';
        this.theRecord['service_ip3'] = '';
        this.theRecord['service_ip4'] = '';
        this.theRecord['service_ip5'] = '';
        this.theRecord['service_ip6'] = '';
        this.theRecord['service_ip7'] = '';
        this.theRecord['service_ip8'] = '';
        this.theRecord['service_ip9'] = '';
        this.theRecord['service_ip10'] = '';
        this.theRecord['service_ip11'] = '';
    }
}