@isTest
public class Test_LeaderboardVFController{
    @isTest static void LeaderboardcuController(){
       List<User> userList = new List<User>();
       account acc;
       contact con;
            user cygateUser1 = Test_DataFactory.createCygateUser();
            user cygateUser2 = Test_DataFactory.createCygateUser(); 
            user businessAdmin = Test_DataFactory.createCygateEnterpriseBusinessAdminUser();
            user cygateUser3 = Test_DataFactory.createCygateChefUser();
            userList.add(cygateUser3);
            userList.add(cygateUser1);
            userList.add(cygateUser2);
            userList.add(businessAdmin);
            insert userList;
        
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User by calling getByPassUser method. Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
               test.starttest();
                acc = Test_DataFactory.createOneCygateAccount(cygateUser1.Id);
                acc.OwnerId = cygateUser1.Id;
                insert acc;
                List<Contact> conList = Test_DataFactory.createContacts(2);

                con = conList[0];
                con.accountid = acc.Id;
                insert con;
        }

        Yearly_Performance_Score__c yp = new Yearly_Performance_Score__c();
        Yearly_Performance_Score__c yp1 = new Yearly_Performance_Score__c();
        list<Yearly_Performance_Score__c> ypList = new List<Yearly_Performance_Score__c>();
        User_Performance__c up = new User_Performance__c();
        User_Performance__c up1 = new User_Performance__c();
        User_Performance__c upA = new User_Performance__c();
        User_Performance__c upB = new User_Performance__c();
        List<User_Performance__c> upList = new List<User_Performance__c>();
        Decimal monthlySalesRevenueTarget;

        System.runAs(businessAdmin){
            up = Test_DataFactory.createUserPerformance(cygateUser1);
            up1 = Test_DataFactory.createUserPerformance(cygateUser2);
            up.User__c = cygateUser1.Id;
            up1.User__c = cygateUser2.Id;
            upList.add(up);
            upList.add(up1);
            insert upList;
            upA = upList[0];
            upB = upList[1];

            yp = Test_DataFactory.createYearlyPerformanceScore(upA.Id);
            ypList.add(yp);
            yp1 = Test_DataFactory.createYearlyPerformanceScore(upB.Id); 
            ypList.add(yp1); 
            insert ypList;
            List<Quarterly_Performance_Score__c> qpsList = new List<Quarterly_Performance_score__c>();
            quarterly_performance_score__c qp1 = new quarterly_performance_score__c();
            qp1.User_performance__c = upA.id;
            qp1.name = 'Q1';
            qp1.yearly_performance_score__c = ypList[0].Id;
            qpsList.add(qp1);
            
            quarterly_performance_score__c qp2 = new quarterly_performance_score__c();
            qp2.User_performance__c = upA.id;
            qp2.name = 'Q2';
            qp2.yearly_performance_score__c = ypList[0].Id;
            qpsList.add(qp2);
            
            quarterly_performance_score__c qp3 = new quarterly_performance_score__c();
            qp3.User_performance__c = upA.id;
            qp3.name = 'Q3';
            qp3.yearly_performance_score__c = ypList[0].Id;
            qpsList.add(qp3);
            
            quarterly_performance_score__c qp4 = new quarterly_performance_score__c();
            qp4.User_performance__c = upA.id;
            qp4.name = 'Q4';
            qp4.yearly_performance_score__c = ypList[0].Id;
            qpsList.add(qp4);
            
            insert qpsList;
        //Account acc1 = Test_DataFactory.createOneKundkontoAccount();
       
        //insert acc1;
        
        //insert events and the training plans :O
        event e = test_DataFactory.createEventWithWhatWhoId(acc.Id,con.id);
        //event e  = Test_DataFactory.createCygateKundbesokEvent();
            //e.WhoId = con.Id;
            //e.WhatId = acc.Id;
            ////e.ActivityDateTime = System.now().addDays(-1); 
            //e.StartDateTime = System.now().addDays(-1);
            //e.EndDateTime = e.ActivityDateTime.addHours(1);
            e.Bredda_aff_ren__c=true;
            e.ka_avtalad_aff_r__c=true;
            e.V_xa_befintlig_aff_r__c=true;
            e.Customer_status__c='Ny kund';
            //e.ActivityDateTime = System.now() + 1; // start time is one day from now -> event is open.          
            insert e;
        //insert e;
        //Apexpages.StandardController controller = new Apexpages.StandardController(acc1);
        //ApexPages.currentPage().getParameters().put('ID');
        
        LeaderboardVFController lvfController = new LeaderboardVFController();
        lvfController.getScores();
        lvfController.getallQ();
        lvfController.getResults();
        lvfController.getPYscores();
        
        LeaderboardListController llcontroller = new LeaderboardListController();
        LeaderboardListController.getLightningScores();
        LeaderboardListController.getLightningResults();
        llController.createPerformanceRankMap(ypList); 
        test.stopTest();       
        }
    }
}