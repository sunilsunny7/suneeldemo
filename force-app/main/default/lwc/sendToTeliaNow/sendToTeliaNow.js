import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import startTeliaNowAPI from '@salesforce/apex/SendToTeliaNowController.startTeliaNowAPI';
import { getRecord } from 'lightning/uiRecordApi';
import subjectTNOW from '@salesforce/label/c.TNOW_Subject';
import productTypeTNOW from '@salesforce/label/c.TNOW_Product_Type';
import descriptionTNOW from '@salesforce/label/c.TNOW_Description';
import emailTNOW from '@salesforce/label/c.TNOW_e_mail';
import createdTNOW from '@salesforce/label/c.TNOW_created';
import buttonTNOW from '@salesforce/label/c.TNOW_button';
import sucessTNOW from '@salesforce/label/c.TNOW_success';
const FIELDS  = ['Case.Subject','Case.ContactEmail','Case.Assignment_group_to_TNOW__c','Case.Description', 'Case.ContactId', 'Case.TNOW_Case_Id__c'];
export default class SendToTeliaNow extends LightningElement {
    @api recordId;
    label = {
        subjectTNOW,
        productTypeTNOW,
        descriptionTNOW,
        emailTNOW,
        createdTNOW,
        buttonTNOW,
        sucessTNOW
    };
    buttonDisabled;
    loaded;
    subject = false;
    assignmentGroup = false;
    description = false;
    email = false;
    tnowCaseId;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
    case({data,error}){
        if(data){
            if (data.fields.TNOW_Case_Id__c.value) {
                this.buttonDisabled = true;
                this.tnowCaseId = data.fields.TNOW_Case_Id__c.value;
            } else {
                this.subject = !data.fields.Subject.value;
                this.assignmentGroup = !data.fields.Assignment_group_to_TNOW__c.value;
                this.description = !data.fields.Description.value;
                this.email = !data.fields.ContactEmail.value && data.fields.ContactId.value;
                this.buttonDisabled = (this.subject || this.assignmentGroup || this.description || this.email);
            }
            
            this.loaded = true;
        }
        else if(error){
            this.closeModuleWithErrorToast(error);
        }
       
    }
    handleClick(){
        this.buttonDisabled = true;
        startTeliaNowAPI({ recordId: this.recordId}).then((result)=>{this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success!',
                message: this.label.sucessTNOW,
                variant: 'success'
            })
        );
        this.buttonDisabled = true;
        //window.location.reload();
        this.dispatchEvent(new RefreshEvent());
        }).catch((error)=>{
            this.closeModuleWithErrorToast(error);
            this.buttonDisabled = false;
    });

    }
    closeModuleWithErrorToast(ldsError){
        this.dispatchEvent(new CloseActionScreenEvent());
        let errorMsg = reduceErrors(ldsError);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: errorMsg.join(','),
                variant: 'error'
            })
        );
    }
}