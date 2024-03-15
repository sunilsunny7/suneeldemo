global class BatchExistingSegmentation implements Database.Batchable < sObject > {

    String query;
    Set<String> ombs = new Set<String>{'Y5501','Y5502','Y5503','Y5504','Y5600'};
    Set<String> BUnit = new Set<String>{'Large Business','Small Business','Public & Key'};
    Set<String> BUnit2 = new Set<String>{'Enterprise other'};
     Set<Id> OrgRecTypeIds = new Set<Id>{SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE),SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_SME),SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC1),SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE_SEC2)};
    global Database.QueryLocator start(Database.BatchableContext BC) {
         //Parent.Kundkonto_nr__c NOT IN :ombs';
        
        query = 'SELECT Parent.DS__c,RecordtypeId,GESB_FLAG_ORG__C,Parent.Industry,Parent.Account_Type__c,Customer_Segment__C,Cust_Business_Unit__c,Business_Area__C,Business_Unit_Lvl1__c,Business_Unit_Lvl2__c,Business_Sales_Unit__c,Business_Unit__c,Sales_Team__c,DS__c,Industry,Account_Type__c,Suggested_Business_Unit__c,Suggested_SubBusinessUnitLvl2__c,Suggested_SubBusinessUnitLvl1__c from Account where Cust_Business_Unit__c NOT IN :BUnit2 and Parent.Kundkonto_nr__c NOT IN :ombs and Kundkonto_nr__c NOT IN :ombs';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List < Account > scope) {
       
        for (Account acc: scope) {
        
         //Cust_Business_Unit__c (Business Unit)
         if(acc.Cust_Business_Unit__c == 'Small Business' || (acc.Cust_Business_Unit__c == 'Large Business' && (acc.Business_Unit_Lvl2__c == 'Large BA 50-99' || acc.Business_Unit_Lvl2__c == 'Large BA 100-149' || acc.Business_Unit_Lvl2__c == 'Large BA 150+')) )
         {
          acc.Cust_Business_Unit__c='SME';
          
         }
         // Suggested_Business_Unit__c (Suggested Unit)
         if(acc.Suggested_Business_Unit__c == 'Large Business' && (acc.Suggested_SubBusinessUnitLvl2__c == 'Large BA 50-99' || acc.Suggested_SubBusinessUnitLvl2__c == 'Large BA 100-149' || acc.Suggested_SubBusinessUnitLvl2__c == 'Large BA 150+'))
         {
           acc.Suggested_Business_Unit__c ='SME';
         }
         
         //Update Business_Unit_Lvl1__c
         if(acc.Business_Unit_Lvl1__c == 'Small 0-4' || acc.Business_Unit_Lvl1__c == 'Small 5-9' || acc.Business_Unit_Lvl1__c == 'Small 10-19' || acc.Business_Unit_Lvl1__c == 'Small 20-49' )
         {
          acc.Business_Unit_Lvl1__c = 'SME MassMarket';
          
         }
         
         else if(acc.Business_Unit_Lvl1__c == 'Small Business Account' || acc.Business_Unit_Lvl1__c == 'Large Business Account')
         {
          acc.Business_Unit_Lvl1__c = 'SME AM';
          
         }
         else if(acc.Business_Unit_Lvl1__c == 'Large Regional Account')
         {
           acc.Business_Unit_Lvl1__c = 'Regional Account';
         }
         else if(acc.Business_Unit_Lvl1__c == 'Key')
         {
           acc.Business_Unit_Lvl1__c = 'Key Account';
         }
         else if(acc.Business_Unit_Lvl1__c == 'Public')
         {
           acc.Business_Unit_Lvl1__c = 'Public Sector';
         }
         
         // Update Business_Unit_Lvl2__c
         if(acc.Business_Unit_Lvl2__c == 'Small 0-4')
         {
          acc.Business_Unit_Lvl2__c = 'SME MM Micro 0-4';
          
         }
         else if(acc.Business_Unit_Lvl2__c == 'Small 5-9')
         {
          acc.Business_Unit_Lvl2__c = 'SME MM Micro 5-9';
          
         }
         else if(acc.Business_Unit_Lvl2__c == 'Small 10-19')
         {
          acc.Business_Unit_Lvl2__c = 'SME MM Small 10-49';
          
         }
         else if(acc.Business_Unit_Lvl2__c == 'Small 20-49')
         {
          acc.Business_Unit_Lvl2__c = 'SME MM Other';
          
         }
         else if(acc.Business_Unit_Lvl2__c == 'Small Business Account')
         {
          acc.Business_Unit_Lvl2__c = 'SME AM 10-49';
          
         }
         else if(acc.Business_Unit_Lvl2__c == 'Large BA 50-99')
         {
          acc.Business_Unit_Lvl2__c = 'SME AM 50-99';
          
         }
         else if(acc.Business_Unit_Lvl2__c == 'Large BA 100-149')
         {
          acc.Business_Unit_Lvl2__c = 'SME AM 100-149';
          
         }
         else if(acc.Business_Unit_Lvl2__c == 'Large BA 150+')
         {
          acc.Business_Unit_Lvl2__c = 'SME AM 150+';
          
         }
          else if(acc.Business_Unit_Lvl2__c == 'Large RA Account')
         {
          acc.Business_Unit_Lvl2__c = 'Large RA Large';
          
         }
         
         //Sector Update
         if(acc.Business_Sales_Unit__c== 'Key Account' || acc.Business_Sales_Unit__c== 'Public Sector')

          {

           acc.Business_Sales_Unit__c='Enterprise P&K';

          }


          if(acc.Business_Unit__c == 'Small Mass Market' || acc.Business_Unit__c == 'Business Account'|| acc.Business_Unit__c == 'SME Mass Market' || acc.Business_Unit__c == 'SME Sales')

          {

           acc.Business_Sales_Unit__c='Enterprise SME ';

          }

          if(acc.Business_Unit__c == 'Small Mass Market'){

          acc.Business_Unit__c ='SME Mass Market';

          }

          if(acc.Business_Unit__c=='Business Account'){

          acc.Business_Unit__c ='SME Sales';

          } 
       
         
         acc.GESB_FLAG_ORG__C=true;
         }
         try{
        update scope;
        }
        catch (Exception e) {
        System.debug('Exception while executing the Segmentation batch job: ' + e);
        }
    }


    public void finish(Database.BatchableContext BC) {
        System.debug('AccountOptOut FINNISH');
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =: BC.getJobId()
        ];

        // Send an email to the Apex job's submitter 
        //   notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {
            a.CreatedBy.Email
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('BatchUpdateRecs ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
            mail
        });

    }
}