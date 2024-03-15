import { LightningElement, api, track } from 'lwc';

export default class GuidedSellingInfo extends LightningElement {

    @track images = [];
    @track imgObject = {};
    @api handleData(data){
        this.images = data;
        // console.log('Inside child js--', JSON.stringify(this.images));

        if (this.images !== null && Array.isArray(this.images)) {
            for (var i = 0; i < this.images.length; i++) {
                this.imgObject[this.images[i].name] = this.images[i].url;
            }
        }

        // console.log(this.imgObject)
    }
}