import { LightningElement, track , api} from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class TeliaSE_MC_AccessoryList extends OmniscriptBaseMixin(LightningElement) {
    @track brands = [];
    @track radioOptions = [];
    @track accessories = [];
    @track AccessioriesCopy = [];
    @track value = '';
    @track selectedAccessoriesList = [];
    @track selectedAccessoriesCount = 0;
    @track filteredArray = [];
    @track updateOmniJsonData = {};
    get options() {
        return this.radioOptions;
    }

     @api
    get listOfAccessories() {
        return this.accessories;
    }
    set listOfAccessories(value) {
        if (value === undefined) {
            this.accessories = false;
        } else {
            this.accessories = value;
        }
    }

    @api
    get listOfButtons() {
        return this.brands;
    }
    set listOfButtons(value) {
        if (value === undefined) {
            this.brands = false;
        } else {
            this.brands = value;
        }
    }

    connectedCallback() {
        this.accessories = JSON.parse(JSON.stringify(this.accessories));
        this.brands = JSON.parse(JSON.stringify(this.brands));
        if (Array.isArray(this.accessories) && this.accessories.length > 0 && Array.isArray(this.brands) && this.brands.length > 0) {
            // this.brands = this.omniJsonData.AccessoriesButtons;
            this.radioOptions.push({'label': 'All', 'value': ''});
            this.brands.forEach(ele => {
                this.radioOptions.push({
                    'label': ele.Brand, 'value': ele.Brand
                })
            })
            // this.accessories = this.omniJsonData.Accessiories;
            this.AccessioriesCopy = JSON.parse(JSON.stringify(this.accessories));
            this.AccessioriesCopy.forEach(ele => {
                ele.checked = false;
            });

            this.filteredArray = this.AccessioriesCopy.filter(ele => (ele.Name).includes(this.value));
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
        if (this.omniJsonData.NumberOfSelectedAccessories > 0) {
            this.selectedAccessoriesCount = JSON.parse(JSON.stringify(this.omniJsonData.NumberOfSelectedAccessories));
            this.selectedAccessoriesList = JSON.parse(JSON.stringify(this.omniJsonData.AccessoriesList));
            const boxes = this.template.querySelectorAll('lightning-input');
            boxes.forEach(element => {
                if (this.selectedAccessoriesList.findIndex(ele => ele.ProductId === element.name) !== -1) {
                    element.checked = true;
                } else {
                    element.checked = false;
                }
            });
        }
    }

    handleChange(event) {
        this.value = event.target.value;
        this.filteredArray = [...this.AccessioriesCopy];
        this.filteredArray = this.AccessioriesCopy.filter(ele => (ele.Name).includes(this.value));
    }

    handleCheckBox(event) {
        var index = this.AccessioriesCopy.findIndex(ele => ele.ProductId === event.target.name);
        this.AccessioriesCopy[index].checked = event.detail.checked;

        // console.log(this.AccessioriesCopy[index]);

        if (event.detail.checked) {
            var index = this.AccessioriesCopy.findIndex(ele => ele.ProductId === event.target.name);
            this.selectedAccessoriesList.push(this.AccessioriesCopy[index]);
            this.selectedAccessoriesCount++;
        } else {
            var index = this.selectedAccessoriesList.findIndex(ele => ele.ProductId === event.target.name);
            this.selectedAccessoriesList.splice(index, 1);
            this.selectedAccessoriesCount--;
        }
    }

    nextStep() {
        if (this.omniJsonData) {
            //let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
            this.updateOmniJsonData['AccessoriesList'] = this.selectedAccessoriesList;
            this.updateOmniJsonData['NumberOfSelectedAccessories'] = this.selectedAccessoriesCount;
            this.omniApplyCallResp(this.updateOmniJsonData); //updating OS data JSON
            this.omniNextStep();
        }
    }

    previousStep() {
        this.omniPrevStep();
    }
}