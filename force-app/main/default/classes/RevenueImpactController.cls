/*
Created by P.S on Nov-2020
----
SALEF-3861 -  Controller for Revenue Impact Lightning Component on Opps Quick action.
*/
public with sharing class RevenueImpactController{
  //Inserting new records
   @AuraEnabled
    public static String saveRevenueImpact(List<Revenue_Effect__c> ListRI){
     String message = '';
     Decimal totalnew = 0;
     Decimal totalold = 0;
     Decimal revenueEffect = 0;
     
    
      Opportunity Opp = new Opportunity(id = ListRI[0].Opportunity__c);
      List<Revenue_Effect__c> existRi = [select id,New_Antal__c,New_Monthly_Cost__c,Old_Antal__c,Old_Monthly_Cost__c,Comments__c,New_Total_Revenue_12_Months__c,Old_Total_Revenue_12_Months__c from Revenue_Effect__c where Opportunity__c =: opp.id];
      
      if(existRi != null)
      existRi.addAll(ListRI);
      for(Revenue_Effect__c ri : existRi){
        totalnew += ri.New_Antal__c*ri.New_Monthly_Cost__c*12;
        totalold += ri.Old_Antal__c*ri.Old_Monthly_Cost__c*12;
      }
      revenueEffect = (totalnew - totalold);
      opp.Int_ktseffekt_12_m_n_Kr__c = revenueEffect ;
      opp.Int_ktseffekt_12_m_n__c = (revenueEffect/totalold)*100;
      
       if(ListRI.size() > 0)
       {
         Insert ListRI;
         message = 'Revenue Impact has been updated successfully.';
         
       }
       update opp;
       return message;
    }
  //For dependent picklist value selection 
 @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
   //returns all existing records based on Oppid 
    @AuraEnabled
    public static List<Revenue_Effect__c> getAllRecords(String Oppid)
    {   
        if(Oppid != null)
        return [select id, Category__c,New_Antal__c, New_Monthly_Cost__c,New_Product_Name__c,New_Total_Revenue_12_Months__c,Old_Antal__c,Old_Monthly_Cost__c,Old_Product_Name__c,Old_Total_Revenue_12_Months__c,Opportunity__c,Sub_Category__c,Comments__c from Revenue_Effect__c where Opportunity__c =: Oppid];    
        else 
        return null;
    }
 //for deleting record based on record id   
     @AuraEnabled
    public static String deleteRecord(String RIid)
    {
      System.debug('***Record to delete: '+RIid);
      Decimal totalnew = 0;
     Decimal totalold = 0;
     Decimal revenueEffect = 0;
      Revenue_Effect__c ri = [select id,Opportunity__c from Revenue_Effect__c where id =: RIid limit 1];
      System.debug('Record to delete:' +ri );
      
      Opportunity Opp = new Opportunity(id = ri.Opportunity__c);
      List<Revenue_Effect__c> existRi = [select id,New_Antal__c,New_Monthly_Cost__c,Old_Antal__c,Old_Monthly_Cost__c,Comments__c from Revenue_Effect__c where Opportunity__c =: opp.id];
      
      //if(existRi != null)
      //existRi.remove(ri.id);
      String message = '';
      if(ri != null){
       delete ri;
       message = 'Revenue Impact has been updated successfully.';
      }
      if(existRi.size()>0){
       for(Revenue_Effect__c ri1 : existRi){
        if(ri1.id != ri.id){
        totalnew += ri1.New_Antal__c*ri1.New_Monthly_Cost__c*12;
        totalold += ri1.Old_Antal__c*ri1.Old_Monthly_Cost__c*12;
      }
      }
      
      revenueEffect = (totalnew - totalold);
      if(revenueEffect != null && totalold!= 0 ){
        opp.Int_ktseffekt_12_m_n_Kr__c = revenueEffect ;
        opp.Int_ktseffekt_12_m_n__c = (revenueEffect/totalold)*100;
       }else{
         opp.Int_ktseffekt_12_m_n_Kr__c = 0;
         opp.Int_ktseffekt_12_m_n__c = 0;
         }
      update opp;
     }
      return message;
    }
   //Returns calculated amount to display in table 
    @AuraEnabled
    public static List<Decimal> getCalculatedAmt(String Oppid)
    { 
      Decimal totalnew = 0;
      Decimal totalold = 0;
      Decimal revenueEffect = 0; 
      Decimal revenueEffectPer = 0; 
      List<Decimal> calamt = new List<Decimal>();
      List<Revenue_Effect__c> existRi = [select id,New_Antal__c,New_Monthly_Cost__c,Old_Antal__c,Old_Monthly_Cost__c,Comments__c from Revenue_Effect__c where Opportunity__c =: oppid];
      if(existRi.size()>0){
      for(Revenue_Effect__c ri : existRi){
        totalnew += ri.New_Antal__c*ri.New_Monthly_Cost__c*12;
        totalold += ri.Old_Antal__c*ri.Old_Monthly_Cost__c*12;
      }
      calamt.add(totalnew);
      calamt.add(totalold);
     // return calamt;
      revenueEffect = (totalnew - totalold);
      revenueEffectPer = (revenueEffect/totalold)*100;
      calamt.add(revenueEffect);
      calamt.add(revenueEffectPer);
    }
    return calamt;
    }
    
    // method for update records after inline editing  
    @AuraEnabled
    public static Boolean updateRi(List<Revenue_Effect__c> lstRi) {
      Decimal totalnew = 0;
      Decimal totalold = 0;
      Decimal revenueEffect = 0; 
      Decimal revenueEffectPer = 0; 
      Decimal updatednewAntal;
      Decimal updatednewMonthlyCost;
      Decimal updatedOldAntal;
      Decimal updatedOldMonthlyCost;
      Opportunity Opp;
      Boolean returnvalue = false;
      
     System.debug('Updated list: '+lstRi);
      map<id,Revenue_Effect__c> uppdatedvalues = new Map<id,Revenue_Effect__c>();
      if(lstRi.size()>0){
      for(Revenue_Effect__c re : lstRi){
        uppdatedvalues.put(re.id,re);
      }
      Revenue_Effect__c[] reforOpp = [select id,Opportunity__c from Revenue_Effect__c where id =: lstRi[0].id limit 1];
        System.debug('**Updated map: '+uppdatedvalues );
      Opp = new Opportunity(id = reforOpp[0].opportunity__c);
     List<Revenue_Effect__c> existRi = [select id,New_Antal__c,New_Monthly_Cost__c,Old_Antal__c,Old_Monthly_Cost__c,Comments__c from Revenue_Effect__c where Opportunity__c =: Opp.id];
      
       System.debug('**existRi: '+existRi );
      for(Revenue_Effect__c ri : existRi ){ 
        if(uppdatedvalues.containskey(ri.id)){
          updatednewAntal = uppdatedvalues.get(ri.id).New_Antal__c != null ? uppdatedvalues.get(ri.id).New_Antal__c : ri.New_Antal__c;
           System.debug('**updatednewAntal :' + updatednewAntal );
           System.debug('**value check :' + uppdatedvalues.get(ri.id).New_Antal__c );
           updatednewMonthlyCost = uppdatedvalues.get(ri.id).New_Monthly_Cost__c != null ? uppdatedvalues.get(ri.id).New_Monthly_Cost__c : ri.New_Monthly_Cost__c;
           System.debug('**updatednewMonthlyCost :' + updatednewMonthlyCost);
           updatedOldAntal = uppdatedvalues.get(ri.id).Old_Antal__c != null ? uppdatedvalues.get(ri.id).Old_Antal__c : ri.Old_Antal__c;
           updatedOldMonthlyCost = uppdatedvalues.get(ri.id).Old_Monthly_Cost__c != null ? uppdatedvalues.get(ri.id).Old_Monthly_Cost__c : ri.Old_Monthly_Cost__c;
           
           totalnew += updatednewAntal*updatednewMonthlyCost*12;
           totalold += updatedOldAntal*updatedOldMonthlyCost*12;
        }else{
       totalnew += ri.New_Antal__c*ri.New_Monthly_Cost__c*12;
       totalold += ri.Old_Antal__c*ri.Old_Monthly_Cost__c*12;
       }
        
      }
      revenueEffect = (totalnew - totalold);
      opp.Int_ktseffekt_12_m_n_Kr__c = revenueEffect ;
      opp.Int_ktseffekt_12_m_n__c = (revenueEffect/totalold)*100;
      
    } 
     
        try{
        if(lstRi.size()>0){
         update lstRi;
         update Opp;
         returnvalue = true;
        }
        }catch(Exception e){
            returnvalue = false;
        }
        return returnvalue ;
    }
}