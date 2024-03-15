/**
 * Created by uly8476 on 2023-04-27.
 */

import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CYGATE_BETS_FIELD from '@salesforce/schema/Opportunity.Cygate_BETS__c';

export default class CygateBETSComponent extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: [CYGATE_BETS_FIELD] })
    opportunityRecord;

    get cygateBetsValue() {
        return getFieldValue(this.opportunityRecord.data, CYGATE_BETS_FIELD);
    }

}