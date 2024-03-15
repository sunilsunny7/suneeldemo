import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';

export default class ProductsAndBandwidth extends OmniscriptBaseMixin(LightningElement) {


    @track products = []; //products array from DR
    @track productsArray = [];
    @track productFamily = '';
    @track total = 0;
    @track productBandwidth = [];
    @track b1 = []; //bandwidths for displaying 
    @track b2 = [];
    @track headers = []; //sending combined headers to the next step
    @track selectedBandwidth1;
    @track selectedBandwidth2;
    @track selectedProducts = [];
    @track isModalOpen = false;
    @track selectedSiteArray = [];
    @track newArray;
    @track modifiedData = [];
    @track errorSitesDetails = [];
    @track _mydata = [];
    @track dataReceived = false;
    @track items_displayed = 0;
    @track items_processed = 0;
    @track averagePrices;
    @track averagePricesArray = [];
    @track precheckDate = '';
    @track OpportunityList = {};
    @track counter = 0;
    @track processing = false;
    @track isPrecheckNotProcessed = false;
    @track counter = 0;
    myInterval;
    progressBarValue;
    _actionUtilClass;
    _ns = getNamespaceDotNotation();

    @track fullSiteListProducts = [];
    @track confirmDeleteModal = false;
    @track arrayOfSitesToDelete = [];


    @api
    get customProducts() {
        return this.products;
    }
    set customProducts(value) {
        if (value === undefined) {
            this.products = false;
        } else {
            this.products = value;
        }
    }

    @api
    get customProductFamily() {
        return this.productFamily;
    }
    set customProductFamily(value) {
        if (value === undefined) {
            this.productFamily = false;
        } else {
            this.productFamily = value;
        }
    }


    @api
    get customBandwidth() {
        return this.productBandwidth;
    }
    set customBandwidth(value) {
        console.log('line:84' + value);
        if (Array.isArray(value)) {
            value.forEach(ele => {
                this.productBandwidth.push(ele);
            });
        }
    }


    connectedCallback() {
        this.progressBarValue = 0;
        this.selectedBandwidth1 = '100';
        this.selectedBandwidth2 = '1000';
        this.products.forEach(ele => {

            if (ele.Label != 'Bredband Start') {
                var checked = true;
                this.selectedProducts.push(ele.Label);
                this.productsArray.push({
                    'productName': ele.Label,
                    'checked': checked
                })
            } else {
                var checked = false;
                this.productsArray.push({
                    'productName': ele.Label,
                    'checked': checked
                })
            }
        })
        this.filterBandwidth();
        this._actionUtilClass = new OmniscriptActionCommonUtil();
        this.OpportunityList = this.omniJsonData.OpportunityList;
        this.refreshData();



    }

    selectBandwidth(event) {
        if (event.target.name === "radioGroup1") {
            this.selectedBandwidth1 = event.target.value;
        } else if (event.target.name === "radioGroup2") {
            this.selectedBandwidth2 = event.target.value;
        }
    }
    selectProducts(event) {

        const index = this.productsArray.findIndex(ele => ele.productName === event.target.value);
        this.productsArray[index].checked = event.target.checked;

        console.log(JSON.parse(JSON.stringify(this.productsArray)));
        this.selectedProducts = [];

        this.productsArray.forEach(ele => {
            if (ele.checked) {
                this.selectedProducts.push(ele.productName);
            }
        })

        this.filterBandwidth();

    }

    //Developer: Abhinav Gupta
    //Dynamic Product Bandwidth
    filterBandwidth() {
        this.selectedBandwidth1 = '100';
        this.selectedBandwidth2 = '1000';
        this.b1 = [];
        this.b2 = [];
        const bandwidthArr = [];

        this.selectedProducts.forEach(element => {
            this.productBandwidth.forEach(pdBw => {
                if (pdBw.productName === element) {
                    pdBw.speeds.forEach(s => {
                        if (bandwidthArr.findIndex(ele => ele.value == s.value) === -1) {
                            bandwidthArr.push(s);
                        }

                    });
                }
            });
        });
        let sortedbandwidth = bandwidthArr.sort(
            (b1, b2) => (parseInt(b1.value) > parseInt(b2.value)) ? 1 : (parseInt(b1.value) < parseInt(b2.value)) ? -1 : 0);
        this.b1 = sortedbandwidth;
        this.b2 = sortedbandwidth;
    }


    openModal(event) {

        var currentSelectedSiteId = event.currentTarget.dataset.id;
        var accId = event.currentTarget.dataset.account;

        const inputData = {
            'ServicepointId': currentSelectedSiteId,
            'AccountId': accId,
            'ProductFamily': this.productFamily
        }

        const params = {
            input: inputData,
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'MassCustomized_PreCheckResultPopup',
            options: '{}',
        };

        this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                let localHeaderArray = [];
                for (let k = 0; k < this.productsArray.length; k++) {
                    localHeaderArray.push(this.productsArray[k].productName);
                }
                this.selectedSiteArray = response.result.IPResult.FullSiteProductList;

                this.selectedSiteArray.forEach(ele => {
                    ele.Products.forEach(element => {
                        element.Data.forEach((ele2, index) => {
                            ele2['key'] = index;
                        })
                    })
                })

                if (this.selectedSiteArray.length > 0) {
                    this.isModalOpen = true;
                } else {
                    console.log('No data found');
                }
            });

    }

    get calculateNumberOfRows() {
        var rows;
        this.selectedSiteArray.map((ele) => {
            rows = ele.Products.length;
        })
        return rows == 1 ? 'slds-col slds-size_12-of-12' : rows == 2 ? 'slds-col slds-size_6-of-12' : rows == 3 ? 'slds-col slds-size_4-of-12' : 'slds-col slds-size_3-of-12';
    }

    deleteSites(servicepointList) {
        this.processing = true;
        const inputData = {
            'servicepoints': servicepointList,
            'accountId': this.OpportunityList.AccountId,
            'oppId': this.OpportunityList.OpportunityId
        }

        console.log(inputData);
        const params = {
            input: inputData,
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'PreCheck_DeleteSites',
            options: '{}',
        };

        this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                this.processing = false;
                console.log(response);
                this.refreshData();
            })
            .catch(error => {
                this.processing = false;
                console.log(error);
            })
    }
    async deleteSingleFailedSite(event) {
        const currentIndex = event.target.dataset.opp;
        console.log(currentIndex);
        const result = await LightningConfirm.open({
            message: 'Är du säker på att du vill ta bort denna site?',
            variant: 'headerless',
            label: 'this is the aria-label value',
        });
        console.log(result);
        if (result) {
            const servicepointList = [];
            servicepointList.push(this.errorSitesDetails[currentIndex].Id);
            this.deleteSites(servicepointList);
        }

    }

    async deleteAllFailedSites() {
        const result = await LightningConfirm.open({
            message: 'Är du säker på att du vill ta bort denna site?',
            variant: 'headerless',
            label: 'this is the aria-label value',
        });
        console.log(result);
        if (result) {
            const servicepointList = [];
            this.errorSitesDetails.forEach(ele => { servicepointList.push(ele.Id) })
            this.deleteSites(servicepointList, true);
        }
    }

    async deleteSite(event) {
        const currentIndex = event.target.dataset.opp;

        const result = await LightningConfirm.open({
            message: 'Är du säker på att du vill ta bort denna site?',
            variant: 'headerless',
            label: 'this is the aria-label value',
        });

        if (result) {
            this.processing = true;
            const arrayOfSitesToDelete = [];
            arrayOfSitesToDelete.push(this.modifiedData[currentIndex].Id);
            const inputData = {
                'servicepoints': arrayOfSitesToDelete,
                'accountId': this.OpportunityList.AccountId,
                'oppId': this.OpportunityList.OpportunityId
            }

            const params = {
                input: inputData,
                sClassName: `${this._ns}IntegrationProcedureService`,
                sMethodName: 'PreCheck_DeleteSites',
                options: '{}',
            };

            this._actionUtilClass
                .executeAction(params, null, this, null, null)
                .then(response => {
                    this.processing = false;
                    console.log(response);
                    this.recalculatePricing();
                })
                .catch(error => {
                    console.log(error);
                })

            console.log(JSON.parse(JSON.stringify(inputData)));
        }
    }

    closeModal() {
        this.selectedSiteArray = [];
        this.isModalOpen = false;
    }

    recalculatePricing() {
        this.processing = true;
        const inputData = {
            'OpportunityId': this.OpportunityList.OpportunityId,
            'AccountId': this.OpportunityList.AccountId
        }

        console.log(inputData);
        const params = {
            input: inputData,
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'Recalculate_ListPriceandAverage',
            options: '{}',
        };

        this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                this.processing = false;
                console.log(response);
                this.refreshData();
            })
            .catch(error => {
                this.processing = false;
                console.log(error);
            })
    }

    refreshData() {
        this.progressBarValue = ((this.items_processed + this.failedItems) / this.total) * 100;
        this.processing = true;
        this.dataReceived = false;

        if (this.selectedProducts.length >= 1) {
            this.headers = [];
            var i = 0;
            this.selectedProducts.forEach(element => {
                const index = this.products.findIndex(ele => ele.Label === element);

                this.headers[i] = {
                    'productName': element,
                    'productCode': this.products[index].ProductCode, //element.ProductCode,
                    'bandwidth1': this.selectedBandwidth1,
                    'bandwidth2': this.selectedBandwidth2,
                    'b1': this.selectedBandwidth1 + ' Mbit/s', //string to display inside the table
                    'b2': this.selectedBandwidth2 + ' Mbit/s'
                };
                i++;
            });
        } else {
            console.error('No products selected');
        }

        const inputData = {
            'headers': this.headers,
            'selectedBandwidth1': this.selectedBandwidth1 * 1000,
            'selectedBandwidth2': this.selectedBandwidth2 * 1000,
            'OpportunityList': this.OpportunityList
        }

        console.log('input-->', JSON.stringify(inputData));

        const params = {
            input: inputData,
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'PreCheck_view',
            options: '{}',
        };

        this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                console.log(response);
                this.processing = false;
                this.modifiedData = response.result.IPResult.finalmap;
                this.fullSiteListProducts = response.result.IPResult.FullSiteProductList;
                this.averagePrices = response.result.IPResult.averagePrices;
                this.precheckDate = response.result.IPResult.PrecheckDate;
                this.items_displayed = response.result.IPResult.ServicePointsProcessed;
                this.items_processed = response.result.IPResult.ServicePointsProcessed;
                this.failedItems = response.result.IPResult.PrecheckNotProcessed;
                this.total = response.result.IPResult.TotalServicePoints;
                this.isPrecheckNotProcessed = response.result.IPResult.isPrecheckNotProcessed;

                if (this.total == this.items_processed + this.failedItems) {
                    this.dataReceived = true;
                    this.items_processed = 0;
                    clearInterval(this.myInterval);

                    this.errorSitesDetails = [];
                    if (this.modifiedData.length > 0) {
                        this.modifiedData.forEach((ele) => {

                            ele.SiteAddress.City = ele.SiteAddress.City.toUpperCase();
                            ele.SiteAddress.StreetAddress = ele.SiteAddress.StreetAddress.toUpperCase();

                            if (ele.PrecheckProcessed == false) {
                                this.errorSitesDetails.push(ele);
                            }

                            ele.Products.forEach(e => {
                                e.Data.forEach(element => {
                                    if (element.info.SLAAvailability == null) {
                                        element.info['SlaAvailable'] = false;
                                    } else {
                                        element.info['SlaAvailable'] = true;

                                        if (element.info.SLAAvailability == 'Available') {
                                            element.info['AvailableC4'] = true;
                                        } else if (element.info.SLAAvailability == 'Not Available') {
                                            element.info['AvailableC4'] = false;
                                        }
                                    }
                                })
                            })
                        })
                    }

                } else {
                    this.dataReceived = false;
                    this.progressBarValue = ((this.items_processed + this.failedItems) / this.total) * 100;
                    this.myInterval = setTimeout((() => {
                        this.refreshData();
                    }).bind(this), 20000);
                }

                var length = this.headers.length * 2;
                this.averagePricesArray = [];
                if (this.averagePrices !== '') {
                    for (var i = 0; i < this.headers.length; i++) {
                        var avg1 = this.headers[i].productName + 'price1';
                        var avg2 = this.headers[i].productName + 'price2';

                        if (this.averagePricesArray.length < length) {
                            if (this.averagePrices[avg1] !== undefined) {
                                this.averagePricesArray.push(this.averagePrices[avg1] + ' SEK');
                            } else {
                                this.averagePricesArray.push('');
                            }
                            if (this.averagePrices[avg2] !== undefined) {
                                this.averagePricesArray.push(this.averagePrices[avg2] + ' SEK');
                            } else {
                                this.averagePricesArray.push('');
                            }
                        }
                    }
                } else {
                    for (var i = 0; i < this.headers.length * 2; i++) {
                        this.averagePricesArray.push('');
                    }
                }

                this.averagePricesArray = JSON.parse(JSON.stringify(this.averagePricesArray));
            })
            .catch(error => {
                window.console.log(error);
                console.log('Precheck failed');
            });

    }


    updateOmniJson(_headers, b1, b2) {
        if (this.omniJsonData) {
            this.headers = _headers;
            let updateJson = JSON.parse(JSON.stringify(this.omniJsonData));
            updateJson.headers = _headers;
            updateJson.selectedBandwidth1 = Number(b1) * 1000;
            updateJson.selectedBandwidth2 = Number(b2) * 1000;
            this.omniApplyCallResp(updateJson);
            return true;
        } else {
            return false;
        }
    }


    downloadExcelFile() {

        const params = {
            input: { 'AccountId': this.OpportunityList.AccountId, 'OppId': this.OpportunityList.OpportunityId, 'productFamily': this.productFamily },
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'DownloadExcel_PrecheckResults',
            options: { 'chainable': true, 'queueableChainable': true },
        };

        console.log('AccountId------', this.OpportunityList.AccountId, 'OppId--------', this.OpportunityList.OpportunityId)
        console.log('productFamily', this.productFamily);
        this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                const excelString = response.result.IPResult.RAForExcelDownload.downloadLink;
                if (excelString !== null) {
                    window.open(excelString);
                }
            });
    }
    previousStep() {
        this.omniPrevStep();
    }
    nextStep() {
        if (this.errorSitesDetails.length > 0) {
            this.showErrorToast();
        } else {
            this.omniNextStep();
        }
    }

    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'Error:',
            message: 'Ta bort felaktiga adresser innan du går vidare',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}