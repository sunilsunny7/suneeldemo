/*************
About
-----
Author: Varma Alluri
Create Date: 15.03.2017
Description: RequirementTriggerHandler on RequirementTrigger

**************/

public class RequirementTriggerHandler {
    public static void OnBeforeupdate(List<Requirement__c> newList, Map<ID, Requirement__c> oldMap ){         
        blankRequirement(newList,oldMap);
    } 
    
    /*************************************************************************************************
    * Author: Varma Alluri                                                                           *
	* Create Date: 20.03.2017                                                                        *
    * Description: RequirementTriggerHandler class will check if                                     *
	* the Related_Solution__c field is blank or not. If the Related_Solution__c field is blank       *
    * then it will make the Status field to Pågående and blank out the below Requirement fields.     *
	**************************************************************************************************/
    
    public static void blankRequirement(List<Requirement__c> newList,Map<Id,Requirement__c>oldMap){
        system.debug('newList:-'+newList);
        for(Requirement__c req: newList) {
            system.debug('oldmap:-'+oldMap.get(req.id).Related_Solution__c);
            if(req.Related_Solution__c == null && oldMap.get(req.id).Related_Solution__c !=null) { 
                req.Reference_Solution__c = false;
                req.Area__c = null;
                req.Platform__c = null;
                req.Article_Version_Number__c = null;
                req.Article_Title__c = null;
                req.Approval_Decision_Date_Time__c = null;
                req.Approval_Decision_Made_By__c = null;
                req.Status__c = 'Pågående';
                req.Requirement_fullfiled__c = null;
            }
        } 
    } 
}