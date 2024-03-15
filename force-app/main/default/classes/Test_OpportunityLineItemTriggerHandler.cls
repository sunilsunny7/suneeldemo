@isTest
public class Test_OpportunityLineItemTriggerHandler {
    
    public static testmethod void nr1_testPopulateBuyInterest(){   
        Test_DataFactory.setUpOrg();
        
        Seller__c seller;
        Account acc = Test_DataFactory.createOneAccount();
        Opportunity opp;
        User salesRep;
        
     //   System.runAs(new User(Id = Userinfo.getUserId())){
     System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User
            salesRep = Test_DataFactory.createSMEUser();
            insert salesRep;
            
            seller = Test_DataFactory.createSeller(salesRep.Id, null);
            seller.Start_Date__c = date.newInstance(2015, 1, 1);
            insert seller;
            Test.StartTest();
            acc = Test_DataFactory.createOneAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        System.runAs(salesRep){
            opp = Test_DataFactory.createSmeOpportunity();
            opp.accountId = acc.id;
            insert opp;
            opp.Converted_from_lead__c = true;
            
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
                           
            //First OPP test, with ÅF lead 
            update opp; 
                       
            //From ÅF
            Buy_Interest__c isAf = new Buy_Interest__c();
            isAf.Lead_Source__c = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
            isAf.Opportunity__c = opp.Id;
            insert isAf;
            
            //Not from ÅF
            Buy_Interest__c notAf = new Buy_Interest__c();
            notAf.Lead_Source__c = LeadTriggerHandler.LEAD_SOURCE_OTHER;
            notAf.Opportunity__c = opp.Id;
            insert notAf;
            
            //Adding OpportunityLineItem without linking it to Buy Interest
            OpportunityLineItem oli = Test_DataFactory.createProductAndOpportunityLineItem(opp.id);
            insert oli;
            
            //Nothing is set
            System.assertEquals(Null, oli.Buy_Interest__c);
            
            //We set the checkbox to true
            oli.From_reseller_lead__c = true;            
            update oli;
            Test.StopTest();
            OpportunityLineItem updatedOli = [SELECT Id, Buy_Interest__c FROM OpportunityLineItem WHERE Id =:oli.Id LIMIT 1];
            
            //Now the Buy_Interest field should be the same as the Buy Interest from AF Lead (isAf variable)
            system.assertEquals(isAf.Id, updatedOli.Buy_Interest__c);
            
            //From ÅF
            Buy_Interest__c isAf2 = new Buy_Interest__c();
            isAf2.Lead_Source__c = LeadTriggerHandler.LEAD_SOURCE_RESELLER;
            isAf2.Opportunity__c = opp.Id;
            insert isAf2;   
            
            //Now we have two Buy Interest that is from AF, and therefor the trigger cannot decide which one it should pick.
            
            //Adding OpportunityLineItem without linking it to Buy Interest
            OpportunityLineItem oli2 = Test_DataFactory.createProductAndOpportunityLineItem(opp.id);
            
            //Is fine, the Is from Reseller checkbox is not set
            insert oli2;
            
            oli2.From_reseller_lead__c = true;
        
            //This gives validation error, because we have two AF Buy Interests on Opportunity
            try{
                update oli2;
                system.assertEquals(false, true);
            }catch(DmlException e){
                system.assertEquals(true, true);
                
            }
            
        }
    }  
}