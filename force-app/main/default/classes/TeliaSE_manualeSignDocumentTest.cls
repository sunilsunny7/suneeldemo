@isTest
public class TeliaSE_manualeSignDocumentTest{

@isTest static void testupdateContract(){

    Test_DataFactory.setUpOrg();
        Account acc;
        Contract cntr;
        System.runAs(new User(Id = Userinfo.getUserId())){
            acc = Test_DataFactory.createOneLargeStandardAccount();
            insert acc;
            
        cntr = new Contract(AccountId = acc.Id);
        cntr.RecordtypeId = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
        cntr.Status = 'Draft';
        cntr.StartDate = system.today();
        insert cntr;
        
        cntr.status = 'Sent for Signing';
        update cntr;
        
        date sgdt = system.today();
        date rcdt = system.today();
        
        id cntrupId = manualeSignDocument.updateContract(cntr.id,sgdt,rcdt);
        }
}
    
    
 @isTest
    public static void documentNameChange()
    {
        System.runAs(Test_DataFactory.getByPassUser()){
            
            Account acc = new Account();
            acc.Name = 'Test Account';
            acc.Org_Nr__c = label.Account_Org_N;
            //acc.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales_Organisation_Account').getRecordTypeId();
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('SME/SOHO Organisation').getRecordTypeId();
            acc.Telia_Service_Manager__c = userInfo.getUserId();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
            
            Quote qut1 = new Quote();
            qut1.Name='Test Quote';
            qut1.status = 'Draft';
            qut1.opportunityId = opp.id;
            qut1.TeliaSE_Approval_Flag__c = False; 
            qut1.TeliaSE_Type__c='Renegotiation';
            insert qut1;
            
            Contract con = new Contract();
            con.AccountId = acc.Id;
            con.vlocity_cmt__QuoteId__c = qut1.id;
            con.StartDate = date.today();
            con.EndDate = date.today().addDays(4);
            insert con;
            
            ContentVersion cv = new ContentVersion();
			cv.Title = 'Test Image';
			cv.PathOnClient = 'Test_Image.pdf';
			cv.VersionData = Blob.valueOf('Test Image Data');
			cv.IsMajorVersion = true;
            cv.FirstPublishLocationId = con.id;
			insert cv;
            
            manualeSignDocument.DocumentTitle(con.id);
        }
    }    

}