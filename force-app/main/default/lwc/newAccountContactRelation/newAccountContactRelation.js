/**
 * Created by uly8476 on 2022-11-16.
 */

import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

//Objects & Fields

import ACR_OBJECT from '@salesforce/schema/AccountContactRelation';
import ACCOUNT_FIELD from '@salesforce/schema/AccountContactRelation.AccountId';
import CONTACT_FIELD from '@salesforce/schema/AccountContactRelation.ContactId';
import ESIGNING_ROLE_FIELD from '@salesforce/schema/AccountContactRelation.E_Signing_Role__c';

//Custom Labels


export default class NewAccountContactRelation extends LightningElement {
    @api recordId;
    isLoading = false;
    accountContactRelationObject = ACR_OBJECT;
    AccContactRelationAccountField = ACCOUNT_FIELD.fieldApiName;
    AccContactRelationContactField = CONTACT_FIELD.fieldApiName;
    AccContactRelationEsigningRoleField = ESIGNING_ROLE_FIELD.fieldApiName;


    handleSubmit(event) {
        this.isLoading = true;
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleClose(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleSuccess(event) {
        this.isLoading = false;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleError(event) {
        this.isLoading = false;
        let message = event.detail.detail;
        const toast = new ShowToastEvent({
            title: 'Error!',
            variant: 'error',
            message: message
        });
        console.error(event);
        this.dispatchEvent(toast);
    }
}