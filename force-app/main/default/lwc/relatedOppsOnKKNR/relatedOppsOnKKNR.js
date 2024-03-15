/**
 * Created by wgm6247 on 2023-04-07.
 */

import { LightningElement, api, wire, track } from 'lwc';
import getReportIds from '@salesforce/apex/RelatedOppsOnKKNRController.getReportIds';
import { CloseActionScreenEvent } from "lightning/actions";
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

export default class RelatedOppsOnKknr extends LightningElement {
    @api recordId;
    @api profiles;
    @track userId = Id;
    relatedOppReportLink;
    relatedOppBusinessReportLink;
    visible = false;
    error;
    @wire(getReportIds,{})
    reportsId({data,error}) {
        if(data) {
            this.relatedOppReportLink = '/lightning/r/Report/' + data.relatedOppReportID + '/view?fv0=' + this.recordId;
            this.relatedOppBusinessReportLink = '/lightning/r/Report/' + data.relatedOppBusinessReportID + '/view?fv0=' + this.recordId;
        }
        else if (error) {
            this.closeModuleWithErrorToast(error);
        }
    }
    @wire(getRecord, { recordId: Id, fields: ['User.Profile.Name']})
        currentUserInfo({error, data}) {
            if (data) {
                if(this.profiles) {
                    this.visible = this.profiles.includes(data.fields.Profile.displayValue);
                }
            } else if (error) {
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