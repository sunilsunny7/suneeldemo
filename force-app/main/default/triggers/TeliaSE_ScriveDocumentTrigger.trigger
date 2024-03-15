/*
About
-----
Description: TeliaSE_ScriveDcoumentTrigger on Scrive Document
Create date: 07.05-2020

Update History
--------------
Created May 2020 - R.R - Created
Updated Fields of Scrive Document Object with ContentVersion object
*/

trigger TeliaSE_ScriveDocumentTrigger on scrive__ScriveDocument__c (before insert) {
    if(Trigger.IsInsert && Trigger.IsBefore){
        Set<Id> opSet = new Set<Id>();
        for(scrive__ScriveDocument__c sd : Trigger.New){
            opSet.add(sd.scrive__opportunity__c);
        }
        Map<String, ContentVersion> cvOppMap = new Map<String, ContentVersion>();
        Map<String, ContentVersion> oppCvMap = new Map<String, ContentVersion>();
        if(opSet != null && opSet.size() > 0){
            List<ContentVersion> cvList = [select Id, TeliaSE_MC_ExternalDataSourceId__c, TeliaSE_MC_Agreement_Number__c, TeliaSE_MC_ReplaceAgreement__c, TeliaSE_MC_Product__c,TeliaSE_MC_Note__c, TeliaSE_MC_Start_Date__c, TeliaSE_MC_End_Date__c,TeliaSE_MC_DocumentType__c from ContentVersion where TeliaSE_MC_ExternalDataSourceId__c in :opSet ORDER BY createddate asc];
            if(cvList != null){
                for(ContentVersion cvObj : cvList){
                    if(cvOppMap.get(cvObj.TeliaSE_MC_ExternalDataSourceId__c) == null){
                        cvOppMap.put(cvObj.TeliaSE_MC_ExternalDataSourceId__c, cvObj);
                    }
                }
            }
           
            List<scrive__ScriveDocument__c> scriveToBeUpdated = new List<scrive__ScriveDocument__c>();
            for(scrive__ScriveDocument__c sd : Trigger.New){
                for(ContentVersion cv : cvList){
                    if(cv.TeliaSE_MC_ExternalDataSourceId__c == sd.scrive__opportunity__c){
                        sd.TeliaSE_MC_ContentVersion_Id__c = cvOppMap.get(cv.TeliaSE_MC_ExternalDataSourceId__c).Id;
                        sd.TelisSE_MC_Agreement_Number__c  = cvOppMap.get(cv.TeliaSE_MC_ExternalDataSourceId__c).TeliaSE_MC_Agreement_Number__c;
                        sd.TeliaSE_MC_ReplaceAgreement__c  = cvOppMap.get(cv.TeliaSE_MC_ExternalDataSourceId__c).TeliaSE_MC_ReplaceAgreement__c;
                        sd.TeliaSE_MC_Product__c           = cvOppMap.get(cv.TeliaSE_MC_ExternalDataSourceId__c).TeliaSE_MC_Product__c;
                        sd.TeliaSE_MC_Note__c              = cvOppMap.get(cv.TeliaSE_MC_ExternalDataSourceId__c).TeliaSE_MC_Note__c;
                        sd.TeliaSE_MC_Start_Date__c        = cvOppMap.get(cv.TeliaSE_MC_ExternalDataSourceId__c).TeliaSE_MC_Start_Date__c;
                        sd.TeliaSE_MC_End_Date__c          = cvOppMap.get(cv.TeliaSE_MC_ExternalDataSourceId__c).TeliaSE_MC_End_Date__c;
                        sd.TeliaSE_MC_DocumentType__c      = cvOppMap.get(cv.TeliaSE_MC_ExternalDataSourceId__c).TeliaSE_MC_DocumentType__c;
                        
                    }
                }
            }
        }
        
    }
}