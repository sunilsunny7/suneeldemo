/**
* @Author:      Surajit Pramanik
* @Company:     Capgemini
* @Date:        7th June, 2019
* @Description: This Class will trigger changeAgreementCase service
*
* History
* <Date>           <Authors Name>      <Brief Description of Change>
* -------------------------------------------------------------
*/
global class TeliaSE_ChangeAgreementBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    String query;
    String ContractStatus = 'Signed';
    String InterfaceName = 'createAgreementCase';
    String InterfaceName1 ='AddItemsToAgreement';
    String InterfaceName2 = 'createSwitchPrices';
    String InterfaceName3 = 'RegisterCase';
    String InterfaceName4 = 'spock_agreementCreateEvent';
    
    global TeliaSE_ChangeAgreementBatch(){
        query = 'SELECT Id, TeliaSE_TUPP_Interface_Name__c, TeliaSE_TUPP_Interface_Status__c, TeliaSE_TUPP_Interface_Error__c, TeliaSE_Start_Date__c, TeliaSE_Start_Date_Flag__c,TeliaSE_Type__c,TeliaSE_is_combi__c, CallOff_QuoteId__c, vlocity_cmt__QuoteId__r.TeliaSE_Touchpoint_Case_Number__c FROM Contract WHERE Status =: ContractStatus AND (TeliaSE_TUPP_Interface_Name__c =: InterfaceName OR TeliaSE_TUPP_Interface_Name__c =: InterfaceName1 OR TeliaSE_TUPP_Interface_Name__c =: InterfaceName2 OR TeliaSE_TUPP_Interface_Name__c =: InterfaceName3 OR  TeliaSE_TUPP_Interface_Name__c =:InterfaceName4) AND  TeliaSE_Case_Id__c != null';
            }    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<Contract> contractList)
	{
        System.debug('contractList'+contractList);
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> outMap = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> callOffInputMap = new Map<String, Object>();
        Map<String,Object> registerCaseInputMap = new Map<String,Object>();
		
		List<Id> callOffIdList = new List<Id>();
		List<Quote> QuoteList = new List<Quote>();
        //List<Quote> callOffCase= new List<Quote>();
        //List<Quote> callOffCaseList = new List<Quote>();
        List<vlocity_cmt__ContractLineItem__c> contractLines = new List<vlocity_cmt__ContractLineItem__c>();
        Boolean flag = false;
		Boolean noMobile = true;
		Map<String,Boolean> standAloneTPMap = new Map<String,Boolean>();
        
		// only extract mobile parent line status for all contracts
        List<vlocity_cmt__ContractLineItem__c> cliList = [Select id,name,TeliaSE_Product_Object_Type__c,vlocity_cmt__ContractId__c,vlocity_cmt__LineStatus__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c in:contractList  and TeliaSE_ParentItemId__c = null and TeliaSE_Product_Object_Type__c = 'Mobile Offer Specification'];        
        
        Map<string,string> contInterfaceNameMap = new Map<String,String>(); 
        // loop to find standalone touchpoint contracts
        for(Contract con: contractList)
		{
            if(con.TeliaSE_TUPP_Interface_Name__c == InterfaceName4){
                ContractHistory contractHistory = [SELECT id,createddate,field,contractid,NewValue,OldValue FROM ContractHistory WHERE (ContractId =: con.id AND Field = 'TeliaSE_TUPP_Interface_Name__c') ORDER BY CreatedDate desc LIMIT 1];
                if(contractHistory != null){
                    contInterfaceNameMap.put((String)con.id,(String)contractHistory.OldValue);
                }
            }
            else{
                contInterfaceNameMap.put((String)con.id,con.TeliaSE_TUPP_Interface_Name__c);
            }

            noMobile = true;
			if(contInterfaceNameMap.get((String)con.id) == InterfaceName2 && con.TeliaSE_Type__c == 'Y')
			{
				for(vlocity_cmt__ContractLineItem__c cli: cliList)
				{
					if(cli.vlocity_cmt__ContractId__c == con.id )
					{
						noMobile = false;
						If(cli.vlocity_cmt__LineStatus__c == 'Active')
						{
							standAloneTPMap.put(String.valueOf(con.id),true);
							break;
						}
						else
						{
							standAloneTPMap.put(String.valueOf(con.id),false);
						}
					}		
				}
				if(noMobile == true)
				{
					standAloneTPMap.put(String.valueOf(con.id),true);
				}	
			}
            else
            {
                standAloneTPMap.put(String.valueOf(con.id),false);
            }
                
		}
		
        //combi case loop
       /* for(Contract contList : contractList)
        {   
            if(ContList.CallOff_QuoteId__c != null)
            {
                Quote callOff = [SELECT Id, TeliaSE_Touchpoint_Case_Number__c FROM Quote WHERE ID =: ContList.CallOff_QuoteId__c];
                // callOffCaseList.add(callOff.TeliaSE_Touchpoint_Case_Number__c);
                if (callOff.TeliaSE_Touchpoint_Case_Number__c == null){
                    flag = true;
                }
            }
        }*/
		//combi case loop updated

		for(Contract contList : contractList)
		{   
		if(contList.CallOff_QuoteId__c != null)
		{
		callOffIdList.add(contList.CallOff_QuoteId__c);
		}
		}
		QuoteList = [SELECT Id, TeliaSE_Touchpoint_Case_Number__c FROM Quote WHERE ID IN :callOffIdList];

		for(Quote qtLst : QuoteList)
		{   
		if (qtLst.TeliaSE_Touchpoint_Case_Number__c == null)
		{
		flag = true;
		}
		}
     
		for(Contract cont : contractList)
        {
            if(String.valueOf(contInterfaceNameMap.get((String)cont.id)) == InterfaceName1 || 
               (String.valueOf(contInterfaceNameMap.get((String)cont.id)) == InterfaceName2 && standAloneTPMap.get(Cont.id)) ||
               (String.valueOf(contInterfaceNameMap.get((String)cont.id)) == InterfaceName3 && cont.TeliaSE_TUPP_Interface_Status__c == 'Error'))
            {
				//Inforhandling scenarios
				//AddItemstoAgreement calls RegisterCase
				//standalone tp scenarios
                registerCaseInputMap.put('ContractId',cont.id);
            }
            else if(String.valueOf(contInterfaceNameMap.get((String)cont.id)) == InterfaceName ||
                    String.valueOf(contInterfaceNameMap.get((String)cont.id)) == InterfaceName2  )
            {
				if((cont.TeliaSE_is_combi__c == false) || (flag == false && String.isNotBlank(cont.CallOff_QuoteId__c) && cont.TeliaSE_is_combi__c == true))
				{
                    inputMap.put('Id', cont.id);
                }
                else If(cont.TeliaSE_is_combi__c == true && String.isNotBlank(cont.CallOff_QuoteId__c) && flag == true)
				{
                    callOffInputMap.put('QuoteId', cont.CallOff_QuoteId__c);
				}
			}
            
        }
        String METHODNAME_CHANGEAGREEMENT = 'changeAgreementCase';
        String METHODNAME_CALLOFFSUBMIT = 'callOffSubmit';
        String METHODNAME_CALLREGISTERCASE = 'RegisterCase';
        
        TeliaSE_UpdateContract_TUPP updateContract = new TeliaSE_UpdateContract_TUPP();
			if(callOffInputMap != null && flag == true && callOffInputMap .keyset().size() > 0)
			{
				updateContract.invokeMethod(METHODNAME_CALLOFFSUBMIT, callOffInputMap, outMap, options);
			}
			if(inputMap != null && flag == false && inputMap.keyset().size() > 0)
			{ 
                System.debug('test');
				updateContract.invokeMethod(METHODNAME_CHANGEAGREEMENT, inputMap, outMap, options);
			}
			if(registerCaseInputMap!= null && registerCaseInputMap.keyset().size() > 0)
			{
				updateContract.invokeMethod(METHODNAME_CALLREGISTERCASE,registerCaseInputMap,outMap,options);
			}               
    }    
    global void finish(Database.BatchableContext bc){
    }    
    
}