public class AccountPlanValidationHandler{
 private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public AccountPlanValidationHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    public void OnbeforeInsert(List<Account_Plan1__c> newList,Map<ID, Account_Plan1__c> oldMap){
        checkForAccountPlanYear(newList,null);
     }
    public void OnbeforeUpdate(List<Account_Plan1__c> newList,Map<ID, Account_Plan1__c> oldMap){
        checkForAccountPlanYear(newList,oldmap);
     }
     
     //SALEF-1567 - Method to put a validation to have only one AcclountPlan per yer year for a Account.
    public void checkForAccountPlanYear(List<Account_Plan1__c> newList,Map<ID, Account_Plan1__c> oldMap){
        //Get the set of Accounts from newList of AccountPlan
        SET<ID> keys = new SET<ID>();
        for(Account_plan1__c acp : newList){
            keys.add(acp.Account_name__c);
        }
       List<Account> lAccPlan = new List<Account>();
       lAccPlan = [SELECT Id,name,(SELECT id,End_Year_of_AccountPlan__c from Account_Plans2__r where Status__c != 'Closed' AND End_Year_of_AccountPlan__c != NULL) from Account Where RecordType.developername =: SEUtility.ACC_RECTYPE_KK AND ID IN: keys];
       //Creating mapping of Account and list of respective Account Plans.
       Map<Id,List<Account_Plan1__c>> lAccPlanMap = new Map<Id,List<Account_Plan1__c>>();
       for(Account ap : lAccPlan){
          lAccPlanMap.put(ap.Id,ap.Account_Plans2__r);     
          }
       System.debug('**** Map:'+lAccPlanMap);
       System.debug('****## newList:'+newList);
      for(Account_Plan1__c accP : newList){
      System.debug('$$$$$ new list' +accP);
        if(lAccPlanMap.containsKey(accP.Account_name__c)){
        System.debug('#### Values' + accP.Account_name__c);
        //To Bypass this validation for the AccountPlan,the flag Skip_Trigger__c.AccPlanValiByPass(Custom Setting) needs to be set to True.
        for(Account_Plan1__c ap: lAccPlanMap.get(accP.Account_name__c)){
           if(accP.End_Year_of_AccountPlan__c == ap.End_Year_of_AccountPlan__c &&(oldMap == null || accP.End_Year_of_AccountPlan__c != oldMap.get(accP.Id).End_Year_of_AccountPlan__c) && !(Skip_Trigger__c.getValues('AccPlanValiByPass').PassMethod__c))
           {
           accP.addError(Label.AccountPlan_Validation_OneAccPlan_Per_Year);
           }
        }
        
      }
     }
   }
}