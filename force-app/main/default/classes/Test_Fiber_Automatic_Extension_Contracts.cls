@isTest
private class Test_Fiber_Automatic_Extension_Contracts {
    @testSetup 
    
    static void setup()
    {
        /*
User usr = Test_DataFactory.createFiberSalesRepUsers(1)[0];
usr.Bypass_VR__c = true;
System.RunAs(usr)
{     */
        //usr.Bypass_VR__c = true;
        List<Contract> contracts = new List<Contract>();
        Id AccRtid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Account acct = new Account(Name='Batch Test Account', recordtypeid = AccRtid);
        Id Rtid = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Connected & Smart Building').getRecordTypeId();
        Id csbid = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('Connected & Smart Building').getRecordTypeId();
        insert acct;
        for (Integer i=0;i<10;i++) {
            contracts.add(new Contract(name='TestBatchtoActive '+i, AccountId=acct.Id, Status = 'Draft',
                                       Contract_Term_Years__c = 4, TeliaSE_Fiber_Installation_Date__c = System.today(),recordtypeid = Rtid));
            //system.debug('it is' + contracts);
            contracts.add(new Contract(name='TestBatchtoCancelled '+i,AccountId=acct.Id, Status = 'Draft',
                                       Contract_Termination_Date__c = System.today(),TeliaSE_Fiber_Installation_Date__c = System.today(),Contract_Term_Years__c = 2,recordtypeid = Rtid));
            //system.debug('it is 2' + contracts);
            contracts.add(new Contract(name='TestBatchforExtension '+i,AccountId=acct.Id, Status = 'Draft',
                                       Contract_Term_Years__c = 5,EndDate = System.today(),TeliaSE_Fiber_Installation_Date__c = System.today(),recordtypeid = Rtid));
        }
        insert contracts;
        Contract CC= new Contract();
        
        CC.TeliaSE_Type__c = 'New Sales';
        CC.status = 'Draft';
        CC.accountId = acct.Id;
        CC.TeliaSE_Fiber_Installation_Date__c = System.today();
        //CC.Contract_Termination_Date__c = system.today();
        CC.Contract_Term_Years__c = 1;
        cc.ContractTerm = 2;
        CC.recordtypeid = csbid;
        insert CC;
        
        Contract CC1= new Contract();
        
        CC1.TeliaSE_Type__c = 'Renegotiation';
        CC1.status = 'Draft';
        CC1.accountId = acct.Id;
        CC1.TeliaSE_Fiber_Previous_ContractId__c = CC.Id;
        CC1.TeliaSE_Fiber_Installation_Date__c = System.today();
        CC1.Contract_Term_Years__c = 2;
        CC1.recordtypeid = Rtid;
        insert CC1;
        
        
        CC.status = 'Signed';
        cc.Contract_Termination_Date__c = system.today();
        update CC;
        
        CC1.status = 'Active';
        cc1.Contract_Termination_Date__c = system.today();
        update CC1;
        
        
        Contract CC2= new Contract();
        
        CC2.TeliaSE_Type__c = 'Renegotiation';
        CC2.status = 'Draft';
        CC2.accountId = acct.Id;
        CC2.TeliaSE_Fiber_Installation_Date__c = System.today();
        CC2.StartDate = CC2.TeliaSE_Fiber_Installation_Date__c;
        
        //CC.Contract_Termination_Date__c = system.today();
        CC2.Contract_Term_Years__c = 1;
        CC2.recordtypeid = csbid;
        insert CC2;
		CC2.status = 'Active';
        CC2.Reason_for_Cancellation__c = 'Omförhandlat';
        cc2.EndDate = system.today();
        cc2.Contract_Termination_Date__c = null;
        update CC2;
        
        Contract CC3= new Contract();
        
        CC3.TeliaSE_Type__c = 'Renegotiation';
        CC3.status = 'Draft';
        CC3.accountId = acct.Id;
        CC3.TeliaSE_Fiber_Installation_Date__c = null;
        CC3.StartDate = CC2.TeliaSE_Fiber_Installation_Date__c;
        
        //CC.Contract_Termination_Date__c = system.today();
        CC3.Contract_Term_Years__c = 1;
        CC3.recordtypeid = csbid;
        insert CC3;
		CC3.status = 'Signed';
        CC3.Reason_for_Cancellation__c = 'Omförhandlat';
        cc3.EndDate = system.today();
        cc3.Contract_Termination_Date__c = null;
        cc3.ContractTerm = 2;
        update CC3;
        cc.TeliaSE_Fiber_Previous_ContractId__c = CC3.Id; 
        update cc;
        List<Contract> updatecon = [select status ,Contract_Termination_Date__c, TeliaSE_Fiber_Installation_Date__c,EndDate from contract where CreatedDate = TODAY and status = 'Draft'];
        for(Contract conn : updatecon)
        {
            if(conn.TeliaSE_Fiber_Installation_Date__c == System.today() && conn.Status == 'Draft')
            {
                conn.Status = 'Signed';
                
            }
            else if(conn.EndDate == System.today() && conn.Status == 'Draft')
            {
                conn.Status = 'Active';
                
            }
            else if(conn.Contract_Termination_Date__c == System.today() && conn.Status == 'Draft')
            {
                conn.Status = 'Active';
                
            }
            //updatecon.add(conn);
        }
        
        update updatecon;
        
    }
    
    static testmethod void test(){  
        
        //CRMSalesrep.Bypass_VR__c = true;
        Test.startTest();
        //User usr = Test_DataFactory.createFiberSalesRepUsers(1)[0];
        //usr.Bypass_VR__c = true;
        List<Contract> lst = [Select Id,StartDate,TeliaSE_Fiber_Previous_ContractId__c,EndDate,Status,Contract_Termination_Date__c,Reason_for_Cancellation__c,TeliaSE_Fiber_Installation_Date__c, ContractTerm from Contract];
        
        Fiber_Automatic_Extension_Contracts bt = new Fiber_Automatic_Extension_Contracts();
        Id batchId = Database.executeBatch(bt);
        Database.BatchableContext bc;
        bt.execute(bc, lst);
        
        Test.stopTest();
    }// test
} // Class