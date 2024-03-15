@isTest
public class Test_LeadAlphaController {
    
    public static testmethod void testWSDLServiceClass(){
        test.startTest();
        GesbWsSfdcLeadexpSchema.remitter_element sch1 = new GesbWsSfdcLeadexpSchema.remitter_element();
        GesbWsSfdcLeadexpSchema.PublishLeadRequest sch2 = new GesbWsSfdcLeadexpSchema.PublishLeadRequest();
        GesbWsSfdcLeadexpSchema.statusResponse_element sch3 = new GesbWsSfdcLeadexpSchema.statusResponse_element();
        GesbWsSfdcLeadexpSchema.contact_element sch4 = new GesbWsSfdcLeadexpSchema.contact_element();
        GesbWsSfdcLeadexpSchema.publishLead_element sch5 = new GesbWsSfdcLeadexpSchema.publishLead_element();
        GesbWsSfdcLeadexpSchema.customer_element sch6 = new GesbWsSfdcLeadexpSchema.customer_element();
        GesbWsSfdcLeadexpSchema.StatusResponse sch7 = new GesbWsSfdcLeadexpSchema.StatusResponse();
        AsyncGesbWsSfdcLeadexpService.AsyncServicePortTypeEndpoint endpt = new AsyncGesbWsSfdcLeadexpService.AsyncServicePortTypeEndpoint();
          Continuation con = new Continuation(60);
endpt.beginPublishLead(con,sch2); 
         /* 
AsyncGesbWsSfdcLeadexpSchema.statusResponse_elementFuture status = new AsyncGesbWsSfdcLeadexpSchema.statusResponse_elementFuture();

GesbWsSfdcLeadexpService c = new GesbWsSfdcLeadexpService();
GesbWsSfdcLeadexpService.ServicePortTypeEndpoint endPoint = new GesbWsSfdcLeadexpService.ServicePortTypeEndpoint();
endPoint.publishLead(sch2);
status.getValue();*/ 
        test.stopTest();
    }
    
    public static testmethod void testLeadControllerClass(){
        LeadAlphaController.response leadres = new LeadAlphaController.response();
        leadres.ErrorMsg = 'Error Occured';
        leadres.SuccessMsg = 'Error Occured';
        leadres.isSuccess = false;
        leadres.isBtnActive = true;
        Buy_Interest__c buyInt = new Buy_Interest__c();
        List<Account> AccList = new List<Account>();
        Lead leadObj = new Lead();
        AccList = Test_DataFactory.createAccounts(3);
        for (Account a: AccList){
            a.Org_Nr__c = '5432199812';
        }
        // update AccList;
        leadObj = Test_DataFactory.createLead();
        leadObj.Account__c = AccList[0].id;
        leadObj.MobilePhone = '9876541231';
        leadObj.Email = 'testemail@gmail.com';
        leadObj.Product_Area__c = 'Broadband';
        leadObj.Form_Source__c = 'telia.se';
        leadObj.LeadSource = 'telia.se';
        leadObj.Telia_Employee_Telia_Id__c = 'scu541';
        leadObj.Lead_Submitter_first_name__c = 'testsubmitterfname';
        leadObj.Lead_Submitter_Last_name__c = 'testsubmitterlname';
        leadObj.Lead_Submitter_phone__c = '9876543121';
        leadObj.Lead_Submitter_No__c = 'L-1234';
        leadObj.Lead_Submitter_email__c = 'testuser@gmail.com';
        
        insert leadObj;
        System.runAs(new User(Id = Userinfo.getUserId())){
        //    buyInt.Name = 'Telefoni';
            buyInt.Alpha_Status__c = '';
            buyInt.Status__c = 'Nytt';
          //  buyInt.Alpha_Queue__c = 'Leadscentralen';
            buyInt.Form_Source__c = 'Telia.se';
            buyInt.Lead__c = leadObj.Id;
            buyInt.Status__c = 'Avfärdat';
            buyInt.Alpha_Status__c = 'Done';
            insert buyInt;
        } 
        String BuyId = buyInt.Id;
        LeadAlphaController.getRecord(BuyId);
        GESB_EndPointURL__c c1 = new GESB_EndPointURL__c();
        c1.Name ='LEAD GESB URL';
        c1.EndPointURL__c = 'https://requestb.in/1jjm6wu1';
        c1.Authentication__c = 'sfdcuser';
        insert c1;
        LeadProductInterest__c l1= new LeadProductInterest__c();
        l1.Name = 'Telefoni';
        l1.Code__c = 'PC';
        insert l1;
        LeadAlphaController.SendAlpha(BuyId);
        LeadAlphaController.sendtoAlpha(BuyId);
        LeadAlphaController.LEAD_ALPHA_SYNC_STATUS_OK = 'TEST DONE';
    }
}