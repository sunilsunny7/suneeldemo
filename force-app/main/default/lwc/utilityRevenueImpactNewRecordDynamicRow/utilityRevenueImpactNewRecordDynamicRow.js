/**
 * Description:
 * Lightning web component implements a row of a new Revenue Effect's (related to an Opportunity) fields a 
 * User can populate and insert the record from the lwc's parent 'c-revenue-impact-component' component.
 * Component:
 *  - displays a row of new Revenue Effect record relevant values
 *  - performs client side validation of the User-provided entries
 * 
 * Modifications:
 * 26.10.2022 [Tomass Brazovskis] SALEF-7482 - Introduced. Original Lightning component (SALEF-3861) transfer from Aura to LWC.
 * 25.11.2022 [Tomass Brazovskis] SALEF-7482_Mod - Modified. Do not display Sub-Category dependent picklist.
*/
import { LightningElement, api, wire, track} from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
// Custom labels
import revenueEffectErrorMsg from '@salesforce/label/c.Revenue_Impact_error';
// Constants
const NONE_SELECTED_STRING_LABEL = '--None--';
const NONE_SELECTED_STRING_VALUE = '';

export default class UtilityRevenueImpactNewRecordDynamicRow extends LightningElement {

    /** Properties passed as component attributes **/
    // Properties required to determine dependent picklist value
    // TODO: Dependent picklist calculation should probably be moved to their own component
    @api objectApiName = '';
    @api recordTypeId = '';
    @api get controllingPicklistField(){
        if( this._controllingPicklistField !== undefined 
            && this._controllingPicklistField['fieldApiName'] !== undefined){
            return this._controllingPicklistField['fieldApiName'];
        } else{
            return '';
        }
    };
    set controllingPicklistField(value){
        if(value !== undefined){
            this._controllingPicklistField = value;
        }
    }
    @api get dependentPicklistField(){
        if( this._dependentPicklistField !== undefined 
            && this._dependentPicklistField['fieldApiName'] !== undefined){
            return this._dependentPicklistField['fieldApiName'];
        } else{
            return '';
        }
    };
    set dependentPicklistField(value){
        if(value !== undefined){
            this._dependentPicklistField = value;
        }
    }
    // Revenue Effect instance to display
    _revenueEffectToInsertJson;
    // Parent Opportunity Id
    _opportunityId;
    // Instance index in the Revenue Effects-to-insert table
    @api get rowIndex(){
        return this._rowIndex;
    }
    set rowIndex(value){
        if(value !== undefined){
            this._rowIndex = value;
        }
    }
    @api get opportunityId(){
        return this._opportunityId
    }
    set opportunityId(value){
        if(value !== undefined){
            this._opportunityId = value;
            this.setRevenueEffectOpportunityId(this._opportunityId, this.revenueEffectToInsert);
        }
    }
    // The new Revenue Effect instance to display/update in the row
    // passed in the JSON string format
    @api
    get revenueEffectToInsertJson(){
        return this._revenueEffectToInsertJson;
    }
    set revenueEffectToInsertJson(value){
        if(this._revenueEffectToInsertJson !== value){
            this._revenueEffectToInsertJson = value;
            this.revenueEffectToInsert = JSON.parse(this._revenueEffectToInsertJson);
            if(this.revenueEffectToInsert !== undefined){
                this._revenueEffectParsed = true;
                this.setRevenueEffectOpportunityId(this._opportunityId, this.revenueEffectToInsert);
            }
        }
    }
 
    // Properties set by the values passed to public properties
    _controllingPicklistField;
    _dependentPicklistField;
    _rowIndex = 0;
    // Controlling picklist options array
    @track _lstControllingPicklistOptions = [];
    // Dependent picklist options array
    @track _lstSelectableDepOptions = [];
    _objDependentPicklistProperties = {};
    // Obj with {'controlerVal0': [depOption0, depOption1]} key-value pairs
    _objControllerValsToLstDependentOptions = {};
    // Initial input element value
    selectedControllingValue = NONE_SELECTED_STRING_VALUE;
    // Fomratted output (number) value
    _oldTotalAmount = '';
    _newTotalAmount = '';
    // Booleans for conditional rendering
    _showPicklist = false;
    _revenueEffectParsed = false;
    _dependentDisabled = true;
    _showDependent = false;
    _isTotalOld = false;
    _isTotalNew = false;
    // Parsed version of the passed Revenue Effect record JSON
    revenueEffectToInsert;

    /** Getters */
    get rowNumber(){
        return (this.rowIndex + 1);
    }
    get lstControllingPicklistOptions(){
        return this._lstControllingPicklistOptions;
    }
    get lstSelectableDepOptions(){
        return this._lstSelectableDepOptions;
    }
    get oldTotalAmount(){
        return this._oldTotalAmount;
    }
    get newTotalAmount(){
        return this._newTotalAmount;
    }
    get showPicklist(){
        return (this._showPicklist && this._revenueEffectParsed);
    }
    get dependentDisabled(){
        return this._dependentDisabled;
    }
    get showDependent(){
        return this._showDependent;
    }
    get isTotalOld(){
        return this._isTotalOld;
    }
    get isTotalNew(){
        return this._isTotalNew;
    }

    /* PUBLIC METHODS */
    /**
     * Description:
     * @return A Revenue Effect object instance
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    @api getRevenueEffectToInsert(){
        return this.revenueEffectToInsert;
    }

    /**
     * Description:
     * Public method verifying the validity of the User-provided
     * values in the Dynamic Row's input fields
     * @return Boolean - True, if User has provided valid values in all the fields required
     *         to successfully insert the Revenue Effect object. False - otherwise.
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    @api isRevenueEffectRecordValid(){
        if(this.opportunityId === undefined || this.opportunityId === ''){
            return false;
        }
        const allInputsValid = [
            ...this.template.querySelectorAll('lightning-input'),
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allInputsValid;
    }

    /**
     * Description: Retrieve <objectApiName> object Picklist Values Collection for the given object 
     * Record Type and use it to construct a mapping from each controlling picklist value to the list
     * of dependent picklist options valid for the given controlling value.
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    @wire(getPicklistValuesByRecordType, { objectApiName: '$objectApiName', recordTypeId: '$recordTypeId' })
    fetchPicklist({error,data}){
        if(data && data.picklistFieldValues){
            // Set controlling picklist's default option
            let initOption = {label : NONE_SELECTED_STRING_LABEL, value : NONE_SELECTED_STRING_VALUE};
            this._lstControllingPicklistOptions.push(initOption);
            // Use the dependent picklist controllerValues map to determine the selectable picklist values for
            // each controlling field's value. 
            this._objDependentPicklistProperties = data.picklistFieldValues[this.dependentPicklistField];
            if(data.picklistFieldValues[this.controllingPicklistField]){
                data.picklistFieldValues[this.controllingPicklistField].values.forEach(objCurControllerValProps => {
                    // Push every controlling picklist option to the controlling field options array
                    this._lstControllingPicklistOptions.push({label : objCurControllerValProps.label, value : objCurControllerValProps.value});
                    // Construct an array of all selectable dependent picklist options for the given controlling picklist value
                    let lstDependentOptions = [];
                    // If dependent picklist has not been passed, simply skip
                    if(this._objDependentPicklistProperties){
                        let curControllerValIdx = this._objDependentPicklistProperties.controllerValues[objCurControllerValProps.value];
                        if(curControllerValIdx !== undefined){
                            this._objDependentPicklistProperties.values.forEach(objCurDependentValProps => {
                                if(objCurDependentValProps.validFor.includes(curControllerValIdx)){
                                    lstDependentOptions.push({label : objCurDependentValProps.label, value : objCurDependentValProps.value});
                                }               
                            });
                        }
                    }
                    this._objControllerValsToLstDependentOptions[objCurControllerValProps.value] = lstDependentOptions;
                });
            }
            // Show picklist upon establishing the mapping
            this._showPicklist = true;
        }
    }

    /**
     * Description:
     * Assign the Revenue Effect to insert its parent Opportunity Id,
     * once both attributes become available.
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    setRevenueEffectOpportunityId(parentOpportunityId, revenueEffectToInsert){
        if( parentOpportunityId !== undefined 
            && parentOpportunityId !== '' 
            && revenueEffectToInsert !== undefined
        ){
            revenueEffectToInsert['Opportunity__c'] = parentOpportunityId;
        }
    }

    /**
     * Description: 
     * Method invoked upon change in the selected controlling picklist value. Constructs 
     * an array of dependent picklist options valid for the selected controlling value.
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    handleControllerFieldChange(event){
        this.revenueEffectToInsert.Category__c = event.detail.value;
        this.revenueEffectToInsert.Sub_Category__c = '';
        this._lstSelectableDepOptions = [{label : NONE_SELECTED_STRING_LABEL, value : NONE_SELECTED_STRING_VALUE}];
        this._showDependent = false;
        this._dependentDisabled = true;
        const selectedControllingVal = event.detail.value;
        this._objControllerValsToLstDependentOptions[selectedControllingVal]?.forEach(curDependentOption => {
            this._lstSelectableDepOptions.push(curDependentOption);
        });
        if(this._lstSelectableDepOptions.length > 1){
            this._dependentDisabled = false;
            this._showDependent = true;
        }
    }

    handleDependentPicklistChange(event){
        this.revenueEffectToInsert.Sub_Category__c = event.detail.value;
    }

    handleOldAntalChange(event){
        this.revenueEffectToInsert.Old_Antal__c = event.target.value;
        this.calculateTotalOld();
    }

    handleOldMonthlyCostChange(event){
        this.revenueEffectToInsert.Old_Monthly_Cost__c = event.target.value;
        this.calculateTotalOld();
    }

    handleNewAntalChange(event){
        this.revenueEffectToInsert.New_Antal__c = event.target.value;
        this.calculateTotalNew();
    }

    handleNewMonthlyCostChange(event){
        this.revenueEffectToInsert.New_Monthly_Cost__c = event.target.value;
        this.calculateTotalNew();
    }

    handleCommentsChange(event){
        this.revenueEffectToInsert.Comments__c = event.detail.value;
    }

    /**
     * Description: 
     * Method invoked upon change in the Old Antal or Old Monthly Cost input fields.
     * Calculates Old Total Amount and, when relevant, marks input fields as invalid. 
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    calculateTotalOld(){
        let oldAntalCmp = this.template.querySelector('[data-id="OldAntal"]');
        let oldMonthlyCostCmp = this.template.querySelector('[data-id="OldMonthlyCost"]');
        let oldAntalVal = parseFloat(this.revenueEffectToInsert.Old_Antal__c);
        let oldMonthlyCostVal = parseFloat(this.revenueEffectToInsert.Old_Monthly_Cost__c);
        oldAntalCmp?.setCustomValidity('');
        oldMonthlyCostCmp?.setCustomValidity('');

        if(oldAntalVal === 0){
            oldAntalCmp?.setCustomValidity(revenueEffectErrorMsg);
        }
        if(oldMonthlyCostVal === 0){
            oldMonthlyCostCmp?.setCustomValidity(revenueEffectErrorMsg);
        }
        oldAntalCmp?.reportValidity();
        oldMonthlyCostCmp?.reportValidity();
        if(!isNaN(oldAntalVal) && !isNaN(oldMonthlyCostVal)){
            this._oldTotalAmount = oldAntalVal * oldMonthlyCostVal * 12;
            this._isTotalOld = true;
        }
    }

    /**
     * Description: 
     * Method invoked upon change in the New Antal or New Monthly Cost input fields.
     * Calculates New Total Amount. 
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    calculateTotalNew(){
        //let newAntalCmp = this.template.querySelector('[data-id="NewAntal"]');
        //let newMonthlyCostCmp = this.template.querySelector('[data-id="NewMonthlyCost"]');
        let newAntalVal = parseFloat(this.revenueEffectToInsert.New_Antal__c);
        let newMonthlyCostVal = parseFloat(this.revenueEffectToInsert.New_Monthly_Cost__c);
        if(!isNaN(newAntalVal) && !isNaN(newMonthlyCostVal)){
            this._newTotalAmount = newAntalVal * newMonthlyCostVal * 12;
            this._isTotalNew = true;
        }
    }

    /**
     * Description: 
     * Send an event to the parent component to remove this row from the list
     * of Revenue Effects to add.
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Introduced.
     */
    removeRow(){
        const event = new CustomEvent('deleterow', {
            detail: this.rowIndex
        });
        this.dispatchEvent(event);
    }

}