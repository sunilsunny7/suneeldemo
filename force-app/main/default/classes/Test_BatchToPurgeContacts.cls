/**
 * Description: 
 * BatchToPurgeContacts test class.
 * 
 * Modifications:
 * 12.12.2022 [Tomass Brazovskis] SALEF-7206 - Removed Contact related Achievement_Assignment__c record insertion to enable 
 *              the removal of the obsolete Almond package (as Achievement_Assignment__c is Almond package's Custom Object).
 **/
@isTest
public class Test_BatchToPurgeContacts {

    /**@Description:
	 * Test the batch job removing inactive Contacts 
     * Modifications:
     *  12.12.2022 [TB] SALEF-7206 - Modified. Removed the creation of Achievement_Assignment__c records.
     *              Changed the class to perform transactions as a Bypass User.  
     **/
    private static testMethod void purgeContacts() {

        User testByPassUser = Test_DataFactory.getByPassUser();
        System.runAs(testByPassUser){               
            Account KKNRacc = Test_DataFactory.createOneKundkontoAccount();
            KKNRacc.Marketing_Mails_Opt_Out__c = 'According to agreement';
            KKNRacc.Process_Opt_Out__c = true;
            KKNRacc.Marketing_Mails_Opt_Out_Cygate__c = 'According to agreement';
            insert KKNRacc;

            //createOneLargeStandardAccount
            Account largeacc = Test_DataFactory.createOneLargeStandardAccount();
            largeacc.ParentId = KKNRacc.id;
            insert largeacc;

            List < Contact > conList = test_DataFactory.createContacts(4);
            for (contact c: conList) {
                c.AccountId = largeacc.Id;
                //c.Deactivation_Date__c= System.Today();

            }
            insert conlist;
            conList[1].RecordTypeId='01224000000LOYA';
            update conList[1];
            
            Asset ass = new Asset(Name='test',ContactId = conList[0].Id);
            insert ass;
            Buy_Interest__c bi= new Buy_Interest__c(Buy_Interest_Submitter__c=conList[1].Id); 
            insert bi;
            Campaign_activity__c ca= new Campaign_activity__c (Contact__c =conList[0].Id);
            insert ca;

            Campaign cp= new Campaign(name='test');
            insert cp;
            CampaignMember cm= new CampaignMember(CampaignId=cp.Id,ContactId= conList[0].Id);
            insert cm;
            Case cas= new Case(ContactId=conList[0].Id);
            insert cas;
            Contract contr= new Contract(AccountId=largeacc.Id,CustomerSignedId=conList[0].Id);
            insert contr;
            Lead l= new Lead(LastName='test',Company='telia', Email='test@1001.com', Contact__c =conList[0].Id);
            insert l;
            Order ord= new Order(AccountId=largeacc.Id,CustomerAuthorizedById =conList[0].Id,EffectiveDate=System.today(),Status='Draft');
            insert ord;
    
            conList[0].Deactivation_Date__c=System.today()- 2500;
            update conList[0];
            conList[1].Deactivation_Date__c=System.today()- 2500;
            update conList[1];
            conList[3].Deactivation_Date__c=System.today()- 220;
            update conList[2];
            
            
            Test.startTest();
            BatchToPurgeContacts toPurgeContacts = new BatchToPurgeContacts();
            DataBase.executeBatch(toPurgeContacts);

            Test.stopTest();
        }
    }
}