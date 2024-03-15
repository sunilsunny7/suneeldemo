import { LightningElement,track } from 'lwc';
    import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
    //import MC_Product_Catalogue from '@salesforce/label/c.MC_Product';
    export default class productsList extends OmniscriptBaseMixin(LightningElement) {
        @track products1 = [];
        @track products2 = [];
        @track prodlist1 = [];
        @track prodlist2 = [];
      connectedCallback() {
        // Call omniUpdateDataJson to update the omniscript
        // this.omniUpdateDataJson({'key':'value'});
        console.log('OmniJSON Data--'+JSON.parse(JSON.stringify(this.omniJsonData.productList)));
        this.products1=JSON.parse(JSON.stringify(this.omniJsonData.productList));
        this.products2=JSON.stringify(this.omniJsonData.productList);
        this.prodlist1= this.products1.toString();
        this.prodlist2= this.prodlist1.Split(",");
        console.log('products1--'+this.products1);
        console.log('products2--'+this.products2);
        console.log('prodlist1--'+this.prodlist1);
        console.log('prodlist2--'+this.prodlist2);


        
      }
    
    }