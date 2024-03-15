/**
 * Created by KWN687 on 2022-03-04.
 */

public with sharing class MassDeleteDocumentsController {

    @AuraEnabled(cacheable=true)
    public static List<Related_Documents__c> retrieveRelatedDocuments(id keySearch){
        List<Related_Documents__c> myRelatedDocuments = [Select id, name, Opportunity_no__c, Type__c, LastModifiedDate, Owner.Name,OwnerId, Document_Link__c From Related_Documents__c Where Opportunity__c =:keySearch];
        return myRelatedDocuments;
    }
    @AuraEnabled(cacheable=true)
    public static List<Related_Documents__c> retrieveDeletedRelatedDocuments(id keySearch){
        List<Related_Documents__c> myDeletedRelatedDocuments = [Select id, name, Opportunity_no__c, Type__c, LastModifiedDate, Owner.Name,OwnerId, Document_Link__c From Related_Documents__c Where Opportunity__c =:keySearch AND IsDeleted = true ALL ROWS];
        return myDeletedRelatedDocuments;
    }
    @AuraEnabled(Cacheable=false)
    public static Boolean  deleteUndeleteRelatedDocuments(List<id> keySearch, Boolean isDelete){
        List<Related_Documents__c> myRelatedDocuments = [Select id From Related_Documents__c Where id IN:keySearch  ALL ROWS];
        if(isDelete)
        {
            delete myRelatedDocuments;
        }
        else
        {
            undelete myRelatedDocuments;
        }

        return true;
    }
}