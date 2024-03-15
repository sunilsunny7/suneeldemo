@IsTest
public class Test_MC_XLSTemplateGenerator {
    
    public static testmethod void testMethod1(){
        User salesManager;
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            salesManager.MobilePhone='975975';
            salesManager.Email='sanjolia2806@gmail.com';
            insert salesManager;
        }
        System.runAs(salesManager){
            Account acc = Test_DataFactory.createOneAccount();
            insert acc; 
            
                 
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();

       
        
        Product2 prod = Test_DataFactory.createProducts(1)[0];
            prod.ProductCode='TPP-Virtuel';
            prod.TeliaSE_MC_isCallOff_Flag__c = false;
        insert prod;
            
        
        pricebookId = stdPriceBookRecId ;
       
       
       
         PricebookEntry objpricebookentry =new PricebookEntry();
         objpricebookentry.Product2ID = prod.id;
         objpricebookentry.Pricebook2ID = stdPriceBookRecId;
         objpricebookentry.UnitPrice=23.50;
         objpricebookentry.UseStandardPrice=false;
         objpricebookentry.isActive=true;//Add this line
         insert objpricebookentry;
            
            Contract conObj = new Contract();
            conObj.recordtypeid = SEUtility.getRecordTypeId(SEUtility.Contract_FRAMEWORK_AGREEMENT);
            conObj.Contract_Record_Type__c = 'Ramavtal';
            conObj.TeliaSE_Parent_Agreement__c = '1234567';
            conObj.TeliaSE_Type__c = 'NewSales';
            conObj.StartDate = system.today();
            conObj.status = 'Draft';
            conObj.accountId = acc.Id;
            conObj.TeliaSE_TUPP_Interface_Name__c = 'AgreementCreateEvent';
            
            insert conObj;
            
           
            
            TPPOrderExtract__c tpporder = new TPPOrderExtract__c();
            	tpporder.name='1';
                tpporder.ProductName__c = 'Touchpoint Virtuel';
                tpporder.ProductCode__c= 'TPP-Virtuel';
                tpporder.Quantity__c= 2;
                tpporder.OneTimeCharge__c= 120;
                tpporder.RecurringCharge__c= 230;
                tpporder.SerialNo__c= 23;
            insert tpporder;
            
             System.currentPagereference().getParameters().put('ContractID', conObj.id);
            
            vlocity_cmt__ContractLineItem__c cliobj = new vlocity_cmt__ContractLineItem__c();
            cliobj.vlocity_cmt__ContractId__c=conObj.id;
            cliobj.TeliaSE_Product_Object_Type__c = 'Touchpoint Plus Offer Spec';
            cliobj.TeliaSE_Start_Date__c = system.today();
            //cliobj.vlocity_cmt__ProductName__c = 'IT-Avdelning som Tjänst Plus';
            cliobj.vlocity_cmt__Product2Id__c= prod.id;
            cliobj.vlocity_cmt__Status__c = 'Active';
            cliobj.TeliaSE_Base_Quantity__c=2;
            cliobj.vlocity_cmt__OneTimeCharge__c=200;
            cliobj.vlocity_cmt__ContractId__c = conobj.id;
            cliobj.vlocity_cmt__RecurringCharge__c=25;
             insert cliobj;
          Map<String,Object> inputMap = new Map<String,Object>();
           inputMap.put('Id',conObj.id);
           XLSTesttemplateGenerator obj1 = new XLSTesttemplateGenerator();
           obj1.invokeMethod('generate', inputMap, inputMap, inputMap);		
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'abc';
        	cv.PathOnClient = 'abc' + ' - ' + DateTime.now() + '.xlsx';
        	//cv.VersionNumber= 1;
            cv.VersionData= EncodingUtil.base64Decode('Unit Test Attachment Body');
        	insert cv;
            
            /* ContentVersion cv2 = cv.clone();
        	cv2.Title= 'ExcelGenerated';        
        	insert cv2;*/

           
        }   
     
        
        
        
       
    }
}