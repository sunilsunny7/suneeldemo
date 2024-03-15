/**
    About
    -----
    Description: BatchToCountEmpOfChildAccount
    Create date: 01.09.2016

    Update History
    --------------
    Created Sep 2016 - N.G - Created
        - This batch sums up 'TotalEmployees_reported__c' from all child accounts of Kknr parent account and displays the result on parent Kknr account in field 'Employees_KKnr__c'.
        - The batch runs once in a month.
        - Using custom settings ExcludedRecords__c (actExcludedAccounts and AcntRollUpExcludedRecords) to exclude accounts that has large number of child accounts to avoid batch failure due to governor limit.
        - The SchBatchToCountEmpOfChildAccount can be used to set up a new schedule of the batch job.
*/
global class BatchToCountEmpOfChildAccount implements Database.Batchable<sObject>{
    global final String query;// Variable to hold Query string
        //Constructor          
        global BatchToCountEmpOfChildAccount(string q){            
                system.debug('q********'+q);
                this.query = q;                      
        }
        global Database.QueryLocator start(Database.BatchableContext BC){           
                system.debug('BC********'+BC);
                return Database.getQueryLocator(query);     
        }
        global void execute(Database.BatchableContext BC, List<account> scope){
            system.debug('scope****'+scope);
            try{
            system.debug('scope****'+scope);
                 map<string, list<account>> parentChildAccMap = new map<string, list<account>>();
                 list<account> finalUpdateAccount = new list<account>();
                 string largeAccRecID = [select id from recordtype where name = 'Large Organisation'].id;
                 string larSak1AccRecID = [select id from recordtype where name = 'Large Organisation Säk 1'].id;
                 string larSak2AccRecID = [select id from recordtype where name = 'Large Organisation Säk 2'].id;
                 string smeAccRecID = [select id from recordtype where name = 'SME/SOHO Organisation'].id;
                
                  // retrieving Accounts from custom settings which are suppose to be excluded
                Set<Id> setExcludedUltimateParentAccounts = new Set<Id>();
                Set<Id> setExcludedUltimateParentAccounts1 = new Set<Id>();
                ExcludedRecords__c excludedUltimateParentAccounts = ExcludedRecords__c.getInstance('actExcludedAccounts');  
                String stringExcludedUltimateParentAccounts = excludedUltimateParentAccounts.Excluded_records_list__c;
                system.debug('stringExcludedUltimateParentAccounts ****'+stringExcludedUltimateParentAccounts);
                ExcludedRecords__c excludedUltimateParentAccounts1 = ExcludedRecords__c.getInstance('AcntRollUpExcludedRecords');  
                String stringExcludedUltimateParentAccounts1 = excludedUltimateParentAccounts1.Excluded_records_list__c;
                system.debug('stringExcludedUltimateParentAccounts1 ****'+stringExcludedUltimateParentAccounts1);
                List<Id> listExcludedUltimateParentAccounts = new List<Id>();
                List<Id> listExcludedUltimateParentAccounts1 = new List<Id>();
                
                if (stringExcludedUltimateParentAccounts != null && stringExcludedUltimateParentAccounts.length() > 0) {
                    listExcludedUltimateParentAccounts = stringExcludedUltimateParentAccounts.split(',');       
                }
                if (stringExcludedUltimateParentAccounts1 != null && stringExcludedUltimateParentAccounts1.length() > 0) {
                    listExcludedUltimateParentAccounts1 = stringExcludedUltimateParentAccounts1.split(',');       
                }
                for (Id exclParentId : listExcludedUltimateParentAccounts) {
                    setExcludedUltimateParentAccounts.add(exclParentId);
                }
                for (Id exclParentId : listExcludedUltimateParentAccounts1) {
                    setExcludedUltimateParentAccounts1.add(exclParentId);
                }
                
                list<account> accList = [select id, TotalEmployees_reported__c,parentID from account 
                                        where TotalEmployees_reported__c !=NULL AND TotalEmployees_reported__c != 0 AND  parentID in : scope AND parentID not in : setExcludedUltimateParentAccounts AND parentID not in : setExcludedUltimateParentAccounts1
                            AND (recordtypeID =: largeAccRecID OR recordtypeID =: larSak1AccRecID OR recordtypeID =: larSak2AccRecID or recordtypeID =: smeAccRecID)];
              
                system.debug('*in test**'+accList);
                for(Account acc : accList){
                    if(parentChildAccMap.containskey(acc.parentID))
                        parentChildAccMap.get(acc.parentID).add(acc);
                    else
                        parentChildAccMap.put(acc.parentID, new list<account>{acc}); //Initializing and adding element to the Map
                }
                for(account acc:scope){
                    if(parentChildAccMap != NULL && parentChildAccMap.containsKey(acc.id)){
                        integer totalEmp = 0;
                        list<account> lstChildAcc = parentChildAccMap.get(acc.id);
                        for(account childAcc : lstChildAcc){
                            if(childAcc.TotalEmployees_reported__c != null){
                                totalEmp +=  integer.valueof(childAcc.TotalEmployees_reported__c);
                            }                           
                        }
                        account newAcc = new account(id= acc.id);
                        newAcc.Employees_KKnr__c = totalEmp;
                        finalUpdateAccount.add(newAcc);                     
                    }
                }
                if(!finalUpdateAccount.isEmpty())
                    update finalUpdateAccount;                
            }
            catch(exception e){
            }
        }
    global void finish(Database.BatchableContext BC){
    }
}