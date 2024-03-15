/**
 * Description:
 * RevenueImpactCalculation Lightning web component's Apex Controller.
 * 
 * Created on the basis of the Aura Lightning component controller (RevenueImpactController) developed
 * by P.S on Nov-2020 for SALEF-3861. 
 * 
 * RevenueImpactCalculation Lightning web component implements an Opportunity record action that allows the User
 * to manage Opportunity related Revenue Effect records.
 * Component:
 *  - displays a table of editable Revenue Effect records related to the Opportunity
 *  - displays a table of calcualted Revenue Effect data summaries
 *  - allows to add new Revenue Effect records
 * 
 * Modifications:
 * 26.10.2022 [Tomass Brazovskis] SALEF-7482 - Introduced. Original Lightning component (SALEF-3861) transfer from Aura to LWC. 
 * LTAT-7424: When removing a intäktseffektskalkyl in standard of förenklad process, then the fields in the opportunity should be blank.
*/
public with sharing class RevenueImpactCalculationController {

    private static List<String> lstRevenueEffectFieldApiNamesNotToBeUpdatedToNull = new List<String>{
        'New_Antal__c',
        'New_Monthly_Cost__c',
        'Old_Antal__c',
        'Old_Monthly_Cost__c'
    };

    @TestVisible
    private static List<String> lstRevenueEffectFieldApiNamesRequiredUponInsertion = new List<String>{  
        'New_Antal__c',
        'New_Monthly_Cost__c',
        'Old_Antal__c',
        'Old_Monthly_Cost__c',
        'Category__c'
    };

    private static List<String> lstRevenueEffectFieldApiNamesToBeGreaterThanZero = new List<String>{  
        'Old_Antal__c',
        'Old_Monthly_Cost__c'
    };

    /**@Description:
     * Return all Revenue Effect records related to an Opportunity
     * @param Oppid - Id of the REs parent Opportunity
     * @return - List of Revenue Effects
     * Modifications:
     *  26.10.2022 [TB] SALEF-7482 - Make method results cacheable.
     **/ 
    @AuraEnabled(cacheable=true)
    public static List<Revenue_Effect__c> getAllRecords(String Oppid)
    {   
        if(Oppid != null){
            return [  SELECT  Id, Category__c, Sub_Category__c,
                              Old_Antal__c, Old_Monthly_Cost__c, Old_Product_Name__c, Old_Total_Revenue_12_Months__c,
                              New_Antal__c, New_Monthly_Cost__c, New_Product_Name__c, New_Total_Revenue_12_Months__c,
                              Comments__c, Opportunity__c
                      FROM Revenue_Effect__c
                      WHERE Opportunity__c =:Oppid
                      ORDER BY CreatedDate DESC];
        } else{ 
          return null;
        }
    }
    
    /**@Description:
     * Insert new Revenue Effect records
     * @param ListRI - List of new Revenue Effect records to insert
     * @return - Success Message String
     * Modifications:
     * 26.10.2022 [TB] SALEF-7482 - Refactored. Invoke a method recalculating RE parent Opportunity
     *              summary fields and updating the Opportunity upon a successful new RE insertion. 
     **/
    @AuraEnabled
    public static String saveRevenueImpact(List<Revenue_Effect__c> ListRI){
        String SUCCESS_MSG_INSERTION = 'A Revenue Effect has been successfully created.';
        String SUCCESS_MSG_INSERTION_PLURAL = 'Revenue Effects have been successfully created.';
        String ERROR_MSG_INSERTION = 'No valid Revenue Effect records to insert.';

        if(ListRI == null || ListRI.size() == 0){
            return ERROR_MSG_INSERTION;
        }
        // If null, Opportunity update attempt will throw an appropriate error msg 
        Id reParentOppId = ListRI[0].Opportunity__c;
        List<Revenue_Effect__c> lstRevenueEffectsToInsert = new List<Revenue_Effect__c>();
        for(Revenue_Effect__c curRevenueEffect : ListRI){
            if(isRevenueEffectValidForInsertion(curRevenueEffect)){
                lstRevenueEffectsToInsert.add(curRevenueEffect);
            }
        }
        if(lstRevenueEffectsToInsert.size() == 0){
            throw new CustomException(ERROR_MSG_INSERTION);
        }
        Savepoint sp = Database.setSavepoint();
        try{
            insert lstRevenueEffectsToInsert;
            updateOpportunityRevenueEffectSummaries(reParentOppId);
        } catch(Exception curException){
            Database.rollback(sp);
            throw new CustomException(curException.getMessage());
        }
        if(lstRevenueEffectsToInsert.size() > 1){
            return (lstRevenueEffectsToInsert.size() + ' ' + SUCCESS_MSG_INSERTION_PLURAL);
        }
        return SUCCESS_MSG_INSERTION;
    }

    /**@Description:
     * Delete a Revenue Effect record with the passed id
     * @param RIid - Id of the Revenue Effect record to delete
     * @return - Success Message String
     * Modifications:
     * 26.10.2022 [TB] SALEF-7482 - Refactored. Invoke a method recalculating RE parent Opportunity
     *              summary fields and updating the Opportunity upon a successful RE deletion. 
     **/   
    @AuraEnabled
    public static String deleteRecord(Id RIid){
        List<Revenue_Effect__c> lstRevenueEffectToDelete = [select id,Opportunity__c from Revenue_Effect__c where id =: RIid limit 1];
        if(lstRevenueEffectToDelete.size() > 0){
            Id reParentOppId = lstRevenueEffectToDelete[0].Opportunity__c;

            Savepoint sp = Database.setSavepoint();
            try{
                delete lstRevenueEffectToDelete;
                updateOpportunityRevenueEffectSummaries(reParentOppId);
            } catch(Exception curException){
                Database.rollback(sp);
                throw new CustomException(curException.getMessage());
            }
            return 'Revenue Impact has been deleted successfully.';
        }
        return 'Revenue Impact does not exist';
    }
    
    /**@Description:
     * Method to update Revenue Effect records after inline editing
     * @param lstRi - List of Revenue Effect records editted by the User
     * @return Boolean - True in case of a successful transaction, False otherwise 
     * Modifications:
     * 26.10.2022 [TB] SALEF-7482 - Refactored. Do not update Revenue Effects with null values in certain fields.
     *              Invoke a method recalculating RE parent Opportunity summary fields and updating the Opportunity 
     *              upon a successful REs update. 
     **/   
    @AuraEnabled
    public static Boolean updateRi(List<Revenue_Effect__c> lstRi) {
        Boolean returnValue = false;
        if(lstRi != null){
            List<Revenue_Effect__c> lstRevenueEffectsToUpdate = new List<Revenue_Effect__c>();
            // Following the original design here - not sure why the fields are not
            // set as required at the field metadata config level
            for(Revenue_Effect__c curUpdatedRevenueEffect : lstRi){
                Revenue_Effect__c revenueEffectUpdateWithRemovedEmptyFields = getUpdateVersionWithNonEmptyFields(curUpdatedRevenueEffect);
                if(revenueEffectUpdateWithRemovedEmptyFields != null){
                    lstRevenueEffectsToUpdate.add(revenueEffectUpdateWithRemovedEmptyFields);
                }
            }
            if(lstRevenueEffectsToUpdate.size() != 0){
                Savepoint sp = Database.setSavepoint();
                try{
                    update lstRevenueEffectsToUpdate;
                    List<Revenue_Effect__c> lstRevenueEffectWithParentOppId = [ SELECT Id, Opportunity__c
                                                                                FROM Revenue_Effect__c
                                                                                WHERE Id = :lstRevenueEffectsToUpdate[0].Id];
                    updateOpportunityRevenueEffectSummaries(lstRevenueEffectWithParentOppId[0].Opportunity__c);
                    returnValue = true;
                } catch(Exception curException){
                    Database.rollback(sp);
                    throw new CustomException(curException.getMessage());
                }
            }
        }
        return returnvalue;
    }


    /**@Description:
     * Method to construct a RevenueEffectDetailsWrapper instance, containing a list of all Opportunity
     * related Revenue Effect records and the corresponding Revenue Effect Summary calculation results.
     * @param opportunityId - Id of the Revenue Effect parent Opportunity
     * @return RevenueEffectDetailsWrapper 
     * Modifications:
     * 26.10.2022 [TB] SALEF-7482 - Introduced. 
     **/   
    @AuraEnabled(cacheable=true)
    public static RevenueEffectDetailsWrapper getRevenueEffectDetails(Id opportunityId){
        RevenueEffectDetailsWrapper objREDetailsWrapper = new RevenueEffectDetailsWrapper();
        objREDetailsWrapper.lstRevenueEffectRecords = getAllRecords(opportunityId);
        if(objREDetailsWrapper.lstRevenueEffectRecords != null){
            try{
                objREDetailsWrapper.mapCalculationNamesToResults = helperPerformSummaryCalculations(objREDetailsWrapper.lstRevenueEffectRecords);
            } catch(Exception curException){
                objREDetailsWrapper.hasError = true;
                objREDetailsWrapper.errorMsg = curException.getMessage();
            }
        }
        return objREDetailsWrapper;
    }

    /**@Description:
     * Method to update relevant Opportunity fields with its related Revenue Effect records'
     * summary calculation results.
     * @param opportunityId - Id of the Opportunity to update
     * @return void 
     * Modifications:
     * 26.10.2022 [TB] SALEF-7482 - Introduced. 
     **/
    @AuraEnabled
    public static void updateOpportunityRevenueEffectSummaries(Id opportunityId){
        List<Revenue_Effect__c> lstOppRelatedRERecords = getAllRecords(opportunityId);
        Opportunity oppToUpdate = new Opportunity(  Id = opportunityId,
                                   //LTAT-7424 Added null value to keep fields blank When removing a intäktseffektskalkyl
                                                    Int_ktseffekt_12_m_n_Kr__c = null,   
                                                    Int_ktseffekt_12_m_n__c = null,
                                                    Total_Old_Revenue_Impact__c = null,
                                                    Total_New_Revenue_Impact__c =null);
        try{
            if(lstOppRelatedRERecords != null && lstOppRelatedRERecords.size() != 0){       
                Map<String,Decimal> mapSummaryCalculationNamesToResults = helperPerformSummaryCalculations(lstOppRelatedRERecords);
                oppToUpdate.Int_ktseffekt_12_m_n_Kr__c = mapSummaryCalculationNamesToResults.get('revenueEffect');
                oppToUpdate.Int_ktseffekt_12_m_n__c = mapSummaryCalculationNamesToResults.get('revenueEffectPer');
                oppToUpdate.Total_New_Revenue_Impact__c = mapSummaryCalculationNamesToResults.get('totalNew');
                oppToUpdate.Total_Old_Revenue_Impact__c = mapSummaryCalculationNamesToResults.get('totalOld');
            }
            update oppToUpdate;
        } catch(Exception curException){
            throw new CustomException(curException.getMessage());
        }
    }

    /**@Description:
     * Helper method to perform calculations summarazing the data stored 
     * in the passed list of Revenue Effect records.
     * @param lstRevenueEffects - List of Revenue Effect records to have summarized
     * @return key-value pairs - {<summaryCalc0_Name>: <summaryCalc0_Result>, <summaryCalc1_Name>: <summaryCalc1_Result>, ...} 
     * Modifications:
     * 26.10.2022 [TB] SALEF-7482 - Introduced. 
     **/
    @TestVisible
    private static Map<String,Decimal> helperPerformSummaryCalculations(List<Revenue_Effect__c> lstRevenueEffects){
        Decimal totalnew = 0;
        Decimal totalold = 0;
        Decimal revenueEffect = 0; 
        Decimal revenueEffectPer = 0;
        Map<String,Decimal> mapSummaryCalculationNamesToResults = new Map<String,Decimal>();

        if(lstRevenueEffects.size() > 0){
            for(Revenue_Effect__c curRE : lstRevenueEffects){
                totalnew += curRE.New_Antal__c * curRE.New_Monthly_Cost__c * 12;
                totalold += curRE.Old_Antal__c * curRE.Old_Monthly_Cost__c * 12;
            }
            revenueEffect = (totalnew - totalold);
            revenueEffectPer = (revenueEffect/totalold) * 100;

            mapSummaryCalculationNamesToResults.put('totalNew', totalnew);
            mapSummaryCalculationNamesToResults.put('totalOld', totalold);
            mapSummaryCalculationNamesToResults.put('revenueEffect', revenueEffect);
            mapSummaryCalculationNamesToResults.put('revenueEffectPer', revenueEffectPer);
        }
        return mapSummaryCalculationNamesToResults;
    }

    /**@Description:
     * Helper method to disallow a User to update certain existing 
     * Revenue Effect record fields with empty values.
     * @param revenueEffect - Revenue Effect record with field-value pairs to update
     * @return Revenue Effect instance - Revenue Effect of field-<non-empty value> pairs to update OR
     * null if the passed Revenue Effect record either does not have an Id or a single field-value pair other than Id
     * Modifications:
     * 26.10.2022 [TB] SALEF-7482 - Introduced. 
     **/
    private static Revenue_Effect__c getUpdateVersionWithNonEmptyFields(Revenue_Effect__c revenueEffect){
        Revenue_Effect__c revenueEffectWithNonEmptyFields = null;
        if(revenueEffect == null){
            return revenueEffectWithNonEmptyFields;
        }
        // Since the passed value is not queried, Map will contain null keys as well
        Map<String, Object> mapFieldApiNamesToValues = revenueEffect.getPopulatedFieldsAsMap().clone();
        // Remove field updates attempting to clear fields that should not be empty
        for(String fieldToCheckForNullValues : lstRevenueEffectFieldApiNamesNotToBeUpdatedToNull){
            if( mapFieldApiNamesToValues.containsKey(fieldToCheckForNullValues)
                && mapFieldApiNamesToValues.get(fieldToCheckForNullValues) == null 
            ){
                mapFieldApiNamesToValues.remove(fieldToCheckForNullValues);
            }
        }
        // Construct a Revenue Effect with only permissible field updates
        if( mapFieldApiNamesToValues.containsKey('Id')
            && mapFieldApiNamesToValues.size() > 1
        ){
            revenueEffectWithNonEmptyFields = new Revenue_Effect__c();
            for(String populatedFieldApiName : mapFieldApiNamesToValues.keySet()){
                revenueEffectWithNonEmptyFields.put(populatedFieldApiName, revenueEffect.get(populatedFieldApiName));
            }
        }
        return revenueEffectWithNonEmptyFields;
    }

    /**@Description:
     * Helper method to disallow a User to create a Revenue Effect record 
     * with invalid fields values.
     * @param revenueEffect - Revenue Effect record to insert
     * @return Boolean - indicates whether the passed Revenue Effect is valid for insertion
     * Modifications:
     * 08.11.2022 [TB] SALEF-7482 - Introduced.
     **/
    private static Boolean isRevenueEffectValidForInsertion(Revenue_Effect__c revenueEffect){
        Boolean isRecordValid = true;
        Integer requiredFieldsLstSize = lstRevenueEffectFieldApiNamesRequiredUponInsertion.size();
        Integer requiredFieldLstIdx = 0;
        while(isRecordValid && requiredFieldLstIdx < requiredFieldsLstSize){
            String curRequiredFieldApiName = lstRevenueEffectFieldApiNamesRequiredUponInsertion[requiredFieldLstIdx];
            isRecordValid = (revenueEffect.get(curRequiredFieldApiName) != null && revenueEffect.get(curRequiredFieldApiName) != '');
            requiredFieldLstIdx++;
        }
        Integer nonZeroFieldsLstSize = lstRevenueEffectFieldApiNamesToBeGreaterThanZero.size();
        Integer nonZeroFieldLstIdx = 0;
        while(isRecordValid && nonZeroFieldLstIdx < nonZeroFieldsLstSize){
            String curNonZeroFieldApiName = lstRevenueEffectFieldApiNamesToBeGreaterThanZero[nonZeroFieldLstIdx];
            isRecordValid = (revenueEffect.get(curNonZeroFieldApiName) != null && (Decimal)revenueEffect.get(curNonZeroFieldApiName) > 0);
            nonZeroFieldLstIdx++;
        }
        return isRecordValid;
    }

    /**@Description:
     * Wrapper containing
     *  - a list of all Revenue Effects related to an Opportunity
     *  - key-value pairs of Revenue Effect summary calculations
     * Modifications:
     * 26.10.2022 [TB] SALEF-7482 - Introduced.
     **/
    public class RevenueEffectDetailsWrapper{
        @AuraEnabled
        public Map<String, Decimal> mapCalculationNamesToResults {get;set;}
        @AuraEnabled
        public List<Revenue_Effect__c> lstRevenueEffectRecords {get;set;}
        @AuraEnabled
        public Boolean hasError{get;set;}
        @AuraEnabled
        public String errorMsg {get;set;}

        public RevenueEffectDetailsWrapper(){
            this.mapCalculationNamesToResults = new Map<String, Decimal>();
            this.hasError = false;
        }     
    }

    /**@Description:
     * CustomException to throw in case of failed dml operations.
     * 26.10.2022 [TB] SALEF-7482 - Introduced.
     **/
    public class CustomException extends Exception {}

}