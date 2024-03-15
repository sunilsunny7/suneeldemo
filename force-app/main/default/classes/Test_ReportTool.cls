@isTest(SeeAlldata =false)
public class Test_ReportTool {
    
    
    public static testmethod void testReportTool(){  
        
      recordType taskRecordType = [SELECT id,developername FROM recordtype WHERE developername = 'Cygate_Tasks' limit 1];
        recordType eventRecordType = [SELECT id,developername FROM recordtype WHERE developername = 'Cygate_Events' limit 1];
        
        Account acc = new Account();
        
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        
        insert adminUser;
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();  
              
            insert acc; 
            
            Account acc1 = Test_DataFactory.createOneAccount();
            acc1.ParentID = acc.id;
            insert acc1;

            Task t1 = new Task(recordTypeID = (String)taskRecordType.Id,
                               Status= 'Stängd',
                               type= 'Web', 
                               ownerID = adminUser.id,
                               Cloud_Datacentre__c = true,
                               Customer_status__c = 'Befintlig kund',
                               Presented_Cloudanalysis__c = true, 
                               whatId= acc1.Id, 
                               ActivityDate = Date.newInstance(2016, 3, 16));
            
            
            insert t1;  
             
            Event e1 = new event(recordTypeID = (String)eventRecordType.Id,
                                 type= 'Web/video',Event_Complete__c = true, 
                                 ownerID = adminUser.id,
                                 Cloud_Datacentre__c = true,
                                 Customer_status__c = 'Befintlig kund',
                          Presented_Cloudanalysis__c = false, 
                                 whatId= acc1.Id, 
                                 EndDateTime = DateTime.newInstance(2020, 1, 10), 
                                 StartDateTime = DateTime.newInstance(2020, 1, 1));
                                
            insert e1;
            test.startTest();
            ReportToolController reportTool = new ReportToolController();
           
            Report_Tool_Setting__c rts = new Report_Tool_Setting__c();
            rts.EventRecordType_Id__c = eventRecordType.Id;
            rts.TaskRecordType_Id__c  = taskRecordType.Id;
            reportTool.rts = rts;
            
            //test.startTest();
            
            reportTool.LoadReport();
            
            
            System.assertEquals(2, reportTool.getActivityList.size()); 
            
            Event e2 = new event(recordTypeID = (String)eventRecordType.Id ,
                                 type= 'Web/video',
                                 Event_Complete__c = true, 
                                 ownerID = adminUser.id ,
                                 Cloud_Datacentre__c = true,
                                 Customer_status__c = 'Befintlig kund',
                        Presented_Cloudanalysis__c = false, 
                                 whatId= acc1.Id, 
                                 EndDateTime = DateTime.newInstance(2016, 1, 10), 
                                 StartDateTime = DateTime.newInstance(2016, 1, 1));
            insert e2;
            
            rts.Presented_Cloudananalys__c = 'False';
      reportTool.rts = rts;
            reportTool.LoadReport();
            System.assertEquals(2, reportTool.getActivityList.size()); 
            test.stopTest();
            rts.Presented_Cloudananalys__c = 'True';
      reportTool.rts = rts;
           // reportTool.LoadReport();
            
           // System.assertEquals(1, reportTool.getActivityList.size());
            
            
        }  
    }
    
     public static testmethod void testExportPage(){  
        
      recordType taskRecordType = [SELECT id,developername FROM recordtype WHERE developername = 'Cygate_Tasks' limit 1];
        recordType eventRecordType = [SELECT id,developername FROM recordtype WHERE developername = 'Cygate_Events' limit 1];
        
        Account acc = new Account();
        
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        insert adminUser;
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();       
            insert acc; 
            
            Account acc1 = Test_DataFactory.createOneAccount();
            acc1.Cygate_Account_Manager__c = cygateUser.id;
            acc1.ParentID = acc.id;
            insert acc1;
            //test.startTest();
            Task t1 = new Task(recordTypeID = (String)taskRecordType.Id,
                               Status= 'Stängd',
                               type= 'Web', 
                               ownerID = adminUser.id,
                               Cloud_Datacentre__c = true,
                               Customer_status__c = 'Befintlig kund',
                               Presented_Cloudanalysis__c = true, 
                               whatId= acc1.Id, 
                               ActivityDate = Date.newInstance(2016, 3, 16));
            
            
            insert t1;  
            //test.startTest();
            Event e1 = new event(recordTypeID = (String)eventRecordType.Id,
                                 type= 'Web/video',Event_Complete__c = true, 
                                 ownerID = adminUser.id,
                                 Cloud_Datacentre__c = true,
                                 Customer_status__c = 'Befintlig kund',
                          Presented_Cloudanalysis__c = false, 
                                 whatId= acc1.Id, 
                                 EndDateTime = DateTime.newInstance(2020, 1, 10), 
                                 StartDateTime = DateTime.newInstance(2020, 1, 1));
            
                                 
            insert e1;
            
            
            test.startTest();
            ReportToolController reportTool = new ReportToolController();
           
            Report_Tool_Setting__c rts = new Report_Tool_Setting__c();
            rts.EventRecordType_Id__c = eventRecordType.Id;
            rts.TaskRecordType_Id__c  = taskRecordType.Id;
            reportTool.rts = rts;
            
          
            
            reportTool.ExportReport();
            System.assertEquals(2, reportTool.getActivityList.size()); 
          // test.stopTest();
            Event e2 = new event(recordTypeID = (String)eventRecordType.Id ,
                                 type= 'Web/video',
                                 Event_Complete__c = true, 
                                 ownerID = adminUser.id ,
                                 Cloud_Datacentre__c = true,
                                 Customer_status__c = 'Befintlig kund',
                        Presented_Cloudanalysis__c = false, 
                                 whatId= acc1.Id, 
                                 EndDateTime = DateTime.newInstance(2016, 1, 10), 
                                 StartDateTime = DateTime.newInstance(2016, 1, 1));
                                
            insert e2;
        
            rts.Presented_Cloudananalys__c = 'False';
      reportTool.rts = rts;
            reportTool.ExportReport();
            System.assertEquals(2, reportTool.getActivityList.size()); 
//test.stopTest();
            rts.Presented_Cloudananalys__c = 'True';
      reportTool.rts = rts;
            reportTool.ExportReport();
            
            System.assertEquals(1, reportTool.getActivityList.size());
            test.stopTest();
            
        }  
    }
}