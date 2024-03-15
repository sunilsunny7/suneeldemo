/**
    About
    -----
    Description: Before update trigger on Task object
    Create date: March 2015

    Filters:
    -------
    1. Filters out all the related accounts to tasks of type Telefonmöte, Fysiskt möte or Webmöte with status Complete
            
    Update History
    --------------
    Created March 2015 - V.I
	Updated May 2015 - V.I removed purpose field on Task. Changed status name to Stängd.
	Updated May 2015 - V.I changed type of tasks to Telefonmöte, Fysiskt möte and Webmöte
	Updated Oct 2015 - V.I changed type of tasks to Telefon, Fysiskt and Web
    Updated Sep 2016 - A.N Merged functionality into TaskTriggerHandler
    
    Issues / TODOs

    DELETE THIS CLASS
    -------------- 
    
*/

trigger TaskBeforeUpdate on Task (before update) {
    
    /* Merged into TaskTriggerHandler method updateAccountContactedDate
    //Creating Lists and Maps based on filter criteria
    Map<Id,DateTime> targetedAccounts = new Map<Id,DateTime>();
    
  	//Filter 1
    for (Task t : Trigger.new){     
        if(t.Status != null && t.Type != null){
            if(Trigger.oldMap.get(t.Id).Status != 'Stängd'){
                if(t.Status == 'Stängd' && (t.Type == 'Telefon' || t.Type == 'Fysiskt' || t.Type == 'Web')){
                    if(t.AccountId != null){
                        if(t.ActivityDate != null){
                        	targetedAccounts.put(t.AccountId,t.ActivityDate);
                        }
                        else{
                            targetedAccounts.put(t.AccountId,System.now());
                        }
                    }
                }
            }
        }
    }
    
    
    //Execute logic in a service class 

    //Filter 1          
    System.debug('Size of filter 1 result in TaskBeforeUpdate trigger: ' + targetedAccounts.size());
    if(!targetedAccounts.isEmpty()){
        AccountServiceClass.accountTargeted(targetedAccounts);
    }
    */
    
}