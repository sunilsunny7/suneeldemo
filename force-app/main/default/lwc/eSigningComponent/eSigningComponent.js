/**
 * Created by uly8476 on 2021-10-20.
 */
//DEFAULT IMPORTS
import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecord, getFieldValue, deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//APEX
import retrieveContacts from '@salesforce/apex/ESigningComponentController.retrieveContacts';
import updateAttachedFiles from '@salesforce/apex/ESigningComponentController.updateAttachedFiles';
import createScriveDocument from '@salesforce/apex/ESigningComponentController.createScriveDocument';
import retrieveScriveDocumentId from '@salesforce/apex/ESigningComponentController.retrieveScriveDocumentId';
import getProductPicklistValues from '@salesforce/apex/ESigningComponentController.getProductPicklistValues';
import updateScriveDocumentFields from '@salesforce/apex/ESigningComponentController.updateScriveDocumentFields';

//CUSTOM LABELS
import cancelLabel from '@salesforce/label/c.eSigningComponentCancelLabel';
import submitLabel from '@salesforce/label/c.eSigningComponentSubmitLabel';
import contractEndLabel from '@salesforce/label/c.eSigningComponentContractEndLabel';
import contractStartLabel from '@salesforce/label/c.eSigningComponentContractStartLabel';
import documentTypeLabel from '@salesforce/label/c.eSigningComponentDocumentTypeLabel';
import headerLabel from '@salesforce/label/c.eSigningComponentHeaderLabel';
import noteLabel from '@salesforce/label/c.eSigningComponentNoteLabel';
import agreementNumberLabel from '@salesforce/label/c.eSigningComponentAgreementLabel';
import replacementLabel from '@salesforce/label/c.eSigningComponentReplacementLabel';
import selectProductLabel from '@salesforce/label/c.eSigningComponentSelectProductLabel';
import signingContactLabel from '@salesforce/label/c.eSigningComponentSigningContactLabel';
import uploadDocumentLabel from '@salesforce/label/c.eSigningComponentUploadDocumentLabel';
import fileSelectErrorLabel from '@salesforce/label/c.eSigningComponentFileSelectErrorLabel';
import emailLabel from '@salesforce/label/c.eSigningComponentEmailLabel';
import nameLabel from '@salesforce/label/c.eSigningComponentNameLabel';
import telephoneLabel from '@salesforce/label/c.eSigningComponentTelephoneLabel';
import uploadedFilesLabel from '@salesforce/label/c.eSigningComponentUploadedFilesLabel';
import deletingErrorLabel from '@salesforce/label/c.eSigningComponentDeletingErrorLabel';
import fileDeletedLabel from '@salesforce/label/c.eSigningComponentFileDeletedLabel';
import uploadHelptextLabel from '@salesforce/label/c.eSigningComponentUploadHelptextLabel';
import signatoryRoleErrorLabel from '@salesforce/label/c.eSigningComponentSignatoryRoleError';

//FIELDS
import OPP_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import ACC_ID_FIELD from '@salesforce/schema/Account.Id';

//CONSTANTS
const CONTACTS_LAYOUT = [
    { label: nameLabel, fieldName: 'Name', type: 'text' },
    { label: telephoneLabel, fieldName: 'MobilePhone', type: 'phone' },
    { label: emailLabel, fieldName: 'Email', type: 'email' }
];
const FILES_LAYOUT = [
    { label: uploadedFilesLabel, fieldName: 'name', type: 'text' },
    { label: '', type: 'button-icon', initialWidth: '50', typeAttributes: { name: 'delete', iconName: 'utility:delete', variant: 'bare' } }
];

export default class ESigningComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track attachedDocuments = [];
    @track files = [];
    contacts = [];
    selectedContactIds = [];
    eSigningProductValues = [];

    scriveDocumentId;
    selectedDocumentType;
    selectedProduct;
    enteredStartDate;
    enteredEndDate;
    enteredAgreementNumber;
    enteredReplacementAgreement;
    enteredNote;
    selectedFileId;
    error;

    isLoading = false;
    scriveDocumentCreated = false;
    contactsSelected = false;
    contactsAvailable = true;

    label = {
        cancelLabel,
        submitLabel,
        headerLabel,
        contractEndLabel,
        contractStartLabel,
        documentTypeLabel,
        noteLabel,
        agreementNumberLabel,
        replacementLabel,
        selectProductLabel,
        signingContactLabel,
        uploadDocumentLabel,
        fileSelectErrorLabel,
        uploadHelptextLabel,
        signatoryRoleErrorLabel
    };

    contactsLayout = CONTACTS_LAYOUT;
    filesLayout = FILES_LAYOUT;

    disconnectedCallback() {
        if(this.attachedDocuments.length > 0 && !this.scriveDocumentCreated){
            this.deleteAllAttached(this.attachedDocuments);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: '$fields'})
    wiredRecord({ data, error }){
        if(data){
            this.error = undefined;
            this.isLoading = true;
            retrieveContacts({recordId: this.recordId, objectApiName: this.objectApiName})
            .then(availableContacts => {
                if(Array.isArray(availableContacts) && availableContacts.length > 0){
                    this.contacts = availableContacts;
                } else {
                    this.contactsAvailable = false;
                }
                this.isLoading = false;
            })
            .catch(error => {
                console.error(error);
                this.error = error.body.message;
                this.isLoading = false;
            });
        }
    }

    @wire(getProductPicklistValues)
       getProductPicklistValues({error, data}) {
           if (data){
              this.eSigningProductValues = data;
           }
           else if (error) {
               console.error ('An error has occured while loading eSigningComponentValues: '+ JSON.stringify(error));
           }
        }

//EVENT HANDLERS
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        uploadedFiles.forEach(file => this.attachedDocuments.push(file));
        this.files = [...this.attachedDocuments];
    }
    handleDocumentTypeChange(event) {
        this.selectedDocumentType = event.detail.value;
    }
    handleProductChange(event) {
        this.selectedProduct = event.detail.value;
    }
    handleStartDateChange(event) {
        this.enteredStartDate = event.detail.value;
    }
    handleEndDateChange(event) {
        this.enteredEndDate = event.detail.value;
    }
    handleAgreementNumberChange(event) {
        this.enteredAgreementNumber = event.detail.value;
    }
    handleReplacementAgreementChange(event) {
        this.enteredReplacementAgreement = event.detail.value;
    }
    handleNoteChange(event) {
        this.enteredNote = event.detail.value;
    }
    handleFileSelect(event){
        if(event.detail.selectedRows.length != 0){
            this.selectedFileId = event.detail.selectedRows[0].documentId;
            this.attachedDocuments.map(obj => {
                obj.selected = obj.documentId == event.detail.selectedRows[0].documentId ? true : false;
            });
        }
    }
    handleDelete(event){
        this.isLoading = true;
        if(this.selectedFileId == event.detail.row.documentId){
            this.selectedFileId = null;
        }
        deleteRecord(event.detail.row.documentId)
            .then(() => {
                for (let i = 0; i < this.attachedDocuments.length; i++) {
                    if (this.attachedDocuments[i].documentId == event.detail.row.documentId) {
                        this.attachedDocuments.splice(i, 1);
                        this.files = [...this.attachedDocuments];
                    }
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: fileDeletedLabel,
                        variant: 'success'
                    })
                );
                this.isLoading = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: deletingErrorLabel,
                        message: error.body.message,
                        variant: 'error'
                    })
                );
                this.isLoading = false;
            });
    }
    handleContactSelection(event){
        if(event.detail.selectedRows.length != 0){
            this.contactsSelected = true;
        } else {
            this.contactsSelected = false;
        }
    }

//GETTERS
    get submitDisabled() {
        return (this.attachedDocuments.length > 0 && this.contactsSelected == true && this.selectedFileId != undefined && this.selectedDocumentType == 'service_agreement' ? false :
                this.attachedDocuments.length > 0 && this.contactsSelected == true && this.selectedFileId != undefined && this.selectedDocumentType == 'frame_agreement' && this.selectedProduct != undefined && this.enteredStartDate != undefined && this.enteredEndDate != undefined && this.enteredAgreementNumber != undefined ? false : true)
    }
    get documentTypeOptions() {
        return [
            { label: 'Avtal', value: 'frame_agreement'},
            { label: 'Fullmakt', value: 'service_agreement'},
        ];
    }
    get productOptions() {
        return this.eSigningProductValues;
    }
    get documentTypeContract() {
        return this.selectedDocumentType == 'frame_agreement' ? true : false
    }
    get filesAttached() {
        return this.attachedDocuments.length != 0 ? true : false
    }
    get fileNotSelected() {
        return (this.selectedFileId == null || this.selectedFileId == undefined) ? true : false
    }
    get acceptedFormats() {
        return ['.pdf'];
    }
    get displayModal() {
        return this.contactsAvailable;
    }
    get fields() {
        if (this.objectApiName === "Account") {
            return ACC_ID_FIELD;
        } else if (this.objectApiName === "Opportunity") {
            return OPP_ID_FIELD;
        }
    }
// ON CLICK HANDLERS
    closeHandler() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    submitHandler() {
        this.isLoading = true;
        let selectedContactRows = this.template.querySelector('.contactsTable').getSelectedRows();
        for (let i = 0; i < selectedContactRows.length; i++){
            this.selectedContactIds.push(selectedContactRows[i].Id);
        }
        this.updateAttachedDocuments(this.attachedDocuments);
    }

// FUNCTIONAL
    updateAttachedDocuments(attachedDocuments) {
        if (attachedDocuments.length > 0) {
            updateAttachedFiles({attachedDocuments, recordId: this.recordId, product: this.selectedProduct, startDate: this.enteredStartDate, endDate: this.enteredEndDate, agreementNumber: this.enteredAgreementNumber, replaceAgreement: this.enteredReplacementAgreement, documentType: this.selectedDocumentType, note: this.enteredNote})
            .then(() => {
                this.createScriveDocument(attachedDocuments, this.recordId, this.selectedContactIds);
            })
            .catch(error => {
                console.error(error);
                this.isLoading = false;
            });
        }
    }

    createScriveDocument(attachedDocuments, recordId, selectedContactIds) {
        createScriveDocument({ attachedDocuments, recordId, selectedContactIds: selectedContactIds })
        .then(result => {
            this.scriveDocumentCreated = result;
            this.getScriveDocumentId(recordId);
        })
        .catch(error => {
            console.error(error);
            this.isLoading = false;
        });
    }

    navigateToScriveLink(scriveDocumentId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/lightning/r/scrive__ScriveDocument__c/'+ scriveDocumentId + '/view'
            }
        },
        true
        );
    }

    deleteAllAttached(attachedFiles) {
        if (attachedFiles.length > 0){
            for(let i = 0; i < attachedFiles.length; i++){
                deleteRecord(attachedFiles[i].documentId)
                .then(() => {
                })
                .catch(error => {
                    console.error(error);
                })
            }
        }
    }

    getScriveDocumentId(recordId) {
        retrieveScriveDocumentId({recordId})
        .then(scriveDocumentId => {
            this.updateScriveDocumentFields(scriveDocumentId, this.attachedDocuments);
        })
        .catch(error => {
            console.error(error);
            this.isLoading = false;
        })
    }

    updateScriveDocumentFields(scriveDocumentId, attachedDocuments) {
        updateScriveDocumentFields({scriveDocumentId, attachedDocuments})
        .then(() => {
            this.isLoading = false;
            this.navigateToScriveLink(scriveDocumentId);
        })
        .catch(error => {
            console.error(error);
            this.isLoading = false;
        })
    }
}