@isTest
public class Test_OpportunityTriggerHandlerOppOwner{

 public static testmethod void nr27_renewalOwnerChangeAccess(){
       
        //To avoid MIXED_DML issue
        
        User uR1 = new User();
        User uR2 = new User();
        User uL1 = new User();
        User uC1 = new User();
        User uC2 = new User();
        string roleuC2 = '';
        system.runAs(new User(Id = UserInfo.getUserId())){
            List<User> renewalUserList = Test_DataFactory.createLargeRenewalUserTeam(2);
            //insert renewalUserList;
            uR1 = renewalUserList[0];
            uR2 = renewalUserList[1];
            List<user> largeUserList = Test_DataFactory.createLargeUserTeam(1);
            //insert LargeUserList;
            uL1 = largeUserList[0];
        
            uC1 = Test_DataFactory.createCygateUser();
            uC2 = Test_DataFactory.createCygateSalesSupportChef();
            insert uC1;
            insert uC2;
            roleuC2 = uC2.UserRoleId;
            
           
        }
        insert new Cygate_Manager_Roles__c(name = 'Cygate Manager Role',Role_ID__c = roleuC2,Role_Name__c = 'CG_Sales_Support_Norr');
        Account acc = new Account();
        List<Opportunity> oppList = new List<Opportunity>();        
        Opportunity opp1 = new Opportunity();
        Opportunity opp2 = new Opportunity();
        Opportunity oppCy = new Opportunity();
        System.runAs(Test_DataFactory.getByPassUser()){  // V.A  Bypassing User. To avoid MIXED_DML OPERATION
            acc = Test_DataFactory.createOneLargeStandardAccount();
            //acc.Cygate_Account_Manager__c = uC1.Id;
            Insert acc;
            acc.Cygate_Account_Manager__c = uC1.Id;
            Update acc;
            test.startTest();
            opp1 = Test_DataFactory.createLargeOpportunity();
            opp1.large_new_sales__c = 56;
            opp1.accountID = acc.id;
            opp1.OwnerId = uR1.Id;         
            opp1.Change_Owner_To__c = Null;
            insert opp1;
            //oppList.add(opp1);
            
            opp2 = Test_DataFactory.createLargeOpportunity();
            opp2.large_new_sales__c = 56;
            opp2.accountID = acc.id;
            opp2.OwnerId = uL1.Id;
            opp2.Change_Owner_To__c = Null;
            insert opp2;
            
            oppCy = Test_DataFactory.createCygateOpportunity();
            oppCy.OwnerId = uC2.Id;
            oppCy.AccountId = acc.Id;
            oppCy.Large_New_Sales__c = 0;
            oppCy.Large_Continuation_Sales__c = 1;
            oppCy.New_Sales__c = 0;
            oppCy.Continuation_Sales__c = 1;
            
            insert oppCy;
              
            string ermsg = '';          
            //test.startTest();//31st aug closed
            opp1.Change_Owner_To__c = uR2.id;
            try{
               update opp1;
            }
            catch(exception e){
                system.debug(e);
            }
              test.stopTest();  
            opp1.Change_Owner_To__c = uL1.Id;
            try{
                update opp1;
            }
            catch(exception e){
                system.debug(e);
            }
                          
            opp2.Change_Owner_To__c = uR1.Id;
            try{
               update opp2;
            }
            catch(exception e){
                system.debug(e);
            }
            /*
            opp1.Change_Owner_To__c = uR2.id;
            try{
                update opp1;
            }
            catch(exception e){
            system.debug(e);
            }
            */
            opp1.Change_Owner_To__c = uL1.Id;
            try{
                update opp1;
             }
            catch(exception e){
                system.debug(e);
            }
            /*
            opp2.Change_Owner_To__c = uR1.Id;
            try{
                    update opp2;
            }
            catch(exception e){
                system.debug(e);
            }*/
        
        //for cygate part of owner change
       
            oppCy.Change_Owner_To__c = uC1.Id;
            try{
            update oppCy;
            }
            catch(exception e){
                system.debug(e);
            }
           
        }
    }
}