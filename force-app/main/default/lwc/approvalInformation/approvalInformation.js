import { LightningElement, api, wire } from 'lwc';

import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CloseActionScreenEvent } from "lightning/actions";
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordData from '@salesforce/apex/ApprovalInformationController.getRecordData';

import OPPORTUNITY_NAME_LABEL from '@salesforce/label/c.Opportunity_Name';
import OPPORTUNITY_OWNER_LABEL from '@salesforce/label/c.Opportunity_Owner_1';
import APPROVAL_DETAILS_LABEL from '@salesforce/label/c.Approval_Details';
import ACCOUNT_NAME_LABEL from '@salesforce/label/c.Account_Name';

export default class ApprovalInformation extends LightningElement {
    @api recordId;
    @api objectApiName;
    oppFieldLabels;
    oppFieldValues;
    marginPercent;
    customLabel = {
        OPPORTUNITY_NAME_LABEL,
        OPPORTUNITY_OWNER_LABEL,
        APPROVAL_DETAILS_LABEL,
        ACCOUNT_NAME_LABEL
    };
     @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
     oppInfo({ data, error }) {
        if(data){
            this.oppFieldLabels = data;
        }
        else if(error){
            this.closeModuleWithErrorToast(error);
        }
    }
    @wire(getRecordData, { recordId: '$recordId', objectApiName: '$objectApiName'})
    wiredRecord({ data, error }){
        if(data) {
            this.oppFieldValues = data;
        }
        else if(error){
            this.closeModuleWithErrorToast(error);
        }
    }    
    closeModuleWithErrorToast(ldsError){
        this.dispatchEvent(new CloseActionScreenEvent());
        let errorMsg = reduceErrors(ldsError);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error while refreshing records',
                message: errorMsg.join(','),
                variant: 'error'
            })
        );
    }
}