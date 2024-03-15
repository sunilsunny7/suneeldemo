@isTest
public class TestWrapperClassConsent {
    
    public static String testApxContainer(){
        ApexDataContainer con = new ApexDataContainer();
        ApexDataContainer.Purposes test1 = new ApexDataContainer.Purposes();
        ApexDataContainer.Description descp1 = new ApexDataContainer.Description();
        ApexDataContainer.category category1 = new ApexDataContainer.category();
        test1.campaignId = '123';
        //test1.fromSourceSystem ='TEST';
        test1.purpose = 'consent-td-marketing';
        test1.collectionMethod = 'salesforce';
        test1.customerProxy = 'Jane Doe';
        test1.legalGround = 'li';
        test1.requested = '2018-04-23T15:34:47.429Z';
        test1.storeId = 'BUTIK';
        test1.version = '1.2.0';
        test1.customerRepresentative = 'Account Agent';
        String getstatus = test1.status;
        test1.status = 'approved';
        descp1.language = 'Language';
        descp1.text = 'Jag godkänner att ni hanterar trafikdata om hur jag använder mina tjänster för att förbättra tjänster och nät';
        category1.example = 'String';
        test1.category = new LIST<ApexDataContainer.category>();
        test1.description = new LIST<ApexDataContainer.Description>();
        List<ApexDataContainer.purposes> purposeList = new LIST<ApexDataContainer.Purposes>();
        purposeList.add(test1);
        con.purposes = purposeList;
        system.debug('&&&&&'+con);
        return JSON.serialize(con);
    }
    public static String testApxContainer2(){
        ApexDataContainer con1 = new ApexDataContainer();
        ApexDataContainer.Purposes test1 = new ApexDataContainer.Purposes();
        ApexDataContainer.Description descp1 = new ApexDataContainer.Description();
        ApexDataContainer.category category1 = new ApexDataContainer.category();
        test1.campaignId = '1234';
       // test1.fromSourceSystem ='TEST';
        test1.purpose = 'consent-td-marketing';
        test1.collectionMethod = 'salesforce';
        test1.customerProxy = 'John Dave';
        test1.legalGround = 'li';
        test1.requested = '2018-04-26T15:34:47.429Z';
        test1.storeId = 'BUTIK';
        test1.version = '1.3.0';
        test1.customerRepresentative = 'Stefan Agent';
        String getstatus = test1.status;
        test1.status = 'denied';
        descp1.language = 'Language';
        descp1.text = 'Jag godkänner att ni hanterar trafikdata om hur jag använder mina tjänster för att förbättra tjänster och nät';
        category1.example = 'String';
        test1.category = new LIST<ApexDataContainer.category>();
        test1.description = new LIST<ApexDataContainer.Description>();
        List<ApexDataContainer.purposes> purposeListAdd = new LIST<ApexDataContainer.Purposes>();
        purposeListAdd.add(test1);
        con1.purposes = purposeListAdd;
        system.debug('&&&&&'+con1);
        return JSON.serialize(con1);
    }
    
    public static void testReqClsWrapper(){
        RequestClassWrapper reqcls = new RequestClassWrapper();
        RequestClassWrapper.purposes purpose1 = new RequestClassWrapper.Purposes();
        reqcls.collectionMethod = 'Salesforce';
        reqcls.requested = '2018-04-23T15:34:47.429Z';
        reqcls.language = 'Language';
        reqcls.storeId = 'BUTIK';
        reqcls.customerIdentificationNumber = '1111111111';
        reqcls.customerRepresentative = 'Account Agent';
        reqcls.customerProxy = 'Jane Doe';
        reqcls.campaignId = '123';
        reqcls.purposes = new List<RequestClassWrapper.purposes>();
        purpose1.purpose = 'consent-td-marketing';
        purpose1.status = 'denied';
        purpose1.version = '1.2.0';
    }
}