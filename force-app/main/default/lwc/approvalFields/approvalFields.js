/**
 * Created by kwn687 on 2022-11-29.
 */

import { LightningElement, api } from 'lwc';

import AMOUNT_FIELD from '@salesforce/schema/Opportunity.Cygate_Amount_for_Approval__c';
import MARGIN_FIELD from '@salesforce/schema/Opportunity.Cygate_Margin_for_Approval__c';
import TYPE_FIELD from '@salesforce/schema/Opportunity.Approval_Type__c';
import STATUS_FIELD from '@salesforce/schema/Opportunity.Approval_Status_Cygate__c';
import ITEMS_FOR_APPROVAL from '@salesforce/label/c.Items_for_Approval';

export default class ApprovalFields extends LightningElement {
    amountField = AMOUNT_FIELD;
    marginField = MARGIN_FIELD;
    typeField = TYPE_FIELD;
    statusField = STATUS_FIELD;
    ItemsForApproval = ITEMS_FOR_APPROVAL;
    @api recordId;
    @api objectApiName;
}