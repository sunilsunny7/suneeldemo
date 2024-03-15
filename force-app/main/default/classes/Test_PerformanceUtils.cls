@isTest(SeeAlldata =false)
private class Test_PerformanceUtils {    
    
    //User Performance, Yearly_Performance_Score  Exist and Event creation will update it
    public static testmethod void testupdateYearlyTaskScore(){  
        
        Integer CURRENT_YEAR = Datetime.now().year();   
        Account acc;
        Account acc1;        
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        adminUser.Cygate_Performance_User__c = true;
        insert adminUser;
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();       
            insert acc; 
            
            acc1 = Test_DataFactory.createOneAccount();
            acc1.Cygate_Account_Manager__c = cygateUser.id;
            acc1.ParentID = acc.id;
            insert acc1;
        } 
        User_Performance__c up = new User_Performance__c();
        up.Name = 'testUP';
        up.User__c = adminUser.id;
        insert up;
        
        Yearly_Performance_Score__c yps = new Yearly_Performance_Score__c();
        yps.User_Performance__c = up.id;
        yps.name = String.valueOf(PerformanceUtils.CURRENT_YEAR);
        insert yps;
        
        Campaign camp = Test_DataFactory.createCygateCampaign();
        insert camp;
        test.starttest();
        task objTask = new Task(recordtypeID = SEUtility.getRecordTypeId(SEUtility.TASK_REC_TYPE_CYGATE),
                                Status= 'Stängd',type= 'Web', ownerID = adminUser.id ,Bredda_aff_ren__c = true ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',
                                Presented_Cloudanalysis__c = true, Prioriterad_partner__c='Cisco',whatId= acc1.Id, Campaign__c = camp.Id, ActivityDate = Date.newInstance(CURRENT_YEAR, 3, 16));
        
        insert objTask;
        task verifyObjTask = [select id,points__c from task where id =: objTask.id];
       // System.assertEquals(12,verifyObjTask.points__c);
        list<Yearly_Performance_Score__c> verifyYPS1 = [SELECT Tasks_Score__c from Yearly_Performance_Score__c WHERE name =: '2017'];
        system.debug('***verifyYPS1***'+verifyYPS1);
        Yearly_Performance_Score__c verifyYPS = [SELECT Tasks_Score__c from Yearly_Performance_Score__c WHERE ID =: yps.id];
        system.debug('**verifyYPStaskscore**'+verifyYPS.Tasks_Score__c);
       // System.assertEquals(8,verifyYPS.Tasks_Score__c);
       test.stoptest();
        
        
    }
    
    /**User Performance and Yearly_Performance_Score does not exist
Event creation will create User Performance and create-update the points in Yearly_Performance_Score*****/
    public static testmethod void testupdateYearlyEventScore(){
        Account acc;
        Integer CURRENT_YEAR = Datetime.now().year();
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        adminUser.Cygate_Performance_User__c = true;
        insert adminUser;
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();     
            insert acc;
            Account acc1 = Test_DataFactory.createOneAccount();
            acc1.Cygate_Account_Manager__c = cygateUser.id;
            acc1.ParentID = acc.id;
            insert acc1;
            test.starttest();
            Campaign camp = Test_DataFactory.createCygateCampaign();
            insert camp;
            
            event objEvent = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Web/video',Event_Complete__c = true, Bredda_aff_ren__c= true,ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',
                                       Presented_Cloudanalysis__c = true, Prioriterad_partner__c = 'Cisco',whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            insert objEvent;
            Event e = [select id,points__c from event where id =: objEvent.id ];
            System.assertEquals(12,e.points__c);
            Yearly_Performance_Score__c verifyYPS = [SELECT id,Contribution_Score__c from Yearly_Performance_Score__c WHERE name = :String.valueOf(PerformanceUtils.CURRENT_YEAR)];
            system.debug('****verifyYPS rec***'+verifyYPS);
            System.assertNotEquals(NULL,verifyYPS.id);  
            //System.assertEquals(12,verifyYPS.Contribution_Score__c);
            system.debug('****verifyYPS***'+verifyYPS.id);
            system.debug('****verifyYPS***'+verifyYPS.Contribution_Score__c);
            test.stoptest();
            
        }
    }
  
  /*User Performance and Quarterly_Performance_Score does not exist
Event creation will create User Performance and create-update the points in Quarterly_Performance_Score*****/
    public static testmethod void testupdateQuarterlyEventScore(){
        Account acc;
        Integer CURRENT_YEAR = Datetime.now().year();
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        adminUser.Cygate_Performance_User__c = true;
        insert adminUser;
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();     
            insert acc;
            Account acc1 = Test_DataFactory.createOneAccount();
            acc1.Cygate_Account_Manager__c = cygateUser.id;
            acc1.ParentID = acc.id;
            insert acc1;
            
            Campaign camp = Test_DataFactory.createCygateCampaign();
            test.starttest();
            insert camp;
            
            event objEvent = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Web/video',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            insert objEvent;
            Event e = [select id,points__c from event where id =: objEvent.id ];
            System.assertEquals(8,e.points__c);
            Quarterly_Performance_Score__c verifyYPS = [SELECT id,Befintlig_Kund__c from Quarterly_Performance_Score__c WHERE name = 'Q1'OR name ='Q2'OR name='Q3'OR name='Q4' limit 1];
            system.debug('****verifyYPS rec***'+verifyYPS);
            System.assertNotEquals(NULL,verifyYPS.id);  
            //System.assertEquals(1,verifyYPS.Befintlig_Kund__c);
            system.debug('****verifyYPS***'+verifyYPS.id);
            system.debug('****verifyYPS***'+verifyYPS.Befintlig_Kund__c);
            test.stoptest();
            
        }
    } 
    /**User Performance Exist but Yearly_Performance_Score does not exist
Event creation will create-update the points in Yearly_Performance_Score*****/
    public static testmethod void testupdateYearlyEventScore1(){
        Account acc;
        Integer CURRENT_YEAR = Datetime.now().year(); 
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        adminUser.Cygate_Performance_User__c = true;
        insert adminUser;
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();     
            insert acc;
            Account acc1 = Test_DataFactory.createOneAccount();
            acc1.Cygate_Account_Manager__c = cygateUser.id;
            acc1.ParentID = acc.id;
            insert acc1;
            
            User_Performance__c up = new User_Performance__c();
            up.User__c = adminUser.id;
            up.Name = 'testUP';
            insert up;
            
            Campaign camp = Test_DataFactory.createCygateCampaign();
            test.starttest();
            insert camp;
            
            event objEvent = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Web/video',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            insert objEvent;
            Event e = [select id,points__c from event where id =: objEvent.id ];
            System.assertEquals(8,e.points__c);
            Yearly_Performance_Score__c verifyYPS = [SELECT id,Contribution_Score__c from Yearly_Performance_Score__c WHERE name = :String.valueOf(PerformanceUtils.CURRENT_YEAR)];
            system.debug('****verifyYPS rec***'+verifyYPS);
            System.assertNotEquals(NULL,verifyYPS.id);  
           // System.assertEquals(8,verifyYPS.Contribution_Score__c);
            system.debug('****verifyYPS***'+verifyYPS.id);
            system.debug('****verifyYPS***'+verifyYPS.Contribution_Score__c);
            test.stoptest();
            
        }
    }
    
  
  /**User Performance Exist but Quarterly_Performance_Score does not exist
Event creation will create-update the points in Quarterly_Performance_Score*****/
    public static testmethod void testupdateQuarterlyEventScore1(){
        Account acc;
        Integer CURRENT_YEAR = Datetime.now().year(); 
        string userRoleId = [SELECT Id from UserRole where name = 'CG:Konsult Hybrid IT' limit 1].id;
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        adminUser.Cygate_Performance_User__c = true;
        insert adminUser;
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();     
            insert acc;
            Account acc1 = Test_DataFactory.createOneAccount();
            acc1.Cygate_Account_Manager__c = cygateUser.id;
            acc1.ParentID = acc.id;
            insert acc1;
            Account acc2 = Test_DataFactory.createOneAccount();
            acc2.Cygate_Account_Manager__c = cygateUser.id;
            acc2.ParentID = acc.id;
            acc2.Org_Nr__c = label.Account_Org_N;
            insert acc2;
            
            contact con = Test_DataFactory.createOneContact();
            con.accountId = acc2.id;
            con.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CYGATE_USER);
            con.Is_Cygate_User_Contact__c = true;
            con.Cygate_User__c = adminUser.id;
            insert con;

            User_Performance__c up = new User_Performance__c();
            up.User__c = adminUser.id;
            up.ownerId = adminUser.Id;
            up.Name = 'testUP';
            insert up;
            
            Yearly_Performance_Score__c yps = new Yearly_Performance_Score__c();
            yps.User_Performance__c = up.id;
            yps.name = String.valueOf(PerformanceUtils.CURRENT_YEAR);
            //insert yps;

            Campaign camp = Test_DataFactory.createCygateCampaign();
            insert camp;
            test.startTest();
            List<event> objEventlist = new List<Event>();
            event objEvent1 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Web/video',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',Bredda_aff_ren__c = True,WhoId = con.Id,Sambes_k__c = true,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            objEventlist.add(objEvent1);
            event objEvent2 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Web/video',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Ny kund',Bredda_aff_ren__c = True,WhoId = con.Id,Sambes_k__c = true,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            objEventlist.add(objEvent2);                 
            event objEvent3 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Web/video',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund, ny kontakt',V_xa_befintlig_aff_r__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
                                       objEventlist.add(objEvent3); 
            event objEvent4 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Web/video',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',ka_avtalad_aff_r__c = true,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            objEventlist.add(objEvent4);
            event objEvent5 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Web/video',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Ny kund',V_xa_befintlig_aff_r__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            objEventlist.add(objEvent5);                 
            event objEvent6 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Web/video',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund, ny kontakt',ka_avtalad_aff_r__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            objEventlist.add(objEvent6);                 
            event objEvent21 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',Bredda_aff_ren__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 1));
            objEventlist.add(objEvent21);
            event objEvent22 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Ny kund',Bredda_aff_ren__c = True,whoId = con.Id,Sambes_k__c = true,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 1));
            objEventlist.add(objEvent22);                 
            event objEvent23 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund, ny kontakt',V_xa_befintlig_aff_r__c = True,WhoId = con.Id,Sambes_k__c = true,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 1));
            objEventlist.add(objEvent23); 
            event objEvent24 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',ka_avtalad_aff_r__c = true,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 1));
            objEventlist.add(objEvent24);
            event objEvent25 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Ny kund',V_xa_befintlig_aff_r__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 1));
            objEventlist.add(objEvent25);                 
            event objEvent26 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund, ny kontakt',ka_avtalad_aff_r__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 4, 1));
            objEventlist.add(objEvent26);
            event objEvent31 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',Bredda_aff_ren__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 1));
            objEventlist.add(objEvent31);
            event objEvent32 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Ny kund',Bredda_aff_ren__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 1));
            objEventlist.add(objEvent32);                 
            event objEvent33 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund, ny kontakt',V_xa_befintlig_aff_r__c = True,Whoid = con.id,Sambes_k__c = true,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 1));
            objEventlist.add(objEvent33); 
            event objEvent34 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',ka_avtalad_aff_r__c = true,WhoId = con.Id,Sambes_k__c = true,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 1));
            objEventlist.add(objEvent34);
            event objEvent35 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Ny kund',V_xa_befintlig_aff_r__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 1));
            objEventlist.add(objEvent35);                 
            event objEvent36 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund, ny kontakt',ka_avtalad_aff_r__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 7, 1));
            objEventlist.add(objEvent36);
            event objEvent41 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',Bredda_aff_ren__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 10, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 10, 1));
            objEventlist.add(objEvent41);
            event objEvent42 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Ny kund',Bredda_aff_ren__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 10, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 10, 1));
            objEventlist.add(objEvent42);                 
            event objEvent43 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund, ny kontakt',V_xa_befintlig_aff_r__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 10, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 10, 1));
            objEventlist.add(objEvent43); 
            event objEvent44 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',ka_avtalad_aff_r__c = true,WhoId = con.id,Sambes_k__c = true,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 10, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 10, 1));
            objEventlist.add(objEvent44);
            event objEvent45 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Ny kund',V_xa_befintlig_aff_r__c = True,WhoId = con.Id,Sambes_k__c = true,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 10, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 10, 1));
            objEventlist.add(objEvent45);                 
            event objEvent46 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund, ny kontakt',ka_avtalad_aff_r__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 10,10), StartDateTime = DateTime.newInstance(CURRENT_YEAR,10,1));
            objEventlist.add(objEvent46);                                                   
            insert objEventlist;
            Event e = [select id,points__c from event where id =: objEventList[0].id ];
            System.assertEquals(18,e.points__c);
            Quarterly_Performance_Score__c verifyYPS = [SELECT id,Befintlig_Kund__c from Quarterly_Performance_Score__c WHERE name = 'Q1'OR name ='Q2'OR name='Q3'OR name='Q4'limit 1];
            System.assertNotEquals(NULL,verifyYPS.id);  
            //System.assertEquals(2,verifyYPS.Befintlig_Kund__c);
            test.stopTest();
        }
    } 
    //Only give event points if Event and task both exist for same date
    public static testmethod void testupdateYearlyEventScore2(){
        Account acc;
        Integer CURRENT_YEAR = Datetime.now().year();
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        adminUser.Cygate_Performance_User__c = true;
        insert adminUser;
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();     
            insert acc;
            Account acc1 = Test_DataFactory.createOneAccount();
            acc1.Cygate_Account_Manager__c = cygateUser.id;
            acc1.ParentID = acc.id;
            insert acc1;
            
            User_Performance__c up = new User_Performance__c();
            up.Name = 'Anders Frölund';
            insert up;
            /* Yearly_Performance_Score will be created automatically after event is created
Yearly_Performance_Score__c yps = new Yearly_Performance_Score__c();
yps.User_Performance__c = up.id;
yps.name = '2017';
insert yps;
*/          
            test.starttest();
            Campaign camp = Test_DataFactory.createCygateCampaign();
            insert camp;
            
            task objTask = new Task(recordtypeID = SEUtility.getRecordTypeId(SEUtility.TASK_REC_TYPE_CYGATE)
                                    ,Status= 'Stängd',type= 'Web', ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',
                                    Presented_Cloudanalysis__c = false, whatId= acc1.Id, Campaign__c = camp.Id, ActivityDate = Date.newInstance(CURRENT_YEAR, 1, 10));
            insert objTask; 
            event objEvent = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),type= 'Web/video',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            insert objEvent;
            Event e = [select id,points__c from event where id =: objEvent.id ];
            System.assertEquals(8,e.points__c);
            Yearly_Performance_Score__c verifyYPS = [SELECT id,Contribution_Score__c from Yearly_Performance_Score__c WHERE name =:String.valueOf(PerformanceUtils.CURRENT_YEAR)];
            test.stoptest();
            PageReference pageRef = Page.MyPerformance;
            Test.setCurrentPage(pageRef);
            MyPerformanceVFController myperfcontroller = new MyPerformanceVFController();        
            ApexPages.currentPage().getParameters().put('ypsId',verifyYPS.Id);
            myperfcontroller.getYps(verifyYPS.Id);
            
                system.debug('****verifyYPS rec***'+verifyYPS);
            System.assertNotEquals(NULL,verifyYPS.id);  
            //System.assertEquals(8,verifyYPS.Contribution_Score__c);
            system.debug('****verifyYPS***'+verifyYPS.id);
            system.debug('****verifyYPS***'+verifyYPS.Contribution_Score__c);
            
        }
    }
    
    public static testmethod void testcheckSambesokForEvent(){
        
        string userRoleId = [SELECT Id from UserRole where name = 'CG:Business Developement' limit 1].id;
        Account acc;
        Integer CURRENT_YEAR = Datetime.now().year();
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        adminUser.UserRoleId = userRoleId;
        insert adminUser;
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();      
            insert acc;
            
            Account acc1 = Test_DataFactory.createOneAccount();
            acc1.Cygate_Account_Manager__c = cygateUser.id;
            acc1.ParentID = acc.id;
            acc1.Org_Nr__c = label.Account_Org_N;
            insert acc1;
            
            User_Performance__c up = new User_Performance__c();
            up.Name = 'Anders Frölund';
            
            insert up;
            
            contact con = Test_DataFactory.createOneContact();
            con.accountId = acc1.id;
            con.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CYGATE_USER);
            con.Is_Cygate_User_Contact__c = true;
            con.Cygate_User__c = adminUser.id;
            
            insert con;
            
            Yearly_Performance_Score__c yps = new Yearly_Performance_Score__c();
            yps.User_Performance__c = up.id;
            yps.name = String.valueOf(PerformanceUtils.CURRENT_YEAR);
            insert yps;
            test.starttest();
            Campaign camp = Test_DataFactory.createCygateCampaign();
            insert camp;
            
            event objEvent = new event(Execute_trigger__c  = true,Sambes_k__c = false, recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),type= 'Web/video',whoID = con.id,Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',
                                       Presented_Cloudanalysis__c = true,whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            System.assertEquals(false,objEvent.Sambes_k__c);
            System.assertEquals(true,objEvent.Execute_trigger__c);
            insert objEvent;
            
            Event e = [select id,Sambes_k__c,Execute_trigger__c from Event where ID =: objEvent.id ];
            
            System.assertEquals(false,e.Sambes_k__c);
            System.assertEquals(true,e.Execute_trigger__c);
            System.assertNotEquals(NULL,objEvent);
            test.stoptest();
        }
    }
    
    public static testmethod void testcheckSambesokForTask(){             
        string userRoleId = [SELECT Id from UserRole where name = 'CG:Business Developement' limit 1].id;
        Account acc;
        Integer CURRENT_YEAR = Datetime.now().year();
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        adminUser.UserRoleId = userRoleId;
        insert adminUser;
        
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();       
            insert acc; 
            Account acc1 = Test_DataFactory.createOneAccount();
            acc1.Cygate_Account_Manager__c = cygateUser.id;
            acc1.ParentID = acc.id;
            acc1.Org_Nr__c = label.Account_Org_N;
            insert acc1;
            
            Campaign camp = Test_DataFactory.createCygateCampaign();
            insert camp;
            
            User_Performance__c up = new User_Performance__c();
            up.Name = 'Anders Frölund';
            insert up;
            
            contact con = Test_DataFactory.createOneContact();
            con.accountId = acc1.id;
            con.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CYGATE_USER);
            con.Is_Cygate_User_Contact__c = true;
            con.Cygate_User__c = adminUser.id;
            insert con;
            
            Yearly_Performance_Score__c yps = new Yearly_Performance_Score__c();
            yps.User_Performance__c = up.id;
            yps.name = String.valueOf(PerformanceUtils.CURRENT_YEAR);
            insert yps;
            Test.startTest();
            task objTask = new Task(Execute_trigger__c  = true,Sambes_k__c = false, whoID = con.id,recordtypeID = SEUtility.getRecordTypeId(SEUtility.TASK_REC_TYPE_CYGATE),Status= 'Stängd',type= 'Web', ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',
                                    Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, ActivityDate = Date.newInstance(CURRENT_YEAR, 3, 16));
            System.assertEquals(false,objTask.Sambes_k__c);
            System.assertEquals(true,objTask.Execute_trigger__c);
            insert objTask;
            Task e = [select id,Sambes_k__c,Execute_trigger__c from Task where ID =: objTask.id ];          
            System.assertEquals(false,e.Sambes_k__c);
            System.assertEquals(true,e.Execute_trigger__c);
            System.assertNotEquals(NULL,objTask);  
            Test.stopTest();
        }
    }     
    public static testmethod void AatestupdateQuarterlyEventScore2(){
        Account acc;
        Integer CURRENT_YEAR = Datetime.now().year(); 
                
        string userRoleId = [SELECT Id from UserRole where name = 'CG:Konsult Hybrid IT' limit 1].id;
        user cygateUser = Test_DataFactory.createCygateUser();
        user adminUser = Test_DataFactory.createAdminUser();
        adminUser.Bypass_VR__c = true;
        adminUser.Cygate_Performance_User__c = true;
        insert adminUser;
        
        System.runAs(adminUser){
            acc = Test_DataFactory.createOneKundkontoAccount();     
            insert acc;
            Account acc1 = Test_DataFactory.createOneAccount();
            acc1.Cygate_Account_Manager__c = cygateUser.id;
            acc1.ParentID = acc.id;
            insert acc1;
            Account acc2 = Test_DataFactory.createOneAccount();
            acc2.Cygate_Account_Manager__c = cygateUser.id;
            acc2.ParentID = acc.id;
            acc2.Org_Nr__c = label.Account_Org_N;
            insert acc2;

            contact con = Test_DataFactory.createOneContact();
            con.accountId = acc1.id;
            con.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CYGATE_USER);
            con.Is_Cygate_User_Contact__c = true;
            con.Cygate_User__c = adminUser.id;
            insert con;
            test.starttest(); 
            User_Performance__c up = new User_Performance__c();
            up.User__c = adminUser.id;
            up.ownerId = adminUser.Id;
            up.Name = 'testUP';
            insert up;
            
            Yearly_Performance_Score__c yps = new Yearly_Performance_Score__c();
            yps.User_Performance__c = up.id;
            yps.name = String.valueOf(PerformanceUtils.CURRENT_YEAR);
            insert yps;
            Campaign camp = Test_DataFactory.createCygateCampaign();
            insert camp;
           
            List<Quarterly_Performance_Score__c> qpsList = [SELECT Id,Yearly_Performance_Score__c FROM Quarterly_Performance_Score__c WHERE Yearly_Performance_Score__c =: yps.Id];
            if(qpslist.size()>0){
                //delete qpslist;
            }
                             
            event objEvent1 = new event(recordtypeID = SEUtility.getRecordTypeId(SEUtility.EVENT_REC_TYPE_CYGATE),
                                       type= 'Telefonmöte',Event_Complete__c = true, ownerID = adminUser.id ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund, ny kontakt',V_xa_befintlig_aff_r__c = True,
                                       Presented_Cloudanalysis__c = true, whatId= acc1.Id, Campaign__c = camp.Id, EndDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 10), StartDateTime = DateTime.newInstance(CURRENT_YEAR, 1, 1));
            insert objEvent1;
            task objTask = new Task(recordtypeID = SEUtility.getRecordTypeId(SEUtility.TASK_REC_TYPE_CYGATE),
                                Status= 'Stängd',type= 'Web', ownerID = adminUser.id ,Bredda_aff_ren__c = true ,Cloud_Datacentre__c = true,Customer_status__c = 'Befintlig kund',
                                Presented_Cloudanalysis__c = true, Prioriterad_partner__c='Cisco',whatId= acc1.Id, Campaign__c = camp.Id, ActivityDate = Date.newInstance(CURRENT_YEAR, 3, 16));
        
            insert objTask;
            List<Task> taskList = [SELECT Id,Points__C FROM Task WHERE ID =: objTask.id];
            system.debug(taskList);
            test.stoptest();
                
        }
    }

}