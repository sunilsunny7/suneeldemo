/**
 * Created by kwn687 on 2022-06-29.
 */
import {
    LightningElement,
    api
} from 'lwc';

export default class SelectedCygateProducts extends LightningElement {
    @api selectedProducts = [];
    @api mainProductsLabel;
    @api cygateProductsLabel;
    handleClick(event) {
        const removeMainProduct = new CustomEvent("mainproductremove", {
            detail: event.target.value
        });
        this.dispatchEvent(removeMainProduct);
    }
}