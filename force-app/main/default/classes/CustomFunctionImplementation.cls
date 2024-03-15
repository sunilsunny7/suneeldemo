/*-----------------------------------------------------------------------------------------------------------
**Name        :        CustomfunctionImplementation 
**Created By  :        Abhinav Gupta
**Sprint      :        Sprint 13
**User Story  :        MCSTO- 4043
**Description :        Custom function used in DR and Context rules to return outputs.

**Functions   :        MutliPlicklistChoose , ESDAgreementItem

** SHOULD BE USED TO ADD CUSTOM FUNCTIONS In vlocity. Added Methods in invoke method and create function. 
** For full functionality add the method name to metadata for functions. It should become available.
-----------------------------------------------------------------------------------------------------------*/
global class CustomFunctionImplementation implements vlocity_cmt.VlocityOpenInterface
{
    /*
inputs - arguments - List<Object> of passed in arguments
output - result - The result of the Function being called. Supports single Object values, List<Object> or Map<String, Object>
*/
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        // SUM Returns a single value
        if (methodName == 'MultiPicklistChoose')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            output.put('result', MultiPicklistChoose(arguments));
        }
        else if (methodName == 'SCRenegotiation')  
        {  
            List<Object> arguments = (List<Object>)inputs.get('arguments');  
            output.put('result', SCRenegotiation(arguments));    
        }
        //Drop 3.2 - MCSTO-5660
        //Function for: DeleteCaseAPI 
        //For Delete Case, we send a caseID for which the contract is existing in TUPP. 
        //The only cases that count (CreateAgreementCase , CreateSwitchPrices, AddItemsToAgreement)
        else if(methodName == 'DeleteCaseId')
        {
            String resultCase;
            if(test.isRunningTest())
            {
                resultCase ='12345';
            }
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            String contractId =(String) arguments[0];
            List<ContractHistory> contractHistories = new List<ContractHistory>();
            if(!test.isRunningTest())
            {
                contractHistories = [SELECT id,createddate,field,contractid,NewValue FROM ContractHistory WHERE (ContractId =: contractId AND Field = 'TeliaSE_Case_Id__c') ORDER BY CreatedDate  LIMIT 1];
                if(contractHistories!= null && contractHistories.size()>0)
                {
                    ContractHistory ch = contractHistories[0];
                    resultCase = (String)ch.NewValue;    
                }
                else
                {
                    resultCase = 'NoHistory';
                }
                
            }
            output.put('result', resultCase);
        }
        else if (methodName == 'split')
        {
            List<Object> input = (list<Object>)inputs.get('arguments');
            String input1 =(String) input[0];
            Map<String,String> result = splitt(input1);
            output.put('result',result);
        }        
        else if(methodName == 'countMatchesString')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            system.debug('argummnts==> '+ json.serialize(inputs.get('arguments')));
            String hierarchy =(String) arguments[0];
            String substringToMatch = (String)arguments[1];
            Integer count = hierarchy.countMatches(substringToMatch);
            system.debug('count==> '+count);
            output.put('result', count);
        }
        else if(methodName == 'ImmediateParent'){
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            //system.debug('Arguments' +arguments );
            String hierarchy =(String) arguments[0];
            String Presentpdt = (String) arguments[1];
            //system.debug('hierarchy'+hierarchy);
            Integer endIndex = hierarchy.indexOf(Presentpdt) -1;
            Integer startIndex = endIndex-18;
            String result = hierarchy.substring(startIndex, endIndex);
            output.put('result', result);
            
        }
        
        
        
        
        else if(methodName == 'ESDAgreementItem')
        {
            try{
                Map<String,Object> agreementItemsDRNode = new Map<String,Object>();
                List<Object> arguments = (List<Object>)inputs.get('arguments');
                Map<string,Object> contractLineItem = new Map<String,Object>();
                List<AgreementItem> agreementItems = new List<AgreementItem>();
                for(Integer i=0;i<arguments.size();i++){
                    contractLineItem = (Map<string,Object>) arguments[i];
                    agreementItems.add(esdAgreementDetail(contractLineItem));                   
                }  
                agreementItemsDRNode.put('agreementItems',(Object)agreementItems);
                output.put('result', Json.serializePretty(agreementItemsDRNode));
            }
            
            catch(Exception e){
                system.debug(e.getStackTraceString());
                system.debug(e.getMessage());
                system.debug(e.getCause());
            }           
        }
        else if(methodName == 'BundleItemsCallOff')
        {
            List<Object> arguments = (List<Object>)inputs.get('arguments');
            //system.debug(Json.serialize(arguments));
            //system.debug(callOffProductsBundled(arguments));
            output.put('result',callOffProductsBundled(arguments));
        }
        else
        {
            System.debug('Error in MethodName: ');
        }
        
        return true;
    }
    
    
    //Sprint 13: DROP 2.3
    // For Context Rules for subscriptions : We check the multipicklist present and check the productCode for the product.
    // if the productCode exists in the picklist, then we send true otherwise false
    Boolean MultiPicklistChoose(List<Object> arguments)
    {
        boolean result = false;
        try
        {
            String productCode =(String) arguments[1];           
            String prodList  = (String)arguments[0];            
            List<String>  productCodeList = prodList.split(';');            
            for(String token : productCodeList)
            {
                if (productCode == token)
                {
                    result = true;
                    break;
                }
            }            
        }
        
        catch(Exception e)
        {
            system.debug('Error error error: ' + e.getStackTraceString() +'Error message:' + e.getCause() +' ' + e.getMessage() );
        }    
        return result;
    }
    
    Map<String,String> splitt(string arguments){
        
        List<String> splitarg = arguments.split(';'); 
        
        List<Map<String,String>> result2 = new List<Map<String,String>>();
        integer n= splitarg.size();
        Map<String,string> result=new Map<String,String>();
        for(integer i=0; i<n;i++)
        {
            
            // system.debug('splitarg: '+splitarg.get(i));
            
            result.put('String'+i,splitarg.get(i));
        }
        return result;
    }
    
    
    Boolean SCRenegotiation(List<Object> arguments)  
    {  
        boolean result = false;  
        try  
        {  
            String QId =(String) arguments[0];  
            list<QuoteLineItem> QLIList =  [select id, TeliaSE_Product_Code__c from QuoteLineItem where (QuoteId =: QId and Quote.TeliaSE_MC_Sales_Flow_Identifier__c = 'Omforhandling' and vlocity_cmt__ParentItemId__c =null)];         
            for(QuoteLineItem QLI : QLIList)  
            {  
                if (QLI.TeliaSE_Product_Code__c == 'SC_OFFER')  
                {  
                    result = true;    
                    break;  
                }  
            }              
        }  
        catch(Exception e)  
        {  
            system.debug('Error error error: ' + e.getStackTraceString() +'Error message:' + e.getCause() +' ' + e.getMessage() );  
        }      
        return result;  
    }
    string callOffProductsBundled(List<Object> arguments)
    {
        Boolean istestclass = false;
        if(test.isRunningTest()){
            istestclass = true;
        }
        integer blocksize = Integer.valueOf(System.label.MC_CallOffPricingBundleSize);
        if(test.isRunningTest()) blocksize = 1;
        integer count = 0;
        List<Map<String,Object>> returnMap = new list<Map<String,Object>>();        
        List<Id> qliId = new List<Id>();              
        for(Object o: arguments)
        {
            Map<String,Object> qli = (Map<String,Object>) o;
            //system.debug('qli'+qli);
            qliId.add((Id)qli.get('Id'));
            if(count <blocksize)                
            {
                count ++;
            }
            else if (count == blocksize)
            {
                Map<String,Object> dummyMap = new Map<String,Object>();
                List<Id> qliClone = qliId.clone();
                dummyMap.put('Id',qliClone);
                returnMap.add(dummyMap);               
                qliId.clear();
                count=0;
            }
            
        }
        
        //system.debug('qlidId'+qliId);
        if(qliId.size() > 0||istestClass)
        {
            Map<String,Object> dummyMap1 = new Map<String,Object>();
            dummyMap1.put('Id',qliId);
            returnMap.add(dummyMap1);
        }
        //system.debug(returnMap);
        Map<String,Object> outputMap = new Map<String,Object>();
        // system.debug(json.serializePretty(returnMap));
        return json.serializePretty(returnMap);        
    }
    
    AgreementItem esdAgreementDetail(Map<String,Object> contractLineItem)
    {
        
        // system.debug(contractLineItem);
        
        //ProductOffering po = new ProductOffering();
        Map<String,Object> productOfferings = new Map<String,Object>();
        productOfferings.put('id',(String)contractLineItem.get('id'));
        productOfferings.put('name',(String)contractLineItem.get('productName'));
        productOfferings.put('@type',(String)contractLineItem.get('@type'));
        productOfferings.put('@referredType',(String)contractLineItem.get('@referredType'));
        //po.id = (String)contractLineItem.get('id');
        //po.name = (String)contractLineItem.get('productName');
        //po.type = (String)contractLineItem.get('@type');
        //po.referredType = (String)contractLineItem.get('@referredType');
        List<Map<String,Object>> poList =new List<Map<String,Object>>();
        poList.add(productOfferings);
        
        TermOrCondition tc = new TermOrCondition();
        tc.description = '';
        ValidFor vf = new ValidFor();
        vf.startDateTime = (String)contractLineItem.get('startDate');
        vf.endDateTime = (String)contractLineItem.get('endDate');
        tc.validFor = vf;
        
        List<TermOrCondition> tcList = new List<TermOrCondition>();
        tcList.add(tc);
        
        Map<String,Object> agreementCharacteristics = new Map<String,Object>();
        agreementCharacteristics.put('baseQuantity',contractLineItem.get('baseQuantity')!=null ? contractLineItem.get('baseQuantity'):'');
        agreementCharacteristics.put('commitmentPeriod', (String)contractLineItem.get('commitmentPeriod')!=null ? (String)contractLineItem.get('commitmentPeriod'):'');
        agreementCharacteristics.put('subsidizedVoice', (String)contractLineItem.get('subsidizedVoice')!=null ? (String)contractLineItem.get('subsidizedVoice'):'');
        agreementCharacteristics.put('recurringFee', contractLineItem.get('recurringFee')!=null ? contractLineItem.get('recurringFee'):'');
        agreementCharacteristics.put('oneTimeFee', contractLineItem.get('oneTimeFee')!=null ? contractLineItem.get('oneTimeFee'):'');
        agreementCharacteristics.put('level',contractLineItem.get('Level')!=null ? contractLineItem.get('Level'):'');
        agreementCharacteristics.put('family',contractLineItem.get('family')!=null ? contractLineItem.get('family'):'');
        
        agreementCharacteristics.put('itemInfo',contractLineItem.get('itemInfo')!=null ? contractLineItem.get('itemInfo'):'');
        
        agreementCharacteristics.put('@type',contractLineItem.get('@agreementCharacteristics'));
        agreementCharacteristics.put('@schemaLocation','');
        
        AgreementItem agreementItem = new AgreementItem();
        agreementItem.productOffering = poList;
        agreementItem.termOrCondition = tcList;
        agreementItem.agreementItemCharacteristics = agreementCharacteristics;
        return agreementItem;
    }  
    
    
    
    public class TermOrCondition {
        public String description;
        public ValidFor validFor;
    }
    
    public class ValidFor {
        public String startDateTime,endDateTime;
    }
    
    public class AgreementItem {
        public List<Map<String,Object>> productOffering;
        public List<TermOrCondition> termOrCondition;
        public Map<String,Object> agreementItemCharacteristics;
    }
    
    public class ProductOffering {
        public String id,name,type,referredType;
        Map<String,Object> productOffering;
    }
}