import { LightningElement, wire, track, api } from 'lwc';
import excelConvert from '@salesforce/apex/TeliaSE_ExportExcelHardwareSubscripton.excelConvert';
import getMobilRecordsWithParam from '@salesforce/apex/HardwareController.getMobilRecordsWithParam';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// all the column for data table mapped with  their field names
const columns = [
    { label: 'Nummer', fieldName: 'Subscription_Id__c', sortable: true, wrapText: true },
    { label: 'Namn', fieldName: 'TeliaSE_User_Name__c', sortable: true },
    { label: 'Produkt', fieldName: 'TeliaSE_Subscription_Name__c', sortable: true },
    { label: 'Bindningstid slutdatum', fieldName: 'CommitmentEndDate__c', sortable: true },
    { label: 'Kan bindas om \n JA/NEJ', fieldName: 'Subsidized_Subscription__c', sortable: true, wrapText: true },
    { label: 'Modell', fieldName: 'Last_Used_Model__c', sortable: true },
    { label: 'IMEI', fieldName: 'MSISDN__c', sortable: true },
    { label: 'Roamingtjänster', fieldName: 'Roaming_Service_Descr__c', sortable: true, wrapText: true }
];

export default class HardwareC2BSubscriptions extends LightningElement {
    @track accountName; 
    defaultSortDirection = 'asc'; sortDirection = 'asc';
    sortedBy;
    @track subs; 
    @api subscriptions;
    @track numberOfRecords;
    excelString;
    error;
    columns = columns;
    @api recordId;

    connectedCallback() {
        getMobilRecordsWithParam({
            accId: this.recordId
        }).then(result => {
            console.log('result:', result);
            this.accountName = result.accountName;
            this.subs = result.mobilabonnemangList;
            this.subscriptions = result.mobilabonnemangList;
            this.numberOfRecords = result.numberOfRecords;
            const evt = new ShowToastEvent({
                title: 'Success',
                message: result.mobilabonnemangList.length + ' Subscription Found.',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        }).catch(error => {
            console.error('**** error **** \n ', error)
        });
    }

/*
    @wire(getMobilRecordsWithParam, { accId: '$recordId' })
    wiredwrapper({ error, data }) {
        if (data) {
            console.log('data:', data);
            this.accountName = data.accountName;
            this.subs = data.mobilabonnemangList;
            this.subscriptions = data.mobilabonnemangList;
            this.numberOfRecords = data.numberOfRecords;
            this.error = undefined;
            const evt = new ShowToastEvent({
                title: 'Success',
                message: data.mobilabonnemangList.length + ' Subscription Found.',
                variant: 'success',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);

        } else if (error) {
            console.log('errormsg:', error);
            this.error = error;
            this.contacts = undefined;
        }
    }
*/
    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.subscriptions];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.subscriptions = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
    downloadCSVFile() {
        excelConvert({
            accId: this.recordId
        }).then(result => {
            this.excelString = result;
            if (this.excelString != null) {
                window.open(this.excelString);
            }
        }).catch(error => {
            console.error('**** error **** \n ', error)
        });
    }
    searchTable(e) {
        let searchFilter = e.target.value.toLowerCase();
        this.subscriptions = this.subs.filter((item) => {
            var MSISDN = item.MSISDN__c;
            if ((item.MSISDN__c && item.MSISDN__c.toLowerCase().includes(searchFilter)) ||
                (item.Subscription_Id__c && item.Subscription_Id__c.toLowerCase().includes(searchFilter)) ||
                (item.TeliaSE_User_Name__c && item.TeliaSE_User_Name__c.toLowerCase().includes(searchFilter)) ||
                (item.Subscription_Type__c && item.Subscription_Type__c.toLowerCase().includes(searchFilter)) ||
                (item.CommitmentEndDate__c && item.CommitmentEndDate__c.toLowerCase().includes(searchFilter)) ||
                (item.Subsidized_Subscription__c && item.Subsidized_Subscription__c.toLowerCase().includes(searchFilter)) ||
                (item.Roaming_Service_Descr__c && item.Roaming_Service_Descr__c.toLowerCase().includes(searchFilter)) ||
                (item.Last_Used_Model__c && item.Last_Used_Model__c.toLowerCase().includes(searchFilter)) ||
                (item.Category__c && item.Category__c.toLowerCase().includes(searchFilter))) {
                return item;
            }
        })
    }
}