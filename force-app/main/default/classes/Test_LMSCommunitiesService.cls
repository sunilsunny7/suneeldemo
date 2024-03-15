@isTest
public class Test_LMSCommunitiesService {
  static testmethod void getTrainingPlanIdsForCategory(){  
        System.debug('@@Test no01_testGetActivitiesNoOrg Starts');
        Test_DataFactory.setUpOrg();

  List<User> adminUsers;
        List<User> lmsUsers;

        System.runAs(new User(Id = Userinfo.getUserId())){
            //Create admin users
            adminUsers = TestUtilClass.createUsers(2,'System Administrator');
            lmsUsers = TestUtilClass.createUsers(2,'Standard User');
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

   /*     TestTrainingPlanData.createSampleData();
        List<Training_Plan__c> tplans = [select id
                                            ,Enable_Self_Registration__c
                                            ,Self_Registration_Access__c
                                            from Training_Plan__c];

        System.assertEquals(1,tplans.size());
        Training_Plan__c tplan = tplans1.get(0);
        tplans.Enable_Self_Registration__c = true;
        tplans.Self_Registration_Access__c = 'Public';
        update tplans;*/
        
        List<Training_Plan_Category__c> cat = [select id,Learning_Category__c,Name,Training_Plan__c from Training_Plan_Category__c];
        List<Training_Track_Account__c> tc = [select id,Training_Track__c from Training_Track_Account__c];
        
        
        //create learning categories
        List<Learning_Category__c> learningCategories = TestLearningData.createTestLearningCategories(2);
        set<id> catId = new Set<Id>();     
        for(Learning_Category__c lc : learningCategories ){
          catId.add(lc.Id);
        } 
        
        //Create training plans
        TestParams.TrainingPlanParam tplan1 = new TestParams.TrainingPlanParam();
        TestParams.TrainingPlanParam tplan2 = new TestParams.TrainingPlanParam();
        TestParams.TrainingPlanParam tplan3 = new TestParams.TrainingPlanParam();
        List<Training_Plan__c> tplans = TestTrainingPlanData.createTrainingPlans(new List<TestParams.TrainingPlanParam>{tplan1,tplan2,tplan3});

        //Add learning categories to training plan
        List<Training_Plan_Category__c> tplanCategories = TestTrainingPlanData.createTrainingPlanCategories(tplans,learningCategories);

        Account a = new Account(Name='TestAccount');   
        insert a; 

       List<TestParams.TrainingTrackParam> params = new List<TestParams.TrainingTrackParam>();
        params.add(new TestParams.TrainingTrackParam());
        params.add(new TestParams.TrainingTrackParam());
        params.add(new TestParams.TrainingTrackParam());
        params.add(new TestParams.TrainingTrackParam());

        List<Training_Track__c> tracks = TestTrainingTrackData.createTrainingTracks(params);
        
        set<id> trackId = new Set<Id>();     
        for(Training_Track__c tId : tracks){
          trackId.add(tId.Id);
        }
        
        
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                LMSCommunitiesService cont = new LMSCommunitiesService ();
                LMSCommunitiesService.WithoutSharingOps ops = new LMSCommunitiesService.WithoutSharingOps();
                ops.getCategoryTrainingPlanMap(catId,a.id);
                ops.getTrainingPlanIdsForAccount(a.id);
                ops.getAccountTrainingTracks(a.id);
                ops.filterTrainingTracksForAccount(trackId,a.id,'Active');
                LMSCommunitiesService.getTrainingPlanIdsForCategory(catId,a.id);
              //  System.assert(cont.tPlan != null);
        
}
}

}