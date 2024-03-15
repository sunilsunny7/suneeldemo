/* Created Date - 02/12/2015*/

/*Update History
Mar 2015 - P.P comment AccountCountUpdate Method since it will not be called by the Trigger - AccountAfter. 
Need to keep this code in case it is needed in Future
Apr 2016 - S.S comment Calling of AccountCountUpdate Method is controlled by custom setting 
Sep 2016 - A.N Merged functionality into AccountTriggerHandler
*/

public class AccountRollUp{
    /* for one time update*/
    /*
    @future
    public static void AccountCountUpdate(Set<Id> AccountList){
    
        system.debug('inside the called method');
        List<Account> updateList = new List<Account>();
        List<Account> ParentList = [SELECT Id,Name FROM Account WHERE ID IN: AccountList];
        List<Account> childList = [SELECT ParentId FROM Account WHERE ParentID IN:AccountList];
        system.debug(childList);
        Map<Id,Boolean> AccountMap = new Map<Id,Boolean>();
        
        for(account acc:childList){
            if(!AccountMap.containskey(acc.ParentId)){
                system.debug('inside IF');
                AccountMap.put(acc.ParentId,True);
                system.debug('inside child condition');
            }
        }
        system.debug('AccountMap after childlist loop' + AccountMap);
        for(Account acc: ParentList){
            if(AccountMap.containsKey(acc.Id)){
            //Boolean accFlag = AccountMap.get(acc.Id);
                //if(accFlag = True){
                    system.debug('inside true condition');
                    acc.Has_Child_Account__c = True;
                    updateList.add(acc);
                //}
            }
        }
        if(updateList.size() >0){
        
            //database.update(updateList);
            if(test.IsRunningTest()){
                System.runAs(new User(Id = Userinfo.getUserId())) {
                    database.update(updateList);
                }
            }
            else{
                database.update(updateList);
            }
        }
    }
    
    @Future
    public static void AccountUpdateFlagTrue(Set<Id> AccountId){
        List<Account> updateList = new List<Account>();
        List<Account> ParentList = [SELECT Id,Has_Child_Account__c FROM Account WHERE ID IN:AccountId];
        for(Account acc:ParentList){
            if(acc.Has_Child_Account__c == False){
                acc.Has_Child_Account__c = True;
                updateList.add(acc);
            }
        }
        if(test.IsRunningTest()){
            System.runAs(new User(Id = Userinfo.getUserId())) {
                database.update(updateList);
            }
        }
        else{
            database.update(updateList);
        }
    }
    @future
    Public static void AccountUpdateFlagFalse(Set<Id> AccountId){
        List<Account> updateList = new List<Account>();
        Set<Id> parentIds = new Set<Id>();
        
        ExcludedRecords__c exclRecords = ExcludedRecords__c.getInstance('AcntRollUpExcludedRecords');
        String stringExclRecords = '';
        stringExclRecords = exclRecords.Excluded_Records_List__c;
        
        List<Id> exclRecordIds = new List<Id>(); 
        Set<Id> setExclRecordIds = new Set<Id>();
        if(stringExclRecords!= Null && stringExclRecords.length()>0){
            exclRecordIds = stringExclRecords.split(','); 
        }
        for(Id acId:exclRecordIds){
            setExclRecordIds.add(acId);
        }
        for(Id acId:AccountId){
            if(!setExclRecordIds.contains(acId)){
                parentIds.add(acId);
                system.debug('acId added'+ acId);
            }
        }
           
        Map<Id,Integer> accountMap = new Map<Id,Integer>();
        List<AggregateResult> childCount = [SELECT count(id) chCount,ParentId FROM Account WHERE ParentId IN : ParentIds Group BY ParentId];
        //for(Id aId:AccountId){
        for(Id aId:ParentIds){
            for(AggregateResult ar:childCount){
                
                system.debug('inside both for');
                List<Integer> ListCount  = new List<Integer>();
                ListCount.add((Integer)ar.get('chCount'));
                system.debug('ListCount details'+ListCount);
                Integer count = ListCount[0];
                accountMap.put(aid,count);
                
            }
                if(!(accountMap.containsKey(aid))){
                    system.debug('inside if');
                    Account ac = new Account(Id = aid);
                    ac.Has_Child_Account__c = False;
                    UpdateList.add(ac);
                }
        }
        
        if(test.IsRunningTest()){
            System.runAs(new User(Id = Userinfo.getUserId())) {
                database.update(updateList);
            }
        }
        else{
            database.update(updateList);
        }
        
            
    }*/
}