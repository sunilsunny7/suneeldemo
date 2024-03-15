@istest
    public class TestSchBatchToCountEmpOfChildAccount{
        
        public static String CRON_EXP = '0 0 0 15 3 ? 2032';
        public static String accParentId;
        
       @testsetup public static void createTestData(){
                System.runAs(new User(Id = Userinfo.getUserId())){
            //Test_DataFactory.setUpOrg();
            List<User> largeUserTeam;
            List<Seller__c> largeSellerTeam;
            List<Yearly_Target__c> largeSellerteamYT;
                test.startTest();
                largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
                largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
               // largeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam);
                
                Account accTemp = Test_DataFactory.createOneKundkontoAccount();
                accTemp.name = 'testAccExclude';               
                insert accTemp;
                //system.debug('*****accTemp***'+accTemp);
                User salesRep = largeUserTeam[1];
                list<ExcludedRecords__c> listCs = new list<ExcludedRecords__c>();
                
                ExcludedRecords__c cs = new ExcludedRecords__c();
                cs.name = 'AcntRollUpExcludedRecords';
                cs.Excluded_records_list__c = accTemp.id;
                listCs.add(cs);
                
               /* ExcludedRecords__c cs1 = new ExcludedRecords__c();
                cs1.name = 'actExcludedAccounts';
                cs1.Excluded_records_list__c = accTemp.id;
                listCs.add(cs1); 
                insert listCs;*/
                Account accP = Test_DataFactory.createOneKundkontoAccount();
                accP.OwnerId = salesRep.Id;
                accP.Employees_KKnr__c = 2;
                insert accP;
                accParentId = accP.id;
                //system.debug('*****accp***'+accp);
                
                Account acc1 = Test_DataFactory.createOneLargeStandardAccount();
                acc1.OwnerId = salesRep.Id;
                acc1.ParentID = accP.id;
                acc1.TotalEmployees_reported__c = 3;
                insert acc1;
                Test.stopTest();
                /*Account acc2 = Test_DataFactory.createOneLargeStandardAccount();
                acc2.OwnerId = salesRep.Id;
                acc2.TotalEmployees_reported__c = 4;
                acc2.ParentID = accP.id;
                insert acc2;*/
                }
        }
        public static testMethod void testschedule1() {
          System.runAs(Test_DataFactory.getByPassUser()){  
           /* System.runAs(new User(Id = Userinfo.getUserId())){   
              //  TestSchBatchToCountEmpOfChildAccount.createTestData();    
                User adminUser = Test_DataFactory.createAdminUser();
            }*/
            
            Test.startTest();
            String jobId = System.schedule('Test - Schedule SchBatchToCountEmpOfChildAccount batch job', CRON_EXP, new SchBatchToCountEmpOfChildAccount());
       
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
         Test.stopTest();
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);

        // Verify the next time the job will run
        System.assertEquals('2032-03-15 00:00:00',String.valueOf(ct.NextFireTime));

        // Verify the scheduled job hasn't run yet.

        
        }
        }
        
    }