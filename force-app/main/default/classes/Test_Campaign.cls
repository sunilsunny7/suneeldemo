/**
About
-----
Description: Test Class to test Campaign custom functionality
Create date: April 2015

Update History
--------------
Created April 2015 - T.R.
Updated May 2015 - V.I. Purpose field was removed from Activity object

Issues / TODOs
--------------  
*/
 
@isTest
public with sharing class Test_Campaign {
    
    //Test that correct campaign member status are created for each type of campaign type
    static testMethod void testCampaignMemberStatusesAssignment() {
        //Arrange
        Test_DataFactory.setUpOrg();
        
        //Get all the campaign types
        Schema.DescribeFieldResult fieldResult = Campaign.Type.getDescribe();
        List<Schema.PicklistEntry> campaignTypes = fieldResult.getPicklistValues();
        System.debug('@@ campaignTypes: ' + campaignTypes);
        
        //Act
        Test.startTest();
        //Create campaigns for each campaign type
        List<Campaign> campaigns = new List<Campaign>();
        for (Schema.PicklistEntry ple : campaignTypes) {
            String campaignType = ple.getValue();
            Campaign campaign = Test_DataFactory.createTeliaCampaign();
            campaign.Name = 'Campaign ' + campaignType;
            campaign.Type = campaignType;
            campaigns.add(campaign);
        }
        insert campaigns;
        Test.stopTest();
        
        //Assert
        Map<String, Set<String>> correctCampaignTypeToMemberStatusSet = getCampaignTypeToMemberStatusSet();
        System.debug('@@ correctCampaignTypeToMemberStatusSet: ' + correctCampaignTypeToMemberStatusSet);
        
        //Create map of campaign Id to campaign Type
       	Map<Id, String> campaignIdToType = new Map<Id, String>();
        for (Campaign campaign : [SELECT Id, Name, Type FROM Campaign]) {
            campaignIdToType.put(campaign.Id, campaign.Type);
        }
        
        //Validate that the member statuses are correct
        Map<String, Set<String>> insertedCampaignTypeToMemberStatuses = new Map<String, Set<String>>();
        List<CampaignMemberStatus> campaignMemberStatusesList = [SELECT Id, CampaignId, Label FROM CampaignMemberStatus];
        //Create a correct map of campaign type to a set of campaign member statuses
        for (CampaignMemberStatus cms : campaignMemberStatusesList) {
            String campaignType = campaignIdToType.get(cms.CampaignId);
            if (!insertedCampaignTypeToMemberStatuses.containsKey(campaignType)) {
                insertedCampaignTypeToMemberStatuses.put(campaignType, new Set<String>());
            }
            insertedCampaignTypeToMemberStatuses.get(campaignType).add(cms.Label);
        }
        System.debug('@@ insertedCampaignTypeToMemberStatuses: ' + insertedCampaignTypeToMemberStatuses);
        for (String campaignType : insertedCampaignTypeToMemberStatuses.keySet()) {
            System.debug('@@ campaignType: ' + campaignType);
            System.debug('@@ correctCampaignTypeToMemberStatusSet: ' + correctCampaignTypeToMemberStatusSet.get(campaignType));
            System.debug('@@ insertedCampaignTypeToMemberStatuses: ' + insertedCampaignTypeToMemberStatuses.get(campaignType));
            System.assertEquals(correctCampaignTypeToMemberStatusSet.get(campaignType), insertedCampaignTypeToMemberStatuses.get(campaignType), 'Incorrect statuses on campaign type: ' + campaignType);
        }
    }

    //Test the correct default campaign member status is set
    static testMethod void testCampaignMemberStatusDefaults() {
        //Arrange
        Test_DataFactory.setUpOrg();
        
        //Get all the campaign types
        Schema.DescribeFieldResult fieldResult = Campaign.Type.getDescribe();
        List<Schema.PicklistEntry> campaignTypes = fieldResult.getPicklistValues();
        System.debug('@@ campaignTypes: ' + campaignTypes);
        
        //Act
        Test.startTest();
        //Create campaigns for each campaign type
        List<Campaign> campaigns = new List<Campaign>();
        for (Schema.PicklistEntry ple : campaignTypes) {
            String campaignType = ple.getValue();
            Campaign campaign = Test_DataFactory.createTeliaCampaign();
            
            campaign.Name = 'Campaign ' + campaignType + Math.random();
            campaign.Type = campaignType;
            campaigns.add(campaign);
        }
        insert campaigns;
        Test.stopTest();
        
        //Assert
        Map<String, String> correctCampaignTypeToDefaultMemberStatus = getCampaignTypeToDefaultMemberStatus();
        System.debug('@@ correctCampaignTypeToDefaultMemberStatus: ' + correctCampaignTypeToDefaultMemberStatus);
        
        //Create map of campaign Id to campaign Type
       	Map<Id, String> campaignIdToType = new Map<Id, String>();
        for (Campaign campaign : [SELECT Id, Name, Type FROM Campaign]) {
            campaignIdToType.put(campaign.Id, campaign.Type);
        }
        
        //Validate that the member default statuses are correct
        Map<String, String> insertedCampaignTypeToDefaultStatus = new Map<String, String>();
        List<CampaignMemberStatus> campaignMemberStatusesList = [SELECT CampaignId, Label FROM CampaignMemberStatus WHERE IsDefault = true];
        System.debug('@@ campaignMemberStatusesList: ' + campaignMemberStatusesList);

        //Create a correct map of campaign type to a default campaign member status
        for (CampaignMemberStatus cms : campaignMemberStatusesList) {
            String campaignType = campaignIdToType.get(cms.CampaignId);
            if (!insertedCampaignTypeToDefaultStatus.containsKey(campaignType)) {
                insertedCampaignTypeToDefaultStatus.put(campaignType, cms.label);
            }
        }
        System.debug('@@ insertedCampaignTypeToDefaultStatus: ' + insertedCampaignTypeToDefaultStatus);
        for (String campaignType : insertedCampaignTypeToDefaultStatus.keySet()) {
            System.debug('@@ campaignType: ' + campaignType);
            System.debug('@@ correctCampaignTypeToDefaultMemberStatus: ' + correctCampaignTypeToDefaultMemberStatus.get(campaignType));
            System.debug('@@ insertedCampaignTypeToDefaultStatus: ' + insertedCampaignTypeToDefaultStatus.get(campaignType));
            System.assertEquals(correctCampaignTypeToDefaultMemberStatus.get(campaignType), insertedCampaignTypeToDefaultStatus.get(campaignType), 'Incorrect statuses on campaign type: ' + campaignType);
        }
    }
    
    //Test the correct next campaign member status is set
    static testMethod void testCampaignMemberStatusRespondedPositive() {
        //Arrange
        Test_DataFactory.setUpOrg();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        //Create a phone campaign
        Campaign campaign = Test_DataFactory.createTeliaCampaign();
        campaign.Type = 'Telefon';
        campaign.IsActive = true;
        insert campaign;
        
        Contact contact = Test_DataFactory.createOneContactWithAccount();
        insert contact;
        
        CampaignMember campaignMember = new CampaignMember();
        campaignMember.CampaignId = campaign.Id;
        campaignMember.ContactId = contact.Id;
        insert campaignMember;
        System.debug('@@ campaignMember: ' + campaignMember);
        
        //Act
        Test.startTest();
        Task task = Test_DataFactory.createTasks(1)[0];
        task.Type = 'Call';
        task.WhoId = contact.Id;
        task.WhatId = campaign.Id;
        task.Subject = 'Call';
        insert task;
        Test.stopTest();
        
        //Assert
        Map<String, String> correctCampaignTypeToFirstResponseStatus = getCampaignTypeToFirstResponseStatus();
        System.debug('@@ correctCampaignTypeToFirstResponseStatus: ' + correctCampaignTypeToFirstResponseStatus);

        List<CampaignMember> campaignMemberList = [SELECT Id, Status FROM CampaignMember WHERE CampaignId =: campaign.Id AND ContactId =: contact.Id];
        System.debug('@@ campaignMemberList: ' + campaignMemberList);
        
        System.assertEquals(1, campaignMemberList.size(), 'Incorrect number of campaign members.');
        System.assertEquals(correctCampaignTypeToFirstResponseStatus.get(campaign.Type), campaignMemberList[0].Status, 'Incorrect status on campaign member.');
    }
    }
    //Test the correct next campaign member status is set
    static testMethod void testCampaignMemberStatusRespondedNegative() {
        //Arrange
        Test_DataFactory.setUpOrg();
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
        //Create a phone campaign
        Campaign campaign = Test_DataFactory.createTeliaCampaign();
        campaign.Type = 'Mejl';
        campaign.IsActive = true;
        insert campaign;
        
        Contact contact = Test_DataFactory.createOneContactWithAccount();
        insert contact;
        
        CampaignMember campaignMember = new CampaignMember();
        campaignMember.CampaignId = campaign.Id;
        campaignMember.ContactId = contact.Id;
        insert campaignMember;
        
        //Act
        Test.startTest();
        Task task = Test_DataFactory.createTasks(1)[0];
        task.Type = 'Call';
        task.WhoId = contact.Id;
        task.WhatId = campaign.Id;
        task.Subject = 'Call';
        insert task;
        Test.stopTest();
        
        //Assert
        List<CampaignMember> campaignMemberList = [SELECT Id, Status FROM CampaignMember WHERE CampaignId =: campaign.Id AND ContactId =: contact.Id];
        System.debug('@@ campaignMemberList: ' + campaignMemberList);
        
        Map<String, String> correctCampaignTypeToDefaultMemberStatus = getCampaignTypeToDefaultMemberStatus();
        System.assertEquals(1, campaignMemberList.size(), 'Incorrect number of campaign members.');
        System.assertEquals(correctCampaignTypeToDefaultMemberStatus.get(campaign.Type), campaignMemberList[0].Status, 'Incorrect status on campaign member.');
    }
    }
    private static Map<String, Set<String>> getCampaignTypeToMemberStatusSet() {
        //Build a map of campaign type to list of member statuses
        Map<String, Set<String>> campaignMemberStatusSetNameToMemberStatuses = new Map<String, Set<String>>();
        for (Campaign_Member_Statuses__c campaignMemberStatus : [SELECT Name, Status_1_Name__c, Status_2_Name__c, Status_3_Name__c,
                                                                 Status_4_Name__c, Status_5_Name__c, Status_6_Name__c, 
                                                                 Status_7_Name__c, Status_8_Name__c 
                                                                 FROM Campaign_Member_Statuses__c]) {
			Set<String> memberStatuses = new Set<String>();
            for (Integer i = 1; i <= 8; i++) {
                String memberStatus = (String) campaignMemberStatus.get('Status_' + i + '_Name__c');
                if (memberStatus != null) {
                    memberStatuses.add(memberStatus);
                }
            }
			campaignMemberStatusSetNameToMemberStatuses.put(campaignMemberStatus.Name, memberStatuses);
		}
        System.debug('@@ campaignMemberStatusSetNameToMemberStatuses: ' + campaignMemberStatusSetNameToMemberStatuses);
        
        //Build a map of campaign type to member status set
        Map<String, Set<String>> correctCampaignTypeToMemberStatusSet = new Map<String, Set<String>>();
        for(Campaign_Type_vs_Member_Statuses__c ctms : [SELECT Id, Campaign_Type__c, Member_Status_Set__c FROM Campaign_Type_vs_Member_Statuses__c]) {
            correctCampaignTypeToMemberStatusSet.put(ctms.Campaign_Type__c, campaignMemberStatusSetNameToMemberStatuses.get(ctms.Member_Status_Set__c));
        }
        return correctCampaignTypeToMemberStatusSet;
    }
    
    private static Map<String, String> getCampaignTypeToDefaultMemberStatus() {
        //Build a map of campaign type to default values
        Map<String, String> campaignMemberStatusSetNameToDefaultStatus = new Map<String, String>();
        for (Campaign_Member_Statuses__c campaignMemberStatus : [SELECT Name, Status_1_Name__c, Status_2_Name__c, Status_3_Name__c,
                                                                 Status_4_Name__c, Status_5_Name__c, Status_6_Name__c, 
                                                                 Status_7_Name__c, Status_8_Name__c, Status_1_Default__c, Status_2_Default__c,
                                                                 Status_3_Default__c, Status_4_Default__c, Status_5_Default__c, Status_6_Default__c,
                                                                 Status_7_Default__c, Status_8_Default__c
                                                                 FROM Campaign_Member_Statuses__c]) {
			Integer defaultStatusIndex = 0;
			String defaultStatus;
            for (Integer i = 1; i <= 8; i++) {
                Boolean defaultStatusValue = (Boolean) campaignMemberStatus.get('Status_' + i + '_Default__c');
                if (defaultStatusValue == true) {
                    defaultStatusIndex = i;
                    defaultStatus = (String) campaignMemberStatus.get('Status_' + defaultStatusIndex + '_Name__c');
                    campaignMemberStatusSetNameToDefaultStatus.put(campaignMemberStatus.Name, defaultStatus);
                    break;
                }
            }
		}
        System.debug('@@ campaignMemberStatusSetNameToDefaultStatus: ' + campaignMemberStatusSetNameToDefaultStatus);
        
        //Build a map of campaign type to member status defaults
        Map<String, String> correctCampaignTypeToDefaultMemberStatus = new Map<String, String>();
        for(Campaign_Type_vs_Member_Statuses__c ctms : [SELECT Id, Campaign_Type__c, Member_Status_Set__c FROM Campaign_Type_vs_Member_Statuses__c]) {
            correctCampaignTypeToDefaultMemberStatus.put(ctms.Campaign_Type__c, campaignMemberStatusSetNameToDefaultStatus.get(ctms.Member_Status_Set__c));
        }
        return correctCampaignTypeToDefaultMemberStatus;
    }
    
    private static Map<String, String> getCampaignTypeToFirstResponseStatus() {
        //Build a map of campaign type to first respond values
        Map<String, String> campaignMemberStatusSetNameToFirstResponseValue = new Map<String, String>();
        for (Campaign_Member_Statuses__c campaignMemberStatus : [SELECT Name, Status_1_Name__c, Status_2_Name__c, Status_3_Name__c,
                                                                 Status_4_Name__c, Status_5_Name__c, Status_6_Name__c, 
                                                                 Status_7_Name__c, Status_8_Name__c, Status_1_Responded__c, Status_2_Responded__c,
                                                                 Status_3_Responded__c, Status_4_Responded__c, Status_5_Responded__c, Status_6_Responded__c,
                                                                 Status_7_Responded__c, Status_8_Responded__c
                                                                 FROM Campaign_Member_Statuses__c]) {
			Integer firstRespondIndex = 0;
			String firstResponseValue;
            for (Integer i = 1; i <= 8; i++) {
                Boolean responseValue = (Boolean) campaignMemberStatus.get('Status_' + i + '_Responded__c');
                if (responseValue == true) {
                    firstRespondIndex = i;
                    firstResponseValue = (String) campaignMemberStatus.get('Status_' + firstRespondIndex + '_Name__c');
                    campaignMemberStatusSetNameToFirstResponseValue.put(campaignMemberStatus.Name, firstResponseValue);
                    break;
                }
            }
		}
        System.debug('@@ campaignMemberStatusSetNameToFirstResponseValue: ' + campaignMemberStatusSetNameToFirstResponseValue);
        
        //Build a map of campaign type to member status defaults
        Map<String, String> correctCampaignTypeToFirstResponseStatus = new Map<String, String>();
        for(Campaign_Type_vs_Member_Statuses__c ctms : [SELECT Id, Campaign_Type__c, Member_Status_Set__c FROM Campaign_Type_vs_Member_Statuses__c]) {
            correctCampaignTypeToFirstResponseStatus.put(ctms.Campaign_Type__c, campaignMemberStatusSetNameToFirstResponseValue.get(ctms.Member_Status_Set__c));
        }
        return correctCampaignTypeToFirstResponseStatus;
    }
}