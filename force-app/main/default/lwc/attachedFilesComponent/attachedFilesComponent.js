/**
  * Created by uly8476 on 2023-02-23.
  */

import { LightningElement, api, wire, track } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/ldsUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
 //APEX
import getRelatedRecordId from '@salesforce/apex/attachedFilesComponentController.getRelatedRecordId';
import retrieveAttachedFiles from '@salesforce/apex/attachedFilesComponentController.retrieveAttachedFiles';
import updateAttachedFiles from '@salesforce/apex/attachedFilesComponentController.updateAttachedFiles';

const FILES_LAYOUT = [
    { label: 'Uploaded Files', fieldName: 'FileLink', type: 'url',
     typeAttributes: { label: { fieldName: 'Title' }, target: '_blank'},
     sortable: 'true'
    },
    { label: '', type: 'button-icon', initialWidth: '50', typeAttributes: { name: 'delete', iconName: 'utility:delete', variant: 'bare'} }
];

export default class AttachedFilesComponent extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api linkedRecordId;
    @track sortBy = 'FileLink';
    @track sortDirection = 'asc';
    userId = Id;
    profileName;
    attachedFileIds = [];
    attachments = [];
    error;
    isLoading = false;
    filesLayout = FILES_LAYOUT;

    @wire(getRelatedRecordId, { recordId: '$recordId', objectApiName: '$objectApiName'})
    wiredRecord({ data, error }){
        if(data) {
            this.linkedRecordId = data;
            if (data != null) {
                this.retrieveAttachedFiles(data);
            }
        } else if (error) {
            console.error ('Error: '+ JSON.stringify(error));
        }
    }

    //GETTERS
    get filesAttached() {
        return this.attachments.length > 0 ? true : false;
    }

    //EVENT HANDLERS
    handleUploadFinished(event) {
        this.isLoading = true;
        const newAttachedFiles = event.detail.files;
        newAttachedFiles.forEach(file => this.attachedFileIds.push(file.contentVersionId));

        updateAttachedFiles({contentVersionIds: this.attachedFileIds})
            .then(() => {
                this.retrieveAttachedFiles(this.linkedRecordId);
            })
            .catch(error => {
                console.error(error);
                this.isLoading = false;
            });
    }

    @wire(getRecord, { recordId: Id, fields: ['User.Profile.Name']})
        currentUserInfo({error, data}) {
            if (data) {
                this.profileName = data.fields.Profile.displayValue;
            } else if (error) {
                console.error(error);
            }
        }

    handleDelete(event){
        this.isLoading = true;
        const row = event.detail.row;
        console.log(event.detail.row);
        const ownerId = event.detail.row.OwnerId;

        if (ownerId === this.userId || this.profileName === 'System Administrator' || this.profileName === 'Enterprise Business Admin') {
            deleteRecord(event.detail.row.ContentDocumentId)
                .then(() => {
                    for (let i = 0; i < this.attachments.length; i++) {
                        if (this.attachments[i].ContentDocumentId == event.detail.row.ContentDocumentId) {
                            this.attachments.splice(i, 1);
                            this.attachments = [...this.attachments];
                        }
                    }
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Attached file deleted successfully',
                            variant: 'success'
                        })
                    );
                    this.isLoading = false;
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Failed to delete selected files',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                    this.isLoading = false;
                });
        } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'You are not the owner of this file',
                        variant: 'error'
                    })
                );
                this.isLoading = false;
            }
    }
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    retrieveAttachedFiles(recordId) {
        retrieveAttachedFiles({ recordId: recordId })
        .then(attachedFiles => {
            this.attachments = attachedFiles;
            this.sortData(this.sortBy, this.sortDirection);
            this.isLoading = false;
        })
        .catch(error => {
            console.error(error);
            this.isLoading = false;
        });
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.attachments));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        this.attachments = parseData;
    }
}