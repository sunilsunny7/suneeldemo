@isTest
public class Test_CreateApprovalURL {
    public static string quId;
    public static string smId;
    @testSetup static void setup()
    {
        User salesManager;   
        User salesApprover;
        
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        System.runAs(new User(Id = Userinfo.getUserId()))
        {    
            salesApprover = Test_DataFactory.createAdminUser();
            insert salesApprover;
            salesManager = Test_DataFactory.createAdminUser();
            SalesManager.TeliaSE_Role_based_Approver__c = salesApprover.id;
            salesManager.Bypass_VR__c = true;
            insert salesManager;
            smId = salesManager.Id;
        }
        System.runAs(salesManager)
        {
            Account acc=Test_DataFactory.createOneSMEAccount();
            insert acc;
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.AccountId=acc.Id;
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';
            opp.Pricebook2Id=Test.getStandardPricebookId();
            insert opp;
       Product2 prod = Test_DataFactory.createProducts(1)[0];
        insert prod;
        
         PricebookEntry objpricebookentry =new PricebookEntry();
         objpricebookentry.Product2ID = prod.id;
         objpricebookentry.Pricebook2ID = stdPriceBookRecId;
         objpricebookentry.UnitPrice=23.50;
         objpricebookentry.UseStandardPrice=false;
         objpricebookentry.isActive=true;//Add this line
         insert objpricebookentry;  
            
            Quote qut1 = new Quote();
        qut1.Name='Test Quote';
        qut1.status = 'Draft';
        qut1.opportunityId = opp.id;
        qut1.Pricebook2ID = stdPriceBookRecId;
        qut1.TeliaSE_Approval_Flag__c = False; 
        qut1.TeliaSE_Type__c='Renegotiation';
        insert qut1;
        quId = qut1.Id;
           
        
        }
    /*}
    public static testMethod void testController()
    {*/
        List<Id> ids=new List<Id>();
        String comments='Blah';
        Quote quote=[select id from Quote WHERE ID =: quId limit 1 ];
        User appuser = [Select Id from USER WHERE TeliaSE_Role_based_Approver__c <> Null AND IsActive = TRUE AND Id=:smid  limit 1];
        System.runAs(appuser)
        {   
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments(comments);
            req.setObjectId(quote.Id);
            req.setNextApproverIds(ids);

            Approval.ProcessResult result = Approval.process(req);
           CreateApprovalURL.generateApprovalURL(quote.id);
       }
    }
}