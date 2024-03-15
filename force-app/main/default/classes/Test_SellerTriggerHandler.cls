@isTest
public with sharing class Test_SellerTriggerHandler {
	@testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }


	@isTest static void testSetEndDateThisYear() {
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

        User salesRep = smeUserTeam[2];
        Seller__c seller = smeSellerTeam[2];

        //Create yearly targets
        Integer targetNewSales = 2000000;
        Integer targetContinuationSales = 1000000;

        List<Yearly_Target__c> ytl = new List<Yearly_Target__c>();
        for(Seller__c s : smeSellerTeam){            
            Yearly_Target__c ytNew = Test_DataFactory.createOneYearlyTarget(s);
            ytNew.Name = String.valueOf(thisYear);
            ytNew.Full_Year_New_Sales_Target__c = targetNewSales;
            ytNew.Full_Year_Continuation_Sales_Target__c = targetContinuationSales;
            //insert ytNew;
            ytl.add(ytNew);
        } 
        insert ytl;
		Yearly_Target__c yt = ytl[2]; // The yearly target for the sales rep

        System.runAs(salesRep){
        	Seller__c currentSeller = [Select Id, End_Date__c From Seller__c Where Id = :seller.Id LIMIT 1];
        	currentSeller.End_Date__c = Date.newInstance(thisYear, 8, 1);
        	update currentSeller;

        	Yearly_Target__c ytAfter = [Select Id, Name, Seller__c, Startweek__c, New_Sales_Target__c, Continuation_Sales_Target__c 
										From Yearly_Target__c Where Id = :yt.Id];
        	//System.assertNotEquals(targetNewSales, ytAfter.New_Sales_Target__c);
        	//System.assertNotEquals(targetContinuationSales, ytAfter.Continuation_Sales_Target__c);
        }
	}
	
	@isTest static void testSetEndDateNextYear() {
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
        
        User salesRep = smeUserTeam[2];
        Seller__c seller = smeSellerTeam[2];

        //Create yearly targets
        Integer targetNewSales = 2000000;
        Integer targetContinuationSales = 1000000;

        List<Yearly_Target__c> ytl = new List<Yearly_Target__c>();
        for(Seller__c s : smeSellerTeam){ 
            Yearly_Target__c ytNew = Test_DataFactory.createOneYearlyTarget(s);
            ytNew.Name = String.valueOf(thisYear);
            ytNew.Full_Year_New_Sales_Target__c = targetNewSales;
            ytNew.Full_Year_Continuation_Sales_Target__c = targetContinuationSales;
            //insert ytNew;
            ytl.add(ytNew);
        } 
         insert ytl;
        Yearly_Target__c yt = ytl[2]; // The yearly target for the sales rep

        System.runAs(salesRep){
        	Seller__c currentSeller = [Select Id, End_Date__c From Seller__c Where Id = :seller.Id LIMIT 1];
        	currentSeller.End_Date__c = Date.newInstance(thisYear+1, 8, 1);
        	update currentSeller;

        	Yearly_Target__c ytAfter = [Select Id, Name, Seller__c, Startweek__c, New_Sales_Target__c, Continuation_Sales_Target__c 
										From Yearly_Target__c Where Id = :yt.Id];
        	System.assertEquals(Integer.valueOf(targetNewSales), Math.round(ytAfter.New_Sales_Target__c));
        	System.assertEquals(Integer.valueOf(targetContinuationSales), Math.round(ytAfter.Continuation_Sales_Target__c));
        }
	}

	@isTest static void testUpdateEndDateEarlierThisYear() {
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
        
        User salesRep = smeUserTeam[2];
        Seller__c seller = smeSellerTeam[2];

        //Create yearly targets
        Integer targetNewSales = 2000000;
        Integer targetContinuationSales = 1000000;

        List<Yearly_Target__c> ytl = new List<Yearly_Target__c>();
        for(Seller__c s : smeSellerTeam){ 
            Yearly_Target__c ytNew = Test_DataFactory.createOneYearlyTarget(s);
            ytNew.Name = String.valueOf(thisYear);
            ytNew.Full_Year_New_Sales_Target__c = targetNewSales;
            ytNew.Full_Year_Continuation_Sales_Target__c = targetContinuationSales;
            //insert ytNew;
            ytl.add(ytNew);
        } 
        insert ytl;
        Yearly_Target__c yt = ytl[2]; // The yearly target for the sales rep

        System.runAs(salesRep){
        	Seller__c currentSeller = [Select Id, End_Date__c From Seller__c Where Id = :seller.Id LIMIT 1];
        	currentSeller.End_Date__c = Date.newInstance(thisYear, 15, 1);
        	update currentSeller;

        	Yearly_Target__c ytAfter = [Select Id, Name, Seller__c, Startweek__c, New_Sales_Target__c, Continuation_Sales_Target__c 
										From Yearly_Target__c Where Id = :yt.Id];
        	currentSeller.End_Date__c = Date.newInstance(thisYear, 5, 1);
        	update currentSeller;        	
        	Yearly_Target__c ytAfter2 = [Select Id, Name, Seller__c, Startweek__c, New_Sales_Target__c, Continuation_Sales_Target__c 
										From Yearly_Target__c Where Id = :yt.Id];
        	System.assert(ytAfter2.New_Sales_Target__c < ytAfter.New_Sales_Target__c);
        	System.assert(ytAfter2.Continuation_Sales_Target__c < ytAfter.Continuation_Sales_Target__c);
        }
	}


	@isTest static void testUpdateEndDateLaterThisYear() {
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
        
        User salesRep = smeUserTeam[2];
        Seller__c seller = smeSellerTeam[2];

        //Create yearly targets
        Integer targetNewSales = 2000000;
        Integer targetContinuationSales = 1000000;

        List<Yearly_Target__c> ytl = new List<Yearly_Target__c>();
        for(Seller__c s : smeSellerTeam){ 
            Yearly_Target__c ytNew = Test_DataFactory.createOneYearlyTarget(s);
            ytNew.Name = String.valueOf(thisYear);
            ytNew.Full_Year_New_Sales_Target__c = targetNewSales;
            ytNew.Full_Year_Continuation_Sales_Target__c = targetContinuationSales;
            //insert ytNew;
            ytl.add(ytNew);
        } 
         insert ytl;
        Yearly_Target__c yt = ytl[2]; // The yearly target for the sales rep

        System.runAs(salesRep){
        	Seller__c currentSeller = [Select Id, End_Date__c From Seller__c Where Id = :seller.Id LIMIT 1];
        	currentSeller.End_Date__c = Date.newInstance(thisYear, 8, 1);
        	update currentSeller;

        	Yearly_Target__c ytAfter = [Select Id, Name, Seller__c, Startweek__c, New_Sales_Target__c, Continuation_Sales_Target__c 
										From Yearly_Target__c Where Id = :yt.Id];
        	currentSeller.End_Date__c = Date.newInstance(thisYear, 11, 1);
        	update currentSeller;        	
        	Yearly_Target__c ytAfter2 = [Select Id, Name, Seller__c, Startweek__c, New_Sales_Target__c, Continuation_Sales_Target__c 
										From Yearly_Target__c Where Id = :yt.Id];
        	System.assert(ytAfter2.New_Sales_Target__c > ytAfter.New_Sales_Target__c);
        	System.assert(ytAfter2.Continuation_Sales_Target__c > ytAfter.Continuation_Sales_Target__c);
        }
	}

	@isTest static void testUpdateEndDateMulitpleSellers() {
		Integer thisYear = System.today().year();
        Date startDate = SEUtility.getFirstDayOfTeliaYear(thisYear);
        // each salesrep end date update will trigger update of >200 records, max number of DML rows is 10000, so max number odf sales reps is approx 40
		Integer noOfSalesReps = 10; 

        List<User> smeUserTeam;
        List<Seller__c> smeSellerTeam;
        List<Yearly_Target__c> smeSellerteamYT;
        List<User> salesRepList;
        List<Seller__c> sellerList;

        System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            // returns list of users {SalesUnitManager, SalesTeamManager, Seller}
            smeUserTeam = Test_DataFactory.createSmeUserTeam();
            // returns list of sellers {SalesUnitManager, SalesTeamManager, Seller}
            smeSellerTeam = Test_DataFactory.createSmeSellerTeam(smeUserTeam, startDate);
            // returns list of yearly targets {YT_SalesUnitManager, YT_SalesTeamManager, YT_Seller}.
            smeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(smeSellerTeam);

            // TEST Setup

            // Create Sales Rep and create Seller records for all Sales Reps
            salesRepList = new List<User>();
            for(integer i=0; i<noOfSalesReps; i++){
                salesRepList.add(Test_DataFactory.createSMEUser());
            }
            insert salesRepList;

            // Create Seller records for all Sales Reps
            sellerList = new List<Seller__c>();        
            for(User u : salesRepList){
                Seller__c s = Test_DataFactory.createSeller(u.Id, smeSellerTeam[1].Id);
                s.Start_Date__c = startDate;
                sellerList.add(s);
            }
            insert sellerList;
        }

        User salesManager = smeUserTeam[1];
        Seller__c salesManagerSeller = smeSellerTeam[1];

        //Create yearly targets
        Integer targetNewSales = 2000000;
        Integer targetContinuationSales = 1000000;

        List<Yearly_Target__c> ytList = new List<Yearly_Target__c>();
        for(Seller__c s : sellerList){            
            Yearly_Target__c ytNew = Test_DataFactory.createOneYearlyTarget(s);
            ytNew.Name = String.valueOf(thisYear);
            ytNew.Full_Year_New_Sales_Target__c = targetNewSales;
            ytNew.Full_Year_Continuation_Sales_Target__c = targetContinuationSales;
            ytList.add(ytNew);
        } 
        insert ytList;

        System.runAs(salesManager){
        	for(Seller__c s : sellerList){
        		s.End_Date__c = Date.newInstance(thisYear, 8, 1);
        	}
        	update sellerList;

        	Yearly_Target__c ytAfter = [Select Id, Name, Seller__c, Startweek__c, New_Sales_Target__c, Continuation_Sales_Target__c 
										From Yearly_Target__c Where Id = :ytList[0].Id];
        	System.assertNotEquals(targetNewSales, ytAfter.New_Sales_Target__c);
        	System.assertNotEquals(targetContinuationSales, ytAfter.Continuation_Sales_Target__c);
        }
	}
}