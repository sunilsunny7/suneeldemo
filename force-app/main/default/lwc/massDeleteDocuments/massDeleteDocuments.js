/**
 * Created by KWN687 on 2022-03-04.
 */

import { LightningElement, api, track, wire } from "lwc";
import retrieveRelatedDocuments from "@salesforce/apex/MassDeleteDocumentsController.retrieveRelatedDocuments";
import retrieveDeletedRelatedDocuments from "@salesforce/apex/MassDeleteDocumentsController.retrieveDeletedRelatedDocuments";
import deleteUndeleteRelatedDocuments from "@salesforce/apex/MassDeleteDocumentsController.deleteUndeleteRelatedDocuments";
import { deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import { refreshApex } from "@salesforce/apex";
import header from "@salesforce/label/c.Mass_Delete_Related_Documents";

const columns = [
  {
    label: "Related Documents Name",
    fieldName: "NameUrl",
    type: "url",
    typeAttributes: { label: { fieldName: "Name" }, target: "_blank" },
  },
  { label: "Opportunity no.", fieldName: "Opportunity_no__c" },
  { label: "Type", fieldName: "Type__c" },
  { label: "Last Modified Date", fieldName: "LastModifiedDate", type: "date" },
  {
    label: "Owner Name",
    fieldName: "OwnerNameURL",
    type: "url",
    typeAttributes: { label: { fieldName: "Owner.Name" }, target: "_blank" },
  },
  { label: "Document Link", fieldName: "Document_Link__c" },
];
export default class MassDeleteDocuments extends LightningElement {
  @api recordId;
  @track records;
  @track deletedRecords;
  @track wireRecord;
  @track setSelectedRows;
  @track delete = false;
  @track buttonLabel = "Delete";
  @api isLoaded = false;
  columns = columns;
  headerLabel = header;
  @wire(retrieveRelatedDocuments, { keySearch: "$recordId" })
  wireRecord(result) {
    this.refreshTable = result;
    if (result.data) {
      this.records = result.data.map((record) =>
        Object.assign(
          {
            "Owner.Name": record.Owner.Name,
            NameUrl: "/" + record.Id,
            OwnerNameURL: "/" + record.OwnerId,
          },
          record
        )
      );
    } else {
      this.error = result.error;
      this.data = undefined;
    }
  }
  @wire(retrieveDeletedRelatedDocuments, { keySearch: "$recordId" })
  wireDeletedRecord(result) {
    this.refreshDeletedTable = result;
    if (result.data) {
      this.deletedRecords = result.data.map((record) =>
        Object.assign(
          {
            "Owner.Name": record.Owner.Name,
            NameUrl: "/" + record.Id,
            OwnerNameURL: "/" + record.OwnerId,
          },
          record
        )
      );
    } else {
      this.error = result.error;
      this.data = undefined;
    }
  }
  tabChanges() {
    this.delete = !this.delete;
    if (this.delete) {
       this.message = "Records deleted successfully";
      this.buttonLabel = "Delete";
    } else {
      this.buttonLabel = "Undelete";
      this.message = "Records undeleted successfully";
    }
  }

  deleteUndeleteRecords() {
    this.isLoaded = !this.isLoaded;
     this.selectedIds = [];
    if(this.delete)
    {
         this.selectedRecords = this.template
              .querySelector("lightning-datatable[data-my-id=deleteTable]")
              .getSelectedRows();


    }
   else
   {
       this.selectedRecords = this.template
                     .querySelector("lightning-datatable[data-my-id=undeleteTable]")
                     .getSelectedRows();
   }
if (this.selectedRecords.length > 0) {
              this.selectedRecords.forEach((currentItem) => {
                this.selectedIds.push(currentItem.Id);
              });
            }
    deleteUndeleteRelatedDocuments({ keySearch: this.selectedIds, isDelete: this.delete })
      .then(() => {
        const toastEvent = new ShowToastEvent({
          title: "Success!",
          message:  this.message,
          variant: "success",
        });
        this.dispatchEvent(toastEvent);
        this.setSelectedRows = [];
        this.isLoaded = !this.isLoaded;
         refreshApex(this.refreshDeletedTable);
         return refreshApex(this.refreshTable);

      })
      .catch((error) => {
        this.isLoaded = !this.isLoaded;
        this.errorMsg = error;
        window.console.log(
          "unable to "+this.buttonLabel+" the record due to " + JSON.stringify(this.errorMsg)
        );
      });
  }
  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}