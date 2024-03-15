@isTest(SeeAllData=true) //we are using this to avoid errors due to Connect.Api
public with sharing class Test_OppTeamTriggerHandler  {
public static testmethod void test_PostToUserChatter(){

            System.debug('@@Test testPostToUserChatter');
            //Test_DataFactory.setUpOrg();
            
            List<User> smeUserTeam;
            List<Seller__c> smeSellerTeam;
            List<Yearly_Target__c> smeSellerteamYT;
            
            List<User> solutionUsers;
            System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            solutionUsers = Test_DataFactory.createSolutionUsers(3);
            for(User u : solutionUsers){
                u.Bypass_VR__c = true;
            }
            insert solutionUsers;
            
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            insert opp;
            
            List<OpportunityTeamMember> otm = new List<OpportunityTeamMember>();
            otm.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId = solutionUsers[1].Id));
            insert otm;
            
            String userId = Userinfo.getUserId();
            ConnectApi.FeedItemInput feedItem;
        
            System.runAs(new User(Id = userId)){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            feedItem = ChatterUtilities.createFeedItem(userId, 'Example Text');
            
            //System.runAs(Test_DataFactory.getByPassUser()){
            OppTeamTriggerHandler.PostToUserChatter(otm);
            OppTeamTriggerHandler oth = new OppTeamTriggerHandler();
            oth.OnAfterInsert(otm);
            oth.OnAfterUpdate(otm);
            }
            }
            
            }
            }