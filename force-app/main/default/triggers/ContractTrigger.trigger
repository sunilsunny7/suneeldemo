/**
* Description:
* Before delete, insert, update and after insert, update and undelete trigger on Contract
* 
* Modifications:
* 11.08.2023 [Tomass Brazovskis] LTAT-7521 - Modified. Run ContractWholesalesTriggerHandler
*             BEFORE ContractTriggerHandler.
**/
trigger ContractTrigger on Contract (before update,before insert, before delete, after update,after insert, after delete){
    system.debug('^^^^^'+trigger.new);
    // LTAT-7521 - ContractWholesalesTriggerHandler must be run before 
    // ContractTriggerHandler to possibly bypass the latter
    ContractWholesalesTriggerHandler curContractWholesalesTHInstance = new ContractWholesalesTriggerHandler();
    curContractWholesalesTHInstance.run();
    if(!curContractWholesalesTHInstance.getContainsBatchAnyWholesalesContracts()){
        ContractTriggerHandler handler = new ContractTriggerHandler(Trigger.isExecuting, Trigger.size);
        TeliaSE_TUPPIntegrationHandler tuppIntHndlr = new TeliaSE_TUPPIntegrationHandler();
        
        if(Trigger.isBefore){      
            if(Trigger.isUpdate){
                handler.OnbeforeUpdate(Trigger.new,Trigger.newMap, Trigger.old, Trigger.oldMap);
            }else if (Trigger.isInsert){
                handler.OnbeforeInsert(Trigger.new, Trigger.newMap);
            }
        }
        else if(Trigger.isAfter){
            if(Trigger.isUpdate){
                If(label.TeliaSE_MC_MigrationFlag=='False')
                {
                    handler.onAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                    for(Contract cont : Trigger.new)
                    {
                        if( cont.Status == 'Cancelled' && cont.TeliaSE_TUPP_Interface_Name__c != 'DeleteAgreementCase' && cont.Status != Trigger.oldMap.get(cont.Id).Status && Trigger.oldMap.get(cont.Id).Status != 'Active' && cont.TeliaSE_Case_Id__c != null){
                            TeliaSE_TUPPIntegrationHandler.callDeleteAgreemntCase(cont.Id);
                        } 
                        //Scenario: When contract is cancelled, the FA Contract field in the account is blanked.
                        //If we are cancelling a draft agreement and an Active agreement also exists for the same account, the below function will update the active contract in the FA contract field in the account
                        if(cont.status == 'Cancelled' && cont.Status != Trigger.oldMap.get(cont.Id).Status && Trigger.oldMap.get(cont.Id).Status != 'Active' && cont.Account.FA_Contract__c == null)
                        {
                            handler.checkActiveContract(cont);
                        }
                        
                        //MCSTO-6652 ESD After Market SnowPublish Extension $$AgreementCaseEvent$$
                        //Contract status (Signed --> Active) 
                        
                        //Commented as part of LTAT-25644- Dsiable SPOCK sync on Signed status
                      	/*
                        if(cont.Status == 'Signed' && cont.Status != Trigger.oldMap.get(cont.Id).Status &&  Trigger.oldMap.get(cont.Id).Status == 'Sent for Signing' && !(cont.TeliaSE_Termination_Contract_Line_Flag__c > 0)  && cont.Contract_Record_Type__c == 'Ramavtal' && System.label.MC_SpockToggle=='true'){
                            TeliaSE_TUPPIntegrationHandler.callPostAgreementDetailsSpock(cont.Id);
                        }*/
                        if(cont.Status == 'Active' && cont.Status != Trigger.oldMap.get(cont.Id).Status &&  Trigger.oldMap.get(cont.Id).Status == 'Signed' && cont.MC_Snow_Sync__c == false && !(cont.TeliaSE_Termination_Contract_Line_Flag__c > 0)  && cont.Contract_Record_Type__c == 'Ramavtal')
                        {
                            TeliaSE_TUPPIntegrationHandler.callPostAgreementDetailsSnow(cont.Id);
                            if(System.label.MC_SpockToggle=='true'){
                                TeliaSE_TUPPIntegrationHandler.callPostAgreementDetailsSpock(cont.Id);
                            }
                        }
                        
                        //MCSTO-6652 ESD After Market SnowPublish Extension $$AgreementStateChangeEvent$$
                        //Contract status (Active --> Cancelled ) 
                        if(cont.Status == 'Cancelled' && cont.Status != Trigger.oldMap.get(cont.Id).Status &&  Trigger.oldMap.get(cont.Id).Status == 'Active' && cont.Contract_Record_Type__c == 'Ramavtal')
                        {
                            TeliaSE_TUPPIntegrationHandler.callDeleteAgreementDetailsSnow(cont.Id);
                            if(System.label.MC_SpockToggle=='true'){
                                TeliaSE_TUPPIntegrationHandler.callAgreementStateChangeEventSpock(cont.Id);
                            }
                        }
                        // AutoTask post Agreement Sync
                        // Contract status (Sent for Signing --> Signed )
                        if(cont.Status == 'Signed' && cont.Status != Trigger.oldMap.get(cont.Id).Status &&  Trigger.oldMap.get(cont.Id).Status == 'Sent for Signing')
                        {
                            TeliaSE_TUPPIntegrationHandler.AutoTaskContractSync(cont.Id);
                            if(System.Label.TeliaSE_Fiber_SiebelAgreementSync_Switch == 'True' && cont.Contract_Record_Type__c == 'Connected & Smart Building' && cont.TeliaSE_Retention_Contract__c != true && cont.Fiber_Contract_Type__c != 'Frame Agreement' && (cont.Agreement_KO_nr__c == null || cont.Agreement_KO_nr__c =='')){
                                TeliaSE_TUPPIntegrationHandler.callPostAgreementDetailsSiebel(cont.Id);
                            }
                        }
                    }
                }
                //Added as part of Fiber Retention(LTAT-8369)
                handler.updatePreviousContractStatus(Trigger.new,Trigger.oldMap,Trigger.newMap);
                ContractEvent__e objEvnt = new ContractEvent__e();
                Eventbus.publish(objEvnt);
            }
            else if(Trigger.isInsert){
                handler.onAfterInsert(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
            }
            else if(Trigger.isDelete) {
                handler.OnAfterDelete(Trigger.old, Trigger.oldMap);
            }
            
        }
    }}