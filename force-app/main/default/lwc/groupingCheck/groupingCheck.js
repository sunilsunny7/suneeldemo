import { LightningElement, track } from 'lwc';

export default class GroupingCheck extends LightningElement {
    @track value1 = '';

    get options() {
        return [
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'no' },
        ];
    }
    @track value1 = '';

    get options2() {
        return [
            { label: 'Yes', value: 'yes' },
            { label: 'No', value: 'no' },
        ];
    }
}