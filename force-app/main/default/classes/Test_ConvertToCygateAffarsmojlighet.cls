/**
About
-----
Description: Test class for ConvertToCygateAffarsmojlighet
Create date: Aug 2016
Update History
--------------
Created Aug 2016 - N.G
Issues / TODOs
--------------  
Idially we should not use 'SeeAllData= true', but here we are using it because activity history table requires 'SeeAllData= true' modifier.
*/
@isTest(SeeAllData= true)
private class Test_ConvertToCygateAffarsmojlighet {
    
    public static testMethod void TestConvertToCygateAffarsmojlighet_NSCSvalidation(){        
         User cygateUser = Test_DataFactory.createCygateUser();
         Account acc;
         System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;         
         }
         System.runAs(cygateUser){   
            Opportunity opp = Test_DataFactory.createProspect();
            opp.accountID = acc.id;
            opp.Kammarkollegiet__c = 'Ej Kammarkollegiet';
            try{
                insert opp;
                ApexPages.currentPage().getParameters().put('id',opp.id);
                ApexPages.StandardController stdContact = new ApexPages.StandardController(opp); 
                ConvertToCygateAffarsmojlighet classObj = new ConvertToCygateAffarsmojlighet(stdContact);
                classObj.processRecord();
                system.assert(false, 'The conversion processRecord() should not have succeeded');
            }
            catch(Exception e){
                system.debug('here i am'+e.getmessage());
                system.assert(e.getMessage().contains('New Sales eller Continuation Sales'), 'The conversion did not throw the correct error message');
            }                   
        }       
    }

    public static testMethod void TestConvertToCygateAffarsmojlighet_Success(){        
         User cygateUser = Test_DataFactory.createCygateUser();
         Account acc;
         System.runAs(new User(Id = Userinfo.getUserId())){ // Avoids MIXED_DML_OPERATION error (when test executes in the Salesforce UI).
            insert cygateUser;
            acc = Test_DataFactory.createOneCygateAccount(cygateUser.Id);
            insert acc;         
         }
         System.runAs(cygateUser){   
            Opportunity opp = Test_DataFactory.createProspect();
            opp.accountID = acc.id;
            opp.new_sales__c = 50;
            opp.Continuation_Sales__c = 12;
            opp.Kammarkollegiet__c = 'Ej Kammarkollegiet';
            try{
                insert opp;
                ApexPages.currentPage().getParameters().put('id',opp.id);
                ApexPages.StandardController stdContact = new ApexPages.StandardController(opp); 
                ConvertToCygateAffarsmojlighet classObj = new ConvertToCygateAffarsmojlighet(stdContact);
                classObj.processRecord();
            }
            catch(Exception e){
                system.assert(false, 'The conversion processRecord() should have succeeded');
            }                   
        }       
    }   
}