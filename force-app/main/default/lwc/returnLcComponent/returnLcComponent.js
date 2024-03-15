/**
 * Created by uly8476 on 2021-09-14.
 */
//Default imports
import { LightningElement, api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getFieldValue } from 'lightning/uiRecordApi';

//APEX
import getLCQueueId from '@salesforce/apex/ReturnLcComponentController.getLCQueueId';

//CONSTANTS
import LEAD_OBJECT from '@salesforce/schema/Lead';
import LEAD_CLOSE_REASON_FIELD from '@salesforce/schema/Lead.Lead_Close_Reason__c';
import LEAD_OTHER_REASON_FIELD from '@salesforce/schema/Lead.Other_reason__c';
import LEAD_STATUS_FIELD from '@salesforce/schema/Lead.Status';

export default class ReturnLcComponentController extends LightningElement {
    @api recordId;
    showOtherReasonField = false;
    recordLoaded = false;
    isLoading = true;
    LCQueueId;

    leadObjectInfo = {
        objectApiName: LEAD_OBJECT.objectApiName,
        closeReasonFieldApiName: LEAD_CLOSE_REASON_FIELD.fieldApiName,
        otherReasonFieldApiName: LEAD_OTHER_REASON_FIELD.fieldApiName,
        leadStatusFieldApiName: LEAD_STATUS_FIELD.fieldApiName
    };

//LIFECYCLE
    connectedCallback() {
        this.fetchLCQueueId();
    }

//FORM EVENT HANDLERS
    handleOnLoad(event) {
        if(!this.recordLoaded){
            console.log('handleOnLoad event');
            let record = event.detail.records[this.recordId];
            this.handleCloseReasonChange({ detail: {value: getFieldValue(record, LEAD_CLOSE_REASON_FIELD)} });
            this.recordLoaded = true;
            this.isLoading = false;
        }
    }

    handleOnSuccess() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleOnError(event) {
        this.isLoading = false;
    }

    handleCloseReasonChange(event) {
        this.showOtherReasonField = (event.detail.value === 'Annat');
    }

//ON CLICK HANDLERS
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    saveRecord() {
        this.isLoading = true;
        let inputFields = this.template.querySelectorAll('lightning-input-field');
        let fields = {};
        inputFields.forEach(field => {
            fields[field.fieldName] = field.value;
        });
        fields.OwnerId = this.LCQueueId;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

//FUNCTIONAL
    fetchLCQueueId() {
        getLCQueueId()
        .then(result => {
            this.LCQueueId = result;
        })
        .catch(error => {
            console.error(error);
        })
    }
}