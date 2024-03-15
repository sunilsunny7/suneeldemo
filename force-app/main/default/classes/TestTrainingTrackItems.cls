@isTest(SeeAllData=true)
    public class TestTrainingTrackItems{
    
      @isTest
       static void testTrainingTrackItem(){
           
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

         System.runAs(lmsUsers.get(0)){
         test.startTest();
         Training_Plan__c tp= new Training_Plan__c();
         insert tp;
         Achievement__c ach=new Achievement__c();
         insert ach;
         Training_Track__c tt= new Training_Track__c();
         tt.Name='abc';
         tt.Achievement__c=ach.id;
         insert tt;
         Training_Track_Level__c ttl = new Training_Track_Level__c();
         ttl.Order__c=1;
         ttl.Training_Track__c=tt.id;
         insert ttl;
         Training_Track_Level_Item__c ttli = new Training_Track_Level_Item__c();
         ttli.Training_Track_Level__c=ttl.id;
         ttli.Training_Plan__c=tp.id;
         insert ttli;
         Training_Plan_Assignment__c tpa=new Training_Plan_Assignment__c();
         tpa.Training_Plan__c=tp.id;
         insert tpa;
         
         Boolean isExpired = false;
        
         }
            
         
         TrainingTrackItem ttitem=new TrainingTrackItem();
         //ttitem.getItemURL();
         
    }
    
    }