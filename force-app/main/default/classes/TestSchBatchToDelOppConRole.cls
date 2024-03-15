@istest
public class TestSchBatchToDelOppConRole {

    public static testMethod void testschedule() {
        DateTime currTime = DateTime.now();
        Integer min = currTime.minute();
        Integer hour = currTime.hour();
        String sch;       
        if(min <= 58)
            sch = '0 '+ (min + 1) + ' ' + hour + ' * * ? '+ currTime.year();
        else          
            sch = '0 0 '+ (hour + 1) + ' * * ? '+ currTime.year();   
       
        
        Test_DataFactory.setUpOrg();
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        List<Yearly_Target__c> largeSellerteamYT;
        Account acc;
        User salesRep;
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error.
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
            largeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam);
            salesRep = largeUserTeam[2];
            acc = Test_DataFactory.createOneLargeStandardAccount();
            acc.OwnerId = salesRep.Id;
            insert acc;
        }
        
        
        
        System.runAs(salesRep){  
            
            
            List<Opportunity> opps = new List<Opportunity>();
            
            Opportunity opp = Test_DataFactory.createOpportunity();
            opp.StageName = OpportunityValidationHandler.OPP_STAGE_QUALIFY;
            opp.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.OPP_RECTYPE_LARGE_STANDARD);
            opp.AccountId = acc.Id;
            opp.Seller__c = largeSellerTeam[2].Id;            
            opps.add(opp);          
            Test.startTest();
            insert opps;
             
            Contact c = new Contact();
            c.lastname = 'testBatchCon';
            c.AccountId = acc.Id;
            c.Email = 'abc@gmail.com';
            c.firstname = 'abc';
            c.Role__c = 'Operativ chef/COO';
            insert c;
            
            
            Add_Opportunity_Contact_Role__c ocr = new Add_Opportunity_Contact_Role__c();
            ocr.contact__c = c.id; 
            ocr.roles__c = 'avtalstecknare';
            ocr.Opportunity__c = opp.id;
            insert ocr;
            system.assert(ocr.id !=null, true );
            
            SchBatchToDelOppConRole obj = new SchBatchToDelOppConRole();                
            String jobId = system.schedule('test', sch, obj);        
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger where id = :jobId];        
            System.assertEquals(sch, ct.CronExpression);
            
            BatchToDeleteAddOppConRolesRecords b = new BatchToDeleteAddOppConRolesRecords('SELECT Id FROM Add_Opportunity_Contact_Role__c');
            database.executebatch(b,200);   
            Test.stopTest();
        }
    }
}