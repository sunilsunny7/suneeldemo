@isTest
public class MC_PriceIndexingTest {
    
    @testSetup
    static void initTestData() {
        User salesManager;
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
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
        
        Product2 prod1 = new Product2 (Name='Jobbmobil 40 GB', ProductCode = 'MOB_MULTI_40_V2',C2BC_Category__c = 'mobilevoicesubscription', vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Unspecified","id":10,"displayText":"Unspecified"}],"values":[{"value":"Unspecified","id":10,"displayText":"Unspecified"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
        insert prod1;
        Date today=Date.today();
        
        MC_PriceIndexationCriteria__c indexation = new MC_PriceIndexationCriteria__c();
        indexation.MC_CurrentBaseValue__c = '450';
        insert indexation;
        
        vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
        cli.vlocity_cmt__Product2Id__c = prod1.id;
        cli.MC_IndexationCriteria__c = indexation.id;
        cli.MC_IndexedDate__c = Date.today();
        cli.MC_PriceUpdateType__c = 'Indexed price update';        
        cli.TeliaSE_ParentItemId__c = Null;
        cli.vlocity_cmt__ContractId__c = contr.id;
        insert cli;
    }
    
    @isTest
    Static void testPriceIndex(){
        String contractid= [Select id from contract where Agreement_Nr__c = '11100491'].id;
        MC_PriceIndexing.getPriceIndexingInfo(contractid);
    }
}