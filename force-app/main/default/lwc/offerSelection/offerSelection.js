import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class offerSelection extends OmniscriptBaseMixin(LightningElement) {
  @track rootProducts = [];
  @track products = [];
  @track selectedArray = [];
  

  connectedCallback() {
    if (this.omniJsonData != undefined) {
      console.log(JSON.parse(JSON.stringify(this.omniJsonData.QLI)));
      this.products =JSON.parse(JSON.stringify(this.omniJsonData.QLI));
      this.products.forEach((item) => {
        if (item.parentItemId == undefined) {
          this.rootProducts.push({ Name: item.productName.toString(), Id: item.id.toString() });
        }
      });
      console.log(this.rootProducts);
    }
    else
    {
      console.log('No Data found');
    }
    
    
  }
  nextStep() {
    this.selectedArray = [];
    let elements = this.template.querySelectorAll(".productCheckbox");
    elements.forEach(ele => {
      if (ele.checked === true) {
        ele.checked = true;
        //this.selectedArray.push({ Id: ele.name});
        this.selectedArray.push(ele.name);
      }
    });
    var selectedoffers = {Id : this.selectedArray.toString() }
    console.log(this.selectedArray);
    let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
    updateOmniJsonData.SelectedOffers = JSON.parse(JSON.stringify(selectedoffers));
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