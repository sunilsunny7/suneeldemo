@isTest public class MC_QuoteListTest {
	@testSetup
    static void initTestData() {
        User salesManager;
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        
        System.runAs(salesManager){            
        Account acc = new Account();
        acc.Name='TestAccount';
        acc.Org_Nr__c =  '1234567890';
        acc.TSCID__c = 'TSCID5609';        
        Insert acc;        
        
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        contr.Agreement_Nr__c = '11100491';
        contr.recordtypeId = rt1.id;
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        contr.Status='Active';
        System.runAs(salesManager){update contr;}
        
        RecordType rt = [Select id,name, DeveloperName from RecordType where Name='Contract Quote'];
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();      
        
        Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Kvalificera';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            opp.AccountId = acc.Id;       
            insert opp; 
        
        Quote testQuote = new Quote();
        testQuote.Name= 'Test Quote';
        testQuote.OpportunityId = opp.Id;
        testQuote.Status = 'Draft';
        testQuote.Pricebook2Id = stdPriceBookRecId;
        testQuote.RecordTypeId = rt.Id;
        testQuote.vlocity_cmt__frameContractId__c=contr.id;
        insert testQuote;
        }
    }
    @isTest
    Static void test1(){
        Test.startTest();
        String oppid= [Select id from Opportunity].id;
        MC_QuoteList.getQuote(oppid);
        Test.stopTest();
    }
}