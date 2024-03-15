/**
* @description       : Fetches and assignes the current sandbox name, switches recordType and prevents deletion of records.
* @author            : Mihir Joshi
* @Company           : Capgemini
* @last modified on  : 03-06-2024
* @last modified by  : Mihir Joshi
**/
public with sharing class MC_AccessRequestTriggerHandler {
    
    public static void handleBeforeInsert(List<MC_Access_Request__c> accessRequestRecordListNew){
        
        List<String> userNameList = new List<String>();
        ID recordTypeId = [SELECT Id FROM RecordType WHERE Name ='MC Access Request Final'].id;
        System.domain domain = System.DomainParser.parse(URL.getOrgDomainURL());
        
        //Fetching the usernames of requestee for new records
        for(MC_Access_Request__c userName : accessRequestRecordListNew){
            userNameList.add(userName.MC_Username__c);
        }
        
        //Fetching existing records based on Username, Approved/Rejected and Timeout flags
        List<MC_Access_Request__c> existingRecords = [ SELECT Id,Name,MC_Username__c
                                                      FROM MC_Access_Request__c
                                                      WHERE MC_Approved__c != True
                                                      AND MC_Rejected__c != True
                                                      AND MC_TimeOut__c != True
                                                      AND MC_Username__c IN: userNameList ];
        
        for(MC_Access_Request__c record : accessRequestRecordListNew){
            if(!existingRecords.isEmpty()){	// Duplicates Verification
                record.addError('Cannot Create Duplicate request since existing request is Open');
            }else{
                record.RecordTypeId = recordTypeId;
                record.MC_Sandbox_Name__c = domain.getSandboxName();   
            }
        }
    }
    
    public static void handleBeforeDelete(List<MC_Access_Request__c> accessRequestRecordListOld){
        for(MC_Access_Request__c record : accessRequestRecordListOld){
            record.addError('Record Cannot Be Deleted!');
        }
    }
}