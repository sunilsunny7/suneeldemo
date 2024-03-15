/**
About
-----
Description: Test Class to test QuarterlyForecastTriggerHandler
Create date: Jan 2016

Update History
--------------
Created Jan 2016 - A.N

*/

@isTest
public class Test_MonthlyPerfScoreTriggerHandler {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }

    @isTest
    static void testCreateMonthlyPerformanceScoreCygate(){
        // Start Initialize Test Data
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);

        User cygateUser;
        User businessAdmin;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            List<User> userList = new List<User>();
            cygateUser = Test_DataFactory.createCygateUser();
            businessAdmin = Test_DataFactory.createCygateEnterpriseBusinessAdminUser();
            userList.add(cygateUser);
            userList.add(businessAdmin);
            insert userList;
        }

        Yearly_Performance_Score__c yp;
        Decimal salesRevenueTarget;
        Integer clientMeetingsTarget;

        System.runAs(businessAdmin){
            User_Performance__c up = Test_DataFactory.createUserPerformance(cygateUser);
            insert up;

            yp = Test_DataFactory.createYearlyPerformanceScore(up.Id);
            insert yp;
            salesRevenueTarget = (yp.Product_Sales_Revenue_Target__c+yp.Services_Sales_Revenue_Target__c);
            clientMeetingsTarget = (Integer) yp.Client_Meetings_Target__c;
        }

        Yearly_Performance_Score__c ypAfterInsert = [SELECT Client_Meetings_Target__c, Competence_Events_Target__c, Sales_Revenue_Target__c,
                                                (SELECT Id, Sales_Revenue_Target__c, Client_Meetings_Target__c FROM Monthly_Performance_Scores__r ORDER BY Name ASC)
                                                FROM Yearly_Performance_Score__c WHERE Id = :yp.Id];

        //System.assertEquals(ypAfterInsert.Client_Meetings_Target__c, clientMeetingsTarget,'Wrong clientMeetingsTarget on Yearly Performance Score');
        //System.assertEquals(ypAfterInsert.Sales_Revenue_Target__c, salesRevenueTarget,'Wrong salesRevenueTarget on Yearly Performance Score');
        // 12 Monthly performance score records should be created by process builder
        //System.assertEquals(ypAfterInsert.Monthly_Performance_Scores__r.size(), 12,'Exactly 12 Monthly Performance Scores should be created on Yearly Performance Score');

        Monthly_Performance_Score__c mp = ypAfterInsert.Monthly_Performance_Scores__r[0];
        //System.assertEquals(mp.Client_Meetings_Target__c, clientMeetingsTarget/12,'Wrong clientMeetingsTarget on Monthly Performance Score');
        //System.assertEquals(mp.Sales_Revenue_Target__c, salesRevenueTarget/12,'Wrong salesRevenueTarget on Monthly Performance Score');
    }

    @isTest
    static void testUpdateMonthlyPerformanceScoreCygate(){
        // Start Initialize Test Data
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);

        User cygateUser;
        User businessAdmin;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            List<User> userList = new List<User>();
            cygateUser = Test_DataFactory.createCygateUser();
            businessAdmin = Test_DataFactory.createCygateEnterpriseBusinessAdminUser();
            userList.add(cygateUser);
            userList.add(businessAdmin);
            insert userList;
        }

        Yearly_Performance_Score__c yp;
        Decimal monthlySalesRevenueTarget;
        Integer monthlyClientMeetingsTarget;

        System.runAs(businessAdmin){
            User_Performance__c up = Test_DataFactory.createUserPerformance(cygateUser);
            insert up;

            yp = Test_DataFactory.createYearlyPerformanceScore(up.Id);
            insert yp;
            monthlySalesRevenueTarget = (yp.Product_Sales_Revenue_Target__c+yp.Services_Sales_Revenue_Target__c)/12;
            monthlyClientMeetingsTarget = (Integer) yp.Client_Meetings_Target__c/12;

            Yearly_Performance_Score__c ypAfterInsert = [SELECT Id, (SELECT Id, Sales_Revenue_Target__c, Client_Meetings_Target__c FROM Monthly_Performance_Scores__r ORDER BY Name ASC)
                                                    FROM Yearly_Performance_Score__c WHERE Id = :yp.Id];
            //System.assertEquals(ypAfterInsert.Monthly_Performance_Scores__r.size(), 12,'Exactly 12 Monthly Performance Scores should be created on Yearly Performance Score');
            Monthly_Performance_Score__c mp = ypAfterInsert.Monthly_Performance_Scores__r[0];
            mp.Sales_Revenue_Target__c = 50000;
            mp.Client_Meetings_Target__c = 5;
            update mp;
        }

        Yearly_Performance_Score__c ypAfterUpdate = [SELECT Client_Meetings_Target__c, Competence_Events_Target__c, Sales_Revenue_Target__c,
                                                (SELECT Id, Sales_Revenue_Target__c, Client_Meetings_Target__c FROM Monthly_Performance_Scores__r ORDER BY Name ASC)
                                                FROM Yearly_Performance_Score__c WHERE Id = :yp.Id];

        // Verify updated Monthly Performance
        Monthly_Performance_Score__c mp1 = ypAfterUpdate.Monthly_Performance_Scores__r[0];
        //System.assertEquals(mp1.Client_Meetings_Target__c, 5,'Wrong clientMeetingsTarget on Monthly Performance Score 1');
        //System.assertEquals(mp1.Sales_Revenue_Target__c, 50000,'Wrong salesRevenueTarget on Monthly Performance Score 1');

        // Verify not updated Monthly Performance
        Monthly_Performance_Score__c mp2 = ypAfterUpdate.Monthly_Performance_Scores__r[1];
        //System.assertEquals(mp2.Client_Meetings_Target__c, monthlyClientMeetingsTarget,'Wrong clientMeetingsTarget on Monthly Performance Score 2');
        //System.assertEquals(mp2.Sales_Revenue_Target__c, monthlySalesRevenueTarget,'Wrong salesRevenueTarget on Monthly Performance Score 2');

        // Verify updated Yearly Performance
        //System.assertEquals(ypAfterUpdate.Client_Meetings_Target__c, 11*monthlyClientMeetingsTarget + 5,'Wrong clientMeetingsTarget on Yearly Performance Score');
        //System.assertEquals(ypAfterUpdate.Sales_Revenue_Target__c, 11*monthlySalesRevenueTarget + 50000,'Wrong salesRevenueTarget on Yearly Performance Score');        
    }



    @isTest
    static void testForecastQuotasCreatedCygate(){
        // Start Initialize Test Data
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);

        User cygateUser;
        User businessAdmin;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            List<User> userList = new List<User>();
            cygateUser = Test_DataFactory.createCygateUser();
            businessAdmin = Test_DataFactory.createCygateEnterpriseBusinessAdminUser();
            userList.add(cygateUser);
            userList.add(businessAdmin);
            insert userList;
        }

        Yearly_Performance_Score__c yp;
        Decimal monthlySalesRevenueTarget;

        System.runAs(businessAdmin){
            User_Performance__c up = Test_DataFactory.createUserPerformance(cygateUser);
            insert up;

            yp = Test_DataFactory.createYearlyPerformanceScore(up.Id);
            insert yp;
            monthlySalesRevenueTarget = (yp.Product_Sales_Revenue_Target__c+yp.Services_Sales_Revenue_Target__c)/12;
        }

        List<ForecastingQuota> fqsUser = [SELECT ForecastingTypeId, QuotaAmount, QuotaOwnerId, StartDate 
            FROM ForecastingQuota WHERE QuotaOwnerId = :cygateUser.Id ORDER BY StartDate ASC];
        //System.assertEquals(fqsUser.size(), 4, 'The correct number of ForecastingQuota has not been created');

        //System.assertEquals(fqsUser[0].QuotaAmount, 3*monthlySalesRevenueTarget, 'The quota amount does not match the monthly performance score');
    }

    @isTest
    static void testForecastQuotasUpdatedCygate(){
        // Start Initialize Test Data
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);

        User cygateUser;
        User businessAdmin;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            List<User> userList = new List<User>();
            cygateUser = Test_DataFactory.createCygateUser();
            businessAdmin = Test_DataFactory.createCygateEnterpriseBusinessAdminUser();
            userList.add(cygateUser);
            userList.add(businessAdmin);
            insert userList;
        }

        Yearly_Performance_Score__c yp;
        Decimal monthlySalesRevenueTarget;

        System.runAs(businessAdmin){
            User_Performance__c up = Test_DataFactory.createUserPerformance(cygateUser);
            insert up;

            yp = Test_DataFactory.createYearlyPerformanceScore(up.Id);
            insert yp;
            monthlySalesRevenueTarget = (yp.Product_Sales_Revenue_Target__c+yp.Services_Sales_Revenue_Target__c)/12;

            Yearly_Performance_Score__c ypAfterInsert = [SELECT Id, (SELECT Id, Sales_Revenue_Target__c, Client_Meetings_Target__c FROM Monthly_Performance_Scores__r ORDER BY Name ASC)
                                                    FROM Yearly_Performance_Score__c WHERE Id = :yp.Id];
            //System.assertEquals(ypAfterInsert.Monthly_Performance_Scores__r.size(), 12,'Exactly 12 Monthly Performance Scores should be created on Yearly Performance Score');
            Monthly_Performance_Score__c mp = ypAfterInsert.Monthly_Performance_Scores__r[0];
            mp.Sales_Revenue_Target__c = 50000;
            update mp;
        }

        List<ForecastingQuota> fqsUser = [SELECT ForecastingTypeId, QuotaAmount, QuotaOwnerId, StartDate 
            FROM ForecastingQuota WHERE QuotaOwnerId = :cygateUser.Id ORDER BY StartDate ASC];
        //System.assertEquals(fqsUser.size(), 4, 'The correct number of ForecastingQuota has not been created');

        //System.assertEquals(fqsUser[0].QuotaAmount, 2*monthlySalesRevenueTarget + 50000, 'The quota amount 1 does not match the monthly performance score');
        //System.assertEquals(fqsUser[1].QuotaAmount, 3*monthlySalesRevenueTarget, 'The quota amount 2 does not match the monthly performance score');
    }
}