import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class TeliaSE_OS_HardwareProductList extends OmniscriptBaseMixin(LightningElement) {
    @track brands = [];
    @track products = [];
    @track value = '';
    @track radioOptions = [];
    @track filteredArray = [];
    @track selectedProductsList = [];
    @track selectedProductsCount = 0;
    @track productsCopy = [];
    @track updateOmniJsonData = {};
    get options() {
        return this.radioOptions;
    }

    @api
    get listOfProducts() {
        return this.products;
    }
    set listOfProducts(value) {
        if (value === undefined) {
            this.products = false;
        } else {
            this.products = value;
        }
    }

    @api
    get listOfBrands() {
        return this.brands;
    }
    set listOfBrands(value) {
        if (value === undefined) {
            this.brands = false;
        } else {
            this.brands = value;
        }
    }

    connectedCallback() {
        this.products = JSON.parse(JSON.stringify(this.products));
        this.brands = JSON.parse(JSON.stringify(this.brands));
        if (Array.isArray(this.products) && this.products.length > 0 && Array.isArray(this.brands) && this.brands.length > 0) {
            this.radioOptions.push({'label': 'All', 'value': ''});
            this.brands.forEach(ele => {
                this.radioOptions.push({
                    'label': ele.Brand, 'value' : ele.Brand
                })
            });
            // this.brands.push({'label':'All', value: 'All'});
            this.productsCopy = JSON.parse(JSON.stringify(this.products));
            this.productsCopy.forEach(ele => {
                ele.checked = false;
            });
            this.filteredArray = this.productsCopy.filter(ele => ele.Name !== null &&  (ele.Name).includes(this.value));
                        
        } else {
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Unable to fetch the data, please contact your administrator',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }
    }

    renderedCallback() {
        if (this.omniJsonData.NumberOfSelectedProducts > 0) {
            this.selectedProductsCount = JSON.parse(JSON.stringify(this.omniJsonData.NumberOfSelectedProducts));
            this.selectedProductsList = JSON.parse(JSON.stringify(this.omniJsonData.SelectedHardwareProductList));
            const boxes = this.template.querySelectorAll('lightning-input');
            boxes.forEach(element => {
                if (this.selectedProductsList.findIndex(ele => ele.ProductId === element.name) !== -1) {
                    element.checked = true;
                } else {
                    element.checked = false;
                }
            });
        }
    }

    handleChange(event){
        this.value = event.target.value;
        this.filteredArray = [...this.productsCopy];
        this.filteredArray = this.productsCopy.filter(ele => ele.Name !== null && (ele.Name).includes(this.value));
    }

    handleCheckBox(event){
        var index = this.productsCopy.findIndex(ele => ele.ProductId === event.target.name);
        this.productsCopy[index].checked = event.detail.checked;

        if(event.detail.checked){
            // var index = this.productsCopy.findIndex(ele => ele.ProductId === event.target.name);
            this.selectedProductsList.push(this.productsCopy[index]);
            this.selectedProductsCount++;
        } else {
            var index = this.selectedProductsList.findIndex(ele => ele.ProductId === event.target.name);
            this.selectedProductsList.splice(index, 1);
            this.selectedProductsCount--;
        }
    }

    nextStep() {
        if (this.selectedProductsCount === 0) {
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Inga produkter har valts, välj minst en mobiltelefon för att fortsätta',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } else if (this.omniJsonData) {
           // let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
            this.updateOmniJsonData['SelectedHardwareProductList'] = this.selectedProductsList;
            this.updateOmniJsonData['NumberOfSelectedProducts'] = this.selectedProductsCount;
            this.omniApplyCallResp(this.updateOmniJsonData); //updating OS data JSON
            this.omniNextStep();
        }
    }

    previousStep() {
        this.omniPrevStep();
    }
}