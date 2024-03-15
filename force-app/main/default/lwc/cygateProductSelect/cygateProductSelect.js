import { LightningElement, api, track, wire} from "lwc";
import cygateInfrastruktur from '@salesforce/label/c.Cygate_Infrastruktur';
import CygateOvrigt from '@salesforce/label/c.Cygate_vrigt';
import cygateInfrastrukturValues from '@salesforce/label/c.Cygate_Infrastruktur_Values';
import CygateOvrigtValues from '@salesforce/label/c.Cygate_vrigt_Values';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

export default class CygateProductSelect extends LightningElement {
    @api mainProductsValues;
    @api cygateProductsValues;
    @api mainProductsLabel;
    @api cygateProductsLabel;
    @api mainProducts;
    @api allCygateProducts = [];
    @api selectedProducts = [];
    @api allCygateProductsEdit = [];
    @track mainProductsValue;
    @track objectInfo;


    @wire(getObjectInfo, { objectApiName: 'Opportunity' })
         objectInfo;
    handleMainProduct(event) {
        if (event.detail.value === cygateInfrastruktur) {
            var allcygateInfrastrukturValues = cygateInfrastrukturValues.split(',');
            for(var i = 0; i < allcygateInfrastrukturValues.length; i++ ){
                if(i === 0){
                    this.allCygateProductsEdit = [{label: allcygateInfrastrukturValues[i],value: allcygateInfrastrukturValues[i]}];
                }
                else{
                    this.allCygateProductsEdit.push({ label: allcygateInfrastrukturValues[i], value: allcygateInfrastrukturValues[i] });
                    }
            }
        } else if (event.detail.value === CygateOvrigt) {
            var allCygateOvrigtValues = CygateOvrigtValues.split(',');
            for(var i = 0; i < allCygateOvrigtValues.length; i++ ){
                if(i === 0){
                    this.allCygateProductsEdit = [{label: allCygateOvrigtValues[i],value: allCygateOvrigtValues[i]}];
                }
                else{
                    this.allCygateProductsEdit.push({ label: allCygateOvrigtValues[i], value: allCygateOvrigtValues[i] });
                    }
            }
        } else {
            this.allCygateProductsEdit = this.allCygateProducts;
        }
        if (this.selectedProducts) {
            var notFound = true;

            for (let i = 0; i < this.selectedProducts.length; i++) {
                if (this.selectedProducts[i].key === event.detail.value || (event.detail.value === cygateInfrastruktur && this.selectedProducts[i].key === "Cygate Infra-gruppen") ) {
                    this.cygateProductsValues = this.selectedProducts[i].name;
                    notFound = false;
                    break;
                }

            }
            if (notFound) {
                this.cygateProductsValues = [];
            }
        }
        this.mainProductsValue = event.target.options.find(mainProducts => mainProducts.value === event.detail.value).value;
        this.mainProductsValues = event.target.options.find(mainProducts => mainProducts.value === event.detail.value).label;
        const mainProductSelect = new CustomEvent("mainproductchange", {
            detail: this.mainProductsValues
        });
        this.dispatchEvent(mainProductSelect);

    }
    handleCygateProduct(event) {
        this.cygateProductsValues = event.detail.value;
        const cygateProductSelect = new CustomEvent("cygateproductchange", {
            detail: this.cygateProductsValues
        });
        this.dispatchEvent(cygateProductSelect);
    }
}