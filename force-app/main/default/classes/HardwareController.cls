global  class HardwareController  implements vlocity_cmt.VlocityOpenInterface2 {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    Boolean result = true;
        try {
            if (methodName.equals('getSubscriptions')){
                SubscriptionEFSServices.getSubscriptions(inputMap,outMap);
            }else if(methodName.equalsIgnoreCase('GenerateButton')) {
                 SubscriptionEFSServices.GenerateButtonForProducts(inputMap, outMap);
            }else if(methodName.equalsIgnoreCase('GenerateButtonForAccessories')) {
                 SubscriptionEFSServices.GenerateButtonForAccessories(inputMap, outMap);
            }else {
                result = false;
           }  
        } catch(Exception e) {          
            result = false;
        }        
        return result;
    }  
    
/*
 * Hardware Need1 (Showing Subscription details in Account page using lightning Component)
 * Description: Calling this method from Lightnign component. In this method we are invoking an Integration procedure with C2BCache to update Mobilabonnemang__c object.  
*/    
    public class ResponseWrapper{
        
        @AuraEnabled public List<Mobilabonnemang__c> mobilabonnemangList {get; set;}
        
        @AuraEnabled public Integer numberOfRecords {get; set;}
        
        @AuraEnabled public String accountName {get; set;}
    }

    @AuraEnabled
    public static ResponseWrapper getMobilRecordsWithParam(string accId){
        try{
            List<Mobilabonnemang__c> subsList = [SELECT Id from Mobilabonnemang__c where Account__c = :accId];
            ResponseWrapper wrapper = new ResponseWrapper();
            String accountName = [select Id, Name from Account where id= :accId limit 1].Name;
            //if there is no data in Mobilabonnemang__c with given accountId it will invoke an IP here
            if(subsList == null || subsList.size() == 0){
                List<Mobilabonnemang__c> moblist = [SELECT Id, Name,Subsidized_Subscription__c,Binding_Time_Left__c,Allowed_To_Bind__c,TeliaSE_User_Name__c,Last_Used_Model__c,TeliaSE_Subscription_Name__c, CommitmentStartDate__c, CommitmentEndDate__c, CommitmentLength__c,MSISDN__c, Agreement__c, Category__c, Subscription_Id__c, Subscription_Type__c, Offering_Name__c, Roaming_Service_Descr__c, GPRS_Service_Allowance__c, Start_Date__c FROM Mobilabonnemang__c where Account__c = :accId];
                wrapper.mobilabonnemangList = HardwareServices.invokeGetSubscriptionsIntegrationProcedure(accId, null);
                wrapper.accountName = accountName;
                wrapper.numberOfRecords = moblist.size();                
                //return wrapper;
            }else{
                List<Mobilabonnemang__c> moblist = [SELECT Id, Name,Subsidized_Subscription__c,Binding_Time_Left__c,Allowed_To_Bind__c,Last_Used_Model__c,TeliaSE_User_Name__c,TeliaSE_Subscription_Name__c,CommitmentStartDate__c, CommitmentEndDate__c, CommitmentLength__c,MSISDN__c, Agreement__c, Category__c, Subscription_Id__c, Subscription_Type__c, Offering_Name__c, Roaming_Service_Descr__c, GPRS_Service_Allowance__c, Start_Date__c FROM Mobilabonnemang__c where Account__c = :accId];
                wrapper.mobilabonnemangList = moblist;
                wrapper.numberOfRecords = moblist.size();
                wrapper.accountName = accountName;
                //return wrapper;
            }

            return wrapper;
        }catch(Exception e){
            system.debug('Exception on HardwareController : '+e.getStackTraceString());
            return null;
        }
    } 
}