/**
About
-----
Description: Before insert and after insert trigger validation handler on Opportunity
Create date: 18.09-2015

Update History
--------------
Created Sep 2015 - A.N - Created
Updated Oct 2015 - A.N - Validation for Avtalstecknare for large moved from stage Qualify to stage Offer Negotiation
Updated Apr 2016 - A.N - Validation for new Cygate Opp Record Types
Updated May 2016 - A.N Updated Contact role reference from Avropare to Bestellare
Updated Jun 2016 - A.N added new method isSecurityLevel2Account, updated validation so that if Security Level 2 Account do not throw error.
Updated Jun 2016 - A.N checkHasOpenActivities validation has been disabled, so commented out this validation. (Might add validation back in if sync issue (want to relate one activity to multiple opps) of activities between outlook/SF is resolved)
Updated July2016 - N.G - added new method smeAccOnlySmeOppRecTyp
Updated Sep 2016 - N.G - 'checkContactRoleActivitiesLarge' validation has been disabled, so commented out this validation. (Might add validation back in future)
Updated Sep 2016 - N.G - 'checkContactRolesLarge' one validation that need to have a Beslutsfattare as an Opportunity contact role has been disabled, so commented out this validation. (Might add validation back in future)
Updated Sep 2016 - A.N - Renamed method smeAccOnlySmeOppRecTyp to validateNoLargeOppsOnSmeAccs and refactored method
Updated Sep 2016 - N.G - Under validateStageChange- replaced 'Soho Standard Process' with 'PR Standard Process' as its more clear to define functionality because SME/DS and PR uses different opp record types.
Updated Sep 2016 - A.N - Replaced hard coded error messages with Custom Labels
Updated Jan 2020 - P.S - Commented PR related code in method-validateStageChange()
--------------  
NONE
*/

public class OpportunityValidationHandler {
    
    // OPPORTUNITY STAGE NAME STRING VALUES
    public static final String OPP_STAGE_ACTIVE_PROSPECT = 'Aktivt prospect';
    public static final String OPP_STAGE_RESTING_PROSPECT = 'Vilande prospect';
    public static final String OPP_STAGE_QUALIFY = 'Kvalificera';
    public static final String OPP_STAGE_DEVELOP = 'Utveckla';
    public static final String OPP_STAGE_SOLUTION = 'Ta fram lösning';
    public static final String OPP_STAGE_OFFER_NEGOTIATION = 'Offerera och förhandla';
    public static final String OPP_STAGE_CLOSE_DEAL = 'Sluta avtal';
    public static final String OPP_STAGE_WON = 'Vunnen';
    public static final String OPP_STAGE_03WON = '03 Vunnen';
    public static final String OPP_STAGE_LOST = 'Förlorad';
    public static final String OPP_STAGE_ABORTED = 'Avbruten';
    public static final String OPP_STAGE_DISAPPOINTED_PROSPECT = 'Avfärdat prospect';
    
    public static void validateInsert(List<Opportunity> newList){
        /*System.debug('@@ validationsDisabled: ' + SEUtility.isBypassValidation());
        if(SEUtility.isBypassValidation()) return;
        
        for(Opportunity opp : newList){
            if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD)){
                if(!(opp.StageName == OPP_STAGE_QUALIFY || (opp.isClosed && !(opp.isWon)))) {
                    opp.addError(Label.Opp_Validation_SME_Avtalstecknare_In_Stage_Kvalificera_Error_Msg);
                }
            }
        }*/
    }
    
    //Author NG, July 2016
    // Covered the standard validation rule 'SME_Accounts_Only_SME_Opp_Record_Types', because we reached the limit of referencing Account in Opportunity object.
    // Validation description: Prevents users from creating Large Opportunity Record Types on SME Accounts. It's important because it will prevent incorrect data in the Commit view.
    // Refactored A.N - Renamed method to validateNoLargeOppsOnSmeAccs as the old name "smeAccOnlySmeOppRecTyp" is misleading after
    // new record types have been introduced (i.e. SOHO and Cygate opps are allowed for SME accs). Restructured the logic.
    public static void validateNoLargeOppsOnSmeAccs(List<Opportunity> newList){
        if(SEUtility.isBypassValidation()) return;
        
        List<Opportunity> largeOpps = new List<Opportunity>();
        Set<Id> accIdsOnLargeOpps = new Set<Id>();
        for(Opportunity opp : newList){ 
            // Filter all Large opps +  Prospect where profile is not Cygate and not Business Admin and not SME and not PR and is not converted by lead
            
             //if(SEUtility.isLargeOpp(opp.RecordTypeId) || (opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT) && !SEUtility.isCygateUser(UserInfo.getProfileId()) && !SEUtility.isEnterpriseBusinessAdminUser(UserInfo.getProfileId())  && !SEUtility.isSmeUser(UserInfo.getProfileId())  && !SEUtility.isPRUser(UserInfo.getProfileId()))) {
               if((SEUtility.isLargeOpp(opp.RecordTypeId) && !SEUtility.isCygateUser(UserInfo.getProfileId()) && !SEUtility.isEnterpriseBusinessAdminUser(UserInfo.getProfileId())  && !SEUtility.isSmeUser(UserInfo.getProfileId())  && !SEUtility.isPRUser(UserInfo.getProfileId()))
               ||
               ((opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PROSPECT) && !SEUtility.isCygateUser(UserInfo.getProfileId()) && !SEUtility.isEnterpriseBusinessAdminUser(UserInfo.getProfileId())  && !SEUtility.isSmeUser(UserInfo.getProfileId())  && !SEUtility.isPRUser(UserInfo.getProfileId()) && !SEUtility.isHealthTeam(UserInfo.getUserRoleId()) && !SEUtility.isIBSTeam(UserInfo.getUserRoleId())&& !SEUtility.isBusinessConsultant(UserInfo.getUserRoleId()) && !SEUtility.isSOHODSUser(UserInfo.getProfileId())))
               
              ){
                  largeOpps.add(opp);
                  accIdsOnLargeOpps.add(opp.AccountID);
              }
        }
        
        if(!largeOpps.isEmpty()){
            Map<Id, Account> accMap = new Map<Id, Account>([SELECT Id, RecordtypeId FROM Account WHERE Id in: accIdsOnLargeOpps AND RecordtypeId =: SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME)]);
            for(Opportunity opp : largeOpps){ 
                
                if(accMap.containsKey(opp.accountID) && accMap.get(opp.AccountId).RecordtypeId == SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME) && (opp.Expected_Opportunity_Type__c == NULL  || opp.Expected_Opportunity_Type__c == '') && opp.RecordTypeId != SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_HW_LARGE_STANDARD))
                    opp.addError(Label.Opp_Validation_No_Large_Opp_On_SME_Acc_Error_Msg);   
            }
        }
        
    }
    
    public static void validateStageChange(List<Opportunity> newList, Map<ID, Opportunity> oldMap){
        System.debug('@@ validationsDisabled: ' + SEUtility.isBypassValidation());
        if(SEUtility.isBypassValidation()) return;
        
        List<Opportunity> oppsWithNewStage = filterOppsWithNewStage(newList, oldMap);
        
        for(Opportunity opp : oppsWithNewStage){
            // If account is Security Level 2 account, no contact role validation is required, so skip to next opportunity
            if(isSecurityLevel2Account(opp)) continue;
            
            // Record type 'Standard Process' or 'PR Standard Process'
            //if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD) || opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_PR_STANDARD)){
            if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_SME_STANDARD)){
                // Record type 'Large standard process'
            } else if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD) || opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_HW_LARGE_STANDARD)){
                if(opp.StageName == OPP_STAGE_DEVELOP || opp.StageName == OPP_STAGE_SOLUTION || opp.StageName == OPP_STAGE_OFFER_NEGOTIATION){
                    checkContactRolesLarge(opp, true, false, false);
                } else if(opp.StageName == OPP_STAGE_CLOSE_DEAL){
                    checkContactRolesLarge(opp, true, false, false);
                    //checkContactRoleActivitiesLarge(opp);
                } else if(opp.IsWon){
                 checkContactRolesLarge(opp, true, true, false);
                }
                // Record type 'Utökning process'
            } else if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_ENLARGEMENT)){
                if(opp.IsWon){
                    checkBestellareCriteria(opp);
                }
                // Record type 'Cygate Opportunity'
            } else if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD)){
                if(opp.StageName == OPP_STAGE_DEVELOP || opp.StageName == OPP_STAGE_SOLUTION || opp.StageName == OPP_STAGE_OFFER_NEGOTIATION){
                    checkContactRolesLarge(opp, false, false, true);
                    //checkHasOpenActivities(opp);
                } else if(opp.StageName == OPP_STAGE_CLOSE_DEAL){
                    checkContactRolesLarge(opp, false, true, false);
                    //checkHasOpenActivities(opp);
                } else if(opp.IsWon){
                    checkContactRolesLarge(opp, false, true, false);
                }
                // Record type 'Cygate Utökning'
            } else if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT)){
                if(opp.StageName == OPP_STAGE_CLOSE_DEAL || opp.IsWon){
                    checkBestellareCriteria(opp);
                }
                // Record type 'Telia Cygate Opportunity'
            } else if(opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_TELIA_CYGATE)){
                if(opp.StageName == OPP_STAGE_CLOSE_DEAL || opp.StageName == OPP_STAGE_WON || opp.IsWon){
                    checkContactRolesLarge(opp, false, true, false);
                }
            }
        }
        // In case the trigger will run recursively, reset the oppDataMap to ensure it is reloaded
        oppDataMap = null;
    }
    
    // OPPORTUNITY CONTACT ROLES STRING VALUES
    public static final String OPP_CR_DECISION_MAKER = 'Beslutsfattare';
    public static final String OPP_CR_AVTALSTECKNARE = 'Avtalstecknare';
    public static final String OPP_CR_BESTELLARE = 'Beställare';
    
    // Author AN, september 2015
    // Returns true if the opportunity contact role list has a contact of type roleName
    @TestVisible private static Boolean hasContactRole(Opportunity opp, String roleName){
        if(opp == null){ return false; }
        for(OpportunityContactRole ocr : opp.OpportunityContactRoles){
            if(ocr.Role == roleName){
                return true;
            }
        }
        return false;
    }
    
    // Author AN, June 2016
    // Security level 2 accounts should escape validation
    @TestVisible private static Boolean isSecurityLevel2Account(Opportunity opp){
        Opportunity oppWithData = oppDataMap.get(opp.Id);
        if(oppWithData.AccountId == null || oppWithData.Account.RecordTypeId == null){
            return false;
        }
        return SEUtility.isSecurityLevel2Account(oppWithData.Account.RecordTypeId);
    }
    
    // Author AN, september 2015
    // Checks that the opp has an 'Beställare' Contact Role, otherwise add error
    @TestVisible private static void checkBestellareCriteria(Opportunity opp){
        Opportunity oppWithData = oppDataMap.get(opp.Id);
        Boolean hasBestellare = hasContactRole(oppWithData, OPP_CR_BESTELLARE);
        if(!hasBestellare){
            if(opp.IsWon) opp.addError(Label.Opp_Validation_Add_Bestellare_Contact_Role_If_Won_Error_Msg);
            else opp.addError(Label.Opp_Validation_Add_Bestellare_Contact_Role_Error_Msg);
        }
    }

    // Author AN, september 2015
    // Checks that the opp has an 'Avtalstecknare' Contact Role, otherwise add error
    @TestVisible private static void checkContactRolesSME(Opportunity opp){
        /*Opportunity oppWithData = oppDataMap.get(opp.Id);
        Boolean hasAvtalstecknare = hasContactRole(oppWithData, OPP_CR_AVTALSTECKNARE);
        if(!hasAvtalstecknare){
            opp.addError(Label.Opp_Validation_SME_Avtalstecknare_In_Stage_Kvalificera_Error_Msg);
        }*/
    }

    // Author AN, september 2015
    // Checks that the opp has a 'Beslutsfattare' and 'Avtalstecknare' Contact Role when needed, otherwise add error
    // Can specify if we need just one of the specific contact roles, both of them or just either one.
    @TestVisible private static void checkContactRolesLarge(Opportunity opp, Boolean needsDecisionMaker, Boolean needsAvtalstecknare, Boolean needsEitherDecisionMakerOrAvtalstecknare){
        Opportunity oppWithData = oppDataMap.get(opp.Id);
        Boolean hasDecisionMaker = hasContactRole(oppWithData, OPP_CR_DECISION_MAKER);
        Boolean hasAvtalstecknare = hasContactRole(oppWithData, OPP_CR_AVTALSTECKNARE);
        
        // Comment NG Sep 2016: Commenting out this code as Opportunity Contact Role with Beslutsfattare validation have been disabled.
        //if(needsDecisionMaker && !hasDecisionMaker){
        //opp.addError('Du måsta lägga till en ' + OPP_CR_DECISION_MAKER + ' innan du går vidare till fas ' + opp.StageName);
        //}
        if(needsAvtalstecknare && !hasAvtalstecknare){
            opp.addError(Label.Opp_Validation_Add_Avtalstecknare_Contact_Role_Error_Msg);
        }
        if(needsEitherDecisionMakerOrAvtalstecknare && !hasDecisionMaker && !hasAvtalstecknare){
            opp.addError(Label.Opp_Validation_Add_Beslutsfattare_Or_Avtalstecknare_Error_Msg);
        }
    }
    
    //@1244: Default Stage update while changing recordtype to cygate affar
    public static void Opptystageupdate(List<Opportunity>newList,Map<Id, Opportunity> oldMap){
        Map<Id,String>mapofdevloperName = new Map<id,String>();
        mapofdevloperName.put(SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFFAR),SEUtility.OPP_RECTYPE_CYGATE_AFFAR);
        mapofdevloperName.put(SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFTERREG),SEUtility.OPP_RECTYPE_CYGATE_AFTERREG);
        mapofdevloperName.put(SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD),SEUtility.OPP_RECTYPE_CYGATE_STANDARD);                
        mapofdevloperName.put(SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT),SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT);                
        for(Opportunity opp: newList){
            if(mapofdevloperName.containsKey(opp.recordtypeId) && opp.recordtypeId != oldMap.get(opp.Id).recordtypeId && opp.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFFAR)){
                system.debug('update Stage:-'+opp.recordtypeId);
                opp.StageName = OPP_STAGE_QUALIFY;
            }
        }
    }
    // Author AN, september 2015
    // Filter out all Opp's that are new or has changed Stage
    @TestVisible private static List<Opportunity> filterOppsWithNewStage(List<Opportunity> newList, Map<ID, Opportunity> oldMap){
        List<Opportunity> oppList = new List<Opportunity>();
        Set<Id> oppIds = new Set<Id>();
        for(Opportunity opp : newList){
            if(opp.StageName != oldMap.get(opp.Id).StageName){
                oppList.add(opp);
                oppIds.add(opp.Id);
            }
        }
        if(oppIds.size() > 0){
            loadOpportunityData(oppIds);
        }
        return oppList;
    }
    
    // Author AN, september 2015
    // Load necessary data for all opps
    private static Map<Id, Opportunity> oppDataMap;
    private static void loadOpportunityData(Set<Id> oppIds){
        if(oppDataMap == null){
            oppDataMap = new Map<Id, Opportunity>([SELECT Id, AccountId, Account.RecordTypeId, 
                                                   (SELECT ContactId, Role FROM OpportunityContactRoles), 
                                                   (SELECT Id, WhoId, EndDateTime, EventWhoIds FROM Events),
                                                   (SELECT Id, WhoId, TaskWhoIds, IsClosed FROM Tasks)
                                                   FROM Opportunity WHERE Id in :oppIds]);
        }
    }
    
    public static void validatecygateoldrecordtype(List<Opportunity> newList, Map<Id, Opportunity> oldMap){
        if(SEUtility.isCygateUser(UserInfo.getProfileId()))
        {
            for(Opportunity opp : newList){
                if(!opp.isClosed){
                    if(oldMap.get(opp.Id).RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_STANDARD) || oldMap.get(opp.Id).RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT) || oldMap.get(opp.Id).RecordTypeId == SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFTERREG ))
                    {
                        if(opp.RecordTypeId != SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_CYGATE_AFFAR))
                        {
                            if(!Test.isRunningTest())
                            {
                                opp.addError(Label.Cygate_record_type_not_allowed_to_change);
                            }  
                        }                       
                    }
                }
            }
        }
    }

    // Author Mantas, march 17, 2021
    public static void checkFantasticFour (List<Opportunity> opportunities, Map<Id, Opportunity> oldMap) {
        List <Opportunity> oppToUpdate = new List <Opportunity> ();
        for (Opportunity opp : opportunities) {
            if (opp.Fantastic_4__c != oldMap.get(opp.Id).Fantastic_4__c && opp.Fantastic_4__c == true) {
                if (opp.OwnerId != UserInfo.getUserId()){
                    opp.addError(System.Label.Not_the_owner_of_opportunity);
                } else  {
                    oppToUpdate.add (opp);
                }
            }
        }
        if (oppToUpdate.size() > 0) {
            List<Opportunity> results = [SELECT OwnerId, Id FROM Opportunity WHERE OwnerId != NULL AND OwnerId = :UserInfo.getUserId() AND Fantastic_4__c = TRUE AND IsClosed = FALSE];
                Integer fantasticCounter = results.size() > 0 ? results.size() : 0;
                if (fantasticCounter + oppToUpdate.size() > 4) {
                    oppToUpdate[0].addError(System.Label.No_more_than_four_opps);
                }
        }
    }

    // Author AN, september 2015
    // Checks that all 'Beslutsfattare' on the opprtunity has closed activities, otherwise add error
    // Comment NG Sep 2016: Commenting out this code as Closed activity with Beslutsfattare validation have been disabled.
    
    /**@TestVisible private static void checkContactRoleActivitiesLarge(Opportunity opp){
Opportunity oppWithData = oppDataMap.get(opp.Id);
Set<Id> decisionMakerIds = new Set<Id>();

for(OpportunityContactRole ocr : oppWithData.OpportunityContactRoles){
if(ocr.Role == OPP_CR_DECISION_MAKER){
decisionMakerIds.add(ocr.ContactId);
}
}

for(Id dmId : decisionMakerIds){
Boolean hasActivity = false;
System.debug('searching events. # of evs' + oppWithData.Events.size());
for(Event e : oppWithData.Events){                
if(e.EndDateTime <= System.now()){ // Event is only closed if EndDateTime has passed
if(dmId == e.WhoId){
hasActivity = true;
break;
}
for(Id eWhoId : e.EventWhoIds){
if(dmId == eWhoId){
hasActivity = true;
break;
}
}
}
}

if(!hasActivity){
for(Task t : oppWithData.Tasks){
if(t.IsClosed){
if(dmId == t.WhoId){
hasActivity = true;
break;
}
for(Id tWhoId : t.TaskWhoIds){
if(dmId == tWhoId){
hasActivity = true;
break;
}
}
}
}
}

if(!hasActivity){
opp.addError('Du måste ha genomfört minst en aktivitet med alla beslutsfattarna innan du går vidare till fasen sluta avtal');
break; // Break the entire for loop. He have found one Beslutsfattare without closed activities, so do not need to check the rest.
}
}
}
**/
    
    // Author AN, february 2016
    // Checks if the opp has an open activity
    // Comment AN June 2016: Commenting out this code as open activities validation have been disabled.
    /*
private static void checkHasOpenActivities(Opportunity opp){
Opportunity oppWithData = oppDataMap.get(opp.Id);

for(Event e : oppWithData.Events){                
if(e.EndDateTime > System.now()){ // Event is only closed if EndDateTime has passed
return;
}
}

for(Task t : oppWithData.Tasks){
if(!t.IsClosed){
return;
}
}

opp.addError('Du måste ha en öppen aktivitet med startdatum i framtiden innan du går vidare till nästa fas');
}
*/
}