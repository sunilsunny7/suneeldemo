@isTest public class MCOnline_UpdateCancelledProducts_Test {
	@testSetup
    static void initTestData() {
        Account acc = new Account();
        acc.RecordTypeId = '012240000008l9YAAQ';
        acc.Name='TestAccount';
        acc.TSCID__c = 'TSCID_1234';
        Insert acc;
        
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Active';
        contr.RecordTypeId = '0121p00000114BeAAI';
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        Product2 prod1 = new Product2 (Name='Office 365', ProductCode = 'C-OFFICE-365',C2BC_Category__c = 'offerbundle',Family ='Online Order',
                                       vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Unspecified","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Unspecified","id":10,"displayText":"Unspecified"}],"values":[{"value":"Unspecified","id":10,"displayText":"Unspecified"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
        insert prod1;
        
        PricebookEntry objpricebookentry =new PricebookEntry();
        objpricebookentry.Product2ID = prod1.id;
        objpricebookentry.Pricebook2ID = stdPriceBookRecId;
        objpricebookentry.UnitPrice=23.50;
        objpricebookentry.UseStandardPrice=false;
        objpricebookentry.isActive=true;//Add this line
        insert objpricebookentry;
        
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        order.Pricebook2Id=stdPriceBookRecId;
        order.MCOnline_FirstName__c = 'Testing';
        order.MCOnline_LastName__c = 'class';
        insert order;
        
        OrderItem oitem = new OrderItem();
        oitem.Product2 = prod1;
        oitem.OrderId = order.Id;
        oitem.Quantity = 1;
        oitem.MCONL_Action_Code__c = 'Delete';
        oitem.PricebookEntryId = objpricebookentry.id;
        oitem.UnitPrice=12;
        oitem.MCONL_multiSubscriptionAssetIdentifier__c='123';
        oitem.vlocity_cmt__RecurringCharge__c=180;
        oitem.vlocity_cmt__OneTimeCharge__c = 190;
        insert oitem;
    }
    @istest
    static  void testupdate(){
        MCOnline_UpdateCancelledProducts cl = new MCOnline_UpdateCancelledProducts();
        cl.execute(null);
    }
}