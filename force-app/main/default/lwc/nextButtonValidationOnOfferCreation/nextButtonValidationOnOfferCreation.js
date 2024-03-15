import { LightningElement, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class nextButtonValidationOnOfferCreation extends OmniscriptBaseMixin(LightningElement) {

  @track maxQuantityError = false;
  @track faQuantities = [];

  connectedCallback() {
    let getOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));

    console.log(getOmniJsonData.QLIResponse);

    if (getOmniJsonData.QLIResponse.length > 0) {
      let data = getOmniJsonData.QLIResponse;

      data.forEach(level1 => {
        if (level1.hideInputs == false) {
          this.faQuantities.push(level1.faQty);
        }

        if (level1.childItem != undefined) {
          level1.childItem.forEach(level2 => {
            if (level2.hideInputs == false) {
              this.faQuantities.push(level2.faQty);
            }


            if (level2.childItem != undefined) {
              level2.childItem.forEach(level3 => {
                if (level3.hideInputs == false) {
                  this.faQuantities.push(level3.faQty);
                }

                if (level3.childItem != undefined) {
                  level3.childItem.forEach(level4 => {
                    if (level4.hideInputs == false) {
                      this.faQuantities.push(level4.faQty);
                    }
                  })
                }
              });
            }
          })
        }
      });

      console.log(this.faQuantities);
    }
  }

  nextStep() {
    let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));

    if (Object.keys(updateOmniJsonData.AddQuantityForSelectedOfferings).length > 0 || updateOmniJsonData.AddQuantityForSelectedOfferings != undefined) {
      this.quantityChangeArray = updateOmniJsonData.AddQuantityForSelectedOfferings.Flexcard_CaptureQuantity

      if (typeof (this.quantityChangeArray) == 'object') {
        for (const [key, value] of Object.entries(this.quantityChangeArray)) {
          if (Number(value.record.faQty) > value.record.maxQuantity) {
            this.maxQuantityError = true;
          }
        }

        if (this.maxQuantityError) {
          const evt = new ShowToastEvent({
            title: 'Error Occured',
            message: 'Kontrollera fältet offertkvantitet och korrigera till rätt antal innan du går vidare.',
            variant: 'error'
          });
          this.dispatchEvent(evt);
        } else {
          console.log('Quantity check cleared');
          this.omniNextStep();
        }
      } else {
        this.omniNextStep();
      }
    } else {
      this.omniNextStep();
    }


  }

  previousStep() {
    this.omniPrevStep();
  }

}