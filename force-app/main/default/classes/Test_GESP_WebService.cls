/**
About
-----
Description: Test Class Test_GESP_WebService for GESP_WebService
Create: November 2016

Update History
--------------
Created Nov 2016 - A.N - New test methods no01-no10 for getLeadStatus SAEN 1881

Issues / TODOs
--------------     
*/

@isTest
public with sharing class Test_GESP_WebService {
    
    public static testmethod void no01_testNoRetailerId(){  
        System.debug('@@Test no01_testNoRetailerId Starts');
        Test_DataFactory.setUpOrg();
        
        // Submitting a blank string as retailer Id, should return error
        GESB_WebService.LeadStatusRequest request = new GESB_WebService.LeadStatusRequest();
        request.retailerID = '';
        
        GESB_WebService.LeadStatusResponse response = GESB_WebService.getLeadStatus(request);
        System.assertEquals(response.success, false, 'The call should not be successful');
        System.assertEquals(response.errorMsg, GESB_WebService.ERR_INVALID_ID, 'Incorrect error message');
        System.assertEquals(response.numberOfRows, 0, 'There should not be any rows in the response');
        System.assertEquals(response.leadStatusList, null, 'The response lead status list should be null');
    }
    
    public static testmethod void no02_testNoResultsFound(){    
        System.debug('@@Test no02_testNoResultsFound Starts');
        Test_DataFactory.setUpOrg();
        
        // Submitting a blank string as retailer Id, should return error
        GESB_WebService.LeadStatusRequest request = new GESB_WebService.LeadStatusRequest();
        request.retailerID = 'NOMATCH';
        
        GESB_WebService.LeadStatusResponse response = GESB_WebService.getLeadStatus(request);
        System.assertEquals(response.success, false, 'The call should not be successful');
        System.assertEquals(response.errorMsg, GESB_WebService.ERR_NO_LEADS, 'Incorrect error message');
        System.assertEquals(response.numberOfRows, 0, 'There should not be any rows in the response');
        System.assertEquals(response.leadStatusList, null, 'The response lead status list should be null');
    }
    
    public static testmethod void no03_testSOQLinjection(){ 
        System.debug('@@Test no03_testSOQLinjection Starts');
        Test_DataFactory.setUpOrg();
        
        // Create Test Data
        List<Lead> leadList = new List<Lead>();
        System.runAs(new User(Id = Userinfo.getUserId())){
            for(Integer i = 0; i < 20; i++){
                Lead lead = Test_DataFactory.createLead();
                lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
                lead.Lead_Submitter_No__c = 'SUBM01';               
                leadList.add(lead);
            }
            insert leadList;
        }
        
        // Submitting a blank string as retailer Id, should return error
        GESB_WebService.LeadStatusRequest request = new GESB_WebService.LeadStatusRequest();
        // If not handled, this query will return all leads in the system!
        request.retailerID = 'ABC \' OR Lead_Submitter_No__c != \'ABC';
        system.debug('request.retailerID: ' + request.retailerID);
        
        // The Web Service should handle the attempted SOQL injection and return no leads.
        GESB_WebService.LeadStatusResponse response = GESB_WebService.getLeadStatus(request);
        System.assertEquals(response.success, false, 'The call should not be successful');
        System.assertEquals(response.errorMsg, GESB_WebService.ERR_NO_LEADS, 'Incorrect error message');
        System.assertEquals(response.numberOfRows, 0, 'There should not be any rows in the response');
        System.assertEquals(response.leadStatusList, null, 'The response lead status list should be null');
    }
    
    public static testmethod void no04_testLeadRetailerIdSearchResponseValues(){    
        System.debug('@@Test no04_testLeadRetailerIdSearch Starts');
        Test_DataFactory.setUpOrg();
        test.starttest();
        Lead lead;
        Buy_Interest__c bi;
        Contact con;
        Account acc;
        Opportunity opp;
        OpportunityLineItem oli;
        Seller__c seller;
        
        System.runAs(new User(Id = Userinfo.getUserId())){          
            seller = Test_DataFactory.createSeller(Userinfo.getUserId(), null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;
            
            lead = Test_DataFactory.createLead();
            lead.Lead_Submitter_No__c = 'RESID';
            lead.Lead_Submitter_ID__c = 'SUBM01';
            lead.LeadSource = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
            lead.Org_nr__c = 'TESTORGNR1';
            insert lead;
            
            acc = Test_DataFactory.createOneAccount();
            acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_RESELLER);
            acc.Telia_Reseller_Id__c = 'RESID';
            acc.name = 'TESTACC';
            insert acc;
            
            con = new Contact();
            con.Reseller_Tholbox_ID__c = 'SUBM01';
            con.FirstName = 'Khal';
            con.LastName = 'Drogo';
            con.RecordTypeId = SEUTility.getRecordTypeId( SEUtility.CONTACT_RECTYPE_RESELLER);
            con.AccountId = acc.Id;
            insert con;
            
            bi = new Buy_Interest__c();
            bi.Buy_Interest_Submitter__c = con.Id;
            bi.Status__c = 'Nytt';
            bi.Lead__c = lead.Id;
            bi.Lead_Source__c = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
            insert bi;
        }
        
        Buy_Interest__c biAfterInsert = [SELECT Id, Status__c, Opportunity__r.IsClosed, 
                                         Opportunity__r.IsWon, Owner.Name, CreatedDate, 
                                         Buy_Interest_Submitter__r.Reseller_Tholbox_ID__c, 
                                         Buy_Interest_Submitter__r.Account.Telia_Reseller_Id__c, 
                                         Lead__r.Lead_No__c, Lead__r.Time_to_first_contact__c, 
                                         Lead__r.Org_nr__c, Lead__r.Company 
                                         FROM Buy_Interest__c LIMIT 1];
        
        GESB_WebService.LeadStatusRequest request = new GESB_WebService.LeadStatusRequest();
        request.retailerID = 'RESID';
        
        GESB_WebService.LeadStatusResponse response = GESB_WebService.getLeadStatus(request);
        System.assertEquals(response.success, true, 'The call should be successful');
        System.assertEquals(response.errorMsg, null, 'There shouldnt be any error message');
        System.assertEquals(response.numberOfRows, 1, 'There should be one row in the response');
        System.assertNotEquals(response.leadStatusList, null, 'The response lead status list should not be null');
        
        GESB_WebService.LeadStatus status = response.leadStatusList[0];
        System.assertEquals(status.retailerID, biAfterInsert.Buy_Interest_Submitter__r.Account.Telia_Reseller_Id__c, 'Wrong value for retailerID');
        System.assertEquals(status.retailerUserId, biAfterInsert.Buy_Interest_Submitter__r.Reseller_Tholbox_ID__c, 'Wrong value for retailerUserId');
        System.assertEquals(status.leadId, biAfterInsert.Id, 'Wrong value for leadId');
        System.assertEquals(status.leadCreationDate, biAfterInsert.CreatedDate, 'Wrong value for leadCreationDate');
        System.assertEquals(status.leadInitialActivityDate, biAfterInsert.Lead__r.Time_to_first_contact__c, 'Wrong value for leadInitialActivityDate');
        System.assertEquals(status.customerOrgNr, biAfterInsert.Lead__r.Org_nr__c, 'Wrong value for customerOrgNr');
        System.assertEquals(status.customerName, biAfterInsert.Lead__r.Company, 'Wrong value for customerName');
        System.assertEquals(status.leadOwnerName, biAfterInsert.Owner.Name, 'Wrong value for leadOwnerName');
        
        System.assertEquals(status.leadStatus, biAfterInsert.Status__c, 'Wrong value for leadStatus');
        System.assertEquals(status.leadStatus, 'Nytt', 'Wrong value for leadStatus');
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            opp = Test_DataFactory.createSmeOpportunity();
            opp.StageName = 'Kvalificera';
            insert opp;
            
            bi.Opportunity__c = opp.Id;
            update bi;
            
            oli = Test_DataFactory.createProductAndOpportunityLineItem(opp.Id);
            oli.OpportunityId = opp.Id;
            oli.Buy_Interest__c = bi.Id;
            insert oli;
        }
        
        Buy_Interest__c biAfterInsert2 = [SELECT Id, Status__c, Opportunity__r.IsClosed, 
                                          Opportunity__r.IsWon, Owner.Name, CreatedDate, 
                                          Opportunity__r.StageName,
                                          Buy_Interest_Submitter__r.Lead_Submitter_ID__c, 
                                          Buy_Interest_Submitter__r.Account.Telia_Reseller_Id__c, 
                                          Lead__r.Lead_No__c, Lead__r.Time_to_first_contact__c, 
                                          Lead__r.Org_nr__c, Lead__r.Company 
                                          FROM Buy_Interest__c LIMIT 1];
        
        test.stoptest();
        GESB_WebService.LeadStatusRequest request2 = new GESB_WebService.LeadStatusRequest();
        request2.retailerID = 'RESID';
        
        GESB_WebService.LeadStatusResponse response2 = GESB_WebService.getLeadStatus(request2);
        GESB_WebService.LeadStatus status2 = response2.leadStatusList[0];
        
        System.assertEquals(status2.leadStatus, biAfterInsert2.Opportunity__r.StageName, 'Should be the Opportunity StageName since it has OpportunityLineItems related to Buy Interest');
        System.assertEquals(status2.leadStatus, 'Kvalificera', 'Should be the same as the Opportunity StageName, since it has OpportunityLineItems related to Buy Interest');
    }
    
    //VM, Will fix this changeclass later due time constraints.
/*    public static testmethod void no05_testLeadSearchMultipleLeads(){ 
        System.debug('@@Test no05_testLeadSearchMultipleLeads Starts');
        Test_DataFactory.setUpOrg();
        
        // Create Test Data
        Seller__c seller;
        List<Account> accsInserted;   
        List<Contact> consInserted;
        List<Buy_Interest__c> biList = new List<Buy_Interest__c>();
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            seller = Test_DataFactory.createSeller(Userinfo.getUserId(), null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;
            
            List<Account> accList = new List<Account>();
            for(Integer i = 0; i < 2; i++){
                Account acc = Test_DataFactory.createOneAccount();
                acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_RESELLER);
                acc.Telia_Reseller_Id__c = 'RESID'+i;
                acc.name = 'TESTACC'+i;
                accList.add(acc);
            }
            
            insert accList;
            
            accsInserted = [SELECT Id FROM Account];
            
            System.debug('-------------accsInserted');
            System.debug(accsInserted);
            
            List<Contact> conList = new List<Contact>();
            for(Integer i = 0; i < 4; i++){
                Contact con = new Contact();
                con.Lead_Submitter_ID__c = 'SUBM0' + i;
                con.FirstName = 'Name' + i;
                con.LastName = 'Last' + i;
                con.RecordTypeId = SEUTility.getRecordTypeId( SEUtility.CONTACT_RECTYPE_RESELLER);
                if(i < 2){
                    con.AccountId = accsInserted[0].Id;
                }else{
                    con.AccountId = accsInserted[1].Id;
                }
                conList.add(con);
            }
            
            insert conList;
            
            System.debug('-------------conList');
            System.debug(conList);
            consInserted = [SELECT Id FROM Contact];
            
            for(Integer i = 0; i < 20; i++){
                Buy_Interest__c bi = new Buy_Interest__c();
                bi.Lead_Source__c = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
                bi.Status__c = 'Nytt';
                // Create 10 bi for each of two bi submitter number
                //  if(i<10) bi.Buy_Interest_Submitter__c = accsInserted[0].Id;
            //  else bi.Lead_Submitter_No__c = accsInserted[1].Id; 
                // Create 5 leads for four different bi submitter ids
                if(i<5) bi.Buy_Interest_Submitter__c = consInserted[0].Id;
                else if(i<10) bi.Buy_Interest_Submitter__c = consInserted[1].Id;
                else if(i<15) bi.Buy_Interest_Submitter__c = consInserted[2].Id;
                else bi.Buy_Interest_Submitter__c = consInserted[3].Id;
                
                biList.add(bi);
            }
            insert biList;
        }       
        
        List<Buy_Interest__c> biAfterInsert = [SELECT Id, Status__c, Opportunity__r.IsClosed, 
                                               Opportunity__r.IsWon, Owner.Name, CreatedDate, 
                                               Opportunity__r.StageName,
                                               Buy_Interest_Submitter__r.Lead_Submitter_ID__c, 
                                               Buy_Interest_Submitter__r.Account.Telia_Reseller_Id__c, 
                                               Lead__r.Lead_No__c, Lead__r.Time_to_first_contact__c, 
                                               Lead__r.Org_nr__c, Lead__r.Company 
                                               FROM Buy_Interest__c];
        
        System.debug('---------biAfterInsert');
        System.debug(biAfterInsert);
        
        // Submitting only retailer Id
        GESB_WebService.LeadStatusRequest request_01 = new GESB_WebService.LeadStatusRequest();
        request_01.retailerID = 'RESID1';
        GESB_WebService.LeadStatusResponse response_01 = GESB_WebService.getLeadStatus(request_01);
        // Assert results
        System.assertEquals(response_01.success, true, 'The call should be successful');
        System.assertEquals(response_01.numberOfRows, 10, 'There should be 10 rows in the response');
        System.assertNotEquals(response_01.leadStatusList, null, 'The response lead status list should not be null');
        GESB_WebService.LeadStatus status_01 = response_01.leadStatusList[0];
        System.assertEquals(status_01.retailerID, 'RESID1', 'Wrong value for retailerID');
        
        // Submitting retailer Id + valid lead submitter Id
        GESB_WebService.LeadStatusRequest request_02 = new GESB_WebService.LeadStatusRequest();
        request_02.retailerID = 'RESID1';
        request_02.retailerUserId = 'RESELLER01';
        GESB_WebService.LeadStatusResponse response_02 = GESB_WebService.getLeadStatus(request_02);
        // Assert results
        System.assertEquals(response_02.success, true, 'The call should be successful');
        System.assertEquals(response_02.numberOfRows, 5, 'There should be 5 rows in the response');
        System.assertNotEquals(response_02.leadStatusList, null, 'The response lead status list should not be null');
        GESB_WebService.LeadStatus status_02 = response_02.leadStatusList[0];
        System.assertEquals(status_02.retailerID, 'RESID1', 'Wrong value for retailerID');
        System.assertEquals(status_02.retailerUserId, 'RESELLER01', 'Wrong value for retailerID');
        
        // Submitting retailer Id + "invalid" lead submitter Id (i.e. the lead submitter does not belong to the retailer)
        GESB_WebService.LeadStatusRequest request_03 = new GESB_WebService.LeadStatusRequest();
        request_03.retailerID = 'RESID1';
        request_03.retailerUserId = 'RESELLER04';
        GESB_WebService.LeadStatusResponse response_03 = GESB_WebService.getLeadStatus(request_03);
        // Assert results
        System.assertEquals(response_03.success, false, 'The call should not be successful');
        System.assertEquals(response_03.errorMsg, GESB_WebService.ERR_NO_LEADS, 'Incorrect error message');
        System.assertEquals(response_03.numberOfRows, 0, 'There should not be any rows in the response');
        System.assertEquals(response_03.leadStatusList, null, 'The response lead status list should be null');
        
        
        // Submitting retailer Id + Date Filters 1
        GESB_WebService.LeadStatusRequest request_04 = new GESB_WebService.LeadStatusRequest();
        request_04.retailerID = 'RESID1';
        request_04.startDate = System.now() - 1;
        GESB_WebService.LeadStatusResponse response_04 = GESB_WebService.getLeadStatus(request_04);
        // Assert results
        System.assertEquals(response_04.numberOfRows, 10, 'There should be 10 rows in the response');
        
        // Submitting retailer Id + Date Filters 2
        GESB_WebService.LeadStatusRequest request_05 = new GESB_WebService.LeadStatusRequest();
        request_05.retailerID = 'RESID1';
        request_05.startDate = System.now() + 1;
        GESB_WebService.LeadStatusResponse response_05 = GESB_WebService.getLeadStatus(request_05);
        // Assert results
        System.assertEquals(response_05.success, false, 'The call should not be successful');
        System.assertEquals(response_05.numberOfRows, 0, 'There should not be any rows in the response');
        
        // Submitting retailer Id + Date Filters 3
        GESB_WebService.LeadStatusRequest request_06 = new GESB_WebService.LeadStatusRequest();
        request_06.retailerID = 'SUBM01';
        request_06.endDate = System.now() + 1;
        GESB_WebService.LeadStatusResponse response_06 = GESB_WebService.getLeadStatus(request_06);
        // Assert results
        System.assertEquals(response_06.numberOfRows, 10, 'There should be 10 rows in the response');
        
        // Submitting retailer Id + Date Filters 4
        GESB_WebService.LeadStatusRequest request_07 = new GESB_WebService.LeadStatusRequest();
        request_07.retailerID = 'RESID1';
        request_07.startDate = System.now() - 1;
        request_07.endDate = System.now() + 1;
        GESB_WebService.LeadStatusResponse response_07 = GESB_WebService.getLeadStatus(request_07);
        // Assert results
        System.assertEquals(response_07.numberOfRows, 10, 'There should be 10 rows in the response');
        
        // Submitting retailer Id + Date Filters 5
        GESB_WebService.LeadStatusRequest request_08 = new GESB_WebService.LeadStatusRequest();
        request_08.retailerID = 'RESID1';
        request_08.startDate = System.now() - 5;
        request_08.endDate = System.now() -1;
        GESB_WebService.LeadStatusResponse response_08 = GESB_WebService.getLeadStatus(request_08);
        // Assert results
        System.assertEquals(response_08.success, false, 'The call should not be successful');
        System.assertEquals(response_08.numberOfRows, 0, 'There should not be any rows in the response');
        
        // Submitting retailer Id + maxRows 100
        GESB_WebService.LeadStatusRequest request_09 = new GESB_WebService.LeadStatusRequest();
        request_09.retailerID = 'RESID1';
        request_09.maxRows = 100;
        GESB_WebService.LeadStatusResponse response_09 = GESB_WebService.getLeadStatus(request_09);
        // Assert results
        System.assertEquals(response_09.numberOfRows, 10, 'There should be 10 rows in the response');
        
        // Submitting retailer Id + maxRows 3
        GESB_WebService.LeadStatusRequest request_10 = new GESB_WebService.LeadStatusRequest();
        request_10.retailerID = 'RESID1';
        request_10.maxRows = 3;
        GESB_WebService.LeadStatusResponse response_10 = GESB_WebService.getLeadStatus(request_10);
        // Assert results
        System.assertEquals(response_10.numberOfRows, 3, 'There should be 3 rows in the response because of the maxRows');
        
    }*/
}