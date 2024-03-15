import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class mc_RootQuantityCapture extends OmniscriptBaseMixin(LightningElement) {

  @track rootProducts = [];
  @track products = [];
  @track selectedArray = [];
  @track checkedOffersList = [];
  className;
  checkedForReng;
  isDisabled;
  connectedCallback() {
    if (this.omniJsonData != undefined) {
      this.products = JSON.parse(JSON.stringify(this.omniJsonData.QLI));
      if (this.products.length > 0) {
        this.products.forEach((item) => {
          //if ((item.salesFlowIdentifier == 'Omforhandling' || item.salesFlowIdentifier == 'Inforhandling' || item.salesFlowIdentifier == 'Tilläggsförhandling') && (item.lineStatus == 'Added' || item.lineStatus == 'Updated')) {
            if ((item.salesFlowIdentifier != 'New Sales' ) && (item.lineStatus == 'Added' || item.lineStatus == 'Updated')) 
            {
            this.className = "slds-text-color_success productCheckbox";
            this.checkedForReng = true;
            this.isDisabled = false;
          }          
          else {
            this.className = "slds-text-color_default productCheckbox";
            this.checkedForReng = false;
            this.isDisabled = false;
          }
          if (item.salesFlowIdentifier == 'Tilläggsförhandling' && item.lineStatus == 'Existing' ) {
            this.isDisabled = true;
          }
          if (item.parentItemId == undefined) {
            this.rootProducts.push({
              Name: item.productName.toString(),
              Id: item.id.toString(),
              className: this.className,
              checkedForReng: this.checkedForReng,
              isDisabled: this.isDisabled
            });
          }
        });
      }     
      else{
        console.log('No Data found');
      }
      //sorting      
        this.rootProducts.sort(function compare(a, b){
          if (a.checkedForReng < b.checkedForReng) {return 1;}
          if (a.checkedForReng > b.checkedForReng) {return -1;}
          return 0;
        });
    }
    else {
      console.log('No Data found');
    }
  }
  renderedCallback() {
    if (this.omniJsonData.SelectedOffers != undefined ) {
      let checkedOffers = JSON.parse(JSON.stringify(this.omniJsonData.SelectedOffers.Id));
        this.checkedOffersList = checkedOffers.split(",");
        const boxes = this.template.querySelectorAll(".productCheckbox");
        boxes.forEach(element => {          
            if (this.checkedOffersList.findIndex(ele => ele === element.name) !== -1) {
                element.checked = true;
            } else {
                element.checked = false;
            }
        });
    }    
}
  nextStep() {
    this.selectedArray = [];
    let elements = this.template.querySelectorAll(".productCheckbox");
    elements.forEach(ele => {
      if (ele.checked === true) {
        ele.checked = true;
        this.selectedArray.push(ele.name);
      }
    });
    if (this.products.length > 0) {
      if (this.selectedArray.length > 0) {
        var selectedoffers = { Id: this.selectedArray.toString() }
        let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
        updateOmniJsonData.SelectedOffers = JSON.parse(JSON.stringify(selectedoffers));
        this.omniApplyCallResp(updateOmniJsonData);
        this.omniNextStep();
      }
      else {
        this.showErrorToast();
      }
    }
    else {
      console.log('No Data found'); 
    }
  }
  changeSelectAll(event) {
    var uncheckProduct = this.template.querySelector('[data-id="SelectAll"]');
    if (uncheckProduct.checked == true) {
      uncheckProduct.checked = event.target.unchecked;
    }
  }
  handleCheckBox(event) {
    let elements = this.template.querySelectorAll(".productCheckbox");
    
    elements.forEach(ele => {
      if (event.target.checked === true && ele.disabled === false) {        
        ele.checked = true;        
      } else if (event.target.checked === false && ele.disabled === false) {
        ele.checked = false;
      }
    });
  }
  showErrorToast() {
    const evt = new ShowToastEvent({
      message: 'Välj minst ett erbjudande för att kunna komma vidare',
      variant: 'error',
      mode: 'dismissable'
    });
    this.dispatchEvent(evt);
  }

}