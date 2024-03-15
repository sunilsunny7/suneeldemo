/**
 * Description:
 * Lightning web component implements an Opportunity record action that allows the User
 * to manage Opportunity related Revenue Effect records.
 * Component:
 *  - displays a table of editable Revenue Effect records related to the Opportunity
 *  - displays a table of calcualted Revenue Effect data summaries
 *  - allows to add new Revenue Effect records
 * 
 * Modifications:
 * 26.10.2022 [Tomass Brazovskis] SALEF-7482 - Introduced. Original Lightning component (SALEF-3861) transfer from Aura to LWC.
 * 25.11.2022 [Tomass Brazovskis] SALEF-7482_Mod - Modified. Do not display Sub-Category dependent picklist.
*/
import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getFieldValue } from 'lightning/uiRecordApi';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import { loadStyle } from "lightning/platformResourceLoader";
// Apex Controller Methods
import saveRevenueImpact from '@salesforce/apex/RevenueImpactCalculationController.saveRevenueImpact';
import deleteRecord from '@salesforce/apex/RevenueImpactCalculationController.deleteRecord';
import getRevenueEffectDetails from '@salesforce/apex/RevenueImpactCalculationController.getRevenueEffectDetails';
import updateRi from '@salesforce/apex/RevenueImpactCalculationController.updateRi';
import { refreshApex } from '@salesforce/apex';
// Static Resources
//import modal from "@salesforce/resourceUrl/revenueEffectActionCustomModal";
// Utility Component Methods
import { reduceErrors } from 'c/ldsUtils';
// Revenue Effect Schema
import REVENUE_EFFECT_OBJECT from '@salesforce/schema/Revenue_Effect__c';
import REVENUE_EFFECT_ID from '@salesforce/schema/Revenue_Effect__c.Id';
import CATEGORY_FIELD from '@salesforce/schema/Revenue_Effect__c.Category__c';
import SUB_CATEGORY_FIELD from '@salesforce/schema/Revenue_Effect__c.Sub_Category__c';
import OLD_ANTAL from '@salesforce/schema/Revenue_Effect__c.Old_Antal__c';
import OLD_MONTHLY_COST from '@salesforce/schema/Revenue_Effect__c.Old_Monthly_Cost__c';
import OLD_PRODUCT_NAME from '@salesforce/schema/Revenue_Effect__c.Old_Product_Name__c';
import OLD_TOTAL_REVENUE_12_MONTHS from '@salesforce/schema/Revenue_Effect__c.Old_Total_Revenue_12_Months__c';
import NEW_ANTAL from '@salesforce/schema/Revenue_Effect__c.New_Antal__c';
import NEW_MONTHLY_COST from '@salesforce/schema/Revenue_Effect__c.New_Monthly_Cost__c';
import NEW_PRODUCT_NAME from '@salesforce/schema/Revenue_Effect__c.New_Product_Name__c';
import NEW_TOTAL_REVENUE_12_MONTHS from '@salesforce/schema/Revenue_Effect__c.New_Total_Revenue_12_Months__c';
import COMMENTS from '@salesforce/schema/Revenue_Effect__c.Comments__c';
import OPPORTUNITY from '@salesforce/schema/Revenue_Effect__c.Opportunity__c';
// Custom labels
import HEADER_LABEL from '@salesforce/label/c.revenueEffectLWCHeaderLabel';
import SUMMARY_HEADER_LABEL from '@salesforce/label/c.revenueEffectLWCSummaryHeaderLabel';
import DELETE_LABEL from '@salesforce/label/c.TeliaSE_DeleteLabel';
import SAVE_LABEL from '@salesforce/label/c.TeliaSE_SaveLabel';
import NEW_TOTAL_REVENUE_EFFECT_LABEL from '@salesforce/label/c.revenueEffectLWCNewRETotalLabel';
import OLD_TOTAL_REVENUE_EFFECT_LABEL from '@salesforce/label/c.revenueEffectLWCOldRETotalLabel';
import OPPORTUNTIY_REVENUE_EFFECT_LABEL from '@salesforce/label/c.revenueEffectLWCSummaryRELabel';
import OPPORTUNTIY_REVENUE_EFFECT_PERCENT_LABEL from '@salesforce/label/c.revenueEffectLWCSummaryREPercentageLabel';
// Constants
const lstRevenueEffectFieldsToRetrieve = [  REVENUE_EFFECT_ID, CATEGORY_FIELD, SUB_CATEGORY_FIELD, 
                                            OLD_ANTAL, OLD_MONTHLY_COST, OLD_PRODUCT_NAME, OLD_TOTAL_REVENUE_12_MONTHS,
                                            NEW_ANTAL, NEW_MONTHLY_COST, NEW_PRODUCT_NAME, NEW_TOTAL_REVENUE_12_MONTHS,
                                            COMMENTS, OPPORTUNITY];
const objDatatableCurrencyAttributes = { currencyCode: 'SEK', step: '0.01' };
const HEADER_LABLE_NEW_REVENUE_EFFECT_TABLE_ROW_NO = 'S.No';
const KEY_FIELD_API_NAME = 'fieldApiName';

export default class RevenueImpactComponent extends LightningElement {

    // Opportunity Id
    @api recordId;
    // Revenue Effect object information
    @track _objRevenueEffectObjInfo;
    @track _objRecTypeIdsToRecTypeInfos;
    // Wire-provisioned value ({data, error}) to be passed to refreshApex()
    // to trigger RevenueEffectDetail Wrapper retrieval
    _wiredRevenueEffectDetails;
    // Objects to store Opportunity related Revenue Effect details returned from server
    @track _objOppRelatedRevenueEffectDetails;
    @track _objRevenueEffectSummaryCalculations;
    // Opportunity related Revenue Effect datatable parameters
    @track _lstOpportunityRelatedRETableCols;
    @track _lstOpportunityRelatedRERecords;
    lstEditedRevenueEffectDraftValues;
    // Opportunity related Revenue Effect Summary datatable parameters
    @track _lstRevenueEffectSummaryTableCols;
    _lstRevenueEffectSummaryTableData;
    lstRevenueEffectSummaryTableDataDisplay;
    // New Revenue Effect records to be inserted
    @track _lstRevenueEffectNewRecordTableHeaders = [];
    @track _lstRevenueEffectsToInsert = [];
    // Error Msg
    error;
    // Variables contolling the modal view
    showWholeCmpSpinner = true;
    showRelatedRecordsSpinner = false;
    _renderNewRevenueEffectTable = false;
    _renderRelatedRevenueEffectTable = false;
    // Component Title
    componentTitle = HEADER_LABEL;
    // Opportunity related Revenue Effect Summary datatable Title
    revenueEffectSummaryTitle = SUMMARY_HEADER_LABEL;
    //New Revenue Effect records Save Button Label
    saveButtonLabel = SAVE_LABEL;
    // Id generator
    _newRevenueEffectCounter = 0;


    // Getters
    get objRevenueEffectSummaryCalculations(){
        return this._objRevenueEffectSummaryCalculations;
    }
    get lstOpportunityRelatedRETableCols() {
        return this._lstOpportunityRelatedRETableCols;
    }
    get lstOpportunityRelatedRERecords() {
        return this._lstOpportunityRelatedRERecords;
    }
    get lstRevenueEffectSummaryTableCols(){
        return this._lstRevenueEffectSummaryTableCols;
    }
    get lstRevenueEffectSummaryTableData(){
        return this._lstRevenueEffectSummaryTableData;
    }
    set lstRevenueEffectSummaryTableData(lstRevenueEffectSummaryTableRecords){
        this._lstRevenueEffectSummaryTableData = lstRevenueEffectSummaryTableRecords;
        this.lstRevenueEffectSummaryTableDataDisplay = this.convertSummaryDataIntoDataTableFormat(this._lstRevenueEffectSummaryTableData);
    }
    get lstRevenueEffectNewRecordTableHeaders(){
        return this._lstRevenueEffectNewRecordTableHeaders;
    }
    get lstRevenueEffectsToInsert(){
        return this._lstRevenueEffectsToInsert;
    }
    // is Opportunity related Revenue Effects Datatable ready to be displayed
    get oppRelatedREColsAndRecsRetrieved(){
        return (this._lstOpportunityRelatedRETableCols && this._lstOpportunityRelatedRERecords);
    }
    // dynamicRowItemLWC (child) component parameters 
    get categoryField(){
        return CATEGORY_FIELD;
    }
    get subCategoryField(){
        return SUB_CATEGORY_FIELD;
    }
    get revenueEffectObjName(){
        return REVENUE_EFFECT_OBJECT;
    }
    get revenueEffectDefaultRecTypeId() {
        // Returns a map of record type Ids
        if(this._objRecTypeIdsToRecTypeInfos !== undefined){
            return Object.keys(this._objRecTypeIdsToRecTypeInfos).find(rti => this._objRecTypeIdsToRecTypeInfos[rti].defaultRecordTypeMapping);
        } else{
            return;
        }
    }
    get showNewRevenueEffectTable(){
        return (this._renderNewRevenueEffectTable
                && this._lstRevenueEffectNewRecordTableHeaders 
                && this._lstRevenueEffectsToInsert);
    }
    get showRelatedRevenueEffectTables(){
        return (this._renderRelatedRevenueEffectTable
                && this._lstOpportunityRelatedRETableCols
                && this._lstOpportunityRelatedRERecords);
    }

    /**
     * Description: Retrieve Revenue Effect object info and use it to construct
     * Opportunity related Revenue Effect table column headers
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    @wire(getObjectInfo, { objectApiName: REVENUE_EFFECT_OBJECT })
    processRevenueEffectObjInfo({ error, data }){
        if (data) {
            this._objRevenueEffectObjInfo = data;
            this._objRecTypeIdsToRecTypeInfos = data.recordTypeInfos;
            this._lstOpportunityRelatedRETableCols = this.constructRelatedRERecordTableCols(data.fields);
            this._lstRevenueEffectNewRecordTableHeaders = this.constructRevenueEffectNewRecordTableHeaders(data.fields);
        } else if (error) {
            this.closeModuleWithErrorToast(error);
        }
        this.reevaluateSpinnerDisplays();
    }

    /**
     * Description:
     * Retrieve all Opportunity-related Revenue Effect records AND results of calculations
     * summarzing data stored in Revenue Effects by invoking an Apex method
     * @param opportunityId - Opportunity record Id
     * @return (Apex method) RevenueEffectDetailsWrapper
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    @wire(getRevenueEffectDetails, {opportunityId : '$recordId'})
    processRevenueEffectDetails(value){
        // Store value to be passed to refreshApex() to force cache refreshment for this wired function 
        this._wiredRevenueEffectDetails = value;
        const { data, error } = value;
        if(data){
            this._objOppRelatedRevenueEffectDetails = data;
            this.error = undefined;
            if(this._objOppRelatedRevenueEffectDetails.hasError){
                // Close the modal window in case of failure to retrieve data
                this.dispatchEvent(new CloseActionScreenEvent());
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while refreshing records',
                        message: this._objOppRelatedRevenueEffectDetails.errorMsg,
                        variant: 'error'
                    })
                );
            } else{
                // Set Opportunity-related Revenue Effects Datatable data
                this._lstOpportunityRelatedRERecords = this._objOppRelatedRevenueEffectDetails.lstRevenueEffectRecords;
                if( this._lstOpportunityRelatedRERecords !== undefined 
                    && this._lstOpportunityRelatedRERecords !== null
                    && this._lstOpportunityRelatedRERecords.length > 0
                ){
                    this._objRevenueEffectSummaryCalculations = this._objOppRelatedRevenueEffectDetails.mapCalculationNamesToResults;
                    let lstTmpRevenueEffectSummaryTableCols = this.helperConstructSummaryTableColumns();
                    // Color relevant summary table values red in case of a negative overall revenue effect by setting
                    // the appropriate claculation result Datatable column cellAttributes property to error 
                    if( this._objRevenueEffectSummaryCalculations['revenueEffect'] !== undefined
                        && this._objRevenueEffectSummaryCalculations['revenueEffect'] < 0
                    ){
                        lstTmpRevenueEffectSummaryTableCols = lstTmpRevenueEffectSummaryTableCols.map(objColumnProperties => {
                            if(['revenueEffect', 'revenueEffectPer'].includes(objColumnProperties.fieldName)){
                                return {...objColumnProperties, cellAttributes: { class: 'slds-text-color_error'}};
                            }
                            return objColumnProperties;
                        });
                    }
                    // Set summary calculation Datatable columns and data
                    this._lstRevenueEffectSummaryTableCols = lstTmpRevenueEffectSummaryTableCols;
                    this.lstRevenueEffectSummaryTableData = [{...this._objRevenueEffectSummaryCalculations}];
                    // Render existing record tables
                    this.renderRelatedRevenueEffectTables();
                } else{
                    // Show only new Revenue Effect list, if no existing related records
                    this.renderNewRevenueEffectTable();
                    this.renderRelatedRevenueEffectTables(false);
                }
            }
        } else if(error){
            this.closeModuleWithErrorToast(error);
        }
        this.reevaluateSpinnerDisplays();
    }

    /**
     * Description:
     * Actions to perform upon this component instance insertion into DOM
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    connectedCallback(){
        this.showWholeCmpSpinner = true;
        // Adjust window size
        loadStyle(this, '/resource/revenueEffectActionCustomModal');
        // Add first row of Revenue Effects to insert
        this.helperCreateTmpRevenueEffectRecord();
    }

    /**
     * Description:
     * Actions to perform upon closing this component instance
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    /**
     * Description:
     * Save any edited Revenue Effect records by invoking an Apex method and refresh
     * both the list of Opportunity-related Revenue Effects and their summary calculations
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    async handleSaveEditedRevenueEffects(event) {
        const lstRERecsWithValuesToUpdate = event.detail.draftValues;
        // Clear all datatable draft values
        this.lstEditedRevenueEffectDraftValues = [];
        try {
            this.showRelatedRecordsSpinner = true;
            // Pass edited fields to the Apex controller updateRi() method 
            let areRecordsUpdated = await updateRi({ lstRi: lstRERecsWithValuesToUpdate });
            // Report success with a toast
            if(areRecordsUpdated){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Revenue Effects updated',
                        variant: 'success'
                    })
                );
            } else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'All modified Revenue Effects contained invalid field values.',
                        variant: 'error'
                    })
                );
            }
            // Display fresh data in the related Revenue Effects and Summary Datatables
            await refreshApex(this._wiredRevenueEffectDetails);
            this.showRelatedRecordsSpinner = false;
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while updating or refreshing records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.showRelatedRecordsSpinner = false;
        }
    }

    /**
     * Description:
     * Delete a Revenue Effect record by invoking an Apex method and refresh
     * both the list of Opportunity-related Revenue Effects and their summary calculations
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    async deleteRevenueEffectRecord(event){
        const revenueEffectToDeleteId = event.detail.row.Id;
        try{
            this.showRelatedRecordsSpinner = true;
            // Pass the Revenue Effect to delete Id to the Apex controller deleteRecord() method
            let successMsg = await deleteRecord({ RIid: revenueEffectToDeleteId });
            // Report success with a toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: successMsg,
                    variant: 'success'
                })
            );
            // Display fresh data in the related Revenue Effects and Summary Datatables
            await refreshApex(this._wiredRevenueEffectDetails);
            this.showRelatedRecordsSpinner = false;
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while deleting or refreshing records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            this.showRelatedRecordsSpinner = false;
        }
    }

    /**
     * Description:
     * Insert new Revenue Effect records by invoking an Apex method and refresh
     * both the list of Opportunity-related Revenue Effects and their summary calculations
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    async addRevenueEffectRecords(){
        try{
            this.showWholeCmpSpinner = true
            // Query all new Revenue Effect rows (custom component instances) and call the public isRevenueEffectRecordValid()
            // method on each component instance to verify whether the corresponding Revenue Effect record is valid for insertion
            const lstNodesRevenueEffectsToInsert = this.template.querySelectorAll('c-utility-revenue-impact-new-record-dynamic-row');
            const areRevenueEffectsValid = Array.from(lstNodesRevenueEffectsToInsert).reduce((validSoFar, revenueEffectNode) => {
                return validSoFar && revenueEffectNode.isRevenueEffectRecordValid();
            }, true);
            if(!areRevenueEffectsValid){
                throw new Error('Please update the invalid form entries and try again.');
            }
            // Transform the child component node list into an array of their corresponding Revenue Effect objects
            const lstTmpRevenueEffectsToInsert = Array.from(
                lstNodesRevenueEffectsToInsert, (curDynamicRowItem) => curDynamicRowItem.getRevenueEffectToInsert()
            );
            // Pass the list of Revenue Effects to insert to the Apex controller saveRevenueImpact() method
            let successMsg = await saveRevenueImpact({ ListRI: Array.from(lstTmpRevenueEffectsToInsert) });
            // Empty the new Revenue Effect list and add an initial empty record 
            this._lstRevenueEffectsToInsert = [];
            this.helperCreateTmpRevenueEffectRecord();
            // Report success with a toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: successMsg,
                    variant: 'success'
                })
            );
            this.renderNewRevenueEffectTable(false);
            // Display fresh data in the related Revenue Effects and Summary Datatables
            await refreshApex(this._wiredRevenueEffectDetails);
            this.showWholeCmpSpinner = false;
        } catch (error) {
            const errorMsg = error.message == null ? error.body.message : error.message;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while inserting records.',
                    message: errorMsg,
                    variant: 'error'
                })
            );
            this.showWholeCmpSpinner = false;
        }
    }

    /** Construct table columns */
    /**
     * Description:
     * Construct Datatable columns for the summary calculation results for 
     * Opportunity-related Revenue Effects
     * @return Array of LWC Datatable columns objects
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    helperConstructSummaryTableColumns(){
        let lstTmpRevenueEffectSummaryTableCols = [];
        lstTmpRevenueEffectSummaryTableCols.push(
            {
                label : OLD_TOTAL_REVENUE_EFFECT_LABEL,
                fieldName : 'totalOld',
                editable: false,
                type: 'currency',
                typeAttributes: objDatatableCurrencyAttributes,
                wrapText: true
            },{
                label : NEW_TOTAL_REVENUE_EFFECT_LABEL,
                fieldName : 'totalNew',
                editable: false,
                type: 'currency',
                typeAttributes: objDatatableCurrencyAttributes,
                wrapText: true
            },{
                label : OPPORTUNTIY_REVENUE_EFFECT_LABEL,
                fieldName : 'revenueEffect',
                editable: false,
                type: 'currency',
                typeAttributes: objDatatableCurrencyAttributes,
                wrapText: true
            }, {
                label : OPPORTUNTIY_REVENUE_EFFECT_PERCENT_LABEL,
                fieldName : 'revenueEffectPer',
                editable: false,
                type: 'percent',
                wrapText: true
            }
        );
        return lstTmpRevenueEffectSummaryTableCols;
    }

    /**
     * Description:
     * Construct Opportunity-related Revenue Effect Datatable columns
     * (automatically using the User's language)
     * @param objREFieldApiNamesToFieldInfos - User Interface API returned Revenue Effect 
     *          objectInfo fields property (object)
     * @return Array of LWC Datatable columns objects
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    constructRelatedRERecordTableCols(objREFieldApiNamesToFieldInfos){
        let lstTmpOpportunityRelatedRETableCols = [];
        lstTmpOpportunityRelatedRETableCols.push(
            {
                label : objREFieldApiNamesToFieldInfos[CATEGORY_FIELD[KEY_FIELD_API_NAME]].label,
                fieldName : CATEGORY_FIELD[KEY_FIELD_API_NAME],
                editable: true,
                type: 'text',
                wrapText: true
            },{
                label : objREFieldApiNamesToFieldInfos[OLD_ANTAL[KEY_FIELD_API_NAME]].label,
                fieldName : OLD_ANTAL[KEY_FIELD_API_NAME],
                editable: true,
                type: 'text'
            },{
                label : objREFieldApiNamesToFieldInfos[OLD_MONTHLY_COST[KEY_FIELD_API_NAME]].label,
                fieldName : OLD_MONTHLY_COST[KEY_FIELD_API_NAME],
                editable: true,
                type: 'text'
            },{
                label : objREFieldApiNamesToFieldInfos[OLD_TOTAL_REVENUE_12_MONTHS[KEY_FIELD_API_NAME]].label,
                fieldName : OLD_TOTAL_REVENUE_12_MONTHS[KEY_FIELD_API_NAME],
                editable: false,
                type: 'text'
            },{
                label : objREFieldApiNamesToFieldInfos[NEW_ANTAL[KEY_FIELD_API_NAME]].label,
                fieldName : NEW_ANTAL[KEY_FIELD_API_NAME],
                editable: true,
                type: 'text'
            },{
                label : objREFieldApiNamesToFieldInfos[NEW_MONTHLY_COST[KEY_FIELD_API_NAME]].label,
                fieldName : NEW_MONTHLY_COST[KEY_FIELD_API_NAME],
                editable: true,
                type: 'text'
            },{
                label : objREFieldApiNamesToFieldInfos[NEW_TOTAL_REVENUE_12_MONTHS[KEY_FIELD_API_NAME]].label,
                fieldName : NEW_TOTAL_REVENUE_12_MONTHS[KEY_FIELD_API_NAME],
                editable: false,
                type: 'text'
            },{
                label : objREFieldApiNamesToFieldInfos[COMMENTS[KEY_FIELD_API_NAME]].label,
                fieldName : COMMENTS[KEY_FIELD_API_NAME],
                editable: true,
                type: 'text',
                wrapText: true
            }, {
                type: 'action',
                typeAttributes: {
                    rowActions: [{ label: DELETE_LABEL, name: 'Delete'}]
                }            
            }
        );
        return lstTmpOpportunityRelatedRETableCols;
    }

    /**
     * Description:
     * Construct table column headers for Revenue Effects to insert 
     * @return Array of objects containing column information
     * Modifications:
     *  25.11.2022 [TB] SALEF-7482_Mod - Sub-category not needed.
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    constructRevenueEffectNewRecordTableHeaders(objREFieldApiNamesToFieldInfos){
        let lstTmpRevenueEffectNewRecordTableHeaders = [];
        lstTmpRevenueEffectNewRecordTableHeaders.push({col : 0, headerLabel : HEADER_LABLE_NEW_REVENUE_EFFECT_TABLE_ROW_NO, isAction : false, class : 'narrowCol'});
        lstTmpRevenueEffectNewRecordTableHeaders.push({col : 1, headerLabel : objREFieldApiNamesToFieldInfos[CATEGORY_FIELD[KEY_FIELD_API_NAME]].label, isAction : false, class : ''});
        //lstTmpRevenueEffectNewRecordTableHeaders.push({col : 2, headerLabel : objREFieldApiNamesToFieldInfos[SUB_CATEGORY_FIELD[KEY_FIELD_API_NAME]].label, isAction : false, class : ''}); // SALEF-7482_Mod
        lstTmpRevenueEffectNewRecordTableHeaders.push({col : 3, headerLabel : objREFieldApiNamesToFieldInfos[OLD_ANTAL[KEY_FIELD_API_NAME]].label, isAction : false, class : ''});
        lstTmpRevenueEffectNewRecordTableHeaders.push({col : 4, headerLabel : objREFieldApiNamesToFieldInfos[OLD_MONTHLY_COST[KEY_FIELD_API_NAME]].label, isAction : false, class : ''});
        lstTmpRevenueEffectNewRecordTableHeaders.push({col : 5, headerLabel : objREFieldApiNamesToFieldInfos[OLD_TOTAL_REVENUE_12_MONTHS[KEY_FIELD_API_NAME]].label, isAction : false, class : ''});
        lstTmpRevenueEffectNewRecordTableHeaders.push({col : 6, headerLabel : objREFieldApiNamesToFieldInfos[NEW_ANTAL[KEY_FIELD_API_NAME]].label, isAction : false, class : ''});
        lstTmpRevenueEffectNewRecordTableHeaders.push({col : 7, headerLabel : objREFieldApiNamesToFieldInfos[NEW_MONTHLY_COST[KEY_FIELD_API_NAME]].label, isAction : false, class : ''});
        lstTmpRevenueEffectNewRecordTableHeaders.push({col : 8, headerLabel : objREFieldApiNamesToFieldInfos[NEW_TOTAL_REVENUE_12_MONTHS[KEY_FIELD_API_NAME]].label, isAction : false, class : ''});
        lstTmpRevenueEffectNewRecordTableHeaders.push({col : 9, headerLabel : objREFieldApiNamesToFieldInfos[COMMENTS[KEY_FIELD_API_NAME]].label, isAction : false, class : ''});
        lstTmpRevenueEffectNewRecordTableHeaders.push({col : 10, headerLabel : objREFieldApiNamesToFieldInfos[COMMENTS[KEY_FIELD_API_NAME]].label, isAction : true, class : 'narrowCol'});
        lstTmpRevenueEffectNewRecordTableHeaders.sort(this.helperSortHeaderColumns);
        return lstTmpRevenueEffectNewRecordTableHeaders;
    }

    /**
     * Description:
     * Logic determining column order in table
     * @param header1 column object (custom)
     * @param header2 column object (custom)
     * @return An integer determining parameter obj order
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    helperSortHeaderColumns(header1, header2){
        return (header1.col - header2.col);
    }

    /**
     * Description:
     * Convert Apex-returned Revenue Effect Summary Calculation object instances into
     * a format required to correctly display the data in a lightning-datatable
     * @param lstRevenueEffectSummaryTableRecords - An array of Revenue Effect Summary Calculation
     * object instances (should only ever be one)
     * @return Array - an array of Revenue Effect Summary Calculation object instances (key-value pairs)
     * with the Apex-returned values converted to be displayed correctly in a lightning-datatable 
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    convertSummaryDataIntoDataTableFormat(lstRevenueEffectSummaryTableRecords){
        let recordCounter = 0;
        return lstRevenueEffectSummaryTableRecords?.map(objSummaryData => {
            const objSummaryDataCopy = {...objSummaryData, id: 'reSummary'+ recordCounter++};
            if(objSummaryDataCopy['revenueEffectPer']){
                objSummaryDataCopy['revenueEffectPer'] = objSummaryDataCopy['revenueEffectPer']/100;
            }
            return objSummaryDataCopy;
        });
    }

    /** Newly added Revenue Effect methods **/
    /**
     * Description:
     * Add an additional Revenue Effect (to be passed to dynamicRowItemLWC)
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    addNewRevenueEffectsToInsertRow(){
        this.helperCreateTmpRevenueEffectRecord();
    }

    /**
     * Description:
     * Helper to push a new Revenue Effect to the list of Revenue Effects to insert
     * Modifications:
     *  25.11.2022 [TB] SALEF-7482_Mod - Sub-category not needed.
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    helperCreateTmpRevenueEffectRecord(){
        const objRevenueEffectToInsert = {};
        objRevenueEffectToInsert['sobjectType'] = REVENUE_EFFECT_OBJECT['objectApiName'];
        objRevenueEffectToInsert[CATEGORY_FIELD[KEY_FIELD_API_NAME]] = '';
        //objRevenueEffectToInsert[SUB_CATEGORY_FIELD[KEY_FIELD_API_NAME]] = ''; //SALEF-7482_Mod
        objRevenueEffectToInsert[NEW_ANTAL[KEY_FIELD_API_NAME]] = '';
        objRevenueEffectToInsert[OLD_ANTAL[KEY_FIELD_API_NAME]] = '';
        objRevenueEffectToInsert[OLD_MONTHLY_COST[KEY_FIELD_API_NAME]] = '';
        objRevenueEffectToInsert[NEW_MONTHLY_COST[KEY_FIELD_API_NAME]] = '';
        objRevenueEffectToInsert[COMMENTS[KEY_FIELD_API_NAME]] = '';
        this.updateRevenueEffectsToInsertList(JSON.stringify(objRevenueEffectToInsert));
    }

    /**
     * Description:
     * Construct an id for a newly added Revenue Effect (to be used as a list key) 
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    updateRevenueEffectsToInsertList(revenueEffect){
        this._lstRevenueEffectsToInsert.push({rowJSON: revenueEffect, id: this._newRevenueEffectCounter++});
        //this._lstRevenueEffectsToInsert = this._lstRevenueEffectsToInsert.map((row) => ({rowJSON : row, id: this._newRevenueEffectCounter++}));
    }

    /**
     * Description:
     * Handle a deleterow event sent by one of the Revenue Effect to insert rows by
     * removing the row from the list.   
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    removeREToInsertDeletedRow(event){
        const rowToDeleteIdx = event.detail;

        if( this._lstRevenueEffectsToInsert !== undefined 
            && this._lstRevenueEffectsToInsert.length !== 0
            && rowToDeleteIdx !== undefined
        ){
            this._lstRevenueEffectsToInsert = this._lstRevenueEffectsToInsert.filter((revenueEffect, idx) => idx !== rowToDeleteIdx);
        }
    }

    /**
     * Description:
     * Check whether the data needed to display tables has been retrieved.  
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    reevaluateSpinnerDisplays(){
        if( this._lstOpportunityRelatedRETableCols !== undefined
            && this._lstOpportunityRelatedRERecords !== undefined
        ){
            this.showWholeCmpSpinner = false;
            this.showRelatedRecordsSpinner = false;
        }
    }

    /**
     * Description:
     * Reveal Revenue Effects to insert table.  
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    renderNewRevenueEffectTable(renderTable = true){
        if(renderTable){
            this._renderNewRevenueEffectTable = true;
        } else{
            this._renderNewRevenueEffectTable = false;
        }
    }

    /**
     * Description:
     * Render tables of the existing related Revenue Effects.  
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    renderRelatedRevenueEffectTables(renderTable = true){
        if(renderTable){
            this._renderRelatedRevenueEffectTable = true;
        } else{
            this._renderRelatedRevenueEffectTable = false;
        }
    }

    /**
     * Description:
     * Reveal Revenue Effects to insert table.  
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    hideAllElements(){
        this._renderRelatedRevenueEffectTable = false;
        this._renderNewRevenueEffectTable = false;
        this.showWholeCmpSpinner = false;
        this.showRelatedRecordsSpinner = false;
    }

    /**
     * Description:
     * Call upon lightning data service error.  
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    closeModuleWithErrorToast(ldsError){
        this.dispatchEvent(new CloseActionScreenEvent());
        let errorMsg = reduceErrors(ldsError);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error while refreshing records',
                message: errorMsg.join(','),
                variant: 'error'
            })
        );
    }

}