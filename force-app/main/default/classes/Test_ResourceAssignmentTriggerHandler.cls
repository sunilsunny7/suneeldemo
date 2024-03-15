/**
About
-----
Description: Test Class Test_ResourceAssignmentTriggerHandler on ResourceAssignment for ResourceAssignment
Create date: 18.09-2017

Update History
--------------
Created September 2017 - Vahraz Mostajir - new test methods for SAEN-2446


Issues / TODOs
--------------
*/

@IsTest
public class Test_ResourceAssignmentTriggerHandler {
    
    @testSetup static void setup() {
        Test_DataFactory.setUpOrg();
        Create_RHA_CS(); 
        
        System.runAs(Test_DataFactory.getByPassUser()){ 
            User salesRep = Test_DataFactory.createLargeUser();
            salesRep.FirstName = 'largeUser';
            insert salesRep;
            
            Seller__c seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;
            
            Account acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
            
            Opportunity opp = Test_DataFactory.createLargeOpportunity();
            opp.New_Sales__c = 0;
            opp.Continuation_Sales__c = 1;
            opp.AccountId = acc.Id;
            opp.Name = 'largeOpp';
            insert opp;         
            
            ResourceHeroApp__Resource__c res = (ResourceHeroApp__Resource__c)ResourceHeroApp__Resource__c.sObjectType.newSObject(null, true);
            res.Name = 'TestResource';
            res.ResourceHeroApp__Weekly_Target_Min_Hours__c = 0;
            res.ResourceHeroApp__Weekly_Target_Max_Hours__c = 40;
            res.ResourceHeroApp__User__c = salesRep.Id;           
            insert res;
        }
    } 
    
    public static void Create_RHA_CS()
    {
        //Ensure that our default opportunity lookup is configured
        ResourceHeroApp__RHA_Object_Translation__c ot = ResourceHeroApp__RHA_Object_Translation__c.getInstance('ResourceHeroApp__opportunity__c');
        if(ot == null) 
        {
            ResourceHeroApp__RHA_Object_Translation__c opp_ot = new ResourceHeroApp__RHA_Object_Translation__c();
            opp_ot.Name = 'ResourceHeroApp__opportunity__c';
            opp_ot.ResourceHeroApp__Object_Name__c = 'opportunity';
            opp_ot.ResourceHeroApp__Name_Field__c = 'Name';
            
            //Added check due to security scan
            if(Schema.sObjectType.ResourceHeroApp__RHA_Object_Translation__c.fields.Name.isCreateable()
               && Schema.sObjectType.ResourceHeroApp__RHA_Object_Translation__c.fields.ResourceHeroApp__Object_Name__c.isCreateable()
               && Schema.sObjectType.ResourceHeroApp__RHA_Object_Translation__c.fields.ResourceHeroApp__Name_Field__c.isCreateable()
              )
                insert opp_ot;
        }
    }
    
    public static testmethod  void nr01_testOppTeamMemberInsert(){   
       
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ResourceHeroApp__Resource__c res = [SELECT Id FROM ResourceHeroApp__Resource__c LIMIT 1];
         test.starttest();
        
        ResourceHeroApp__Resource_Assignment__c ra = (ResourceHeroApp__Resource_Assignment__c)ResourceHeroApp__Resource_Assignment__c.sObjectType.newSObject(null, true);
        ra.ResourceHeroApp__Opportunity__c = opp.Id;
        ra.ResourceHeroApp_Status__c = ResourceAssignmentTriggerHandler.STATUS_BOOKED;
        ra.ResourceHeroApp__Role__c = 'Bid Owner';
        ra.ResourceHeroApp__Resource__c = res.Id;
        insert ra;
        
        OpportunityTeamMember otm = [SELECT Id, Resource_Assignment__c, UserId, OpportunityId, TeamMemberRole FROM OpportunityTeamMember WHERE Resource_Assignment__c = :ra.Id LIMIT 1 ];
        
        User salesRep = [SELECT Id FROM User WHERE FirstName = 'largeUser' LIMIT 1];
        test.stoptest();
        System.assertNotEquals(otm, null, 'There should have been one OpportunityTeamCreated');
        System.assertEquals(otm.UserId, salesRep.Id, 'OpportunityTeamMember userId should be the same as the Resource User');
        System.assertEquals(otm.TeamMemberRole, ra.ResourceHeroApp__Role__c, 'The OpportunityTeamMember role should be the same as the Resource Assignment role');
    }
    
    
    public static testmethod  void nr02_testOppTeamMemberUpdate(){   
        test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        ResourceHeroApp__Resource__c res = [SELECT Id FROM ResourceHeroApp__Resource__c LIMIT 1];
        
        ResourceHeroApp__Resource_Assignment__c ra = (ResourceHeroApp__Resource_Assignment__c)ResourceHeroApp__Resource_Assignment__c.sObjectType.newSObject(null, true);
        ra.ResourceHeroApp__Opportunity__c = opp.Id;
        ra.ResourceHeroApp_Status__c = ResourceAssignmentTriggerHandler.STATUS_BOOKED;
        ra.ResourceHeroApp__Role__c = 'Bid Owner';
        ra.ResourceHeroApp__Resource__c = res.Id;
        insert ra;
        
        OpportunityTeamMember otm = [SELECT Id, Resource_Assignment__c, UserId, OpportunityId, TeamMemberRole FROM OpportunityTeamMember WHERE Resource_Assignment__c = :ra.Id LIMIT 1 ];
        
        User salesRep = [SELECT Id FROM User WHERE FirstName = 'largeUser' LIMIT 1];
        
        System.assert(otm != null, 'There should have been one OpportunityTeamCreated');
        System.assertEquals(otm.UserId, salesRep.Id, 'OpportunityTeamMember userId should be the same as the Resource User');
        System.assertEquals(otm.TeamMemberRole, ra.ResourceHeroApp__Role__c, 'The OpportunityTeamMember role should be the same as the Resource Assignment role');
        
        
        
        //Updating Role
        ra.ResourceHeroApp__Role__c = 'Advisor';
        update ra;
        
        List<OpportunityTeamMember> otmRoleUpdate = [SELECT Id, Resource_Assignment__c, UserId, OpportunityId, TeamMemberRole FROM OpportunityTeamMember WHERE Resource_Assignment__c = :ra.Id];
        
        System.assertEquals(otmRoleUpdate.size(),  1, 'There should only be one OpportunityTeamMember');
        System.assertEquals(otmRoleUpdate[0].UserId, salesRep.Id, 'OpportunityTeamMember userId should be the same as the Resource User');
        System.assertEquals(otmRoleUpdate[0].TeamMemberRole, ra.ResourceHeroApp__Role__c, 'The OpportunityTeamMember role should be the same as the Resource Assignment role');
        
        
        test.stopTest();
    }
    
    
    
}