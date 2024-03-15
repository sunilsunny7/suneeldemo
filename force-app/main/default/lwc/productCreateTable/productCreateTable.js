/**
 * Created by kwn687 on 2022-07-07.
 */
import { LightningElement, api, wire, track} from "lwc";
import { getPicklistValues} from "lightning/uiObjectInfoApi";
import SUPPLIER_FIELD from "@salesforce/schema/OpportunityLineItem.Supplier__c";
import SALES_TYPE_FIELD from "@salesforce/schema/OpportunityLineItem.Sales_Type_Cygate__c";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class ProductCreateTable extends LightningElement {
    @api selectedProducts = [];
    @api newProducts = [];
    @api productCount;
    @api mainProductsLabel;
    @api cygateProductsLabel;
    @track objectInfo;
    @track opportunityProductInfo;
    picklistValues;
    salesTypeValues;

    @wire(getObjectInfo, { objectApiName: 'Opportunity' })
     objectInfo;
    @wire(getObjectInfo, { objectApiName: 'OpportunityLineItem' })
     opportunityProductInfo;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: SUPPLIER_FIELD,
    })
        getPicklistValues({ error, data }) {
            if (data) {
                this.picklistValues = data.values;
            } else if (error) {
                console.error(error);
            }
    }
    @wire(getPicklistValues, {
            recordTypeId: "$objectInfo.data.defaultRecordTypeId",
            fieldApiName: SALES_TYPE_FIELD,
        })
        getSalesTypeValues({ error, data }) {
            if (data) {
                this.salesTypeValues = data.values;
            } else if (error) {
                console.error(error);
            }
        }
    handleSaveTG(event) {
        var notFound = false;
        if (this.newProducts.length !== 0) {
            for (var i = 0; i < this.newProducts.length; i++) {
                if (
                    this.newProducts[i].mainProduct === event.target.title &&
                    this.newProducts[i].cygateProduct === event.target.dataset.index
                ) {
                    this.newProducts[i].cygateTG = event.target.value;
                    notFound = false;
                    break;
                } else {
                    notFound = true;
                }
            }
        } else {
            this.newProducts.push({
                mainProduct: event.target.title,
                cygateProduct: event.target.dataset.index,
                cygateTG: event.target.value
            });
        }
        if (notFound) {
            this.newProducts.push({
                mainProduct: event.target.title,
                cygateProduct: event.target.dataset.index,
                cygateTG: event.target.value
            });
        }
        const allProducts = new CustomEvent("passproducts", {
            detail: this.newProducts
        });
        this.dispatchEvent(allProducts);
    }
    handleSaveUP(event) {
            var notFound = false;
            if (this.newProducts.length !== 0) {
                for (var i = 0; i < this.newProducts.length; i++) {
                    if (
                        this.newProducts[i].mainProduct === event.target.title &&
                        this.newProducts[i].cygateProduct === event.target.dataset.index
                    ) {
                        this.newProducts[i].unitePrice = event.target.value;
                        notFound = false;
                        break;
                    } else {
                        notFound = true;
                    }
                }
            } else {
                this.newProducts.push({
                    mainProduct: event.target.title,
                    cygateProduct: event.target.dataset.index,
                    unitePrice: event.target.value
                });
            }
            if (notFound) {
                this.newProducts.push({
                    mainProduct: event.target.title,
                    cygateProduct: event.target.dataset.index,
                    unitePrice: event.target.value
                });
            }
            const allProducts = new CustomEvent("passproducts", {
                detail: this.newProducts
            });
            this.dispatchEvent(allProducts);
        }
        /* Removed for LTAT-10020 by Ignas Bujevičius on 2023/05/22
        handleSaveQuantity(event) {
                    var notFound = false;
                    if (this.newProducts.length !== 0) {
                        for (var i = 0; i < this.newProducts.length; i++) {
                            if (
                                this.newProducts[i].mainProduct === event.target.title &&
                                this.newProducts[i].cygateProduct === event.target.dataset.index
                            ) {
                                this.newProducts[i].quantiy = event.target.value;
                                notFound = false;
                                break;
                            } else {
                                notFound = true;
                            }
                        }
                    } else {
                        this.newProducts.push({
                            mainProduct: event.target.title,
                            cygateProduct: event.target.dataset.index,
                            quantiy: event.target.value
                        });
                    }
                    if (notFound) {
                        this.newProducts.push({
                            mainProduct: event.target.title,
                            cygateProduct: event.target.dataset.index,
                            quantiy: event.target.value
                        });
                    }
                    const allProducts = new CustomEvent("passproducts", {
                        detail: this.newProducts
                    });
                    this.dispatchEvent(allProducts);
                }
            */
        handleSaveSF(event) {
                    var notFound = false;
                    if (this.newProducts.length !== 0) {
                        for (var i = 0; i < this.newProducts.length; i++) {
                            if (
                                this.newProducts[i].mainProduct === event.target.title &&
                                this.newProducts[i].cygateProduct === event.target.dataset.index
                            ) {
                                this.newProducts[i].startFee = event.target.value;
                                notFound = false;
                                break;
                            } else {
                                notFound = true;
                            }
                        }
                    } else {
                        this.newProducts.push({
                            mainProduct: event.target.title,
                            cygateProduct: event.target.dataset.index,
                            startFee: event.target.value
                        });
                    }
                    if (notFound) {
                        this.newProducts.push({
                            mainProduct: event.target.title,
                            cygateProduct: event.target.dataset.index,
                            startFee: event.target.value
                        });
                    }
                    const allProducts = new CustomEvent("passproducts", {
                        detail: this.newProducts
                    });
                    this.dispatchEvent(allProducts);
                        }
    handleSaveContractPeriod(event) {
        var notFound = false;
        if (this.newProducts.length !== 0) {
            for (var i = 0; i < this.newProducts.length; i++) {
                if (
                    this.newProducts[i].mainProduct === event.target.title &&
                    this.newProducts[i].cygateProduct === event.target.dataset.index
                ) {
                    this.newProducts[i].contractPeriod = event.target.value;
                    notFound = false;
                    break;
                } else {
                    notFound = true;
                }
            }
        } else {
            this.newProducts.push({
                mainProduct: event.target.title,
                cygateProduct: event.target.dataset.index,
                contractPeriod: event.target.value
            });
        }
        if (notFound) {
            this.newProducts.push({
                mainProduct: event.target.title,
                cygateProduct: event.target.dataset.index,
                contractPeriod: event.target.value
            });
        }
        const allProducts = new CustomEvent("passproducts", {
            detail: this.newProducts
        });
        this.dispatchEvent(allProducts);
    }
    handleBlur(event) {
        var inputCmp = this.template.querySelector('.inputCmp');
        var value = inputCmp.value;
        if (!value) {
            inputCmp.setCustomValidity('Do not leave field empty');
        } else {
            inputCmp.setCustomValidity(''); // if there was a custom error before, reset it
        }
        inputCmp.reportValidity(); // Tells lightning-input to show the error right away without needing interaction
    }
    handleSaveSupplier(event) {
        var notFound = false;
        if (this.newProducts.length !== 0) {
            for (var i = 0; i < this.newProducts.length; i++) {
                if (
                    this.newProducts[i].mainProduct === event.target.title &&
                    this.newProducts[i].cygateProduct === event.target.dataset.index
                ) {
                    this.newProducts[i].supplier = event.target.value;
                    notFound = false;
                    break;
                } else {
                    notFound = true;
                }
            }
        } else {
            this.newProducts.push({
                mainProduct: event.target.title,
                cygateProduct: event.target.dataset.index,
                supplier: event.target.value
            });
        }
        if (notFound) {
            this.newProducts.push({
                mainProduct: event.target.title,
                cygateProduct: event.target.dataset.index,
                supplier: event.target.value
            });
        }
        const allProducts = new CustomEvent("passproducts", {
            detail: this.newProducts
        });
        this.dispatchEvent(allProducts);
    }
    handleSaveSalesType(event) {
            var notFound = false;
            var countFilledFields = 0;
            if (this.newProducts.length !== 0) {
                for (var i = 0; i < this.newProducts.length; i++) {
                    if (
                        this.newProducts[i].mainProduct === event.target.title &&
                        this.newProducts[i].cygateProduct === event.target.dataset.index
                    ) {
                        this.newProducts[i].salesType = event.target.value;
                        notFound = false;
                        break;
                    } else {
                        notFound = true;
                    }
                }
            } else {
                this.newProducts.push({
                    mainProduct: event.target.title,
                    cygateProduct: event.target.dataset.index,
                    salesType: event.target.value
                });
            }
            if (notFound) {
                this.newProducts.push({
                    mainProduct: event.target.title,
                    cygateProduct: event.target.dataset.index,
                    salesType: event.target.value
                });
            }
            const allProducts = new CustomEvent("passproducts", {
                detail: this.newProducts
            });
            this.dispatchEvent(allProducts);
            for (var i = 0; i < this.newProducts.length; i++) {
                if (this.newProducts[i].salesType) {
                    countFilledFields = countFilledFields + 1;
                }
            }
            if (countFilledFields === this.productCount) {
                const enableSave = new CustomEvent("passsave", {
                    detail: false
                });
                this.dispatchEvent(enableSave);
            } else {
                const disableSave = new CustomEvent("passsave", {
                    detail: true
                });
                this.dispatchEvent(disableSave);
            }
        }

}