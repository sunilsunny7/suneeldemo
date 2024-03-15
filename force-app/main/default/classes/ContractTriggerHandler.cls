/**
About
-----
Description: ContractTriggerHandler on Contract
Update History:
MC Drop 1: MCSTO 433 : PP : Updated Class to add Framework Agreement and Service Agreement inside the custom field Contract Record Type 
MC Drop 1: PP : Updated Class with Method 'updateEndDate' to replace workflow with apex, updates existing record type with End Date from Start Date and Contract Term
SALEF 2260 : PP : Updated method - 'updateEndDate' to include Fiber Contract Record Type in end date auto calciulation
SALEF - 3266 : PS - Fiber Contract Extension - fiberContractExtension()
17.11.2022 [Tomass Brazovskis] SALEF-7685 - Added Cygate_Contract to updatecontractrecType. HARDCODED - Temporary.
12/01/2023 [Lokesh Singh]- MCSTO-11791 - -- AC3 Send email when Single-Case been sent to TUPP
--------------
*/
public without sharing class ContractTriggerHandler{
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    boolean recursiv = false;
    public static final String TUPP_STATUS = 'Active';
    private static final String INTERFACE_NAME = 'CreateSingleCase';
    
    public ContractTriggerHandler(boolean isExecuting,integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnbeforeInsert(List<Contract> newList,Map<Id,Contract>newMap){
        For(Contract conObj : newList){
            if(String.isBlank(conObj.Contract_Record_Type__c) && String.isNotBlank(conObj.recordtypeId)){
                conObj.Contract_Record_Type__c = Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosById().get(conObj.recordtypeId).getName();
            }
        }
        checkTypeOfAddress(newList,null);
        updateEndDate(newList,NewMap,null,null);
        updateStatus(newList);
    }
    public void onBeforeUpdate(List<Contract> newList,Map<Id,Contract> newMap,List<Contract> oldList, Map<Id,Contract> oldMap){
        updatecontractrecType(newList);
        updateEndDate(newList,newMap,oldList,oldMap);
        fiberContractExtension(newList,newMap,oldmap);
        checkTypeOfAddress(newList,oldMap);
        List<Id> conList = new List<Id>();
        List<Id> conList2 = new List<Id>();
        //Developer: Sanjoli 25-04-2022
        for(contract con:newList){
            if(con.Status == 'Signed' && (newMap.get(con.Id).status!=oldMap.get(con.Id).Status) && con.Agreement_Nr__c != null && con.Contract_Record_Type__c == 'Ramavtal'){
                conList.add(con.Id);
            }
            if(con.Status == 'Signed' && (newMap.get(con.Id).status!=oldMap.get(con.Id).Status) && con.Agreement_Nr__c == null && con.Contract_Record_Type__c == 'Ramavtal'){
                conList2.add(con.Id);
            }            
        }
        if(conList.size()>0){ 
            invokeSetUtilizer(conList, newMap, oldList, oldMap);  
        }
        if(conList2.size()>0){
            updateUtilizerContractStatus(conList2);
        }
    }
    
    public void onAfterUpdate(List<Contract> newList,Map<Id,Contract> newMap,List<Contract> oldList,Map<Id,Contract> oldMap){
        //updateFAEndDate(newList, newMap, oldList, oldMap);
        //checkFAStatus(newList, newMap, oldList, oldMap);
        unlockQuote(newList);
        updatePrimaryQuote(newList,newMap,oldmap);
        UpdateOpportunityStatus(newList,oldMap);
        List<contract> lockContractList = new List<Contract>();
        List<contract> unlockContractList = new List<Contract>();
        list<Id> conList = new List<Id>();
        // handling recursion here
        if(RecursionHandler.afterUpdateFlag){
            updateUtilizerInAccount(newList,newMap,oldmap);
            RecursionHandler.afterUpdateFlag = false;
        }
        List<Account> accToUpdate = new List<Account>();
        for(Contract con : newList){
            if(con.Status == 'Signed' && (newMap.get(con.Id).status!=oldMap.get(con.Id).status)&& con.Contract_Record_Type__c =='Ramavtal'){
                conList.add(con.Id);
            }
            /*if(con.Status == 'Draft' && con.Customer_Unique_Terms__c != null){
                Contract oldCon = oldMap.get(con.Id);
                If(con.Customer_unique_terms_Approved__c == false && con.Customer_Unique_Terms__c != oldCon.Customer_Unique_Terms__c){
                    lockContractList.add(con);
                }
                if(oldCon.Customer_unique_terms_Approved__c == false && con.Customer_unique_terms_Approved__c == true){
                    unlockContractList.add(con);
                }
            }*/
            If((con.Status == 'Signed' || con.Status == 'Active') && con.RecordTypeId == SeUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT) && con.TeliaSE_MC_sales_flow_identifier__c == 'New Sales' && con.CustomerSignedDate != null && con.account.Is_MC_customer__c != true){
                Account updateAcc = new Account(Id = con.AccountID);
                updateAcc.Is_MC_customer__c = true;
                updateAcc.MC_Customer_Date__c = con.CustomerSignedDate;
                accToUpdate.add(updateAcc);
            }
        }
        if(conList.size()>0 )
        {
            invokeEmail(conList, newMap, oldList, OldMap);       
        }
        if(lockContractList.size() > 0){
            Approval.lock(lockContractList, false);
        }
        if(unlockContractList.size() > 0){
            Approval.unlock(unlockContractList, false);
        }
        if(accToUpdate.size() > 0){ update accToUpdate; }
        matchNumberFields(newList, oldMap);
        updateCSMExistingCustomerValue(newList, oldMap);
        
        SendEmailSmartConnect(newList,OldMap);
        
        
    }
    //Added as part of Fiber Retention(LTAT-8369)
    public void updatePreviousContractStatus(List<Contract> newConList,Map<Id,Contract> oldMap,Map<Id,Contract> newMap){  
        List<Contract> contracts = new List<Contract>();
        Contract prevContract = new Contract();
        for(Contract c:newConList){
            if(c.Contract_Record_Type__c == 'Connected & Smart Building' && oldMap.get(c.id).Status =='Signed' && newMap.get(c.id).Status =='Active'&& c.TeliaSE_Fiber_Previous_ContractId__c !=null ){
                prevContract = new Contract();
                prevContract.id = c.TeliaSE_Fiber_Previous_ContractId__c;
                prevContract.Status ='Cancelled';
                prevContract.Reason_for_Cancellation__c = 'Nytt avtal med Telia';
                contracts.add(prevContract);
            }
        }
        if(contracts.size() >0){
            Database.update(contracts,false) ;
        } 
    }
    public void onAfterInsert(List<Contract> newList, Map<Id,Contract> newMap,List<Contract> oldList,Map<Id,Contract> oldMap){
        cloneContractLineItems(newList);
        matchNumberFields(newList,null);
        updateCSMExistingCustomerValue(newList,oldMap);
    }
    public void OnAfterDelete(List<Contract> oldList, Map<Id,Contract> oldMap){
        updateCSMExistingCustomerValue(null,oldMap);
    }
    // Updating Contract Record Types
    public void updatecontractrecType(List<Contract>newList){
        for(Contract con : newList){
             if(con.Contract_Record_Type__c == 'Telia Konkurrentavtal'){
                con.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.Contract_TELIA);
            }else if(con.Contract_Record_Type__c == 'Teliaavtal'){
                con.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.Contract_TELIA_Avtal);
            }else if(con.Contract_Record_Type__c == 'Cygate Contract'){ // SALEF-7685
                con.RecordTypeId = SEUtility.getRecordTypeId('Cygate_Contract');
            }
        }
    }
    public void updateStatus(List<Contract>newList){
        for(contract cont : newList){
            if(cont.isClone()){
                cont.Status = 'Draft';
            }
        }
    }
    public void cloneContractLineItems(List<Contract>newList){
        Map<id,id> clonedOriginalIDs = new Map<id,id>();
        for(contract cont : newList){
            if(cont.isClone()){ clonedOriginalIDs.put(cont.getCloneSourceId(),cont.id);  }
        }
        if(!clonedOriginalIDs.keySet().isEmpty()){ 
            Map<String,Schema.SObjectField> mapFields = vlocity_cmt__ContractLineItem__c.getSObjectType().getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>();
            for(String fieldName : mapFields.keySet()){
                fieldNames.add(fieldName);
            }
            Set<id> originalContractsIDs = clonedOriginalIDs.keySet();
            String query =
                ' SELECT ' +
                String.join(fieldNames, ',') +
                ' FROM vlocity_cmt__ContractLineItem__c ' +
                ' WHERE ' +
                ' vlocity_cmt__ContractId__c IN :originalContractsIDs';
            list<vlocity_cmt__ContractLineItem__c> clonedContractLineItems = Database.query(query).deepClone();
            if(clonedContractLineItems.size() > 0){
                for(vlocity_cmt__ContractLineItem__c clonedContractLineItem : clonedContractLineItems){
                    clonedContractLineItem.vlocity_cmt__ContractId__c = clonedOriginalIDs.get(clonedContractLineItem.vlocity_cmt__ContractId__c);
                }
                insert clonedContractLineItems;
            }
        }
    }
    /*
// Method to check if FA's end date is greater than or equal to it's subsequent SA's end date
private void updateFAEndDate(List<Contract> newList, Map<Id,Contract> newMap, List<Contract> oldList, Map<Id,Contract> oldMap)
{
List<Contract> contracts = new List<Contract>();
List<Contract> parents=new List<Contract>();
Set<Id> ids=new Set<Id>();
//Getting ids for Frame Contract
Id recordTypeId=Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().get(SEUtility.FRAMEAGREEMENT).getRecordTypeId();  
//Adding the SA's parent contracts(FA) to list
for(Contract con:newList)
{
ids.add(con.vlocity_cmt__ParentContractId__c);
if(con.RecordTypeId==SEUtility.getRecordTypeId(SEUtility.Contract_SERVICE_AGREEMENT)){
contracts.add(con);
}

}
// SOQL statement to get the id, enddate 
Map<Id,Contract> parentObj=new Map<Id,Contract>([select id,vlocity_cmt__ParentContractId__c,EndDate,ContractTerm from Contract where id in :ids]);
//Iterating the filtered Contract list   
for(Contract con:contracts)
{

Contract parentCon = parentObj.get(con.vlocity_cmt__ParentContractId__c);
if(parentCon !=null)
{
//If SA's end date comes after FA's(parent's) end date, the end date of FA will be equal to end date of SA
if(con.EndDate > parentCon.EndDate)
{
parentCon.EndDate= con.EndDate;
parents.add(parentCon);
}
}

}
//Try catch block
if(parents.size() >0)
{
try{
update parents;
}catch(exception e){

}

}

}
*/
    /*
public void checkFAStatus(List<Contract> newList, Map<Id,Contract> newMap, List<Contract> oldList, Map<Id,Contract> oldMap)
{
List<Contract> faContracts=new List<Contract>(); 
Map<Id,Id> integrationIds=new Map<Id,Id>();
for(Contract con:newList)
{
Id recordTypeId=Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().get(SEUtility.FRAMEAGREEMENT).getRecordTypeId();
if(oldMap.get(con.id).status=='Signed' && newMap.get(con.id).status=='Active' && newMap.get(con.Id).RecordTypeId==recordTypeId)
{
faContracts.add(con);
}
}
if(faContracts.size()>0)
{
List<Contract> saContracts=[select id,Status,vlocity_cmt__ParentContractId__c from Contract where vlocity_cmt__ParentContractId__c =:faContracts and Status=:System.Label.TeliaSE_Draft];
List<vlocity_cmt__ContractLineItem__c> saItems = [SELECT vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.vlocity_cmt__ParentContractId__c,Name FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__ContractId__c IN : saContracts AND Name IN('Jobbmobil All-In Plus','Jobbmobil Total')];
for(vlocity_cmt__ContractLineItem__c item: saItems)
{
integrationIds.put(item.vlocity_cmt__ContractId__r.vlocity_cmt__ParentContractId__c,item.vlocity_cmt__ContractId__c);
}

//Call MADAM by getting Service AgreementId from integrationIds Map by passing Key value is Frame Agreement id
for(Id serviceAgreementId:integrationIds.values())
{
TeliaSE_MADAMIntegrationsWS.createRequest(serviceAgreementId);
}
}
}*/
    private void updateEndDate(List<Contract> newList,Map<Id,Contract> newMap, List<Contract> oldList, Map<Id,Contract> oldMap){
        list<Contract> conList = new List<contract>();
        for(contract con : newList){
            /*adding contract record type custom field for Fiber since Fiber record type developer name is shared with Opportunity and does not give proper result when queried*/
            if(con.RecordTypeId == SeUtility.getRecordTypeId(SEUtility.Contract_TELIA) || con.RecordTypeId == SeUtility.getRecordTypeId(SEUtility.Contract_TELIA_Avtal) || con.RecordTypeId == SeUtility.getRecordTypeId(SEUtility.Contract_CYGATE) ||
               con.RecordTypeId == SeUtility.getRecordTypeId(SEUtility.Contract_CYGATE_Avtal) || con.Contract_Record_Type__c == system.label.Real_Estate_FIber_Contract_RT){
                   if (oldMap == null || (con.Startdate != oldmap.get(con.Id).StartDate) || (con.ContractTerm != oldMap.get(con.Id).ContractTerm)){
                       conList.add(con);
                   }
               }
        }
        for(contract con : conList){
            if(con.StartDate != Null){
                date conStartDate = con.StartDate;
                date conM1StartDate = conStartDate.addDays(-1);
                if(con.contractTerm != Null){
                    con.EndDate = conM1StartDate.addMonths(con.ContractTerm);
                }
            }
        }
    }
    private static void unlockQuote(List<Contract> newList){
        List<Id> ids = new List<Id>();
        for (Contract con : newList){
            //if(con.Status == 'InActive')
            if(con.status == 'Cancelled'){
                ids.add(con.Id);
            }
        }if(ids.size() > 0){
            List<Account> accountList = new List<Account>();
            list <Account> accList = [select id from Account where FA_Contract__c = :ids];
            list<Utilizer_Contract_Relationship__c> utililzerList = [select AccountId__c,ContractNumber__c from Utilizer_Contract_Relationship__c where Status__c = 'Aktiv' and AccountId__c in :accList and ContractNumber__r.Contract_Record_Type__c = 'Ramavtal' and ContractNumber__r.status = 'Active'];
            Map<Id,Id> accountToContractUtilizer = new Map<Id,Id>();
            for (Utilizer_Contract_Relationship__c utilizer: utililzerList){
              accountToContractUtilizer.put(utilizer.AccountId__c,utilizer.ContractNumber__c);
            }
            for(Account acc : accList){
              
                if(accountToContractUtilizer.get(acc.Id) != null){
          acc.FA_Contract__c = accountToContractUtilizer.get(acc.Id);
                  acc.TeliaSE_Utilzer_Role__c = 'Utilizer';
                  accountList.add(acc);                    
                }
                else{
                  acc.FA_Contract__c = null;
                  acc.TeliaSE_Utilzer_Role__c = null;
                  accountList.add(acc);
                }
            }if(accountList.size() > 0){
                update accountList;
            }
        }
    }
    private static void updatePrimaryQuote(List<Contract> newList,Map<Id,Contract> newMap,Map<Id,Contract> oldMap){
        List<Id> quoteIds = new List<Id>();
        List<Id> oldcontractIds = new List<Id>();
        Map<Id,Id> oldnewMap = new Map<Id,Id>();
        for(Contract con : newList){
            if(oldMap.get(con.Id).status == 'Signed' && newMap.get(con.Id).status == 'Active' && newMap.get(con.Id).TeliaSE_Type__c == 'Y' && con.Contract_Record_Type__c == 'Ramavtal' && !con.TeliaSE_Parent_Agreement__c.contains(con.ContractNumber)){
                quoteIds.add(con.vlocity_cmt__QuoteId__c);
                oldnewMap.put(con.vlocity_cmt__QuoteId__c,con.id);
            }
        }
        if(quoteIds.size()>0 || oldnewMap.size()>0){
            List<Quote> quotes = new List<Quote>();
            List<Contract> contracts = new List<Contract>();
            List<Account> accounts = new List<Account>();
            Map<Id, Id> oldnnewContractIds = new Map<Id, Id>();
            for(Quote quote : [select Id,TeliaSE_RenegotiatedAgreement__c from Quote Where id = :quoteIds]){
                oldcontractIds.add((Id) quote.TeliaSE_RenegotiatedAgreement__c);
                oldnnewContractIds.put((Id) quote.TeliaSE_RenegotiatedAgreement__c,oldnewMap.get(quote.id));
            }
            for(Contract con : [select status,vlocity_cmt__QuoteId__c from Contract where id = :oldcontractIds]){
                quoteIds.add(con.vlocity_cmt__QuoteId__c);
                con.status = 'Cancelled';
                con.TeliaSE_Reason_for_Cancellation__c = 'Re-negotiated';
                contracts.add(con);
            }
            for(Account utilizerAccount : [select id,FA_Contract__c from Account where FA_Contract__c = :oldnnewContractIds.keyset()]){
                utilizerAccount.FA_Contract__c = oldnnewContractIds.get(utilizerAccount.FA_Contract__c);
                accounts.add(utilizerAccount);
            }
            for(Quote quote : [select status,TeliaSE_Type__c from Quote where id = :quoteIds]){
                if(quote.TeliaSE_Type__c == 'Renegotiation'){
                    quote.TeliaSWE_Primary_Quote__c = true;
                }else{
                    quote.TeliaSWE_Primary_Quote__c = false;
                    quote.status = 'Cancelled';
                }
                quotes.add(quote);
            }
            if(accounts.size() > 0){
                update accounts;
            }if(quotes.size() > 0){
                update quotes;
            }if(contracts.size() > 0){
                update contracts;
            }
        }
    }
    //To extend the EndDate of Fiber Contract based on given number of years
    public void fiberContractExtension(List <Contract> newList,Map <Id,Contract> newMap,Map <Id,Contract> oldMap){
        if(RecursionHandler.isFirstRun()){
            Map<id,Contract> mapintval = new Map<id,Contract>();
            for(Contract con : newList){
                if(newMap.get(con.Id).status == 'Active' && con.Contract_Record_Type__c == system.label.Real_Estate_FIber_Contract_RT && oldMap.get(con.Id).Fiber_Contract_Extension_Period__c != newMap.get(con.Id).Fiber_Contract_Extension_Period__c && newMap.get(con.Id).Fiber_Contract_Extension_Period__c != null){
                    if(con.EndDate != null && con.StartDate != null){
                        con.EndDate = Date.newInstance(con.EndDate.year() + (con.Fiber_Contract_Extension_Period__c).intValue(), con.EndDate.month(), con.EndDate.day());
                        con.ContractTerm = con.StartDate.monthsBetween(con.enddate);
                        con.Contract_Term_Years__c = con.StartDate.monthsBetween(con.enddate) / 12;
                    }
                }
            }
        }
    }
    private static void updateUtilizerInAccount(List<Contract> newList,Map<Id,Contract> newMap,Map<Id,Contract> oldMap){
        String newStatus = '',oldStatus = '',contractId = '';
        Id accountId,activeContractId;
        for(Contract c : newList){
            newStatus = c.Status;
            accountId = c.AccountId;
            contractId = c.Id;
        }
        List<Account> accList = new List<Account>();
        List<Contract> idList = oldMap.values();
        for(Contract id1 : idList){
            oldStatus = id1.Status;
        }
        if(!newStatus.equals(oldStatus) && newStatus == 'Active'){
            for(Utilizer_Contract_Relationship__c utilizier : ([select AccountId__c from Utilizer_Contract_Relationship__c where Status__c = 'Aktiv' and ContractNumber__c = :contractId and ContractNumber__r.Contract_Record_Type__c = 'Ramavtal'])){
                Account a = new Account();
                a.Id = utilizier.AccountId__c;
                a.FA_Contract__c = contractId;
                if(utilizier.AccountId__c == accountId) a.TeliaSE_Utilzer_Role__c = 'Owner'; else a.TeliaSE_Utilzer_Role__c = 'Utilizer';
                accList.add(a);
            }    
        }
        
        Set<Account> accListSet = new Set<Account>();
        List<Account> finalaccList = new List<Account>();
        accListSet.addall(accList);
        finalaccList.addall(accListSet);
        List<Contract> activeContract = [select Id from Contract where AccountId = :accountId and status = 'Active'];
        List<Account> activeUtilizerUpdateList = new List<Account>();
        Set<Account> activeUtilizerUpdateSet = new Set<Account>();
        List<Account> finalactiveUtilizerUpdateList = new List<Account>();
        
        if(activeContract.size()>0){
            activeContractId = activeContract[0].Id;
            for(Utilizer_Contract_Relationship__c utAcc : ([select AccountId__c, Status__c from Utilizer_Contract_Relationship__c where ContractNumber__c = :activeContractId and (Status__c = 'Aktiv' OR Status__c = 'PendingActive') and ContractNumber__r.Contract_Record_Type__c = 'Ramavtal'])){
                Account accounts = new Account();
                accounts.Id = utAcc.AccountId__c;
                accounts.FA_Contract__c = activeContractId;
                if(utAcc.AccountId__c == accountId) accounts.TeliaSE_Utilzer_Role__c = 'Owner'; else accounts.TeliaSE_Utilzer_Role__c = 'Utilizer';
                activeUtilizerUpdateList.add(accounts);   
            }
        }
        activeUtilizerUpdateSet.addAll(activeUtilizerUpdateList);
        finalactiveUtilizerUpdateList.addAll(activeUtilizerUpdateSet);
        if(finalaccList.size() > 0){
            update finalaccList;
        }else if(finalactiveUtilizerUpdateList.size() > 0){
            update finalactiveUtilizerUpdateList;
        }else if(!newStatus.equals(oldStatus) && newStatus != 'Active'){
        }
    }
    private static void UpdateOpportunityStatus(List<Contract> newList, Map<Id,Contract> oldMap){
        List<Id> ids = new List<Id>();
        for(Contract con : newList){
            if(con.status == 'Signed' && con.Contract_Record_Type__c == system.label.Real_Estate_FIber_Contract_RT && oldMap.get(con.id).status != 'Signed'){
                ids.add(con.vlocity_cmt__OpportunityId__c);
            }
        }
        if(ids.size()>0){
            List<Opportunity> opportunityList = new List<Opportunity>();
            for(Opportunity opp : [select id,StageName from Opportunity where id = :ids]){
                opp.StageName = 'Vunnen';
                opportunityList.add(opp);
            }
            if(opportunityList.size() > 0){
                update opportunityList;
            }
        }
    }
    //Drop 3: 
    //Method to check when contract is cancelled, the FAContract field is not empty if an active contract exists for the same account
    public void checkActiveContract(Contract con){
        String accountId = con.AccountId;
        List<Contract> conList = [Select id from contract where AccountId = :accountId and RecordType.Name = 'Ramavtal' and status = 'Active'];
        if(conList != null && conList.size() > 0){
            Account a = new Account();
            a.id = accountId;
            a.FA_Contract__c = conList[0].id;
            a.TeliaSE_Utilzer_Role__c = 'Owner';
            update a;
        }
    }
    public static void checkTypeOfAddress(List<Contract> newList,Map<Id,Contract> oldMap){
        Set<Id> opportunityIds = new Set<Id>();
        for(Contract conObj : newList){
            if(Trigger.isInsert && conObj.vlocity_cmt__OpportunityId__c != null){
                opportunityIds.add(conObj.vlocity_cmt__OpportunityId__c);
            }else if(
                conObj.vlocity_cmt__OpportunityId__c != null && conObj.vlocity_cmt__OpportunityId__c != oldMap.get(conObj.Id).vlocity_cmt__OpportunityId__c ){
                    opportunityIds.add(conObj.vlocity_cmt__OpportunityId__c);
                }
        }
        if(opportunityIds.size() != 0){
            Map<ID,Opportunity> mapOpportunities = new Map<ID,Opportunity>([SELECT Id, Type_of_Address__c FROM Opportunity WHERE id IN :OpportunityIds AND RecordType.DeveloperName = 'Real_Estate_Fiber']);
            for(Contract conObj : newList){
                if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null){
                    conObj.Type_of_Address__c = mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Type_of_Address__c;
                }
            }
        }
    }
    public static void updateCSMExistingCustomerValue(List<Contract> newList,Map<Id,Contract> oldMap){
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
        if(newList !=null){
            for(Contract contract : newList){
                if(contract.Status == 'Active' && contract.Contract_Record_Type__c == System.Label.Real_Estate_FIber_Contract_RT){
                    Account acc = new Account(Id = contract.AccountId);
                    acc.C_SM_Existing_Customer__c = true;
                    accountsToUpdate.put(acc.Id, acc);
                }else if(oldMap != null && contract.Status != 'Active' && oldMap.get(contract.Id).Status == 'Active' && contract.Contract_Record_Type__c == System.Label.Real_Estate_FIber_Contract_RT){
                    Account acc = new Account(Id = contract.AccountId);
                    acc.C_SM_Existing_Customer__c = false;
                    accountsToUpdate.put(acc.Id, acc);
                }
            }
        }else{
            for(Contract contract : oldMap.values()){
                if(contract.Status == 'Active' && contract.Contract_Record_Type__c == System.Label.Real_Estate_FIber_Contract_RT){
                    Account acc = new Account(Id = contract.AccountId);
                    acc.C_SM_Existing_Customer__c = false;
                    accountsToUpdate.put(acc.Id,acc);
                }
            }
        }
        if(!accountsToUpdate.isEmpty()){
            Map<Id,List<Contract>> accWithContracts = new Map<Id, List<Contract>>();
            for(Account acc : [SELECT Id, C_SM_Existing_Customer__c, (SELECT Id, Status FROM Contracts) FROM Account WHERE Id= :accountsToUpdate.keySet()]){
                List<Contract> contractsList = new List<Contract>();
                for(Contract contract : acc.Contracts){
                    if(contract.Status == 'Active'){
                        contractsList.add(contract);
                    }
                }
                //If value already updated, don't update again
                if(accountsToUpdate.get(acc.Id).C_SM_Existing_Customer__c == acc.C_SM_Existing_Customer__c){
                    accountsToUpdate.remove(acc.Id);
                }else{
                    accWithContracts.put(acc.Id,contractsList);
                }
            }
            //Check if there are any other active contracts under same account, if yes, then do not update account
            for(Account acc : accountsToUpdate.values()){
                if(accWithContracts.get(acc.Id).size() >= 1 && acc.C_SM_Existing_Customer__c == false){
                    for(Contract contract : accWithContracts.get(acc.Id)){
                        if(contract.Status == 'Active'){
                            accountsToUpdate.remove(acc.Id);
                        }
                    }
                }
            }
        }
        if(!accountsToUpdate.isEmpty()){
            update accountsToUpdate.values();
        }
    }
    public static void matchNumberFields(List<Contract> newList,Map<Id,Contract> oldMap){
        Set<Id> opportunityIDs = new Set<Id>();
        for(Contract conObj : newList){
            if(conObj.vlocity_cmt__OpportunityId__c != null){
                if(Trigger.isInsert){
                    opportunityIds.add(conObj.vlocity_cmt__OpportunityId__c);
                }else if(conObj.Number_of_Households__c != oldMap.get(conObj.Id).Number_of_Households__c || conObj.Number_of_other_Ports__c != oldMap.get(conObj.Id).Number_of_other_Ports__c || conObj.Number_of_Ports__c != oldMap.get(conObj.Id).Number_of_Ports__c ||
                         conObj.Number_of_Premises__c != oldMap.get(conObj.Id).Number_of_Premises__c || conObj.Number_of_Facilities__c != oldMap.get(conObj.Id).Number_of_Facilities__c || conObj.Wished_delivery_date_not_guaranteed__c != oldMap.get(conObj.Id).Wished_delivery_date_not_guaranteed__c){
                             opportunityIds.add(conObj.vlocity_cmt__OpportunityId__c);
                         }
            }
        }
        if(opportunityIds.size() != 0){
            Map<ID,Opportunity> mapOpportunities = new Map<ID,Opportunity>([SELECT Number_of_other_Ports__c,Number_of_Households__c,Number_of_Ports__c,Number_of_Premises__c,Number_of_Facilities__c,Wished_delivery_date_not_guaranteed__c FROM Opportunity WHERE Id IN :opportunityIds AND RecordType.DeveloperName = 'Real_Estate_Fiber']);
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            for(Contract conObj : newList){
                if(Trigger.isUpdate){
                    oppsToUpdate.add(updatedOppOnUpdate(conObj,mapOpportunities,oldMap));
                }else if(Trigger.isInsert){
                    oppsToUpdate.add(updatedOppOnInsert(conObj,mapOpportunities));
                }
            }  
            if(!oppsToUpdate.isEmpty()){
                try{
                    update oppsToUpdate;
                }catch (Exception ex){
                    insert errorHandling(ex,'Exception','ContractTriggerHandler','Contract');
                }
            }
        }
    }
    public static vlocity_cmt__VlocityErrorLogEntry__c errorHandling(Exception ex,String errorType,String sourceName,String objectName){
        vlocity_cmt__VlocityErrorLogEntry__c errlog = new vlocity_cmt__VlocityErrorLogEntry__c(
            vlocity_cmt__ErrorType__c = errorType,
            vlocity_cmt__ErrorMessage__c = String.valueOf(ex.getmessage()),
            vlocity_cmt__SourceName__c = sourceName,
            vlocity_cmt__ObjectName__c = objectName
        );
        return errlog;
    }
    public static Opportunity updatedOppOnUpdate(Contract conObj,Map<Id, Opportunity> mapOpportunities,Map<Id, Contract> oldMap){
        Boolean needToUpdateOpp = false;
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Number_of_other_Ports__c != oldMap.get(conObj.Id).Number_of_other_Ports__c && conObj.Number_of_other_Ports__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_other_Ports__c ){
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_other_Ports__c = conObj.Number_of_other_Ports__c;
            needToUpdateOpp = true;
        }
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Number_of_Households__c != oldMap.get(conObj.Id).Number_of_Households__c && conObj.Number_of_Households__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Households__c){
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Households__c = conObj.Number_of_Households__c;
            needToUpdateOpp = true;
        }
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Number_of_Ports__c != oldMap.get(conObj.Id).Number_of_Ports__c && conObj.Number_of_Ports__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Ports__c){
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Ports__c = conObj.Number_of_Ports__c;
            needToUpdateOpp = true;
        }
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Number_of_Premises__c != oldMap.get(conObj.Id).Number_of_Premises__c && conObj.Number_of_Premises__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Premises__c){
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Premises__c = conObj.Number_of_Premises__c;
            needToUpdateOpp = true;
        }
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Number_of_Facilities__c != oldMap.get(conObj.Id).Number_of_Facilities__c &&
           conObj.Number_of_Facilities__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Facilities__c ){
               mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Facilities__c = conObj.Number_of_Facilities__c;
               needToUpdateOpp = true;
           }
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Wished_delivery_date_not_guaranteed__c != oldMap.get(conObj.Id).Wished_delivery_date_not_guaranteed__c && conObj.Wished_delivery_date_not_guaranteed__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Wished_delivery_date_not_guaranteed__c ){
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Wished_delivery_date_not_guaranteed__c = conObj.Wished_delivery_date_not_guaranteed__c;
            needToUpdateOpp = true;
        }
        if(needToUpdateOpp){
            return mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c);
        }else{
            return null;
        }
    }
    public static Opportunity updatedOppOnInsert(Contract conObj,Map<Id,Opportunity> mapOpportunities){
        Boolean needToUpdateOpp = false;
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Number_of_other_Ports__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_other_Ports__c ){
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_other_Ports__c = conObj.Number_of_other_Ports__c;
            needToUpdateOpp = true;
        } 
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Number_of_Households__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Households__c ) {
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Households__c = conObj.Number_of_Households__c;
            needToUpdateOpp = true;
        }
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Number_of_Ports__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Ports__c ) {
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Ports__c = conObj.Number_of_Ports__c;
            needToUpdateOpp = true;
        }
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Number_of_Premises__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Premises__c ){
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c)
                .Number_of_Premises__c = conObj.Number_of_Premises__c;
            needToUpdateOpp = true;
        }
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Number_of_Facilities__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Facilities__c ){ 
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Number_of_Facilities__c = conObj.Number_of_Facilities__c;
            needToUpdateOpp = true;
        }
        if(mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c) != null && conObj.Wished_delivery_date_not_guaranteed__c != mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Wished_delivery_date_not_guaranteed__c ){
            mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c).Wished_delivery_date_not_guaranteed__c = conObj.Wished_delivery_date_not_guaranteed__c;
            needToUpdateOpp = true;
        }
        if(needToUpdateOpp){
            return mapOpportunities.get(conObj.vlocity_cmt__OpportunityId__c);
        }else{
            return null;
        }
    }
    //Developer: Sanjoli 25-04-2022
    //MCSTO-8990: Long term Utilizer solution: This method invokes SetUtilizer API to sync DRAFT utilizer to Tupp when contract is signed.
    //In case of non mobile scenario we will sync utilizers to TUPP MADAM using this method.
    private void invokeSetUtilizer(List<Id> conList, Map<Id,Contract> newMap, List<Contract> oldList, Map<Id,Contract> oldMap){
        List<Utilizer_Contract_Relationship__c> utilcon= [SELECT id,contractnumber__c,status__c FROM Utilizer_Contract_Relationship__c where Status__c ='Draft' and contractnumber__c IN :conList];
        set<Id> UtilizerContractSet = new set<Id>();
        for(Utilizer_Contract_Relationship__c uc:utilcon){
            UtilizerContractSet.add(uc.contractnumber__c); //use set to store contract number instead 
        }
        for(Id con:conList){
            if(UtilizerContractSet.contains(con)){
                Map<String,Object> ipInput = new Map<String,Object>();
                Map<String,Object> ipOptions = new Map<String,Object>();
                Map<String,Object> ipOutput = new Map<String,Object>();
                /* Populating input map for the Integration Procedure*/
                String ContractId = con; 
                ipInput.put('ContractId',ContractId);
                ipInput.put('AddUtilizer',true);
                ContractTriggerHandler.setUtilizerAPI(JSON.serialize(ipInput),JSON.serialize(ipOptions),JSON.serialize(ipOutput),ContractId);
            }
        }  
    }
    
    //Developer: Sanjoli 25-04-2022
    @future(callout=true)
    public static void setUtilizerAPI(String ipInputstr,String ipOptionsstr,String ipOutputstr,String conId){
        Map<String,Object> ipInput = (Map<String,Object>)JSON.deserializeUntyped(ipInputstr);
        Map<String,Object> ipOptions = (Map<String,Object>)JSON.deserializeUntyped(ipOptionsstr);
        Map<String,Object> ipOutput = (Map<String,Object>)JSON.deserializeUntyped(ipOutputstr);
        String procedureName = 'TUPP_setUtilizers';
        ipOutput = (Map<String,Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
        ipOutput.put('ContractId',conId);
        String dataJson = Json.serialize(ipOutput);
        vlocity_cmt.DRProcessResult result = vlocity_cmt.DRGlobal.processObjectsJSON(dataJson, 'TeliaSE_setUtilizersStatusUpdate');
        Map<String,Object> resultMap = result.convertToMap();
    }
/*
* EPIC: LTAART-85 || Utilizer breakout_Scenario: Breakout and create own agreement
* This method is used to update the status of utilizerContractRelationship to 'Active' for contracts without Agreement number.
*/
    private void updateUtilizerContractStatus(List<Id> conList){
        List<Utilizer_Contract_Relationship__c> utilCon= [SELECT id FROM Utilizer_Contract_Relationship__c WHERE Status__c ='Draft' and ContractNumber__c  IN :conList];
        List<Utilizer_Contract_Relationship__c> utilizerContractList = new List<Utilizer_Contract_Relationship__c>();
        for(Utilizer_Contract_Relationship__c uc:utilCon){
            uc.Status__c = 'Aktiv';
            utilizerContractList.add(uc);
        }
        if(utilizerContractList.size()>0){
            update utilizerContractList;
        }  
    }
    
    public Static void invokeEmail(List<Id> conList, Map<Id,Contract> newMap, List<Contract> oldList, Map<Id,Contract> oldMap){ 
        List<vlocity_cmt__ContractLineItem__c> CLI=[select id,Name,TeliaSE_Product_Object_Type__c,vlocity_cmt__ContractId__c,vlocity_cmt__ProductCode__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c IN :conList AND TeliaSE_MasterQuote__c != true AND ((TeliaSE_Product_Object_Type__c ='Smart Connect Offer Spec'AND vlocity_cmt__ProductCode__c ='SC_TRAINING_GUIDED') OR (TeliaSE_Product_Object_Type__c ='TouchPoint Plus Offer Spec' AND TeliaSE_ParentItemId__c = null  AND (vlocity_cmt__ContractId__r.TeliaSE_MC_sales_flow_identifier__c ='New Sales' OR (vlocity_cmt__ContractId__r.TeliaSE_MC_sales_flow_identifier__c !='New Sales' And (vlocity_cmt__LineStatus__c ='Added' OR vlocity_cmt__LineStatus__c ='Updated')))))];  
        // Removed (AND vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c>0) from above query for MCSTO-11678 - Smart Connect - Change requirement for sending Guided delivery mail
        // Updated the query for LTAART-424 - Added TPP checks 
        String orderEmailId= System.Label.MC_OrderEmailId;      
        Boolean scPresent = false, tppPresent = false;
        String contractID;
        for(vlocity_cmt__ContractLineItem__c clis:CLI){
            contractId = clis.vlocity_cmt__ContractId__c;
            scPresent = false;
            tppPresent = false;
            if(clis.TeliaSE_Product_Object_Type__c == 'Smart Connect Offer Spec'){
                scPresent= true;
            }else if(clis.TeliaSE_Product_Object_Type__c == 'TouchPoint Plus Offer Spec'){
                tppPresent =true;
            }
            Map <String, Object> ipInputstr = new Map <String, Object> ();  
            Map <String, Object> ipOptionsstr = new Map <String, Object> ();    
            Map <String, Object> ipOutputstr = new Map <String, Object> (); 
            ipInputstr.put('ContextId',contractId);  
			ipInputstr.put('SCpresent',SCpresent);
			ipInputstr.put('TPPPresent',TPPPresent);
            ipInputstr.put('OrderEmailId',orderEmailId);
            String procedureName = 'MC_SendEmailToOrderTeam';  // update the IP name
            vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInputstr, ipOptionsstr);     
        }             
    }
     //AC3 Send email when Single-Case been sent to TUPP
    public static void SendEmailSmartConnect(List<contract> lstContract, Map<id, Contract> oldContractMap){ 
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>(); 
        set<id> contractIDSet = new set<ID>();            
        for(Contract contrObj:lstContract){
          if(contrObj.TeliaSE_TUPP_Interface_Name__c !=null && contrObj.MC_SmartConnectCaseId__c!=null &&
             contrObj.MC_SmartConnectCaseId__c !=oldContractMap.get(contrObj.id).MC_SmartConnectCaseId__c
             && contrObj.TeliaSE_TUPP_Status__c ==TUPP_STATUS){
             contractIDSet.add(contrObj.id) ;          
          }
        }         
        for(Contract contrObj:[select id, name ,TeliaSE_TUPP_Interface_Name__c, ContractNumber,MC_SmartConnectCaseId__c,TeliaSE_TUPP_Status__c, account.name,owner.email from contract where id in :contractIDSet]){                       
                       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                       String[] toAddresses = new String[] {contrObj.owner.Email};                     
                       mail.setToAddresses(toAddresses);
                       String accountName = contrObj.Account.name;//accountNameMap.containskey(contrObj.id)?accountNameMap.get(contrObj.id):'';
                       mail.setSubject('Case '+contrObj.MC_SmartConnectCaseId__c+' skickat till TUPP för Smart Connect');
                       mail.setPlainTextBody('Hej \n \n' + 'Ett ärende för Smart Connect har nu skickats till TUPP för '+accountName+' avtal '+contrObj.ContractNumber+' med ärendernummer '+contrObj.MC_SmartConnectCaseId__c+ '\n \n Med vänliga hälsningar,'+'\n Telia Salesforce');//'Hi \n \n' + 'Welcome to Gavan''Hej Ett \n'+ <br/> 'case för Smart Connect har nu skickats till TUPP för Account Name avtal Contract Number med Caseid ' +contrObj.MC_SmartConnectCaseId__c+ ' Med vänliga hälsningar <br/> Telia Salesforce');
                       messages.add(mail);  
                   
               
        }
        if(!test.isRunningTest()){
        Messaging.sendEmail(messages);
        }

    }
}