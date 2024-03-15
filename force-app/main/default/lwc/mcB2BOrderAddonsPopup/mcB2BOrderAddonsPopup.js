import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';

// const 

export default class McB2BOrderAddonsPopup extends LightningModal {
    @api content;
    @api orderNumber;
    @track label;
    @track data = [];
    handleOkay() {
        this.close('okay');
    }

    columns = [
        { label: 'Produkt', fieldName: 'MC_Product_Info__c', type: 'string', sortable: true, },
        { label: 'Tillval Antal', fieldName: 'MC_Item_Quantity__c', type: 'number', sortable: true },
        { label: 'Tillval Status', fieldName: 'MC_Item_Status__c', type: 'string', sortable: true },
        { label: 'Tillval Utlovat leveransdatum', fieldName: 'MC_Item_Promised_Date__c', type: 'date', sortable: true, typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric' } },
        { label: 'Tillval Önskat leveransdatum', fieldName: 'MC_Item_Req_Del_Date__c', type: 'date', sortable: true, typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric' } },

    ];

    connectedCallback() {
        // console.log(this.content);
        this.data = this.content.addons;

        this.data = JSON.parse(JSON.stringify(this.data));
        this.label = 'Orderdetaljer ( ' + this.content.numberOfRecords + ' )';
    }
}