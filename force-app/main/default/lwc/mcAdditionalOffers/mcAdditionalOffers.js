import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';

    export default class mcAdditionalOffers extends OmniscriptBaseMixin(LightningElement) {
      @track products = [];
    @track productscopy = [];
    @track CLIParent = [];
    @track cartProducts = [];
    @track filteredArray = [];
    selectAllOrUnselect = false;

    connectedCallback() {
        if (this.omniJsonData.CLIParent != undefined) {
            this.CLIParent = JSON.parse(JSON.stringify(this.omniJsonData.CLIParent));
        }        
        if (this.omniJsonData.productList != undefined) {
            this.products = JSON.parse(JSON.stringify(this.omniJsonData.productList));
        }        

        this.CLIParent.forEach((item, index) => {
            if (item.ObjectType === "Mobile Offer Specification") {
                item.ProductName = "Jobbmobil";
            }
            else if (item.ObjectType === "ICT Offer Specification") {
                item.ProductName = "Slutanvändarsupport";
            }
        }
        );
        this.products.forEach((item, index) => {
            if (this.CLIParent.some(ele => ele.ProductName === item)) {
                this.cartProducts.push({ Name: item.toString() });
            }            
            else {
                this.productscopy.push({ Name: item.toString() });
            }

        });
    }

    nextStep() {
        this.filteredArray = [];
        let elements = this.template.querySelectorAll(".productCheckbox");
        elements.forEach(ele => {
            if (ele.checked === true) {
                ele.checked = true;
                this.cartProducts.push({ Name: ele.name });
            }
        });
        // console.log(this.cartProducts);
        let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
        this.filteredArray = Array.from(new Set(this.cartProducts));
        updateOmniJsonData.Offer = JSON.parse(JSON.stringify(this.filteredArray));
        this.omniApplyCallResp(updateOmniJsonData);
        this.omniNextStep();
    }

    handleCheckBox(event) {


        let elements = this.template.querySelectorAll(".productCheckbox");
        elements.forEach(ele => {
            if (event.target.checked === true) {
                ele.checked = true;
            } else if (event.target.checked === false) {
                ele.checked = false;
            }
        });


    }

    
    }