import { LightningElement,track } from 'lwc';
    import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
    export default class mc_ClearQuantities extends OmniscriptBaseMixin(LightningElement) {
      @track jsonData;
      @track selectedOfferings = [];
      connectedCallback() {
        if (this.omniJsonData.AddQuantityForSelectedOfferings) {
          this.jsonData = JSON.parse(JSON.stringify(this.omniJsonData.AddQuantityForSelectedOfferings));
          console.log(this.jsonData);
        }
      }
      clearOfferQty()
      {
        this.selectedOfferings = this.jsonData.Flexcard_CaptureQuantity;
        console.log('Flexcard_CaptureQuantity--',this.selectedOfferings);
        if (this.selectedOfferings.length > 0) {
          this.selectedOfferings.forEach((item) => {
            console.log('item-qty',item.name,item.offerQty);
          });
      }      
    }
  }