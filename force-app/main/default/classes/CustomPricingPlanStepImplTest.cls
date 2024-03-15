/**
* Created by somalmac on 6/18/18.
* Updated - Dipanwita Dutta 
* Update test methods test1() and test2()
* Created Test Matrix Setup - created the calculation matrix, calculation procedure and the procedure steps
* Created Test Product Setup (Office 365), added Quote and QuoteLineItems
*/
@isTest(SeeAllData=false)
public class CustomPricingPlanStepImplTest {
    
    private static String namespace = 'vlocity_cmt__';
    
    // Intitialized in Setup, used throughout
    public static vlocity_cmt__CalculationMatrixVersion__c version;
    public static vlocity_cmt__CalculationMatrix__c parent;
    public static List<vlocity_cmt__CalculationMatrixRow__c> lineItems;
    private static Id orderId;
    private static boolean flag;  //used to upload matrix row data for test1 or test2
    private static Id quoteId, quoteId2; // added by Dipanwita
    static TeliaSERecordTypeSetting__mdt TeliaSERecordTypeSetting;
    
    @testSetup
    static void initTestData() {
        Test_DataFactory.setUpOrg();
        
        TeliaSERecordTypeSetting = returnTestingMetadataRecord();
        FiberDiscountMandate__c fb = new FiberDiscountMandate__c();
        fb.Role__c = 'Manager';
        fb.Name = 'Manager';
        fb.EBIT_Max_Mandate__c = 12;
        fb.EBIT_Min_Mandate__c = 1;
        fb.ProductDiscountMaxMandate__c = 12;
        fb.ProductDiscountMinMandate__c = 12;
        insert fb;
        
        FiberDiscountMandate__c fb1 = new FiberDiscountMandate__c();
        fb1.Role__c = 'Director';
        fb1.Name = 'Director';
        fb1.EBIT_Max_Mandate__c = 12;
        fb1.EBIT_Min_Mandate__c = 1;
        fb1.ProductDiscountMaxMandate__c = 12;
        fb1.ProductDiscountMinMandate__c = 12;
        insert fb1; 
    }
    
    @isTest
    static void createAccount(){
        Account testAcc;
        System.runAs(new User(Id = Userinfo.getUserId())){
            testAcc =Test_DataFactory.createOneKundkontoAccount();
            insert testAcc;
        }      
    }
    
    static private testmethod void updateDiscount(){
        
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = true;
        
        testProductSetup();
        testMatrixSetup();
        Id quoRtid = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('Individual Quote').getRecordTypeId();
        
        /*-- Opportunity opp = new Opportunity();
opp.Name='opp1';
opp.CloseDate = System.today();
opp.StageName='01 Prospect';
opp.Pricebook2Id=Test.getStandardPricebookId();

insert opp;*/
        Id AccRtid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account acc = new Account(Name='Test Account', recordtypeid = AccRtid);
        Test.startTest();
        insert acc;
        //Test.startTest();
        //Id OppRtid =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Real Estate Fiber').getRecordTypeId();
        Id OppRtid =Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Connected & Smart Building').getRecordTypeId();
        
        //Connected & Smart Building
        Opportunity opp = new Opportunity(Name='opp1',AccountId=acc.Id,CloseDate=system.today(),stageName='01 Prospect',recordtypeid = OppRtid);
        insert opp;
        
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        Quote quoteSObject = new Quote();
        quoteSObject.Name='Test Quote';
        quoteSObject.status = 'Draft';
        quoteSObject.RecordTypeId = quoRtid;
        quoteSObject.opportunityId = opp.id;
        quoteSObject.Pricebook2ID = stdPriceBookRecId;
        quoteSObject.TeliaSE_Approval_Flag__c = False;        
        insert quoteSObject;
        
        
        sObject targetProduct1 = [ SELECT Id, Name, vlocity_cmt__JSONAttribute__c FROM Product2 WHERE Name = 'Office 365'];
        
        //sObject quoteSObject =[Select Id , RecordTypeId, RecordType.DeveloperName FROM Quote WHERE Id =: quoteId];
        List<SObject> quoteItemList =[SELECT Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode,
                                      PricebookEntry.Product2.vlocity_cmt__JSONAttribute__c,vlocity_cmt__RootItemId__c,vlocity_cmt__AssetReferenceId__c,
                                      vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                                      vlocity_cmt__LineNumber__c, vlocity_cmt__PricingLogData__c, vlocity_cmt__OneTimeCharge__c,
                                      vlocity_cmt__Product2Id__c, Quantity, ListPrice, UnitPrice,
                                      vlocity_cmt__ProductHierarchyPath__c, Product2Id, vlocity_cmt__EffectiveQuantity__c,
                                      vlocity_cmt__InCartQuantityMap__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__ServiceAccountId__r.Id,
                                      vlocity_cmt__ServiceAccountId__r.Name, vlocity_cmt__ServiceAccountId__r.RecordTypeId,
                                      vlocity_cmt__BillingAccountId__c, vlocity_cmt__BillingAccountId__r.Id,
                                      vlocity_cmt__BillingAccountId__r.Name, vlocity_cmt__BillingAccountId__r.RecordTypeId,
                                      TeliaSE_Base_Quantity__c,TeliaSE_PriceTypeCategory__c,vlocity_cmt__ParentItemId__c,TeliaSE_MC_Customer_Requested_Price__c
                                      FROM QuoteLineItem 
                                      WHERE QuoteId =: quoteId];
        List<SObject> updatedQuoteItemList = new List<SObject>();
        for(SObject eachQLI : quoteItemList){
            QuoteLineItem qLI = (QuoteLineItem)eachQLI;
            //qLI.QuoteId = quoteSObject.Id;
            if(qLI.vlocity_cmt__AssetReferenceId__c == qLI.vlocity_cmt__RootItemId__c){
                qLI.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Uncommitted","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"Uncommitted","id":10,"value":"Uncommitted"}],"values":[{"displayText":"Uncommitted","id":10,"value":"Uncommitted"},{"displayText":"24 months","id":20,"value":"24"},{"displayText":"36 months","id":30,"value":"36"}],"selectedItem":{"displayText":"Uncommitted","id":10,"value":"Uncommitted"}},"isnottranslatable__c":false,"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number","value":8},"isnottranslatable__c":false,"$$AttributeDefinitionEnd$$":null}]}';
            }
            updatedQuoteItemList.add(qLI);
        }
        
        update updatedQuoteItemList;        
        
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', quoteSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', updatedQuoteItemList);
        
        input.put('ProcedureName','RangeAttributePricingProcedure');
        input.put('MatrixName','RangeAttributePricingMatrix');        
        input.put('RangeFields','Quantity');       
        
        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);
        
        for(SObject quoteItem : quoteItemList){
            if(quoteItem.get('vlocity_cmt__RecurringCharge__c')!=null)
            {
                System.assert(quoteItem.get('vlocity_cmt__RecurringCharge__c') == 300 );
                System.assert(quoteItem.get('vlocity_cmt__OneTimeCharge__c') == 125 );
            }
        }
        
        TeliaSERecordTypeSetting = returnTestingMetadataRecord();
        PricingPlanHelper helper=new PricingPlanHelper();
        helper.invokeMethod('abc',input,output,options);
        //helper.invokeMethod('updateDiscount',input,output,options);
        helper.invokeMethod('updateFlag',input,output,options);
        Test.stopTest();
    }
    private static TeliaSERecordTypeSetting__mdt  returnTestingMetadataRecord() {
        return [SELECT Id, 
                MassCustomized__c, 
                CRMFiber__c, 
                QualifiedApiName, 
                Label, 
                NamespacePrefix, 
                Language, 
                MasterLabel, 
                DeveloperName 
                FROM TeliaSERecordTypeSetting__mdt
                WHERE  MasterLabel in ('Quote')];
    }
    //Negative Scenario 
    static private testmethod void test3(){
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String,Object>();
        Map<String, Object> input = new Map<String, Object>();
        flag = true;
        
        Test.startTest();
        testProductSetup();
        testMatrixSetup();
        
        sObject targetProduct1 = [ SELECT Id, Name, vlocity_cmt__JSONAttribute__c FROM Product2 WHERE Name = 'Office 365'];
        
        sObject quoteSObject =[Select Id , RecordTypeId, RecordType.DeveloperName FROM Quote WHERE Id =: quoteId];
        List<SObject> quoteItemList =[SELECT Id, PricebookEntryId, PricebookEntry.Product2.Name, PricebookEntry.Product2.ProductCode,
                                      PricebookEntry.Product2.vlocity_cmt__JSONAttribute__c,vlocity_cmt__RootItemId__c,vlocity_cmt__AssetReferenceId__c,
                                      vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProvisioningStatus__c, vlocity_cmt__RecurringCharge__c,
                                      vlocity_cmt__LineNumber__c, vlocity_cmt__PricingLogData__c, vlocity_cmt__OneTimeCharge__c,
                                      vlocity_cmt__Product2Id__c, Quantity, ListPrice, UnitPrice,
                                      vlocity_cmt__ProductHierarchyPath__c, Product2Id, vlocity_cmt__EffectiveQuantity__c,
                                      vlocity_cmt__InCartQuantityMap__c, vlocity_cmt__ServiceAccountId__c, vlocity_cmt__ServiceAccountId__r.Id,
                                      vlocity_cmt__ServiceAccountId__r.Name, vlocity_cmt__ServiceAccountId__r.RecordTypeId,
                                      vlocity_cmt__BillingAccountId__c, vlocity_cmt__BillingAccountId__r.Id,
                                      vlocity_cmt__BillingAccountId__r.Name, vlocity_cmt__BillingAccountId__r.RecordTypeId,
                                      TeliaSE_Base_Quantity__c,TeliaSE_PriceTypeCategory__c
                                      FROM QuoteLineItem 
                                      WHERE QuoteId =: quoteId];
        vlocity_cmt.PricingPlanService.putInPricingContext('Parent', quoteSObject);
        vlocity_cmt.PricingPlanService.putInPricingContext('LineItemList', quoteItemList);
        
        
        input.put('ProcedureName','');
        input.put('MatrixName','RangeAttributePricingMatrix');        
        input.put('RangeFields','Quantity');  
        CustomPricingPlanStepImpl testing = new CustomPricingPlanStepImpl();
        testing.invokeMethod('GetMatrixPrice',input,output,options);    
        
        Test.stopTest();
        
        
    }
    /*
static public testmethod void test_updateApprovalFlag(){

List<QuoteLineItem> qlist = new List<QuoteLineItem>();
List<QuoteLineItem> abc = new List<QuoteLineItem>([SELECT Id FROM Quotelineitem LIMIT 10]);
for (QuoteLineItem qli : abc) {
qli.TeliaSE_Approved_Price__c = 20;
qli.TeliaSE_Nullify_Check__c =false;
qlist.add(qli);
}
Double fprice = 5;
Double floorper = 10;

PricingPlanHelper.updateApprovalFlag(qlist,fprice,floorper);  

}*/
    
    // added by Dipanwita - calculation matrix, calculation procedure and procedure steps
    
    static private void testMatrixSetup() {
        insert new vlocity_cmt__TriggerSetup__c(Name = 'AllTriggers', vlocity_cmt__IsTriggerOn__c = true);        
        parent = new vlocity_cmt__CalculationMatrix__c(Name = 'RangeAttributePricingMatrix');
        insert parent;
        
        version = new vlocity_cmt__CalculationMatrixVersion__c(Name = 'RangeAttributePricingMatrix V2', vlocity_cmt__VersionNumber__c = 2,
                                                               vlocity_cmt__IsEnabled__c = false, vlocity_cmt__CalculationMatrixId__c = parent.Id,
                                                               vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-10), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(10),vlocity_cmt__Priority__c = 2);
        insert version;
        
        //Populating Headers
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Characteristic Name","listValues":null,"lineItemId":"a311l0000000DnLAAU","label":null,"headerType":"Input","displayOrder":3,"dataType":"Text","columnKey":"26ee5f"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Source Product Code","listValues":null,"lineItemId":"a311l0000000DnKAAU","label":null,"headerType":"Input","displayOrder":2,"dataType":"Text","columnKey":"3a0611"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Source Product Name","listValues":null,"lineItemId":"a311l0000000DnJAAU","label":null,"headerType":"Input","displayOrder":1,"dataType":"Text","columnKey":"13c541"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Characteristic Value","listValues":null,"lineItemId":"a311l0000000DnMAAU","label":null,"headerType":"Input","displayOrder":4,"dataType":"Text","columnKey":"2a0cd2"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Quantity","listValues":null,"lineItemId":"a311l0000000DnNAAU","label":null,"headerType":"Input","displayOrder":5,"dataType":"Text","columnKey":"bd81e8"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"Target Product Name","listValues":null,"lineItemId":"a311l0000000DnVAAU","label":null,"headerType":"Output","displayOrder":14,"dataType":"Text","columnKey":"1f3956"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MRC","listValues":null,"lineItemId":"a311l0000000DnOAAU","label":null,"headerType":"Output","displayOrder":6,"dataType":"Text","columnKey":"7cdae9"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"NRC","listValues":null,"lineItemId":"a311l0000000DnIAAU","label":null,"headerType":"Output","displayOrder":7,"dataType":"Text","columnKey":"7cea71"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MC Discount Percentage","listValues":null,"lineItemId":"a311l0000000DnQAAU","label":null,"headerType":"Output","displayOrder":8,"dataType":"Percent","columnKey":"bf59bc"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MC CM Mandate Discount","listValues":null,"lineItemId":"a311l0000000DnRAAU","label":null,"headerType":"Output","displayOrder":9,"dataType":"Percent","columnKey":"b295c3"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MC SM Mandate Discount","listValues":null,"lineItemId":"a311l0000000DnSAAU","label":null,"headerType":"Output","displayOrder":10,"dataType":"Percent","columnKey":"f00e31"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MC AM Mandate Discount","listValues":null,"lineItemId":"a311l0000000DnTAAU","label":null,"headerType":"Output","displayOrder":11,"dataType":"Percent","columnKey":"ca485a"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"MC SD Mandate Discount","listValues":null,"lineItemId":"a311l0000000DnUAAU","label":null,"headerType":"Output","displayOrder":12,"dataType":"Percent","columnKey":"b1664a"}'
                                                              ));
        lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id, Name = 'Header',
                                                               vlocity_cmt__InputData__c ='{"name":"PricePlanCode","listValues":null,"lineItemId":"a311l0000000DnPAAU","label":null,"headerType":"Output","displayOrder":13,"dataType":"Text","columnKey":"4b11bf"}'
                                                              ));
        insert lineItems;
        
        //Populating Row Data
        lineItems = new List<vlocity_cmt__CalculationMatrixRow__c>();
        
        if(flag)  //running test2
        {
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                                   vlocity_cmt__InputData__c ='{"Quantity":"1-5","Characteristic Value":"Uncommitted","Characteristic Name":"Commitment Period","Source Product Code":"C-BUS-ESSEN-OFFER","Source Product Name":"Business Essential Offer"}',
                                                                   vlocity_cmt__OutputData__c = '{"Target Product Name":"Business Essential Offer","PricePlanCode":"NA","MC SD Mandate Discount":0.0,"MC AM Mandate Discount":0.0,"MC SM Mandate Discount":0.0,"MC CM Mandate Discount":0.0,"MC Discount Percentage":0.0,"NRC":"0","MRC":"44"}'
                                                                  ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                                   vlocity_cmt__InputData__c ='{"Quantity":"6-10","Characteristic Value":"Uncommitted","Characteristic Name":"Commitment Period","Source Product Code":"C-BUS-ESSEN-OFFER","Source Product Name":"Business Essential Offer"}',
                                                                   vlocity_cmt__OutputData__c = '{"Target Product Name":"Business Essential Offer","PricePlanCode":"NA","MC SD Mandate Discount":0.0,"MC AM Mandate Discount":0.0,"MC SM Mandate Discount":0.0,"MC CM Mandate Discount":0.0,"MC Discount Percentage":0.0,"NRC":"0","MRC":"44"}'
                                                                  ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                                   vlocity_cmt__InputData__c ='{"Quantity":"11-20","Characteristic Value":"Uncommitted","Characteristic Name":"Commitment Period","Source Product Code":"C-BUS-ESSEN-OFFER","Source Product Name":"Business Essential Offer"}',
                                                                   vlocity_cmt__OutputData__c = '{"Target Product Name":"Business Essential Offer","PricePlanCode":"NA","MC SD Mandate Discount":0.0,"MC AM Mandate Discount":0.0,"MC SM Mandate Discount":0.0,"MC CM Mandate Discount":0.0,"MC Discount Percentage":0.0,"NRC":"0","MRC":"44"}'
                                                                  ));
            lineItems.add(new vlocity_cmt__CalculationMatrixRow__c(vlocity_cmt__CalculationMatrixVersionId__c = version.Id,
                                                                   vlocity_cmt__InputData__c ='{"Quantity":"21-50","Characteristic Value":"Uncommitted","Characteristic Name":"Commitment Period","Source Product Code":"C-BUS-ESSEN-OFFER","Source Product Name":"Business Essential Offer"}',
                                                                   vlocity_cmt__OutputData__c = '{"Target Product Name":"Business Essential Offer","PricePlanCode":"NA","MC SD Mandate Discount":0.0,"MC AM Mandate Discount":0.0,"MC SM Mandate Discount":0.0,"MC CM Mandate Discount":0.0,"MC Discount Percentage":5.0,"NRC":"0","MRC":"44"}'
                                                                  ));
        }
        
        insert lineItems;
        
        //lineItems = [SELECT Name, vlocity_cmt__InputData__c, vlocity_cmt__OutputData__c FROM vlocity_cmt__CalculationMatrixRow__c WHERE Name != 'Header'];
        update new vlocity_cmt__CalculationMatrixVersion__c(Id = version.Id, vlocity_cmt__IsEnabled__c = true);
        
        //service
        vlocity_cmt__CalculationProcedure__c calcProcedure = new vlocity_cmt__CalculationProcedure__c(Name='RangeAttributePricingProcedure');
        insert calcProcedure;
        
        //Making isEnabled = false due to ERROR="Please add steps before enabling this procedure configuration."
        vlocity_cmt__CalculationProcedureVersion__c procVersion = new vlocity_cmt__CalculationProcedureVersion__c(Name='RangeAttributePricingProcedure v2', vlocity_cmt__VersionNumber__c=2, vlocity_cmt__IsEnabled__c=false,
                                                                                                                  vlocity_cmt__CalculationProcedureId__c=calcProcedure.Id, vlocity_cmt__StartDateTime__c = DateTime.now().addDays(-5), vlocity_cmt__EndDateTime__c = DateTime.now().addDays(5), vlocity_cmt__Priority__c=2);
        insert procVersion;
        
        List<vlocity_cmt__CalculationProcedureStep__c> steps = new List<vlocity_cmt__CalculationProcedureStep__c> ();
        vlocity_cmt__CalculationProcedureStep__c step1 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQm', vlocity_cmt__Sequence__c=1,vlocity_cmt__Function__c='Matrix Lookup', vlocity_cmt__CalculationMatrixId__c=parent.Id, vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                       vlocity_cmt__Input__c='[{"name":"Source Product Name","listValues":null,"label":null,"dataType":"Text","columnKey":"13c541"},{"name":"Source Product Code","listValues":null,"label":null,"dataType":"Text","columnKey":"3a0611"},{"name":"Characteristic Name","listValues":null,"label":null,"dataType":"Text","columnKey":"26ee5f"},{"name":"Characteristic Value","listValues":null,"label":null,"dataType":"Text","columnKey":"2a0cd2"},{"name":"Quantity","listValues":null,"label":null,"dataType":"Text","columnKey":"bd81e8"}]',
                                                                                                       vlocity_cmt__OutputMappingJSON__c ='{"NRC":"RangeAttributePricingMatrix__NRC","MRC":"RangeAttributePricingMatrix__MRC","PricePlanCode":"RangeAttributePricingMatrix__PricePlanCode","MC Discount Percentage":"RangeAttributePricingMatrix__MCDiscountPercentage","MC CM Mandate Discount":"RangeAttributePricingMatrix__MCCMMandateDiscount","MC SM Mandate Discount":"RangeAttributePricingMatrix__MCSMMandateDiscount","MC AM Mandate Discount":"RangeAttributePricingMatrix__MCAMMandateDiscount","MC SD Mandate Discount":"RangeAttributePricingMatrix__MCSDMandateDiscount","Target Product Name":"RangeAttributePricingMatrix__TargetProductName"}',
                                                                                                       vlocity_cmt__OutputJSON__c='[{"name":"NRC","listValues":null,"label":null,"dataType":"Text","columnKey":"7cea71"},{"name":"MRC","listValues":null,"label":null,"dataType":"Text","columnKey":"7cdae9"},{"name":"PricePlanCode","listValues":null,"label":null,"dataType":"Text","columnKey":"4b11bf"},{"name":"MC Discount Percentage","listValues":null,"label":null,"dataType":"Percent","columnKey":"bf59bc"},{"name":"MC CM Mandate Discount","listValues":null,"label":null,"dataType":"Percent","columnKey":"b295c3"},{"name":"MC SM Mandate Discount","listValues":null,"label":null,"dataType":"Percent","columnKey":"f00e31"},{"name":"MC AM Mandate Discount","listValues":null,"label":null,"dataType":"Percent","columnKey":"ca485a"},{"name":"MC SD Mandate Discount","listValues":null,"label":null,"dataType":"Percent","columnKey":"b1664a"},{"name":"Target Product Name","listValues":null,"label":null,"dataType":"Text","columnKey":"1f3956"}]');
        
        vlocity_cmt__CalculationProcedureStep__c step2 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQn', vlocity_cmt__Sequence__c=2,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                       vlocity_cmt__CalculationFormulaLong__c='RangeAttributePricingMatrix__MRC', 
                                                                                                       vlocity_cmt__OutputJSON__c='{"name":"REC_MNTH_STD_PRC","dataType":"Currency","alias":"REC_MNTH_STD_PRC"}',
                                                                                                       vlocity_cmt__OutputMappingJSON__c = '{"REC_MNTH_STD_PRC":"REC_MNTH_STD_PRC"}', 
                                                                                                       vlocity_cmt__CalculationFormulaTags__c='[{"text":"MRC ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MRC","userDefined":false,"dataType":"Text"}]');
        
        vlocity_cmt__CalculationProcedureStep__c step3 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQo', vlocity_cmt__Sequence__c=3,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                       vlocity_cmt__CalculationFormulaLong__c='RangeAttributePricingMatrix__NRC',
                                                                                                       vlocity_cmt__OutputMappingJSON__c = '{"OT_STD_PRC":"OT_STD_PRC"}',
                                                                                                       vlocity_cmt__OutputJSON__c='{"name":"OT_STD_PRC","dataType":"Currency","alias":"OT_STD_PRC"}',
                                                                                                       vlocity_cmt__CalculationFormulaTags__c='[{"text":"NRC ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__NRC","userDefined":false,"dataType":"Text"}]' );
        
        vlocity_cmt__CalculationProcedureStep__c step4 = new vlocity_cmt__CalculationProcedureStep__c (Name='a1L46000001ASQp', vlocity_cmt__Sequence__c=4,vlocity_cmt__Function__c='Calculation', vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                       vlocity_cmt__CalculationFormulaLong__c='RangeAttributePricingMatrix__MCDiscountPercentage',
                                                                                                       vlocity_cmt__OutputMappingJSON__c = '{"REC_MNTH_DISC_PERCENTAGE":"REC_MNTH_DISC_PERCENTAGE"}',
                                                                                                       vlocity_cmt__OutputJSON__c='{"name":"REC_MNTH_DISC_PERCENTAGE","dataType":"Percent","alias":"REC_MNTH_DISC_PERCENTAGE"}',
                                                                                                       vlocity_cmt__CalculationFormulaTags__c='[{"text":"MC Discount Percentage ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MCDiscountPercentage","userDefined":false,"dataType":"Percent"}]' );
        
        vlocity_cmt__CalculationProcedureStep__c step5 = new vlocity_cmt__CalculationProcedureStep__c(Name ='a1L46000001ASQq', vlocity_cmt__Sequence__c=5, vlocity_cmt__Function__c='Calculation',vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                      vlocity_cmt__CalculationFormulaLong__c ='RangeAttributePricingMatrix__MCAMMandateDiscount', 
                                                                                                      vlocity_cmt__OutputMappingJSON__c ='{"REC_MNTH_AM_MANDATE_DISC":"REC_MNTH_AM_MANDATE_DISC"}',
                                                                                                      vlocity_cmt__OutputJSON__c ='{"name":"REC_MNTH_AM_MANDATE_DISC","dataType":"Percent","alias":"REC_MNTH_AM_MANDATE_DISC"}' ,
                                                                                                      vlocity_cmt__CalculationFormulaTags__c= '[{"text":"MC AM Mandate Discount ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MCAMMandateDiscount","userDefined":false,"dataType":"Percent"}]' );
        
        vlocity_cmt__CalculationProcedureStep__c step6 = new vlocity_cmt__CalculationProcedureStep__c(Name ='a1L46000001ASQq', vlocity_cmt__Sequence__c=6, vlocity_cmt__Function__c='Calculation',vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                      vlocity_cmt__CalculationFormulaLong__c ='RangeAttributePricingMatrix__MCSDMandateDiscount', 
                                                                                                      vlocity_cmt__OutputMappingJSON__c ='{"REC_MNTH_SD_MANDATE_DISC":"REC_MNTH_SD_MANDATE_DISC"}',
                                                                                                      vlocity_cmt__OutputJSON__c ='{"name":"REC_MNTH_SD_MANDATE_DISC","dataType":"Percent","alias":"REC_MNTH_SD_MANDATE_DISC"}' ,
                                                                                                      vlocity_cmt__CalculationFormulaTags__c= '[{"text":"MC SD Mandate Discount ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MCSDMandateDiscount","userDefined":false,"dataType":"Percent"}]');
        
        vlocity_cmt__CalculationProcedureStep__c step7 = new vlocity_cmt__CalculationProcedureStep__c(Name ='a1L46000001ASQq', vlocity_cmt__Sequence__c=7, vlocity_cmt__Function__c='Calculation',vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                      vlocity_cmt__CalculationFormulaLong__c ='RangeAttributePricingMatrix__MCCMMandateDiscount', 
                                                                                                      vlocity_cmt__OutputMappingJSON__c ='{"REC_MNTH_CM_MANDATE_DISC":"REC_MNTH_CM_MANDATE_DISC"}',
                                                                                                      vlocity_cmt__OutputJSON__c ='{"name":"REC_MNTH_CM_MANDATE_DISC","dataType":"Percent","alias":"REC_MNTH_CM_MANDATE_DISC"}' ,
                                                                                                      vlocity_cmt__CalculationFormulaTags__c= '[{"text":"MC CM Mandate Discount ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MCCMMandateDiscount","userDefined":false,"dataType":"Percent"}]');
        
        vlocity_cmt__CalculationProcedureStep__c step8 = new vlocity_cmt__CalculationProcedureStep__c(Name ='a1L46000001ASQq', vlocity_cmt__Sequence__c=8, vlocity_cmt__Function__c='Calculation',vlocity_cmt__IsIncludedInResult__c=true, vlocity_cmt__CalculationProcedureVersionId__c= procVersion.Id,
                                                                                                      vlocity_cmt__CalculationFormulaLong__c ='RangeAttributePricingMatrix__MCSMMandateDiscount', 
                                                                                                      vlocity_cmt__OutputMappingJSON__c ='{"REC_MNTH_SM_MANDATE_DISC":"REC_MNTH_SM_MANDATE_DISC"}',
                                                                                                      vlocity_cmt__OutputJSON__c ='{"name":"REC_MNTH_SM_MANDATE_DISC","dataType":"Percent","alias":"REC_MNTH_SM_MANDATE_DISC"}' ,
                                                                                                      vlocity_cmt__CalculationFormulaTags__c= '[{"text":"MC SM Mandate Discount ( RangeAttributePricingMatrix )","alias":"RangeAttributePricingMatrix__MCSMMandateDiscount","userDefined":false,"dataType":"Percent"}]');
        
        steps.add(step1);
        steps.add(step2);
        steps.add(step3);
        steps.add(step4);
        steps.add(step5);
        steps.add(step6);
        steps.add(step7);
        steps.add(step8);        
        insert steps;
        
        List<vlocity_cmt__CalculationProcedureVariable__c> calcProcVariableList = new List<vlocity_cmt__CalculationProcedureVariable__c>{
            new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_STD_PRC',vlocity_cmt__alias__c='REC_MNTH_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='OT_STD_PRC',vlocity_cmt__alias__c='OT_STD_PRC',vlocity_cmt__datatype__c='Currency',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Name',vlocity_cmt__alias__c='SourceProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Source Product Code',vlocity_cmt__alias__c='SourceProductCode',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Name',vlocity_cmt__alias__c='CharacteristicName',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Characteristic Value',vlocity_cmt__alias__c='CharacteristicValue',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Quantity',vlocity_cmt__alias__c='Quantity',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='MRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='NRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC Discount Percentage',vlocity_cmt__alias__c='MCDiscountPercentage',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC SD Mandate Discount',vlocity_cmt__alias__c='MCSDMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC AM Mandate Discount',vlocity_cmt__alias__c='MCAMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC SM Mandate Discount',vlocity_cmt__alias__c='MCSMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC CM Mandate Discount',vlocity_cmt__alias__c='MCCMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_AM_MANDATE_DISC',vlocity_cmt__alias__c='REC_MNTH_AM_MANDATE_DISC',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_SM_MANDATE_DISC',vlocity_cmt__alias__c='REC_MNTH_SM_MANDATE_DISC',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_CM_MANDATE_DISC',vlocity_cmt__alias__c='REC_MNTH_CM_MANDATE_DISC',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_SD_MANDATE_DISC',vlocity_cmt__alias__c='REC_MNTH_SD_MANDATE_DISC',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='REC_MNTH_DISC_PERCENTAGE',vlocity_cmt__alias__c='REC_MNTH_DISC_PERCENTAGE',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='Target Product Name',vlocity_cmt__alias__c='RangeAttributePricingMatrix__TargetProductName',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MRC',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='NRC',vlocity_cmt__alias__c='  RangeAttributePricingMatrix__NRC',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='PricePlanCode',vlocity_cmt__alias__c='RangeAttributePricingMatrix__PricePlanCode',vlocity_cmt__datatype__c='Text',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC Discount Percentage',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MCDiscountPercentage',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC CM Mandate Discount',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MCCMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC SM Mandate Discount',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MCSMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC AM Mandate Discount',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MCAMMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id),
                new vlocity_cmt__CalculationProcedureVariable__c(name='MC SD Mandate Discount',vlocity_cmt__alias__c='RangeAttributePricingMatrix__MCSDMandateDiscount',vlocity_cmt__datatype__c='Percent',vlocity_cmt__CalculationProcedureVersionId__c=procVersion.Id)
                };
                    insert calcProcVariableList;
        
        //Creating and enabling CalculationProcedureVersion
        update new vlocity_cmt__CalculationProcedureVersion__c(Id = procVersion.Id, vlocity_cmt__IsEnabled__c = true);
        
    }
    //Initializing Product Details
    // added by Dipanwita - created products, child products, price book, Quote and Quote Line Items
    
    //Initializing Product Details
    static private void testProductSetup(){
        System.runAs(Test_DataFactory.getByPassUser()){
            MC_RangeAttributePricingMatrixSettings__c mat = new MC_RangeAttributePricingMatrixSettings__c();
            mat.Active__c = true;
            mat.Customer_Segment__c = 'Forced RA';
            mat.Matrix_Name__c = 'PriceMatrix_Office365';
            mat.ProcedureName__c = 'Small_Office365_RangeAttributePricingProcedure';
            mat.Name = 'C-OFFICE-365';
            mat.Product_Family_Code__c = 'C-OFFICE-365';
            insert mat;
            
            vlocity_cmt__TriggerSetup__c itemTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
            insert itemTrigger;
            
            List<SObject> sObjList = new List<sObject>();
            Product2 prod1 = new Product2 (Name='Office 365', ProductCode = 'C-OFFICE-365', vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Uncommitted","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Uncommitted","id":10,"displayText":"Uncommitted"}],"values":[{"value":"Uncommitted","id":10,"displayText":"Uncommitted"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
            sObjList.add(prod1);
            
            Product2 prod2 = new Product2 (Name='Business Essential Offer', ProductCode = 'C-BUS-ESSEN-OFFER', vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0D000000pZKxQAM","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p0D0000004DgrQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Uncommitted","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Uncommitted","id":10,"displayText":"Uncommitted"}],"values":[{"value":"Uncommitted","id":10,"displayText":"Uncommitted"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0D000000pZKxQAM","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p0D0000004DgsQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
            sObjList.add(prod2);
            
            Product2 prod3 = new Product2 (Name='Business Premium Offer', ProductCode = 'C-BUS-PREM-OFFER', vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0D000000paTHQAY","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p0D0000004Di9QAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Uncommitted","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Uncommitted","id":10,"displayText":"Uncommitted"}],"values":[{"value":"Uncommitted","id":10,"displayText":"Uncommitted"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0D000000paTHQAY","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p0D0000004DiAQAU","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
            sObjList.add(prod3);
            
            Product2 prod4 = new Product2 (Name='Office 365 Abonnemang Add-On', ProductCode = 'C-OFF-AB-ADDON-OFFER', vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0D000000qS6CQAU","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p0D0000004DvdQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"value":"Uncommitted","id":10,"displayText":"Uncommitted"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}],"default":[]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0D000000qS6CQAU","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p0D0000004DsDQAU","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}' );
            sObjList.add(prod4);
            
            Product2 prod5 = new Product2 (Name='Audio Conferencing', ProductCode = 'C-AUD-CONF', vlocity_cmt__JSONAttribute__c='{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0D000000qS7oQAE","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p0D0000004DvsQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Uncommitted","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"value":"Uncommitted","id":10,"displayText":"Uncommitted"}],"values":[{"value":"Uncommitted","id":10,"displayText":"Uncommitted"},{"value":"24","id":20,"displayText":"24 months"},{"value":"36","id":30,"displayText":"36 months"}]},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t0D000000qS7oQAE","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"null","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p0D0000004DtBQAU","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number"},"$$AttributeDefinitionEnd$$":null}]}');
            sObjList.add(prod5);
            
            
            insert sObjList;       
            sObjList.clear();
            
            Account acc=[select id from Account limit 1];
            Date today=Date.today();
            Contract contract=new Contract();
            contract.Name='Test';
            contract.AccountId=acc.id;
            contract.Status='Draft';
            contract.Solution_Area__c='Vxl';
            contract.StartDate=Date.today();
            contract.EndDate=today.addDays(10);
            contract.ContractTerm=24;
            
            insert contract;
            
            contract.Status='Active';
            update contract;
            
            
            vlocity_cmt__ContractLineItem__c cli=new vlocity_cmt__ContractLineItem__c();
            cli.name='Office';
            cli.vlocity_cmt__product2id__c=prod1.id;
            cli.vlocity_cmt__ContractId__c=contract.id;
            cli.TeliaSE_MC_Customer_Requested_Percentage__c=5;
            cli.TeliaSE_End_Date__C=today.addDays(10);
            cli.TeliaSE_ProductHierarchy__c='ABC';
            cli.TeliasSETargetPercentage__c=5;
            cli.vlocity_cmt__RecurringCharge__c=200;
            cli.vlocity_cmt__EffectiveStartDate__c = today.addDays(1);
            cli.vlocity_cmt__EffectiveEndDate__c = today.addDays(10);
            insert cli;
            
            
            // Create Product Child Item
            //Office 365
            vlocity_cmt__ProductChildItem__c pci1 = new vlocity_cmt__ProductChildItem__c();
            pci1.vlocity_cmt__ParentProductId__c = prod1.Id;
            pci1.vlocity_cmt__ChildProductId__c = prod2.Id;
            pci1.Name = 'Test PCI1';
            pci1.vlocity_cmt__Quantity__c = 1;
            pci1.vlocity_cmt__MinQuantity__c = 1;
            pci1.vlocity_cmt__MaxQuantity__c = 25;
            pci1.vlocity_cmt__IsRootProductChildItem__c = false;
            pci1.vlocity_cmt__IsOverride__c = false;
            pci1.vlocity_cmt__ChildLineNumber__c = '10';
            pci1.vlocity_cmt__IsVirtualItem__c = false;
            sObjList.add(pci1);
            
            vlocity_cmt__ProductChildItem__c pci2 = new vlocity_cmt__ProductChildItem__c();
            pci2.vlocity_cmt__ParentProductId__c = prod1.Id;
            pci2.vlocity_cmt__ChildProductId__c = prod3.Id;
            pci2.Name = 'Test PCI2';
            pci2.vlocity_cmt__Quantity__c = 1;
            pci2.vlocity_cmt__MinQuantity__c = 1;
            pci2.vlocity_cmt__MaxQuantity__c = 1;
            pci2.vlocity_cmt__IsRootProductChildItem__c = false;
            pci2.vlocity_cmt__IsOverride__c = false;
            pci2.vlocity_cmt__ChildLineNumber__c = '20';
            pci2.vlocity_cmt__IsVirtualItem__c = false;
            sObjList.add(pci2);
            
            vlocity_cmt__ProductChildItem__c pci3 = new vlocity_cmt__ProductChildItem__c();
            pci3.vlocity_cmt__ParentProductId__c = prod1.Id;
            pci3.vlocity_cmt__ChildProductId__c = prod4.Id;
            pci3.Name = 'Test PCI3';
            pci3.vlocity_cmt__Quantity__c = 1;
            pci3.vlocity_cmt__MinQuantity__c = 1;
            pci3.vlocity_cmt__MaxQuantity__c = 1;
            pci3.vlocity_cmt__IsRootProductChildItem__c = false;
            pci3.vlocity_cmt__IsOverride__c = false;
            pci3.vlocity_cmt__ChildLineNumber__c = '30';
            pci3.vlocity_cmt__IsVirtualItem__c = false;
            sObjList.add(pci3);
            
            vlocity_cmt__ProductChildItem__c pci4 = new vlocity_cmt__ProductChildItem__c();
            pci4.vlocity_cmt__ParentProductId__c = prod4.Id;
            pci4.vlocity_cmt__ChildProductId__c = prod5.Id;
            pci4.Name = 'Test PCI4';
            pci4.vlocity_cmt__Quantity__c = 1;
            pci4.vlocity_cmt__MinQuantity__c = 1;
            pci4.vlocity_cmt__MaxQuantity__c = 20;
            pci4.vlocity_cmt__IsRootProductChildItem__c = false;
            pci4.vlocity_cmt__IsOverride__c = false;
            pci4.vlocity_cmt__ChildLineNumber__c = '10';
            pci4.vlocity_cmt__IsVirtualItem__c = false;
            sObjList.add(pci4);
            
            insert sObjList;
            System.debug(LoggingLevel.ERROR,'Prods-->'+sObjList);       
            sObjList.clear();
            
            
            Pricebook2 standardBook =  new Pricebook2(Id = Test.getStandardPricebookId(), Name = 'TestPricebook5', IsActive = true);
            Pricebook2 testPricebook = new Pricebook2(Name = 'TestPricebook7', IsActive = true);
            insert testPricebook;
            
            //Inserting into standard Pricebook
            PricebookEntry pbe11 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                                                      Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true);
            sObjList.add(pbe11);
            
            PricebookEntry pbe12 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                                                      Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true);
            sObjList.add(pbe12);
            
            PricebookEntry pbe13 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                                                      Product2Id = prod3.Id, UnitPrice = 30, vlocity_cmt__RecurringPrice__c = 15, IsActive = true);
            sObjList.add(pbe13);
            
            PricebookEntry pbe14 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                                                      Product2Id = prod4.Id, UnitPrice = 40, vlocity_cmt__RecurringPrice__c = 20, IsActive = true);
            sObjList.add(pbe14);
            
            PricebookEntry pbe15 = new PricebookEntry(Pricebook2Id = standardBook.Id,
                                                      Product2Id = prod5.Id, UnitPrice = 50, vlocity_cmt__RecurringPrice__c = 25, IsActive = true);
            sObjList.add(pbe15);
            
            //insert sObjList;
            //sObjList.clear();
            
            //Inserting into Custom Pricebook
            PricebookEntry pbe1 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                     Product2Id = prod1.Id, UnitPrice = 10, vlocity_cmt__RecurringPrice__c = 5, IsActive = true, UseStandardPrice = false);
            sObjList.add(pbe1);
            
            PricebookEntry pbe2 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                     Product2Id = prod2.Id, UnitPrice = 20, vlocity_cmt__RecurringPrice__c = 10, IsActive = true, UseStandardPrice = false);
            sObjList.add(pbe2);
            
            PricebookEntry pbe3 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                     Product2Id = prod3.Id, UnitPrice = 30, vlocity_cmt__RecurringPrice__c = 15, IsActive = true, UseStandardPrice = false);
            sObjList.add(pbe3);
            
            PricebookEntry pbe4 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                     Product2Id = prod4.Id, UnitPrice = 40, vlocity_cmt__RecurringPrice__c = 20, IsActive = true, UseStandardPrice = false);
            sObjList.add(pbe4);
            
            PricebookEntry pbe5 = new PricebookEntry(Pricebook2Id = testPricebook.Id,
                                                     Product2Id = prod5.Id, UnitPrice = 45, vlocity_cmt__RecurringPrice__c = 25, IsActive = true, UseStandardPrice = false);
            sObjList.add(pbe5);
            
            insert sObjList;
            System.debug(LoggingLevel.ERROR,'PBE-->'+sObjList);
            sObjList.clear();
            
            vlocity_cmt__PriceList__c pl1 = new vlocity_cmt__PriceList__c(vlocity_cmt__Pricebook2Id__c = testPricebook.Id, vlocity_cmt__IsActive__c = true, vlocity_cmt__Code__c = 'TestPricebook5');
            insert pl1;
            
            // Create Object Type
            SObject sObj = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];
            vlocity_cmt__ObjectClass__c chargeObjType = new vlocity_cmt__ObjectClass__c(Name = 'Charge', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c discObjType = new vlocity_cmt__ObjectClass__c(Name = 'Discount', vlocity_cmt__ObjectApiName__c = 'PricingElement__c', RecordTypeId = sObj.Id);
            vlocity_cmt__ObjectClass__c officeObjType = new vlocity_cmt__ObjectClass__c(Name = 'OFFICE365 Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObj.Id);
            
            sObjList.clear();
            sObjList.add(chargeObjType);
            sObjList.add(discObjType);
            sObjList.add(officeObjType);
            insert sObjList; 
            sObjList.clear();
            
            vlocity_cmt__PricingVariable__c oneTimeStdPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'One Time Std Price', vlocity_cmt__Code__c = 'OT_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                     vlocity_cmt__ChargeType__c='One-time',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                     vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
            sObjList.add(oneTimeStdPriceVar);
            
            vlocity_cmt__PricingVariable__c mrcPriceVar = new vlocity_cmt__PricingVariable__c(Name = 'Recurring Monthly Std Price', vlocity_cmt__Code__c = 'REC_MNTH_STD_PRC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                              vlocity_cmt__ChargeType__c='Recurring', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                              vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
            sObjList.add(mrcPriceVar);
            
            vlocity_cmt__PricingVariable__c mCAMMandateDiscount = new vlocity_cmt__PricingVariable__c(Name = 'MC AM Mandate Discount', vlocity_cmt__Code__c = 'REC_MNTH_AM_MANDATE_DISC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                      vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                      vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
            sObjList.add(mCAMMandateDiscount);
            
            vlocity_cmt__PricingVariable__c mCDiscountPercent = new vlocity_cmt__PricingVariable__c(Name = 'MC Discount Percent', vlocity_cmt__Code__c = 'REC_MNTH_DISC_PERCENTAGE',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                    vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                    vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
            sObjList.add(mCDiscountPercent);
            
            vlocity_cmt__PricingVariable__c mCCMMandateDiscount = new vlocity_cmt__PricingVariable__c(Name = 'MC CM Mandate Discount', vlocity_cmt__Code__c = 'REC_MNTH_CM_MANDATE_DISC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                      vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                      vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
            sObjList.add(mCCMMandateDiscount);
            
            vlocity_cmt__PricingVariable__c mCSDMandateDiscount = new vlocity_cmt__PricingVariable__c(Name = 'MC SD Mandate Discount', vlocity_cmt__Code__c = 'REC_MNTH_SD_MANDATE_DISC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                      vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                      vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
            sObjList.add(mCSDMandateDiscount);
            
            vlocity_cmt__PricingVariable__c mCSMMandateDiscount = new vlocity_cmt__PricingVariable__c(Name = 'MC SM Mandate Discount', vlocity_cmt__Code__c = 'REC_MNTH_SM_MANDATE_DISC',vlocity_cmt__Aggregation__c = 'Unit',
                                                                                                      vlocity_cmt__ChargeType__c='Adjustment', vlocity_cmt__RecurringFrequency__c ='Monthly',vlocity_cmt__IsActive__c = true,vlocity_cmt__Scope__c = 'Line',vlocity_cmt__SubType__c = 'Standard',vlocity_cmt__Type__c = 'Price',
                                                                                                      vlocity_cmt__ValueType__c='Pricing Element',vlocity_cmt__CurrencyType__c='Currency');
            sObjList.add(mCSMMandateDiscount);
            
            insert sObjList;
            System.debug(LoggingLevel.ERROR,'PricingVariable-->'+sObjList);
            sObjList.clear();
            
            insert sObjList;
            
            // Create Pricing Element
            vlocity_cmt__PricingElement__c pElem1 = new vlocity_cmt__PricingElement__c(Name = '44 SEK', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 44,
                                                                                       vlocity_cmt__Code__c = 'PELEM1', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
            vlocity_cmt__PricingElement__c pElem2 = new vlocity_cmt__PricingElement__c(Name = '20 SEK', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 20,
                                                                                       vlocity_cmt__Code__c = 'PELEM2', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = true, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
            vlocity_cmt__PricingElement__c pElem4 = new vlocity_cmt__PricingElement__c(Name = '400 SEK', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 400,
                                                                                       vlocity_cmt__Code__c = 'PELEM4', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
            vlocity_cmt__PricingElement__c pElem5 = new vlocity_cmt__PricingElement__c(Name = '50 SEK', vlocity_cmt__ObjectTypeId__c = chargeObjType.Id, vlocity_cmt__Amount__c = 50,
                                                                                       vlocity_cmt__Code__c = 'PELEM5', vlocity_cmt__EffectiveFromDate__c = Datetime.now(), vlocity_cmt__IsActive__c = true, vlocity_cmt__IsReusable__c = false, vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id, vlocity_cmt__PriceListId__c = pl1.Id);
            sObjList.clear();
            sObjList.add(pElem1);
            sObjList.add(pElem2);
            sObjList.add(pElem4);
            sObjList.add(pElem5);
            
            insert sObjList;
            sObjList.clear();
            
            
            List<vlocity_cmt__PricingElement__c> pricingElement = [SELECT Id, Name FROM vlocity_cmt__PricingElement__c];
            vlocity_cmt__PriceListEntry__c ple1 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod1.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
            sObjList.add(ple1);
            vlocity_cmt__PriceListEntry__c ple2 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod2.Id, vlocity_cmt__PricingElementId__c = pElem4.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
            sObjList.add(ple2);
            vlocity_cmt__PriceListEntry__c ple5 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod3.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
            sObjList.add(ple5);
            vlocity_cmt__PriceListEntry__c ple7 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod4.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
            sObjList.add(ple7);
            vlocity_cmt__PriceListEntry__c ple8 = new vlocity_cmt__PriceListEntry__c(vlocity_cmt__PriceListId__c=pl1.Id, vlocity_cmt__ProductId__c=prod5.Id, vlocity_cmt__PricingElementId__c = pElem1.Id, vlocity_cmt__EffectiveFromDate__c=Datetime.now(), vlocity_cmt__IsActive__c=true);
            sObjList.add(ple8);
            
            insert sObjList;
            sObjList.clear();
            
            //Creating PricingVariableBinding
            vlocity_cmt__PricingVariableBinding__c pvb1 = new vlocity_cmt__PricingVariableBinding__c(Name='One Time Std Price - QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                     vlocity_cmt__DestinationFieldApiName__c = 'OneTimeCharge__c', vlocity_cmt__PricingVariableId__c = oneTimeStdPriceVar.Id);
            sObjList.add(pvb1);
            vlocity_cmt__PricingVariableBinding__c pvb2 = new vlocity_cmt__PricingVariableBinding__c(Name='Recurring Monthly Std Price - QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                     vlocity_cmt__DestinationFieldApiName__c = 'RecurringCharge__c', vlocity_cmt__PricingVariableId__c = mrcPriceVar.Id);
            sObjList.add(pvb2);        
            vlocity_cmt__PricingVariableBinding__c pvb3 = new vlocity_cmt__PricingVariableBinding__c(Name='MC Discount Percentage - QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                     vlocity_cmt__DestinationFieldApiName__c = 'TeliaSE_Discount_Percentage__c', vlocity_cmt__PricingVariableId__c = mCDiscountPercent.Id);
            sObjList.add(pvb3);
            vlocity_cmt__PricingVariableBinding__c pvb4 = new vlocity_cmt__PricingVariableBinding__c(Name='MC AM Mandate Discount- QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                     vlocity_cmt__DestinationFieldApiName__c = 'TeliaSE_AM_Mandate_Percentage__c', vlocity_cmt__PricingVariableId__c = mCAMMandateDiscount.Id);
            sObjList.add(pvb4);
            vlocity_cmt__PricingVariableBinding__c pvb5 = new vlocity_cmt__PricingVariableBinding__c(Name='MC CM Mandate Discount- QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                     vlocity_cmt__DestinationFieldApiName__c = 'TeliaSE_CM_Mandate_Percentage__c', vlocity_cmt__PricingVariableId__c = mCCMMandateDiscount.Id);
            sObjList.add(pvb5);
            vlocity_cmt__PricingVariableBinding__c pvb6 = new vlocity_cmt__PricingVariableBinding__c(Name='MC SM Mandate Discount- QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                     vlocity_cmt__DestinationFieldApiName__c = 'TeliaSE_SM_Mandate_Percentage__c', vlocity_cmt__PricingVariableId__c = mCSMMandateDiscount.Id);
            sObjList.add(pvb6);
            vlocity_cmt__PricingVariableBinding__c pvb7 = new vlocity_cmt__PricingVariableBinding__c(Name='MC SD Mandate Discount- QuoteLineItem',vlocity_cmt__DestinationSObjectType__c='QuoteLineItem',
                                                                                                     vlocity_cmt__DestinationFieldApiName__c = 'TeliaSE_SD_Mandate_Percentage__c', vlocity_cmt__PricingVariableId__c = mCSDMandateDiscount.Id);
            sObjList.add(pvb7);
            
            insert sObjList;
            System.debug(LoggingLevel.ERROR, 'PVB-->'+sObjList);
            sObjList.clear();
            
            vlocity_cmt__InterfaceImplementation__c iit1 = new vlocity_cmt__InterfaceImplementation__c (Name='PricingInterface');
            insert iit1;
            vlocity_cmt__InterfaceImplementationDetail__c iid1 = new vlocity_cmt__InterfaceImplementationDetail__c (Name = 'PricingElementServiceImplementation',
                                                                                                                    vlocity_cmt__InterfaceId__c=iit1.Id, vlocity_cmt__IsActive__c=true);
            insert iid1;
            
            vlocity_cmt__InterfaceImplementation__c intImpl = new vlocity_cmt__InterfaceImplementation__c (Name='TightestMatchInterface');
            insert intImpl;
            
            vlocity_cmt__InterfaceImplementationDetail__c iit004_001 = new vlocity_cmt__InterfaceImplementationDetail__c
                (Name = 'TightestMatchServiceImplementation', vlocity_cmt__InterfaceId__c=intImpl.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);
            insert iit004_001;
            
            vlocity_cmt__TriggerSetup__c myTrigger = new vlocity_cmt__TriggerSetup__c(Name='AllTriggers', vlocity_cmt__IsTriggerOn__c=true);
            insert myTrigger;
            vlocity_cmt__InterfaceImplementation__c iit = new vlocity_cmt__InterfaceImplementation__c (Name='ContextRuleService');
            insert iit;
            List<vlocity_cmt__InterfaceImplementationDetail__c> iidList = new List<vlocity_cmt__InterfaceImplementationDetail__c> ();
            vlocity_cmt__InterfaceImplementationDetail__c iit_001 = new vlocity_cmt__InterfaceImplementationDetail__c  (Name = 'ContextRuleService', vlocity_cmt__InterfaceId__c=iit.Id, vlocity_cmt__IsDefault__c=true,vlocity_cmt__IsActive__c=true);
            
            iidList.add(iit_001);
            insert iidList;
            
            Account accountInfo = [SELECT Id FROM Account LIMIT 1];  
            accountInfo.MC_Commercial_Setup__c = 'Forced RA';
            update accountInfo;
            
            Quote testQuote = new Quote();
            Id userId = Userinfo.getUserId();
            Seller__c sellerInfo = Test_DataFactory.createBusinessAreaManagerSeller(userId);
            insert sellerInfo;
            Opportunity testOpportunity = Test_DataFactory.createSmeOpportunity();
            testOpportunity.AccountId = accountInfo.Id;
            insert testOpportunity;
            RecordType rt = [Select id,name, DeveloperName from RecordType where Name='Contract Quote'];               
            
            Contract con=[select id from Contract limit 1];
            //Quote for Roll Down Test(Office 365)
            testQuote.Name= 'Test Quote';
            testQuote.OpportunityId = testOpportunity.Id;
            testQuote.Status = 'Draft';
            testQuote.vlocity_cmt__PriceListId__c =pl1.Id;
            testQuote.Pricebook2Id = testPricebook.Id;
            testQuote.RecordTypeId = rt.Id; //RecordTypeIdQuote; //rt.Id;
            testQuote.vlocity_cmt__frameContractId__c=con.id;
            insert testQuote;
            
            Quote quoteAfterInsert = [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Quote WHERE Id =: testQuote.Id LIMIT 1]; 
            System.debug(LoggingLevel.ERROR,'Quote-->'+quoteAfterInsert);  
            
            String recordtypeName = SEUtility.getRecordTypeDevName(quoteAfterInsert.RecordTypeId);
            System.assertEquals(recordtypeName, quoteAfterInsert.RecordType.DeveloperName);
            
            quoteId = testQuote.Id;  
            
            List<priceBookEntry> priceBookEntry = [SELECT Id FROM PricebookEntry WHERE Product2Id =: prod1.Id];
            Id priceBookEntryId = priceBookEntry[0].Id;
            
            //creating QuoteItem
            QuoteLineItem quoteItem = new QuoteLineItem();
            quoteItem.QuoteId = testQuote.Id;
            quoteItem.PricebookEntryId = pbe1.Id;
            quoteItem.Quantity = 1;
            quoteItem.vlocity_cmt__LineNumber__c = '0001';
            quoteItem.UnitPrice = 100;
            quoteItem.vlocity_cmt__ProvisioningStatus__c = 'New';
            quoteItem.vlocity_cmt__BillingAccountId__c = accountInfo.Id;
            quoteItem.vlocity_cmt__ServiceAccountId__c = accountInfo.Id; 
            quoteItem.vlocity_cmt__EffectiveQuantity__c= 1 ;
            quoteItem.vlocity_cmt__JSONAttribute__c =  '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005t7AAA","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":true,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008REzAAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":"Uncommitted","valuedatatype__c":"Picklist","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","default":[{"displayText":"Uncommitted","id":10,"value":"Uncommitted"}],"values":[{"displayText":"Uncommitted","id":10,"value":"Uncommitted"},{"displayText":"24 months","id":20,"value":"24"},{"displayText":"36 months","id":30,"value":"36"}],"selectedItem":{"displayText":"Uncommitted","id":10,"value":"Uncommitted"}},"isnottranslatable__c":false,"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t1l000000pixdAAA","attributeid__c":"a2s1w00000005tMAAQ","attributecategoryid__c":"a2r1w0000008xvuAAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Telia Mobile Agreements","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":false,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a2p1l0000008RF0AAM","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":null,"value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"attributeRunTimeInfo":{"dataType":"Number","value":22},"isnottranslatable__c":false,"$$AttributeDefinitionEnd$$":null}]}';
            quoteItem.TeliaSE_Base_Quantity__c = '22';
            sObjList.add(quoteItem);
            
            QuoteLineItem quoteItem2 = new QuoteLineItem();
            quoteItem2.QuoteId = testQuote.Id;
            quoteItem2.PricebookEntryId = pbe2.Id;
            quoteItem2.Quantity = 1;
            quoteItem2.vlocity_cmt__LineNumber__c = '0001.0001';
            quoteItem2.UnitPrice = 100;
            quoteItem2.vlocity_cmt__ProvisioningStatus__c = 'New';
            quoteItem2.vlocity_cmt__BillingAccountId__c = accountInfo.Id;
            quoteItem2.vlocity_cmt__ServiceAccountId__c = accountInfo.Id;  
            quoteItem2.vlocity_cmt__EffectiveQuantity__c= 1 ;
            quoteItem2.vlocity_cmt__JSONAttribute__c = '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGZQA2","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NanQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"24 months","id":20,"value":"24 months"},{"displayText":"36 months","id":30,"value":"36 months"},{"displayText":"Uncommitted","id":10,"value":"Uncommitted"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGcQAM","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NaoQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null}]}';
            sObjList.add(quoteItem2);
            
            
            QuoteLineItem quoteItem3 = new QuoteLineItem();
            quoteItem3.QuoteId = testQuote.Id;
            quoteItem3.PricebookEntryId = pbe3.Id;
            quoteItem3.Quantity = 1;
            quoteItem3.vlocity_cmt__LineNumber__c = '0001.0002';
            quoteItem3.UnitPrice = 100;
            quoteItem3.vlocity_cmt__ProvisioningStatus__c = 'New';
            quoteItem3.vlocity_cmt__BillingAccountId__c = accountInfo.Id;
            quoteItem3.vlocity_cmt__ServiceAccountId__c = accountInfo.Id;  
            quoteItem3.vlocity_cmt__EffectiveQuantity__c= 1 ;
            quoteItem3.vlocity_cmt__JSONAttribute__c= '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGZQA2","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NanQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"24 months","id":20,"value":"24 months"},{"displayText":"36 months","id":30,"value":"36 months"},{"displayText":"Uncommitted","id":10,"value":"Uncommitted"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGcQAM","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NaoQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null}]}';
            sObjList.add(quoteItem3);
            
            
            QuoteLineItem quoteItem4 = new QuoteLineItem();
            quoteItem4.QuoteId = testQuote.Id;
            quoteItem4.PricebookEntryId = pbe4.Id;
            quoteItem4.Quantity = 1;
            quoteItem4.vlocity_cmt__LineNumber__c = '0001.0003';
            quoteItem4.UnitPrice = 100;
            quoteItem4.vlocity_cmt__ProvisioningStatus__c = 'New';
            quoteItem4.vlocity_cmt__BillingAccountId__c = accountInfo.Id;
            quoteItem4.vlocity_cmt__ServiceAccountId__c = accountInfo.Id; 
            quoteItem4.vlocity_cmt__EffectiveQuantity__c= 1 ;
            sObjList.add(quoteItem4);
            
            QuoteLineItem quoteItem5 = new QuoteLineItem();
            quoteItem5.QuoteId = testQuote.Id;
            quoteItem5.PricebookEntryId = pbe5.Id;
            quoteItem5.Quantity = 5;
            quoteItem5.vlocity_cmt__LineNumber__c = '0001.0003.0001';
            quoteItem5.UnitPrice = 100;
            quoteItem5.vlocity_cmt__ProvisioningStatus__c = 'New';
            quoteItem5.vlocity_cmt__BillingAccountId__c = accountInfo.Id;
            quoteItem5.vlocity_cmt__ServiceAccountId__c = accountInfo.Id; 
            quoteItem5.vlocity_cmt__EffectiveQuantity__c= 1 ;
            quoteItem5.vlocity_cmt__JSONAttribute__c= '{"ATT_CODE_TELIAMOBAGGR":[{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGZQA2","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_CMTP","attributeconfigurable__c":true,"attributedisplaysequence__c":"20","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Commitment Period","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":true,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NanQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Dropdown","value__c":null,"valuedatatype__c":"Picklist","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Picklist","uiDisplayType":"Dropdown","values":[{"displayText":"24 months","id":20,"value":"24 months"},{"displayText":"36 months","id":30,"value":"36 months"},{"displayText":"Uncommitted","id":10,"value":"Uncommitted"}],"default":[],"selectedItem":{}},"$$AttributeDefinitionEnd$$":null},{"$$AttributeDefinitionStart$$":null,"objectid__c":"01t6E000004jFiHQAU","attributeid__c":"a366E0000006QGcQAM","attributecategoryid__c":"a356E0000006u99QAA","categorycode__c":"ATT_CODE_TELIAMOBAGGR","categoryname__c":"Attributes","attributeuniquecode__c":"ATT_RT_NoU","attributeconfigurable__c":true,"attributedisplaysequence__c":"10","attributefilterable__c":false,"attributecloneable__c":true,"isactive__c":true,"attributedisplayname__c":"Number of Users","displaysequence__c":"10","categorydisplaysequence__c":10,"customconfiguitemplate__c":null,"formatmask__c":null,"hasrule__c":false,"isconfigurable__c":false,"ishidden__c":true,"valueinnumber__c":null,"objecttype__c":"Product2","querycode__c":null,"isreadonly__c":false,"isquerydriven__c":false,"querylabel__c":null,"id":"a336E0000002NaoQAE","isrequired__c":false,"rulemessage__c":null,"uidisplaytype__c":"Single Value","value__c":null,"valuedatatype__c":"Number","valuedescription__c":null,"isnottranslatable__c":false,"attributeRunTimeInfo":{"dataType":"Number","uiDisplayType":"Single Value","value":null},"$$AttributeDefinitionEnd$$":null}]}';
            sObjList.add(quoteItem5);        
            insert sObjList;   
            quoteItem5.vlocity_cmt__RootItemId__c = quoteItem.vlocity_cmt__AssetReferenceId__c;
            update quoteItem5;
            sObjList.clear();        
            
            // Create Pricing Plan
            vlocity_cmt__PricingPlan__c plan = new vlocity_cmt__PricingPlan__c(Name = 'Default Pricing Plan', vlocity_cmt__Code__c = 'DEFAULT_PRICING_PLAN', vlocity_cmt__IsActive__c = true);
            insert plan;
            vlocity_cmt__PricingPlanStep__c planStep13 = new vlocity_cmt__PricingPlanStep__c(Name = 'RangeAttributePricingMatrix', vlocity_cmt__ImplementationName__c = 'CustomPricingPlanStepImpl', vlocity_cmt__IsActive__c = true, vlocity_cmt__MethodName__c = 'GetMatrixPrice', vlocity_cmt__Sequence__c = 103, vlocity_cmt__PricingPlanId__c = plan.Id, vlocity_cmt__Parameters__c ='{"ProcedureName":"RangeAttributePricingProcedure","MatrixName":"RangeAttributePricingMatrix","RangeFields":"Quantity"}');
            sObjList.add(planStep13);
            insert sObjList;        
            sObjList.clear();
        }
    }
    static private testmethod void getProcedureName(){
        testProductSetup();
        Quote quote = [select id, MC_Commercial_Setup__c from Quote where MC_Commercial_Setup__c='Forced RA' limit 1];
        List<QuoteLineItem> qliList = [select vlocity_cmt__ParentItemId__c from QuoteLineItem where QuoteId = :quote.Id and vlocity_cmt__ParentItemId__c = null LIMIT 1];
        PricingPlanHelper.getProcedureName(qliList[0], quote);
        PricingPlanHelper.getMatrixName(qliList, quote);
    }
    
    /*  Static public testmethod void UpdateBindingTime(){

User salesManager;
Id stdPriceBookRecId = Test.getStandardPricebookId();
System.runAs(new User(Id = Userinfo.getUserId())){
salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
salesManager.Bypass_VR__c = true;
insert salesManager;
}
System.runAs(salesManager){
Account acc = Test_DataFactory.createOneAccount();
insert acc; 


Opportunity oppr = new Opportunity();
oppr.Name='OpprTest';
oppr.CloseDate = System.today();
oppr.AccountId = acc.Id;
oppr.StageName='Kvalificera';  
oppr.Pricebook2Id= stdPriceBookRecId;
oppr.TeliaSE_SharingSetting_Flag__c = false;
insert oppr;

ID rtd=[select Id from RecordType where sObjectType = 'Quote' And Name = 'Hardware Quote'].Id;
Quote quot1 = new Quote();
quot1.RecordTypeId=rtd;
quot1.Name='QuoteTest';
quot1.status = 'Draft';
quot1.opportunityId = oppr.Id;
quot1.Pricebook2ID = stdPriceBookRecId;
quot1.TeliaSE_Approval_Flag__c = False;     
insert quot1;

SObject sObjt = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE IsActive = TRUE and SobjectType = 'vlocity_cmt__ObjectClass__c' and DeveloperName = 'ObjectType' LIMIT 1];   
vlocity_cmt__ObjectClass__c ObjClss = new vlocity_cmt__ObjectClass__c(Name = 'Hardware Offer Spec', vlocity_cmt__ObjectApiName__c = 'Product2', RecordTypeId = sObjt.Id);
insert     ObjClss;

Product2 prodt = new Product2();
prodt.name='Mobiltelefoner';
prodt.ProductCode='MOB_HARDWARE_OFFER';
prodt.vlocity_cmt__ObjectTypeId__c=ObjClss.Id;
insert prodt;
List<Id> prodList = new List<Id>();
prodList.add(prodt.Id);

PricebookEntry objpricebookentry =new PricebookEntry();
objpricebookentry.Product2ID = prodt.Id;
objpricebookentry.Pricebook2ID = stdPriceBookRecId;
objpricebookentry.UnitPrice=23.50;
objpricebookentry.UseStandardPrice=false;
objpricebookentry.isActive=true;//Add this line
insert objpricebookentry;

QuoteLineItem quoteItems1= new QuoteLineItem();
quoteItems1.PricebookEntryId = objpricebookentry.Id;
quoteItems1.QuoteId = quot1.id;
quoteItems1.UnitPrice = 200;
quoteItems1.Quantity = 1;
quoteItems1.Product2Id = prodt.Id;  
quoteItems1.TeliaSE_MC_Binding_Time__c='24 Månader';
quoteItems1.Price_List_Setup__c ='Månadsavgift';
insert quoteItems1;

ID rtd1=[select Id from RecordType where sObjectType = 'Quote' And Name = 'Offer Quote'].Id;
Quote quot2 = new Quote();
quot2.RecordTypeId=rtd1;
quot2.Name='QuoteTest';
quot2.status = 'Draft';
quot2.opportunityId = oppr.Id;
quot2.Pricebook2ID = stdPriceBookRecId;
quot2.TeliaSE_Approval_Flag__c = False;     
insert quot2;

QuoteLineItem quoteItems2= new QuoteLineItem();
quoteItems2.PricebookEntryId = objpricebookentry.Id;
quoteItems2.QuoteId = quot2.id;
quoteItems2.UnitPrice = 200;
quoteItems2.Quantity = 4;
quoteItems2.Product2Id = prodt.Id;  
insert quoteItems2;
QuoteLineItem qliList = new QuoteLineItem();
qliList = [select Id,Product2.Name,Quote.RecordType.DeveloperName,Quote.AccountId from QuoteLineItem where TeliaSE_Product_Code__c = 'MOB_HARDWARE_OFFER' and QuoteId =:quot2.Id ];
System.debug('qliList-->'+qliList);
PricingPlanHelper pphelper = new PricingPlanHelper();
test.startTest();
pphelper.getBindingTimeAndPricelistSetup(prodList,quot2.Id,quot2);
test.stopTest();
}
}*/
    
}