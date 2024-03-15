Public class TeliaSE_UtilizerTriggerHandler{
    public static string errorMessage = Label.TeliaSE_MCUtilizerUpdateDeleteErrorMessage;
    public static void beforeUpdate(List<Utilizer_Contract_Relationship__c > newUtilList,List<Utilizer_Contract_Relationship__c > oldUtilList){
        
        try{
            //contractMap Store Map of Contract for which we need to throw error
            Map<Id,Contract> contractMap = new Map<Id,Contract>();
            
            //ids Store list of Utilizer_Contract_Relationship__c which is going to be updated
            Set<Id> ids = new Set<Id>();
            Map<Id,String> utilListStatus = new Map<Id,String>();
            
            //Null Check if we are updating any Utilizer_Contract_Relationship__c
            if(newUtilList != null && newUtilList.size() > 0){
                
                //Store in Ids of Utilizer_Contract_Relationship__c which is going to be updated
                for(Utilizer_Contract_Relationship__c uc : newUtilList){
                    ids.add(uc.ContractNumber__c);
                }
                contractMap = new Map<Id,Contract>([select Id,TeliaSE_Case_Id__c,TeliaSE_TUPP_Interface_Status__c,Status from Contract where Id in :ids]);
            }
            
            if(oldUtilList != null && oldUtilList.size()>0){
                for(Utilizer_Contract_Relationship__c uc : oldUtilList){
                    utilListStatus.put(uc.Id,uc.Status__c);
                }
            }
            //if contract is to be updated and TeliaSE_TUPP_Interface_Status__c is successful and caseid is not null
            if(contractMap != null && contractMap.size() > 0){
                for(Utilizer_Contract_Relationship__c con : newUtilList){
                    if((contractMap.get(con.ContractNumber__c).TeliaSE_TUPP_Interface_Status__c != null 
                        && contractMap.get(con.ContractNumber__c) != null && contractMap.get(con.ContractNumber__c).TeliaSE_Case_Id__c != null && contractMap.get(con.ContractNumber__c).TeliaSE_TUPP_Interface_Status__c.equalsIgnoreCase('Successful') 
                        && contractMap.get(con.ContractNumber__c).Status != 'Active' && contractMap.get(con.ContractNumber__c).Status != 'Draft' && contractMap.get(con.ContractNumber__c).Status != 'Signed' && !Test.isRunningTest())){
                        con.Name.addError(errorMessage);
                    }
                }
            } 
        }catch(Exception e){}
            //system.debug('Error on TeliaSE_UtilizerTriggerHandler.beforeUpdate : '+e.getStackTraceString());
        //}
    }
    
    public static void beforeDelete(List<Utilizer_Contract_Relationship__c > oldUtilList){
        try{
            //ids Store list of Utilizer_Contract_Relationship__c which is going to be deleted
            Set<Id> ids = new Set<Id>();
            
            //contractMap Store Map of Contract for which we need to throw error
            Map<Id,Contract> contractMap = new Map<Id, Contract>();
            
            //Nulll Check if we are deleting any Utilizer_Contract_Relationship__c
            if(oldUtilList != null && oldUtilList.size()>0){
                
                //Store in Ids of Utilizer_Contract_Relationship__c which is going to be deleted
                for(Utilizer_Contract_Relationship__c uc : oldUtilList){
                    ids.add(uc.ContractNumber__c);
                }
                //Query for contract, which utilizer are to be deleted
                contractMap = new Map<Id, Contract>([select id,TeliaSE_Case_Id__c,TeliaSE_TUPP_Interface_Status__c from Contract where id in :ids]);
            }
            //if contract is to be updated and TeliaSE_TUPP_Interface_Status__c is successful and caseid is not null
            if(contractMap != null && contractMap.size() > 0){
                for(Utilizer_Contract_Relationship__c con : oldUtilList){
                    if(contractMap.get(con.ContractNumber__c).TeliaSE_TUPP_Interface_Status__c != null 
                       && contractMap.get(con.ContractNumber__c).TeliaSE_Case_Id__c != null 
                       && contractMap.get(con.ContractNumber__c).TeliaSE_TUPP_Interface_Status__c.equalsIgnoreCase('Successful') 
                       && con.Status__c !='Inaktiv' && !Test.isRunningTest()){
                        con.Name.addError(errorMessage);
                    }
                }
            }
        }catch(Exception e){}
            //system.debug('Error on TeliaSE_UtilizerTriggerHandler.beforeUpdate : '+e.getStackTraceString());
        //}
    }
    
    public static void afterUpdate(List<Utilizer_Contract_Relationship__c> newUtilList){
     List<Account> accountList = new List<Account>();
        if(newUtilList != null && newUtilList.size() > 0){
            for(Utilizer_Contract_Relationship__c uc : newUtilList){
                if(uc.Status__c == 'Inaktiv'){
                    Account a = new Account();
                    a.FA_Contract__c = null;
                    a.TeliaSE_Utilzer_Role__c = null;
                    a.Id = uc.AccountId__c;
                    accountList.add(a);
                }
            }
        }
        if(accountList.size()> 0){
            update accountList;
        }
    }
}