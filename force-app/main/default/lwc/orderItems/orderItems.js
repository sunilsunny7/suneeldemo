import { LightningElement, track, api,wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getOrderItems from "@salesforce/apex/OrderItemController.getOrderItems";

export default class OrderItems extends NavigationMixin(LightningElement) {

    @track state = {}
    @api numberOfRecords = 0;
    @api orderId
    @api orderProducts=[];
    @api itemsExists=false
    @api fields='Product2.Name,Product2.ProductCode,Quantity,UnitPrice';
    @api  columns = [
        { label: 'Product', fieldName: 'ProductName' },
        { label: 'Product Code', fieldName: 'ProductCode' },
        { label: 'Quantity', fieldName: 'Quantity' },
        { label: 'Unit Price', fieldName: 'UnitPrice'},
    ];

    @api
    get recordId() {
        return this.orderId;
    }

    set recordId(value) {
        this.orderId = value;
    }

    @wire(getOrderItems,{orderId:'$recordId'})
    orderItemsData(result){
        if(result.data)
        {
                this.orderProducts=result.data
                this.itemsExists=this.orderProducts.length>0?true:false
                this.numberOfRecords=this.orderProducts.length;
        }
    }




    
    get hasRecords() {
        return this.state.records != null && this.state.records.length;
    }

   

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (this.rowActionHandler) {
            this.rowActionHandler.call()
        } else {
            switch (actionName) {
                case "delete":
                    this.handleDeleteRecord(row);
                    break;
                case "edit":
                    this.handleEditRecord(row);
                    break;
                default:
            }
        }
    }

    handleGotoRelatedList() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordRelationshipPage",
            attributes: {
                recordId: this.recordId,
                relationshipApiName: this.state.parentRelationshipApiName,
                actionName: "view",
                objectApiName: this.sobjectApiName
            }
        });
    }

    handleRefreshData() {
        //this.init();
    }


    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (this.rowActionHandler) {
            this.rowActionHandler.call()
        } else {
            switch (actionName) {
                case "delete":
                    this.handleDeleteRecord(row);
                    break;
                case "edit":
                    this.handleEditRecord(row);
                    break;
                default:
            }
        }
    }
    getSelectedItem(event)
    {
        console.log(event.detail)
    }
    handleGotoRelatedList() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordRelationshipPage",
            attributes: {
                recordId: this.recordId,
                relationshipApiName: "OrderItems",
                actionName: "view",
                objectApiName: "Order"
            }
        });
    }
}