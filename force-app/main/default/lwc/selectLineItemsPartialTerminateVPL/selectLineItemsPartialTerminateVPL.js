import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SelectLineItemsPartialTerminateVPL extends OmniscriptBaseMixin(LightningElement) {
    @track data;
    dataProcessing = true;
    check = false;
    error = [];
    draftValues = [];
    selectedRows = [];
    @track refinedValues = [];
    @track columns = [
        { label: 'PRODUKTFAMILJ', fieldName: 'ProdName' },
        { label: 'STARTDATUM', fieldName: 'StartDate', type: 'date' },
        { label: 'SLUTDATUM', fieldName: 'EndDate', type: 'date' },
        {
            label: 'AVSLUTADATUM', fieldName: 'CLIEndDate', type: 'date-local', editable: true,
            cellAttributes: {
                iconName: 'utility:event',
                iconPosition: 'left',
                iconAlternativeText: 'Close Date',
            },
        }
    ];
    @api
    get customItems() {
        return this.data;
    }
    set customItems(value) {
        if (value === undefined) {
            this.data = false;
        } else {
            this.data = value;
        }
    }

    connectedCallback() {
        this.data = JSON.parse(JSON.stringify(this.data));

        if (Array.isArray(this.data) && this.data.length > 0) {
            //Assigning Row ids for validation check
            this.data.forEach((ele, i) => {
                ele.rowId = 'row-' + i;
                ele.hasError = false;
                ele.isEmpty = true;
            });
            this.dataProcessing = false;
        } else {
            this.dataProcessing = false;
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Inga produkter tillgängliga för uppsägning',
                variant: 'warning'
            });
            this.dispatchEvent(evt);
        }
    }

    previousStep() {
        this.omniPrevStep();
    }

    getDraftValues(event) {
        this.data = JSON.parse(JSON.stringify(this.data));
        console.log(this.data);
        this.error = [];
        this.refinedValues = [];
        this.data.forEach(ele => {
            ele.hasError = false;
        });
        this.draftValues = this.template.querySelector("lightning-datatable").draftValues;
        // console.log(this.draftValues);
        this.draftValues.forEach((ele, index) => {
            var dataIndex = this.data.findIndex(e => e.rowId === ele.id);
            console.log(ele.CLIEndDate, dataIndex, index);

            if (ele.CLIEndDate !== null && ele.CLIEndDate !== '') {
                var date = ele.CLIEndDate.split('T');
                if (this.data[dataIndex].StartDate.valueOf() < date[0].valueOf() && date[0].valueOf() < this.data[dataIndex].EndDate.valueOf()) {
                    this.data[dataIndex].hasError = false;
                    this.data[dataIndex].isEmpty = false;
                    this.data[dataIndex].CLIEndDate = ele.CLIEndDate;
                } else {
                    this.data[dataIndex].hasError = true;
                }
            } else {
                this.data[dataIndex].isEmpty = true;
            }
        });

        this.error = this.data.filter(e => e.hasError === true);

        console.log(this.error);

        if (Array.isArray(this.error) && this.error.length > 0) {
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Var god välj Slutdatum mellan startdatum och slutdatum!',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }
    }

    // nextStep() {
    //     this.check = false;
    //     if (this.selectedRows.length === 0 && this.draftValues.length === 0) {
    //         const evt = new ShowToastEvent({
    //             title: 'Error Occured',
    //             message: 'Please select a row and enter end date for at least one product',
    //             variant: 'error'
    //         });
    //         this.dispatchEvent(evt);
    //     } else if (this.draftValues.length > 0) {
    //         this.draftValues.forEach((ele) => {
    //             var index = this.data.findIndex(e => e.rowId === ele.id);
    //             var index2 = this.selectedRows.findIndex(e => e.rowId === ele.id);
    //             this.data[index].CLIEndDate = ele.CLIEndDate;

    //             if (index2 === -1 && ele.CLIEndDate !== '' && ele.CLIEndDate !== null && ele.CLIEndDate !== undefined) {
    //                 this.check = true;
    //             }
    //         });
    //         if (this.check) {
    //             const evt = new ShowToastEvent({
    //                 title: 'Error Occured',
    //                 message: 'For the given date, row is not selected',
    //                 variant: 'error'
    //             });
    //             this.dispatchEvent(evt);
    //         } else if (this.check === true || this.error.length > 0 || this.selectedRows.length === 0 || this.draftValues.length === 0) {
    //             const evt = new ShowToastEvent({
    //                 title: 'Error Occured',
    //                 message: 'Either the selected date is incorrect or the row is not selected',
    //                 variant: 'error'
    //             });
    //             this.dispatchEvent(evt);
    //         } else {
    //             let updateJSON = JSON.parse(JSON.stringify(this.omniJsonData));
    //             const result = this.data.filter(e => e.CLIEndDate !== undefined);
    //             updateJSON.Contract.Item = result;
    //             this.omniApplyCallResp(updateJSON);
    //             this.omniNextStep();
    //         }


    //     } else if (this.selectedRows.length > 0 && this.draftValues.length === 0) {
    //         const evt = new ShowToastEvent({
    //             title: 'Error Occured',
    //             message: 'Please enter a date for each of the selected rows',
    //             variant: 'error'
    //         });
    //         this.dispatchEvent(evt);
    //     }
    // }

    nextStep(){
        this.refinedValues = this.data.filter(function(ele){
            return ele.hasError === false && ele.isEmpty === false && (ele.CLIEndDate !== '' || ele.CLIEndDate !== null);
        });

        if(Array.isArray(this.refinedValues) && this.refinedValues.length === 0){
            //throw Error that atleast one date has to be selected.
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Välj minst ett giltigt datum i tabellen för att gå vidare',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } else if(this.error.length > 0) {
            //if selected date is incorrect.
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Var god välj Slutdatum mellan startdatum och slutdatum!',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } else {
            let updateJSON = JSON.parse(JSON.stringify(this.omniJsonData));
            const result = this.refinedValues;
            updateJSON.Contract.Item = result;

            // console.log(JSON.stringify(result));
            this.omniApplyCallResp(updateJSON);
            this.omniNextStep();
        }
    }

}