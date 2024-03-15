/* 
* ******************************************************************************************************
* @author         Lokesh Singh
* Maintained by   /Lokesh Singh
* @version        1.0
* @created        2023-08-31
* @modified       2023-0- 31
* Story           LTAT-15927
*
* ******************************************************************************************************/
public class MCOnline_EmailNotificationPrsimaBatch implements Database.Batchable<sObject>, Database.Stateful {
    Boolean isRun = true;    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, createddate, MC_PricePlan__c,MC_AgreementNumber__c, MC_PricePlanCategory__c FROM MC_AgreementPlanChange__c WHERE CreatedDate = YESTERDAY';
        List<MC_AgreementPlanChange__c> objRecords = Database.query(query);
        
        if (objRecords.isEmpty()) {
            MCOnline_EmailNotificationSender.sendSingleEmailMethod();
        }        
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<MC_AgreementPlanChange__c> objRecords ){
        list<MC_AgreementPlanChange__c> lstAgrPlanChange = new list<MC_AgreementPlanChange__c>();
        Boolean isFileExist = false;
        Boolean isFileExistPrisma = false;  
        if(objRecords.size()>0){               
            FOR(MC_AgreementPlanChange__c obj :objRecords){
                if(obj.MC_PricePlan__c == null || obj.MC_PricePlanCategory__c==null|| obj.MC_AgreementNumber__c==null){ 
                    isFileExist = true;
                    Break;
                    
                }
            }
            
            if(isFileExist == true){
                MCOnline_EmailNotificationSender.sendSingleEmailMethod();               
            }else{
                if(isRun ==true){                    
                    list<MC_PrismaPlan__c> lstObj = [select id , name,MC_Price_Plan__c, MC_Price_Plan_Category__c from MC_PrismaPlan__c WHERE CreatedDate = YESTERDAY];
                    if(lstObj.size()>0){
                        FOR(MC_PrismaPlan__c obj :lstObj){
                            if(obj.MC_Price_Plan__c == null || obj.MC_Price_Plan_Category__c==null){ 
                                isFileExistPrisma = true; 
                                Break;                            
                            }
                        }
                        if(isFileExistPrisma==true){
                            MCOnline_EmailNotificationSender.sendSingleEmailMethod();
                        }                   
                    }else{
                        MCOnline_EmailNotificationSender.sendSingleEmailMethod();
                    }
                    isRun = false;
                }                            
            }            
        }else{
            MCOnline_EmailNotificationSender.sendSingleEmailMethod();
        }        
    }
    
    public void finish(Database.BatchableContext BC){
    }
}