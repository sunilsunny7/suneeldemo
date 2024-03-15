/**
About
-----
Description: OppTeamMemberHandler Class for Opportunity Team functionality in Apex
** Covered under Test Class 'Test_ChatterUtilities'
Create date: Aug 2016

Update History
--------------
Created Aug 2016 - N.G Created
Updated Sep 2016 - A.N Refactored the postToUserChatter method
Updated Sep 2016 - A.N Merged existing functionality in OpportunityTeamMemberAfter trigger into the new method createSolutionSalesOutcomeRecords
Updated Feb 2017 - S.M added a new method called SetUserRoleOnOpportunityTeam.
Issues / TODOs
--------------  

*/

public class OppTeamMemberHandler {

    // When system tests are running, the ConnectAPI is only available if SeeAllData=true.
    // We therefore do not post the ChatterPosts when unit tests are running unless this is specifically stated (by setting testChatterPosts = true)
    @TestVisible private static Boolean testChatterPosts = false;
    
    //Otm1 was used to get the user who created the opportunity team member.
    list<OpportunityTeamMember> otm1= new list<OpportunityTeamMember> ();
    
    /* * * * * * * * * * * * * * * * * * * * * */
    /* * OppTeamMemberHandler Trigger Calls  * */
    /* * * * * * * * * * * * * * * * * * * * * */

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    

    public OppTeamMemberHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    //Author S.M Merged the Before Insert, Before Update Trigger
    
     public void OnBeforeInsert(List<OpportunityTeamMember> newList){
        System.debug('OppTeamMemberHandler.OnBeforeInsert starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        
        SetUserRoleOnOpportunityTeam(newList);
    }
        
        public void OnBeforeUpdate(List<OpportunityTeamMember> newList){
        System.debug('OppTeamMemberHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        
        SetUserRoleOnOpportunityTeam(newList);
    } 
    public void OnAfterInsert(List<OpportunityTeamMember> newList){
        System.debug('OppTeamMemberHandler.OnAfterInsert starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);

        createSolutionSalesOutcomeRecords(newList);
        
        
        postToUserChatter(newList);     
    }
    
    public void OnAfterUpdate(List<OpportunityTeamMember> newList){
        System.debug('OppTeamMemberHandler.OnAfterUpdate starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);

        postToUserChatter(newList);
    }
    
    public void OnAfterDelete(List<OpportunityTeamMember> oldList){
        System.debug('OppTeamMemberHandler.OnAfterDelete starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        
        createSolutionSalesOutcomeRecords(oldList);
    }

    /* * * * * * * * * * * * * * * * * * * * * * */
    /* * OppTeamMemberHandler Trigger Methods  * */
    /* * * * * * * * * * * * * * * * * * * * * * */

    // Author V.I / A.N - merged from OpportunityTeamMemberAfter-trigger
    // Delete and recreate 
    private static void createSolutionSalesOutcomeRecords(List<OpportunityTeamMember> otmList) {        
        Set<Id> oppIds = new Set<Id>();
        
        for(OpportunityTeamMember otm : otmList) oppIds.add(otm.OpportunityId);

        List<Opportunity> closedWonOpps = [SELECT Id, CloseDate, OwnerId, AccountId FROM Opportunity WHERE Id in : oppIds AND IsWon = true];

        if(!closedWonOpps.isEmpty()){
            SolutionsSalesOutcomeServiceClass.deleteExistingRecords(closedWonOpps);
            SolutionsSalesOutcomeServiceClass.createNewRecords(closedWonOpps);
        }
    }

    
    // Author S.M FEB 2017 
   // Merged the Before Trigger added a new method SetUserRoleOnOpportunityTeam
  //Add the User role to the opporuntiy team members
 
    private static void SetUserRoleOnOpportunityTeam(List <OpportunityTeamMember> otm2List )
    {
       Set<Id> setTeamMemberID = new Set<Id>();
        Map<Id, User> usrMap = new Map<Id,User>();
        for (OpportunityTeamMember otm2: otm2List)
        {
            setTeamMemberID.add(otm2.UserId); 
        }
        if(setTeamMemberID.size() > 0)  
        {
            usrMap = new Map<Id, User>([SELECT Id, User_Role__c FROM User WHERE Id IN :setTeamMemberId]);
        }
       
        //Getting the user role and Id to the Team member role and Team member user id on Opportunity teams.
        for (OpportunityTeamMember otm2:otm2List)
        {
            if(usrMap.size() > 0)
            {
                User usr = usrMap.get(otm2.UserId);           
                otm2.Team_Member_Role__c= usr.User_Role__c;
                otm2.Team_Member_User_ID__c = String.valueOf(usr.Id).substring(0,15);        
            }           
        }
  
    }   
    // Author N.G Aug 2016
    // Create Chatter posts when Users added to Opportunity Team and post on User's personal chatter
    private static void postToUserChatter(List<OpportunityTeamMember> newList) { 
         if(RecursionHandler.isFirstRun()){         
        SEUtility.loadProfileMapId();
        Map<String,Id> mapofProfileId = SEUtility.profileIdMapName;
              
        string OppoteamCreatedBy= '';
        
        OppoteamCreatedBy = System.Label.IntegrationUser;
        Id SystemAdminId = mapofProfileId.get('System Administrator');
        system.debug('SystemAdminId:-'+SystemAdminId);
        List<OpportunityTeamMember> filteredOtmList = new List<OpportunityTeamMember>();
        
        
        
        // Author S.M June 2017
        //System Administrator is excluded from create chatter posts for bulk data work purpose.
        if(UserInfo.getProfileId()!=SystemAdminId)
        {
            if(OppoteamCreatedBy != Null) 
               {
        
        /* Opportunity owner will not get a notification when added to Opportunity team
        if the opportunity team member created by the integration user user will not get the chatter post*/
        //for(OpportunityTeamMember otm : [SELECT Id, UserId, OpportunityId, Opportunity.Name, Opportunity.OwnerID FROM OpportunityTeamMember WHERE Id in :newList]){
              
        for(OpportunityTeamMember otm : [SELECT Id, UserId,CreatedByID, OpportunityId, Opportunity.Name, Opportunity.OwnerID FROM OpportunityTeamMember WHERE Id in :newList])
        {
         if(otm.CreatedById != OppoteamCreatedBy){
                    
        if(otm.UserId != otm.Opportunity.OwnerID)
        {
           filteredOtmList.add(otm);
               }       
           }
       }
            
         
       if(filteredOtmList.isEmpty()) return;

        List<ConnectApi.BatchInput> chatterPosts = new List<ConnectApi.BatchInput>();

        for(OpportunityTeamMember otm: filteredOtmList){
            if(UserInfo.getProfileId()!=SystemAdminId)
            {
            
             ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
             ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
             ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
             ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
             ConnectApi.FeedElementCapabilitiesInput capability = new ConnectApi.FeedElementCapabilitiesInput();
             ConnectApi.LinkCapabilityInput link = new ConnectApi.LinkCapabilityInput();

             messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
             mentionSegmentInput.id = otm.UserId;
             messageBodyInput.messageSegments.add(mentionSegmentInput);
             textSegmentInput.text = 'lades till i affärsmöjlighetsteamet för: ';
             messageBodyInput.messageSegments.add(textSegmentInput);
             link.url = '/'+otm.OpportunityId;
             link.urlName = otm.Opportunity.Name;
             capability.link = link;
             feedItemInput.capabilities = capability;            
             feedItemInput.body = messageBodyInput;
             feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
             feedItemInput.subjectId = otm.OpportunityId;
             ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
             chatterPosts.add(batchInput);
        }
    }
        if(!chatterPosts.isEmpty() && (!Test.isRunningTest() || testChatterPosts)){
            System.debug('OppTeamMemberHandler.postToUserChatter number of new feed items: ' + chatterPosts.size());
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPosts);            
        }

    }
    }
}
}
}