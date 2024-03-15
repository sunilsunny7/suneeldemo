import { track, api, LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class multiSelectPicklistRequired extends OmniscriptBaseMixin(LightningElement) {

    @api
    values = [];

    @track
    selectedvalues = [];

    @api
    picklistlabel = '';

    showdropdown;

    // @track selectedValues = [];

    handleleave() {

        let sddcheck = this.showdropdown;

        if (sddcheck) {
            this.showdropdown = false;
            this.fetchSelectedValues();
        }
    }

    connectedCallback() {
        this.values.forEach(element => element.selected
            ? this.selectedvalues.push(element.value) : '');
        console.log(this.selectedvalues);
    }

    fetchSelectedValues() {

        this.selectedvalues = [];

        //get all the selected values
        this.template.querySelectorAll('c-picklist-value').forEach(
            element => {
                if (element.selected) {
                    // console.log(element.value);
                    this.selectedvalues.push(element.value);
                }
            }
        );

        this.dispatchEvent(new CustomEvent
            ('selectevent', { detail: this.selectedvalues })
        );

        //refresh original list
        this.refreshOrginalList();
    }

    refreshOrginalList() {
        //update the original value array to shown after close

        const picklistvalues = this.values.map(eachvalue => ({ ...eachvalue }));

        picklistvalues.forEach((element, index) => {
            if (this.selectedvalues.includes(element.value)) {
                picklistvalues[index].selected = true;
            } else {
                picklistvalues[index].selected = false;
            }
        });

        this.values = picklistvalues;
    }

    handleShowdropdown() {
        let sdd = this.showdropdown;
        if (sdd) {
            this.showdropdown = false;
            this.fetchSelectedValues();
        } else {
            this.showdropdown = true;
        }
    }

    closePill(event) {
        console.log(event.target.dataset.value);
        let selection = event.target.dataset.value;
        let selectedpills = this.selectedvalues;
        console.log(selectedpills);
        let pillIndex = selectedpills.indexOf(selection);
        console.log(pillIndex);
        this.selectedvalues.splice(pillIndex, 1);
        this.refreshOrginalList();
    }

    get selectedmessage() {
        return this.selectedvalues.length + ' values are selected';
    }
}