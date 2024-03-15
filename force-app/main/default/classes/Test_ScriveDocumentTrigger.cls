@isTest
public class Test_ScriveDocumentTrigger {
	public static testmethod void insertScrive(){
		Account acc = new Account();
        acc.Name = 'testAccount1';
        acc.Org_Nr__c = '5564867793';
        acc.RecordTypeId = '012240000008l9YAAQ';
        insert acc;
        
		Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        con.Email = 'praveena.taru@capgemini.com';
        con.MobilePhone = '465678876';
        insert con;        
		
        Opportunity opp = new Opportunity();
        opp.Name='testoppScrive';
        opp.AccountId=acc.Id;
        opp.CloseDate = System.today();
        opp.StageName='Needs Analysis';
        opp.Pricebook2Id=Test.getStandardPricebookId();
        opp.TeliaSE_MC_Signing_Contact__c=con.Id;
        insert opp;
		
		
		//Create document
		ContentVersion cv=new Contentversion();
		cv.title='ABC';
		cv.TeliaSE_MC_ExternalDataSourceId__c=opp.Id;//Associated opportunity
		cv.PathOnClient ='test';
		cv.TeliaSE_MC_Agreement_Number__c ='agreementnumber';
		cv.TeliaSE_MC_ReplaceAgreement__c ='agree';
		cv.TeliaSE_MC_Product__c ='product';
		cv.TeliaSE_MC_Note__c ='notes';
		cv.TeliaSE_MC_Start_Date__c =Date.newInstance(2020, 2, 17);
		cv.TeliaSE_MC_End_Date__c =Date.newInstance(2021, 2, 17);
		cv.TeliaSE_MC_DocumentType__c ='doc type';
		Blob b=Blob.valueOf('Unit Test Attachment Body');
		cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
		insert cv;
		
		//Scrive Document Record creation
		scrive__ScriveDocument__c sc = new scrive__ScriveDocument__c();
		sc.name='abc';
		sc.scrive__opportunity__c = opp.Id;//Associated opportunity
		insert sc;
	}
}