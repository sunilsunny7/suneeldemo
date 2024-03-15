/**
 * Created by kwn687 on 2022-06-15.
 */
import { LightningElement, api, track, wire } from 'lwc';
import { CloseActionScreenEvent } from "lightning/actions";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord } from "lightning/uiRecordApi";
import { loadStyle } from "lightning/platformResourceLoader";
import RecordTypeId_FIELD from "@salesforce/schema/Opportunity.RecordTypeId";
import MainProduct_FIELD from "@salesforce/schema/Opportunity.Main_Product_Area__c";
import CygateProduct_FIELD from "@salesforce/schema/Opportunity.CygateProduct__c";
import insertProducts from '@salesforce/apex/mainProductSceenController.insertProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import successfullInsert from '@salesforce/label/c.Successful_insert';
import saveLabel from '@salesforce/label/c.TeliaSE_SaveLabel';
import cancelLabel from '@salesforce/label/c.eSigningComponentCancelLabel'
import addLabel from '@salesforce/label/c.Add'
import backLabel from '@salesforce/label/c.Back'
import nextLabel from '@salesforce/label/c.Next'
import chooseProductsLabel from '@salesforce/label/c.Choose_Products'
import myLWCStyles from './mainCygateProductScreen.css';

export default class MainCygateProductScreen extends LightningElement {
    @api recordId;
    @track mainProduct;
    @track recordTypeId;
    @track mainProductsValue;
    @track cygateProductsValue;
    @track allCygateProducts;
    @track allValueCount;
    @track productMap = [];
    @track mainProductsLabel;
    @track cygateProductsLabel;
    isLoaded = true;
    allProducts = [];
    editTable = false;
    disabledAddMore = true;
    disabledNext = true;
    dataIsLoaded = false;
    // Custom Lables:
    save = saveLabel;
    cancel = cancelLabel;
    add = addLabel;
    back = backLabel;
    next = nextLabel;
    chooseProducts = chooseProductsLabel;
    static styles = [myLWCStyles];

 @wire(getObjectInfo, { objectApiName: 'Opportunity' })
     objectInfo({error, data}){
         if(data){
             this.cygateProductsLabel = data.fields.CygateProduct__c.label;
             this.mainProductsLabel = data.fields.Main_Product_Area__c.label;
         }
     }

    @wire(getRecord, { recordId: "$recordId", fields: [RecordTypeId_FIELD], })
    getOpportunity({ error, data }) {
        if (data) {
            this.recordTypeId = data.fields.RecordTypeId.value;

        } else if (error) {
            console.error(error);
        }
    }
    // Getting Main product Area and Cygate Product picklst values
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: MainProduct_FIELD,
    })
    mainProducts;
    @wire(getPicklistValues, {
        recordTypeId: "$recordTypeId",
        fieldApiName: CygateProduct_FIELD,
    })
    getAllCygateProducts({
        error,
        data
    }) {
        if (data) {
            // Map picklist values
            this.allCygateProducts = data.values.map(plValue => {
                return {
                    label: plValue.label,
                    value: plValue.value
                };
            });

        } else if (error) {
            // Handle error
            console.error(error);
        }
    }
    // Getting main product values from cygateProductSelect
    handleProductChange(event) {
         this.disabledNext = true;
         this.disabledAddMore = true;
         this.mainProductsValue = event.detail;
        for (let i = 0; i < this.productMap.length; i++) {
                    if (this.productMap[i].key === event.detail) {
                        this.disabledNext = false;
                       this.disabledAddMore = true;
                        break;
                    }
        }
    }
    // Getting cygate product values from cygateProductSelect
    handleCygateChange(event) {
        this.cygateProductsValue = event.detail;
        if (this.mainProductsValue && this.cygateProductsValue) {
            this.disabledNext = false;
            this.disabledAddMore = false;
        }
    }
    // Creating map from cygateProductSelect data and sending data to selectedCygateProducts
    @api handleAddMore(event) {
        this.mapCreation();

        this.mainProductsValue = null;
        this.disabledAddMore = true;

    }
    // Removing values from map if it was needed
    handleProductRemove(event) {
        for (let i = 0; i < this.productMap.length; i++) {
            if (this.productMap[i].key === event.detail) {
                this.productMap.splice(i, 1);

                break;
            }

        }
        if (this.productMap.length === 0) {
            this.dataIsLoaded = false;
            this.disabledNext = true;
        }
    }
    // Finishing to create final map which will be transferred for productCreateTable
    handleSubmit(event) {
        this.allValueCount = 0;
        if (this.mainProductsValue && this.cygateProductsValue) {
            this.mapCreation();
            this.mainProductsValue = null;
            this.cygateProductsValue = null;
        }
        this.disabledNext = true;
        this.editTable = true;
        for (let i = 0; i < this.productMap.length; i++) {
            this.allValueCount = this.allValueCount + (this.productMap[i].rowspan - 1);
        }

    }
    // Common methode for map edit and create
    mapCreation() {
        let selectedProduct = {
            key: this.mainProductsValue,
            name: this.cygateProductsValue,
            rowspan: (this.cygateProductsValue.length) + 1
        };

        let founded = false;
        for (let i = 0; i < this.productMap.length; i++) {
            if (this.productMap[i].key === selectedProduct.key) {
                this.productMap.splice(i, 1, selectedProduct);
                founded = true;
                break;
            }

        }
        if (!founded) {
            this.productMap.push(selectedProduct);
            this.dataIsLoaded = true;
            founded = false;
        }
    }

    handleBack() {
        this.editTable = false;
        this.disabledNext = false;
        this.disabledAddMore = true;
    }
    handleSaveButton(event) {
        this.disabledNext = event.detail;
    }
    handleProductFieldsFill(event) {
        this.allProducts = event.detail;

    }
    // Sending data to Apex for new product insert
    handleSave() {
        this.isLoaded = false;
         var messageSplit = successfullInsert.split(',');
        insertProducts({
                allProducts: this.allProducts,
                recordId: this.recordId
            })
            .then(result => {
                this.isLoaded = true;
                const event = new ShowToastEvent({
                    title: messageSplit[0],
                    message: messageSplit[1],
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(event);
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                this.isLoaded = true;
                console.error(error);
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: error,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
            })
    }
    handleCancel(event) {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}