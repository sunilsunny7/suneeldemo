@isTest
public class Test_CommitViewControllerLarge {
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
    }
    
    @isTest
    static void testCommit(){
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        List<Yearly_Target__c> largeSellerteamYT;
            
        System.runAs(new User(Id = Userinfo.getUserId())){
            // returns list of large users 
            largeUserTeam = Test_DataFactory.createLargeUserTeam(5);
            // returns list of sellers 
            largeSellerTeam = Test_DataFactory.createLargeSellerTeam(largeUserTeam,Date.parse('2015-01-01'));
            // returns list of yearly targets 
            largeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam);
        }

        User salesRep = largeUserTeam[4];
        Id sellerId;
        for(Seller__c s : largeSellerTeam){
            if(s.User__c == salesRep.Id){
                sellerId = s.Id;
            }
        }
        System.runAs(salesRep){  
         	CommitViewControllerLarge controller = new CommitViewControllerLarge();
            
            List<List<String>> judgeValues = new List<List<String>>();
            judgeValues.add(new List<String>{'44',sellerId,'2000','199'}); 
            
            PageReference reference = Page.CommitView;
            reference.getParameters().put('judgeValueString', JSON.serialize(judgeValues));
            Test.setCurrentPage(reference);
            
            controller.selectedQuarter = 'Q1';
            controller.selectedYear = String.valueOf(Date.today().year());
            
            PageReference commitSaved = controller.saveJudge();
            System.assertEquals('Commit Saved', controller.status, 'Commit was not saved');
       }
    }
    
    @isTest
    static void testCommitAsManager(){
        List<User> largeUserTeam;
        List<Seller__c> largeSellerTeam;
        List<Yearly_Target__c> largeSellerteamYT;

        System.runAs(new User(Id = Userinfo.getUserId())){
            // returns list of large users 
            largeUserTeam = Test_DataFactory.createLargeUserTeam(5);
            // returns list of sellers 
            largeSellerTeam = Test_DataFactory.createLargeSellerTeam(largeUserTeam,Date.parse('2015-01-01'));
            // returns list of yearly targets 
            largeSellerteamYT = Test_DataFactory.createYearlyTargetsSellerTeam(largeSellerTeam);
        }

        User manager = largeUserTeam[3];
        Id sellerId;
        for(Seller__c s : largeSellerTeam){
            if(s.User__c == manager.Id){
                sellerId = s.Id;
            }
        }
        System.runAs(manager){  
         	CommitViewControllerLarge controller = new CommitViewControllerLarge();
            
            List<List<String>> judgeValues = new List<List<String>>();
            judgeValues.add(new List<String>{'44',sellerId,'2000','199'}); 
            
            PageReference reference = Page.CommitView;
            reference.getParameters().put('judgeValueString', JSON.serialize(judgeValues));
            Test.setCurrentPage(reference);
            
            controller.selectedQuarter = 'Q1';
            controller.selectedYear = String.valueOf(Date.today().year());
            
            PageReference commitSaved = controller.saveJudge();
            System.assertEquals('Commit Saved', controller.status, 'Commit was not saved');
       }
    }
}