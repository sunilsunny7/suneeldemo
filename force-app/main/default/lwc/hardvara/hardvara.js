import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
export default class hardvara extends OmniscriptBaseMixin(LightningElement) {

@api parentvalue;
@track theRecord = {};
get options() {
        return [
            { label: 'Ja', value: 'Ja' },
            { label: 'Nej', value: 'Nej' },
        ];
    }
    
handleChange(event) {
        this.theRecord[event.target.name] = event.target.value;
        this.dispatchEvent(new CustomEvent
            ('produktertabevent', { detail: this.theRecord})
        );
    }
    connectedCallback() {
        this.theRecord['Utbyte'] = this.parentvalue.switchReplacement;
        this.theRecord['AntalMC'] = this.parentvalue.isHelaPaketetQuantity;
        this.theRecord['AntalBredbandsswitch'] = this.parentvalue.isBredbandsswitchQuantity;
        this.theRecord['AntalRouter'] = this.parentvalue.isRouterQuantity;
        this.theRecord['AntalTv-boxar'] = this.parentvalue.isTvBoxQuantity;
        this.theRecord['AntalTradlos'] = this.parentvalue.isWirelessTvQuantity;
        


        this.dispatchEvent(new CustomEvent
            ('produktertabevent', { detail: this.theRecord })
        );
    }

}