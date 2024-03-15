/**-------------
Description: DisplayRichContext
Created 2022-05-12 12:38 Lokesh Singh - used to display Rich context message
SALEF-6798
-------------- */    
public class DisplayRichContext {
    @AuraEnabled
    Public Static ResultWrapper getRichContext(String recordId){
        ResultWrapper resWrap = new ResultWrapper();
        List<Contract> contractList = new List<Contract>();
        Id rrdRamavtalTypeId = Schema.SObjectType.contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();  
        User usrObj=[SELECT Id,LanguageLocaleKey from User where id =:UserInfo.getUserId()];
        contractList =[select id, Customer_unique_terms__c,Customer_unique_terms_Approved__c 
                           from  contract where id =: recordId and recordTypeId=:rrdRamavtalTypeId];  
        if(contractList.size()>0){
            if(contractList[0].Customer_unique_terms__c!=null && contractList[0].Customer_unique_terms_Approved__c==false){        
                resWrap.showRichContext  = true;  
                resWrap.LanguageLocaleKey =usrObj.LanguageLocaleKey;
            }else{ 
                resWrap.showRichContext  = false;  
                resWrap.LanguageLocaleKey =usrObj.LanguageLocaleKey;
            }
        }
        return resWrap;
    }
    public class ResultWrapper{
        @AuraEnabled Public String LanguageLocaleKey;
        @AuraEnabled Public Boolean showRichContext;
    }
}