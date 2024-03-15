import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getB2BOrdersFromUOR from '@salesforce/apex/MC_FetchB2BOrders.getRecordsForB2BOrders';
import getAddonsForB2BOrders from '@salesforce/apex/MC_FetchB2BOrders.getAddonsForB2BOrders';
import fetchAddonsApiCall from '@salesforce/apex/MC_FetchB2BOrders.fetchAddonsApiCall';
import excelConvert from '@salesforce/apex/MC_ExportExcelB2BOrders.excelConvert';
import ACCOUNT_ORGNUMBER from '@salesforce/schema/Account.C2B_Org_nr__c';
import ACCOUNT_NAME from '@salesforce/schema/Account.Name';
// import { loadStyle } from 'lightning/platformResourceLoader';
// import CustomDatatableResource from '@salesforce/resourceUrl/CustomDatatable';

const fieldArray = [ACCOUNT_ORGNUMBER, ACCOUNT_NAME];
// import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import McB2BOrderAddonsPopup from "c/mcB2BOrderAddonsPopup";

// all the columns for data table mapped with their field names
const columns = [
    
    {
        label: 'Ordernummer', fieldName: 'MC_Order_Number__c', type: 'string', sortable: true, initialWidth: 250,
        
    },
    {
        label: 'Detaljer', fieldName: 'MC_UOR_Link', type: 'button', sortable: true, initialWidth: 100, 
        typeAttributes: { label: { fieldName: 'MC_UOR_Link' }, disabled: { fieldName: 'disabled' }, variant: 'base' }, 
        cellAttributes: {class: "myButtons",}
    },
    { label: 'Produkt', fieldName: 'MC_Product_Info__c', type: 'string', sortable: true, initialWidth: 300, },
    { label: 'Status', fieldName: 'MC_Order_Status__c', type: 'string', sortable: true, initialWidth: 100, },
    { label: 'Ordertyp', fieldName: 'MC_Order_Type__c', type: 'string', sortable: true, initialWidth: 100, },
    { label: 'Utlovat leveransdatum', fieldName: 'MC_Promised_Date__c', type: 'date', sortable: true, initialWidth: 100, typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric' } },
    { label: 'Önskat leveransdatum', fieldName: 'MC_Requested_Delivery_Date__c', type: 'date', sortable: true, initialWidth: 100, typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric' } },
    { label: 'Faktiskt leveransdatum', fieldName: 'MC_Delivery_Date__c', type: 'date', sortable: true, initialWidth: 100, typeAttributes: { year: 'numeric', month: 'numeric', day: 'numeric' } },
    { label: 'Beställare', fieldName: 'MC_Ordered_By__c', type: 'string', sortable: true, initialWidth: 200, },
    { label: 'Beställare epost', fieldName: 'MC_Orderer_Email__c', type: 'string', sortable: true, initialWidth: 300, },
    { label: 'Källsystem', fieldName: 'MC_Source__c', type: 'string', searchable: true, sortable: true, initialWidth: 200, },
    { label: 'Kanal', fieldName: 'MC_Channel__c', type: 'string', searchable: true, sortable: true, initialWidth: 200, }

];

export default class mcB2BOrderDisplay extends LightningElement {
    defaultSortDirection = 'asc'; sortDirection = 'asc';
    sortedBy;
    numberOfRecords; displayRecords = false;
    columns = columns;
    isCssLoaded = false

    @api uorOrderDisplay;
    @track optionsStatus;
    @api uorOrder;
    @api recordId;
    @track c2borg;
    @track account123;
    @track value1 = 'all';
    @track value2 = 'all';
    @track value3;
    @track value4;
    @track filetersAreClear = false;
    @track filter1 = false;
    @track filter2 = false;
    @track status = '';
    @track orderType = '';
    changeOrderIds;
    processing = true;
    @track addonInformation;

    get options() {
        return [
            { label: 'Alla', value: 'all' },
            { label: 'Pågående', value: 'pågående' },
            { label: 'Avslutad', value: 'avslutad' },
            { label: 'Ofullständig', value: 'ofullständig' },
            { label: 'Levererad', value: 'levererad' },
            { label: 'Mottagen', value: 'mottagen' }
        ];
    }

    get optionsOrderType() {
        return [
            { label: 'Alla', value: 'all' },
            { label: 'Inportering', value: 'inportering' },
            { label: 'Överföring', value: 'överföring' },
            { label: 'Ny', value: 'ny' },
            { label: 'Ändring', value: 'ändring' },
            { label: 'Annullering', value: 'annullering' },
            { label: 'Flytt', value: 'flytt' }
        ];
    }

    get getStatus() {
        return this.value1 != 'all' && this.value1 != null;
    }

    get getOrderType() {
        return this.value2 != 'all' && this.value2 != null;
    }

    renderedCallback(){
        // const a = this.template.querySelector('.slds-button');
        // a.css
    }

    @wire(getRecord, { recordId: '$recordId', fields: fieldArray })
    wiredRecord(response) {
        this.account123 = response;
        if (response.data) {
            this.c2borg = response.data.fields.C2B_Org_nr__c.value;
            this.makeApiCallout(this.recordId, this.c2borg);
        }
    }

    makeApiCallout(recordId, c2bOrg) {
        getB2BOrdersFromUOR({
            accId: recordId, orgNr: c2bOrg
        }).then(result => {
            if (result != null) {
                this.processing = false;
                this.uorOrder = result.uorOrders;
                // console.log(result);
                this.uorOrderDisplay = result.uorOrders;
                this.numberOfRecords = result.numberOfRecords;
                if (result.numberOfRecords > 0) {
                    this.uorOrderDisplay.forEach(ele => {

                        const req_delivery_date = ele.MC_Requested_Delivery_Date__c ? ele.MC_Requested_Delivery_Date__c.split('T')[0] : '';
                        ele.MC_Requested_Delivery_Date__c = req_delivery_date;

                        const promised_delivery_date = ele.MC_Promised_Date__c ? ele.MC_Promised_Date__c.split('T')[0] : '';
                        ele.MC_Promised_Date__c = promised_delivery_date;

                        const mc_delivery_date = ele.MC_Delivery_Date__c ? ele.MC_Delivery_Date__c.split('T')[0] : '';
                        ele.MC_Delivery_Date__c = mc_delivery_date;

                        ele['MC_UOR_OrderId__c'] = ele.MC_UOR_OrderId__c;
                        if (ele.MC_Order_Type__c == 'Ändring') {
                            ele['MC_UOR_Link'] = 'Klicka här';
                            // ele['buttonVariant'] = 'outline-brand';
                            ele['disabled'] = false;
                        } else {
                            // ele['buttonVariant'] = 'base';
                            ele['disabled'] = true;
                        }
                    })
                    this.displayRecords = true;
                }

                if (result.changeOrderIds) {
                    this.changeOrderIds = result.changeOrderIds;
                    // const totalPages = result.changeOrderIds.length;
                    const batchSize = 5;
                    const parts = this.splitArray(this.changeOrderIds, batchSize);

                    let end = parts.length - 1;
                    for (var i = 0; i <= end; i++) {
                        fetchAddonsApiCall({ changeOrders: parts[i], accId: this.recordId, })
                            .then(result => {
                                console.log(result);
                            })
                    }
                }
            }
        })
    }

    splitArray(array, size) {
        let newArray = array;
        let chunkSize = size;
        let chunks = [];

        for (let i = 0; i < newArray.length; i += chunkSize) {
            chunks.push(newArray.slice(i, i + chunkSize));
        }

        return chunks;
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.uorOrderDisplay];
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.uorOrderDisplay = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }

    orderId;
    async handleRowAction(event) {
        const row = event.detail.row;

        this.selectedOrderId = row.MC_UOR_OrderId__c;
        this.orderId = row.MC_Order_Number__c;

        if (row.MC_Order_Type__c == 'Ändring') {
            this.getAddons(this.recordId, this.selectedOrderId, this.orderId);
        } else {
            console.log('This is not a change order type, please select change order type ids only');
            // const evt = new ShowToastEvent({
            //     message: 'Only change order type has addons to display',
            //     variant: 'warning'
            // });
            // this.dispatchEvent(evt);
        }


    }

    getAddons(accountId, uorOrderId, orderId) {
        getAddonsForB2BOrders({ accId: accountId, orderNr: uorOrderId })
            .then(result => {
                // console.log(result);

                this.addonInformation = result;
                this.addonInformation.addons.forEach(ele => {
                    const req_delivery_date_addon = ele.MC_Item_Req_Del_Date__c ? ele.MC_Item_Req_Del_Date__c.split('T')[0] : '';
                    ele.MC_Item_Req_Del_Date__c = req_delivery_date_addon;

                    const promised_delivery_date_addon = ele.MC_Item_Promised_Date__c ? ele.MC_Item_Promised_Date__c.split('T')[0] : '';
                    ele.MC_Item_Promised_Date__c = promised_delivery_date_addon;
                });

                if (result.error == 'Exception') {
                    console.log('Error Occured');
                } else {
                    const result1 = McB2BOrderAddonsPopup.open({

                        size: 'medium',
                        description: 'Accessible description of modal\'s purpose',
                        content: this.addonInformation,
                        orderNumber: orderId,
                        label: '          ',
                    });
                }
            })
            .catch(error => {
                this.errorMsg = error;
            })
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                return primer(x[field]);
            }
            : function (x) {
                return x[field];
            };

        return function (a, b) {
            a = key(a) ? key(a) : ''; //handling empty values
            b = key(b) ? key(b) : ''; //handling empty values
            return reverse * ((a > b) - (b > a));
        };
    }

    handleClick(event) {
        let array = this.uorOrder;
        if (this.value1 != null || this.value2 != null) {
            if (this.value1 != null) {
                array = array.filter((item => {
                    if ((item.MC_Order_Status__c && item.MC_Order_Status__c.toLowerCase().includes(this.value1))) { return item; }
                }))
            }
            if (this.value2 != null) {
                array = array = array.filter((item => {
                    if ((item.MC_Order_Type__c && item.MC_Order_Type__c.toLowerCase().includes(this.value2))) { return item; }
                }))
            }
        }
        this.uorOrderDisplay = array;
    }

    filterTable(searchFilter) {
        this.uorOrderDisplay = this.uorOrder.filter((item) => {
            if ((item.MC_Order_Status__c && item.MC_Order_Status__c.toLowerCase().includes(searchFilter)) ||
                (item.MC_Product_Info__c && item.MC_Product_Info__c.toLowerCase().includes(searchFilter)) ||
                (item.MC_Order_Number__c && item.MC_Order_Number__c.includes(searchFilter)) ||
                (item.MC_Order_Type__c && item.MC_Order_Type__c.toLowerCase().includes(searchFilter))) {
                return item;
            }
        })
    }

    downloadCSVFile() {
        excelConvert({
            accId: this.recordId
        }).then(result => {
            this.excelString = result;
            if (this.excelString != null) {
                window.open(this.excelString);
            }
        }).catch(error => {
            console.error('**** error **** \n ', error)
        });
    }


    handleStatusChange(event) {
        this.value1 = event.detail.value.toLowerCase();
        this.filter1 = true;

        if (this.value1 == 'pågående') {
            this.status = '<b> Pågående  - </b>  Försäljningsordern bearbetas av Telia.';
        } else if (this.value1 == 'ofullständig') {
            this.status = '<b> Ofullständig - </b>  Försäljningsordern inväntar information från kunden.';
        } else if (this.value1 == 'avslutad') {
            this.status = '<b> Avslutad - </b>  Försäljningsordern är levererad och stängd utan ytterligare åtgärder.';
        } else if (this.value1 == 'levererad') {
            this.status = '<b> Levererad - </b> Försäljningsordern har levererats till kunden.';
        } else if (this.value1 == 'mottagen') {
            this.status = '<b> Mottagen - </b>  Försäljningsordern är mottagen av Telia.';
        }
        this.filterOrders();
    }

    handleTypeChange(event) {
        this.value2 = event.detail.value.toLowerCase();
        this.filter2 = true;


        if (this.value2 == 'ny') { this.orderType = '<b> Ny - </b> En ny försäljningsorder är en begäran från en kund till Telia om att leverera ett angivet antal produkter eller tillhandahålla en tjänst vid en viss tidpunkt för t.ex. mobilabonnemang, tilläggstjänster mm.' }
        else if (this.value2 == 'inportering') { this.orderType = '<b> Inportering - </b> En porteringsorder är en begäran från en kund till Telia om att flytta befintliga tjänster från nuvarande operatör till Telia.  ' }
        else if (this.value2 == 'annullering') { this.orderType = '<b> Annullering - </b> En borttagsorder är en begäran från en kund till Telia om att avsluta en angiven aktiv tjänst hos Telia.' }
        else if (this.value2 == 'ändring') { this.orderType = '<b> Ändring - </b> En förändringsorder är en begäran från en kund till Telia om att modifiera befintliga tjänster genom att lägga till / ta bort / eller uppdatera en angiven tjänst.' }
        else if (this.value2 == 'flytt') { this.orderType = '<b> Flytt - </b> En förflyttningsorder är en begäran från en kund till Telia om att flytta befintliga tjänster till en ny plats.' }
        else if (this.value2 == 'överföring') { this.orderType = '<b> Överföring - </b> En överföringsorder är en begäran från en kund till Telia om att överföra ägande av befintliga tjänster från nuvarande kund till en ny kund.' }
        this.filterOrders();
    }

    handleOrderNumberChange(event) {
        this.value3 = event.target.value.toLowerCase();

        // console.log(this.value3);
        this.filterOrders();
    }

    handleProduktChange(event) {
        this.value4 = event.target.value.toLowerCase();
        this.filterOrders();
    }

    filterOrders() {
        let array = this.uorOrder;
        if (this.value1 && this.filter1) {
            if (this.value1 == 'all') {
                this.uorOrderDisplay = array;
                this.filtersAreClear = false;
            } else {
                this.filtersAreClear = true;
                array = array.filter((item => {
                    if ((item.MC_Order_Status__c && item.MC_Order_Status__c.toLowerCase().indexOf(this.value1) > -1)) { return item; }
                }))
            }
        }
        if (this.value2 && this.filter2) {
            if (this.value2 == 'all') {
                this.uorOrderDisplay = array;
                this.filtersAreClear = false;
            } else {
                this.filtersAreClear = true;
                array = array.filter((item => {
                    if ((item.MC_Order_Type__c && item.MC_Order_Type__c.toLowerCase().indexOf(this.value2) > -1)) { return item; }
                }))


            }
        }
        if (this.value3) {
            array = array = array.filter((item => {
                if ((item.MC_Order_Number__c && item.MC_Order_Number__c.toLowerCase().indexOf(this.value3) > -1)) { return item; }
            }))
        }
        if (this.value4 != null) {
            array = array = array.filter((item => {
                if ((item.MC_Product_Info__c && item.MC_Product_Info__c.toLowerCase().indexOf(this.value4) > -1)) { return item; }
            }))
        }

        this.uorOrderDisplay = array;

    }

    clearFilters() {

        if (this.value1 != 'all') {
            this.value1 = 'all';
        }
        if (this.value2 != 'all') {
            this.value2 = 'all';
        }
        this.value3 = '';
        this.value4 = '';

        this.uorOrderDisplay = this.uorOrder;
    }

}