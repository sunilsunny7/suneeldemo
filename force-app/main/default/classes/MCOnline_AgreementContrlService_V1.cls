global class MCOnline_AgreementContrlService_V1 implements Database.Batchable<sObject>,Schedulable, Database.AllowsCallouts, Database.Stateful {
    public list<MCOnline_Agreement_Services_Temp_data__c> mcobjList = new list<MCOnline_Agreement_Services_Temp_data__c>();
    public list<string> agreementNum = New list<string>();
    public set<string> agreementNumSet = New set<string>();
    public map<string,string> agreementServiceValuesMap = New map<string,string> ();
    public MCOnline_AgreementContrlService_V1(){
        agreementServiceValuesMap.put('DEF','Pre-selected');
        agreementServiceValuesMap.put('OBL','Mandatory');
        agreementServiceValuesMap.put('VAL','Optional');
        agreementServiceValuesMap.put('E','Non-selectable');
        agreementServiceValuesMap.put('N','Non-selectable');
        mcobjList = [SELECT id, MCOnline_Agreement_number__c,MCOnline_Subscription_type_code__c,MCOnline_Service_code__c,MCOnline_Service_type__c,MCOnline_Service_availability__c,MCOnline_Service_status__c FROM MCOnline_Agreement_Services_Temp_data__c order by CreatedDate asc];
        
    }
    
    global list<MCOnline_Agreement_Services_Temp_data__c> start(Database.BatchableContext BC) {
        
        return mcobjList;
    }
    global void execute(Database.BatchableContext BC,List<MCOnline_Agreement_Services_Temp_data__c> mcobjList){ 
        List<MCOnline_Agreement_Services_Temp_data__c> agrList;
        list<vlocity_cmt__ContractLineItem__c> contractLineItemsListtoUpdate = New list<vlocity_cmt__ContractLineItem__c>();
        Map<String,List<MCOnline_Agreement_Services_Temp_data__c>> test = new Map<String,List<MCOnline_Agreement_Services_Temp_data__c>>();
        for(MCOnline_Agreement_Services_Temp_data__c m :mcobjList ){
            agreementNumSet.add(m.MCOnline_Agreement_number__c);
            if(test.containsKey(m.MCOnline_Agreement_number__c)){
                agrList = test.get(m.MCOnline_Agreement_number__c);
                agrList.add(m);
                test.put(m.MCOnline_Agreement_number__c,agrList);
            }else{
                agrList = new List<MCOnline_Agreement_Services_Temp_data__c>();
                agrList.add(m);
                test.put(m.MCOnline_Agreement_number__c, agrList);
            }
        }
        //system.debug('size of test'+test.size());
        list<contract> clist = [select id,Agreement_Nr__c,(select id,vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c,vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c from vlocity_cmt__ContractLineItems__r) from contract where Agreement_Nr__c in:agreementNumSet];
        //system.debug('clist '+clist);
        //system.debug('size of contract list'+clist.size());
        for(contract contractObj : clist){
            if (test.containsKey(contractObj.Agreement_Nr__c)) {
                agrList = test.get(contractObj.Agreement_Nr__c);
                //system.debug('agrList'+agrList);
                //system.debug('contractObj.Agreement_Nr__c'+contractObj.Agreement_Nr__c);
                for(MCOnline_Agreement_Services_Temp_data__c mcOnlineObj : agrList){                      
                    for(vlocity_cmt__ContractLineItem__c contractLineObj : contractObj.vlocity_cmt__ContractLineItems__r ){
                        if(String.isNotBlank(contractLineObj.vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c) && contractLineObj.vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c.contains('-')){
                            list<string> serviceCode = contractLineObj.vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c.split('-');
                           // String subscriptionTypeCode = contractLineObj.vlocity_cmt__Product2Id__r.TeliaSE_Subscription_Type__c;
                            if(serviceCode.get(0) == mcOnlineObj.MCOnline_Service_code__c  && serviceCode.get(1) == mcOnlineObj.MCOnline_Service_type__c){
                                if(mcOnlineObj.MCOnline_Service_status__c=='E'|| mcOnlineObj.MCOnline_Service_status__c=='N'){
                                   contractLineObj.MCOnline_Agreement_controlled_service__c = agreementServiceValuesMap.get(mcOnlineObj.MCOnline_Service_status__c); 
                                }else{
                                  contractLineObj.MCOnline_Agreement_controlled_service__c = agreementServiceValuesMap.get(mcOnlineObj.MCOnline_Service_availability__c);  
                                }
                                //system.debug('contract Id ===>'+contractLineObj.vlocity_cmt__ContractId__c);
                                //system.debug('contractLineItemsListtoUpdate'+contractLineItemsListtoUpdate);
                                if(contractLineItemsListtoUpdate.indexOf(contractLineObj)==-1){
                                    contractLineItemsListtoUpdate.add(contractLineObj);
                                    
                                }else{
                                    contractLineItemsListtoUpdate.remove(contractLineItemsListtoUpdate.indexOf(contractLineObj));
                                    contractLineItemsListtoUpdate.add(contractLineObj);
                                }
                                //system.debug('contractLineItemsListtoUpdate'+contractLineItemsListtoUpdate);
                                //system.debug('contractLineObj'+contractLineObj);
                                //break;
                            }
                        } else {
                            if(contractLineObj.vlocity_cmt__Product2Id__r.TeliaSE_Product_Service_Code__c == mcOnlineObj.MCOnline_Service_code__c ){
                                if(mcOnlineObj.MCOnline_Service_status__c=='E'|| mcOnlineObj.MCOnline_Service_status__c=='N'){
                                   contractLineObj.MCOnline_Agreement_controlled_service__c = agreementServiceValuesMap.get(mcOnlineObj.MCOnline_Service_status__c); 
                                }else{
                                   contractLineObj.MCOnline_Agreement_controlled_service__c = agreementServiceValuesMap.get(mcOnlineObj.MCOnline_Service_availability__c); 
                                }
                                system.debug('contractLineItemsListtoUpdate'+contractLineItemsListtoUpdate);
                                if(contractLineItemsListtoUpdate.indexOf(contractLineObj)==-1){
                                   
                                  contractLineItemsListtoUpdate.add(contractLineObj);  
                                }else{
                                    contractLineItemsListtoUpdate.remove(contractLineItemsListtoUpdate.indexOf(contractLineObj));
                                    contractLineItemsListtoUpdate.add(contractLineObj);
                                }
                                //system.debug('contractLineItemsListtoUpdate'+contractLineItemsListtoUpdate);
                                //system.debug('contractLineObj '+contractLineObj + ' mcOnlineObj ' + mcOnlineObj);
                                //break;
                            }
                        }   
                    }
                }  
            }
        }
        if(!contractLineItemsListtoUpdate.isEmpty()){
            system.debug('contractLineItemsListtoUpdate'+contractLineItemsListtoUpdate);
            Database.update(contractLineItemsListtoUpdate);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new MCOnline_AgreementContrlService_V1());    
    }
}