/**
About
-----
Description: Test Class to test QuarterlyForecastTriggerHandler
Create date: Jan 2016

Update History
--------------
Created Jan 2016 - A.N
Updated Feb 2018 - Yogini: Case 842- Targets (Sales) automatic update
Updated July 2022  - Lokesh Singh SALEF-7200 Optimize code and removed DML out of for loop by creating a new list 	
*/

@isTest
public class Test_QuarterlyForecastTriggerHandler {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }
    
    @isTest
    static void testForecastQuotasNotCreatedSME(){
        // Start Initialize Test Data
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);
        
        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam, startDate);
        }
        
        //Create yearly targets
        Integer targetNewSales = 2000000;
        Integer targetContinuationSales = 1000000;
        /*added by PP for Sales Value Target*/
        Integer targetSalesValue = 1000000;
        User salesRep = smeUserTeam[2];
        Seller__c seller = smeSellerTeam[2];
        List<Yearly_Target__c> lstytNew = new list<Yearly_Target__c>();
        for(Seller__c s : smeSellerTeam){            
            Yearly_Target__c ytNew = Test_DataFactory.createOneYearlyTarget(s);
            ytNew.Name = String.valueOf(thisYear);
            ytNew.Full_Year_New_Sales_Target__c = targetNewSales;
            ytNew.Full_Year_Continuation_Sales_Target__c = targetContinuationSales;
            ytNew.Full_Year_Sales_Value_Target__c = targetSalesValue;
            lstytNew.add(ytNew);           
        }
        insert lstytNew;
        // End Initialize Test Data
        
        List<Quarterly_Forecast_Item__c> qfisSeller = [SELECT Name, Continuation_Sales_Target__c, New_Sales_Target__c,  Sales_Value_Target__c 
                                                       FROM Quarterly_Forecast_Item__c WHERE User__c = :salesRep.Id];
        System.assertEquals(qfisSeller.size(), 4, 'The correct number of Quarterly_Forecast_Item__c has not been created');
        
        List<ForecastingQuota> fqsSeller = [SELECT ForecastingTypeId, QuotaAmount, QuotaOwnerId, StartDate 
                                            FROM ForecastingQuota WHERE QuotaOwnerId = :salesRep.Id];
        System.assertEquals(fqsSeller.size(), 0, 'No ForecastingQuota should have been created for SME users');
    }
    
    @isTest
    static void testForecastQuotasCreatedLarge(){
        // Start Initialize Test Data
        Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);
        
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        
        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of large users {SalesUnitManager, SalesTeamManager, Seller}
            largeUserTeam = Test_DataFactory.createLargeUserTeam(3);
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            largeSellerTeam = Test_DataFactory.createSmeSellerTeam(largeUserTeam);
        }
        
        User salesRep = largeUserTeam[2];
        Seller__c seller = largeSellerTeam[2];
        
        //Create yearly targets
        Integer targetNewSales = 2000000;
        Integer targetContinuationSales = 1000000;
        /*added by PP for Sales Value Target Change*/
        Integer targetSalesValue = 1000000;
        List<Yearly_Target__c> lstytNew = new list<Yearly_Target__c>();
        for(Seller__c s : largeSellerTeam){            
            Yearly_Target__c ytNew = Test_DataFactory.createOneYearlyTarget(s);
            ytNew.Name = String.valueOf(thisYear);
            ytNew.Full_Year_New_Sales_Target__c = targetNewSales;
            ytNew.Full_Year_Continuation_Sales_Target__c = targetContinuationSales;
            ytNew.Full_Year_Sales_Value_Target__c = targetSalesValue;           
            lstytNew.add(ytNew);
        }
        insert lstytNew;
        // End Initialize Test Data
        
        List<Quarterly_Forecast_Item__c> qfisSeller = [SELECT Name, Continuation_Sales_Target__c, New_Sales_Target__c, Sales_Value_Target__c 
                                                       FROM Quarterly_Forecast_Item__c WHERE User__c = :salesRep.Id];
        System.assertEquals(qfisSeller.size(), 4, 'The correct number of Quarterly_Forecast_Item__c has not been created');
        
        List<ForecastingQuota> fqsSeller = [SELECT ForecastingTypeId, QuotaAmount, QuotaOwnerId, StartDate 
                                            FROM ForecastingQuota WHERE QuotaOwnerId = :salesRep.Id];
        //System.assertEquals(fqsSeller.size(), 12, 'The correct number of ForecastingQuota has not been created');
        
        Id fqTypeNSid = SEUtility.getForecastingTypeId(SEUtility.OPP_SPLIT_TYPE_NS_DEVNAME);
        Id fqTypeCSid = SEUtility.getForecastingTypeId(SEUtility.OPP_SPLIT_TYPE_CS_DEVNAME);
        Id fqTypeSid = SEUtility.getForecastingTypeId (SEUtility.OPP_SPLIT_TYPE_S_DEVNAME); 
        
        // Check that the ForecastingQuota QuotaAmount matches the qfi New Sales/Cont Sales Target
        for(Quarterly_Forecast_Item__c qfi : qfisSeller){
            Date fqStartdate = QuarterlyForecastTriggerHandler.getStartDate(thisYear, qfi.Name);
            for(ForecastingQuota fq : fqsSeller){
                if(fq.StartDate == fqStartdate){
                    if(fq.ForecastingTypeId == fqTypeNSid ){
                        System.assertEquals(qfi.New_Sales_Target__c, fq.QuotaAmount, 'The quota amount does not match the quarterly forecast item for New Sales');
                    } else if (fq.ForecastingTypeId == fqTypeCSid ){
                        System.assertEquals(qfi.Continuation_Sales_Target__c, fq.QuotaAmount, 'The quota amount does not match the quarterly forecast item for New Sales');
                    } else if (fq.ForecastingTypeId == fqTypeSid) { 
                        System.assertEquals (qfi.Sales_Value_Target__c, fq.QuotaAmount, 'The quota amount does not match the quarterly forecast item for Sales'); 
                    } 
                }
            }
        }
    }
}