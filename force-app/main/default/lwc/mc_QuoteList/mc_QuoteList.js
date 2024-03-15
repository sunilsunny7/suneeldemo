import { LightningElement, wire, api, track } from 'lwc';
import getDetails from '@salesforce/apex/MC_QuoteList.getQuote';

const columns = [
    { label: 'Offertnamn', fieldName: 'Quote_url',type: 'url',typeAttributes: { label: { fieldName: 'Name' },target: '_blank' }} ,
    { label: 'Offertnummer', fieldName: 'QuoteNumber_url',type: 'url',typeAttributes: { label: { fieldName: 'QuoteNumber' },target: '_blank'}} ,
    { label: 'Status', fieldName: 'Status' },
    { label: 'Skapad av', fieldName: 'Createdby_url',type: 'url',typeAttributes: { label: { fieldName: 'CreatedBy_Name' },target: '_blank' }}
];
export default class Mc_QuoteList extends LightningElement {
    @api recordId;
    @track data;
    columns = columns;
    connectedCallback() {       
        getDetails({ oppId: this.recordId }).then(result => {            
            this.data = JSON.parse(JSON.stringify(result));          
            this.data.forEach(element => {               
                element.Quote_url = '/'+element.Id;
                element.QuoteNumber_url = '/'+element.Id; 
                element.Createdby_url = '/'+element.CreatedById; 
                element.CreatedBy_Name = element.CreatedBy.Name;                                                   
            });
        });
        
    }
}