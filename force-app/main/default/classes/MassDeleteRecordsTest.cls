@isTest public class MassDeleteRecordsTest {
    @testSetup
    static void initTestData() {
        User salesManager;
        salesManager = Test_DataFactory.createAdminUser();
        salesManager.ForecastEnabled = true;
        salesManager.Bypass_VR__c = true;
        insert salesManager;
        Account acc=Test_DataFactory.createOneSMEAccount();
        acc.MC_Commercial_Setup__c = 'Forced RA';
        acc.Org_Nr__c  = '0123456789';
        acc.Name = 'R21.4_Test_CO_Acc_Grouping';
        acc.Has_Orders__c = true;
        insert acc;
        RecordType rt1 = [Select id,name, DeveloperName from RecordType where Name='Ramavtal'];
        Contract contr=new Contract();
        contr.Name='Test';
        contr.AccountId=acc.id;
        contr.Status='Draft';
        //contr.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Ramavtal').getRecordTypeId();
        contr.recordtypeId = rt1.id;
        contr.Solution_Area__c='Vxl';
        contr.StartDate=Date.today();
        contr.ContractTerm=24;
        insert contr;
        contr.Status='Active';
        System.runAs(salesManager){update contr;}
        Order order = new Order();
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';
        order.AccountId = acc.Id;  
        order.ContractId = contr.Id;
        insert order;
        
        MCOnline_ParentBasket__c pbasket = new MCOnline_ParentBasket__c();
        pbasket.TSCID__c = 'TSCID_1234';
        pbasket.BasketStatus__c = 'Success';
        pbasket.Order__c = order.Id;
        pbasket.CreatedDate = Date.today();
        pbasket.AgreementId__c = contr.Id;
        pbasket.Admin__c = UserInfo.getUserId();
        pbasket.Account__c = acc.Id;        
        pbasket.UpdateOrderRequest__c = '';
        pbasket.CheckoutResponse__c = '';
        //pbasket.Order__c = order.Id;
        insert pbasket;
        
        vlocity_cmt__VlocityErrorLogEntry__c entrylog = new vlocity_cmt__VlocityErrorLogEntry__c();
        entrylog.vlocity_cmt__SourceName__c ='MassCustomized_MadamIntegration';
        entrylog.Name = 'TestCheck';
        entrylog.vlocity_cmt__ErrorCode__c = '500';
        insert entrylog;
        MC_RAMMFA_Settings__c rec = new MC_RAMMFA_Settings__c();
        rec.Name = 'ParentBasket';
        rec.Type__c = '10';
        insert rec;
        MC_RAMMFA_Settings__c rec1 = new MC_RAMMFA_Settings__c();
        rec1.Name = 'Order';
        rec1.Type__c = '10';
        insert rec1;
        MC_RAMMFA_Settings__c rec2 = new MC_RAMMFA_Settings__c();
        rec2.Name = 'ErrorLogEntry';
        rec2.Type__c = '10';
        insert rec2;

        MC_PrismaPlan__c  prismaPlan=new MC_PrismaPlan__c();
        prismaPlan.Name='Test';
        insert prismaPlan;
    }
    @isTest public static void test1(){
        String query = 'select id from Account';
        MassDeleteRecords jobInst = new MassDeleteRecords(query);
        Database.executeBatch(jobInst);       
    }
    @isTest public static void scheduleTest(){         
        MassDeleteRecords mass=new MassDeleteRecords();
        MassDeleteRecords sch = new MassDeleteRecords('Order',true);
        sch.execute(null); 
        MassDeleteRecords sch1 = new MassDeleteRecords('MCOnline_ParentBasket__c',true);
        sch1.execute(null);
        MassDeleteRecords sch2 = new MassDeleteRecords('vlocity_cmt__VlocityErrorLogEntry__c',true);
        sch2.execute(null);
        MassDeleteRecords sch3 = new MassDeleteRecords('prismaPlan',true);
        sch3.execute(null);
        MassDeleteRecords sch4 = new MassDeleteRecords('agreementPlanChange',true);
        sch4.execute(null);
    }
}