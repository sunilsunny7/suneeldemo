/* ______________________________________________________________________________________________________
 * ******************************************************************************************************
 * @author         Binamra Guha <binamra.a.guha@capgemini.com>
 * @modifiedBy     
 * @maintainedBy   
 * @version        3.0
 * @created        2021-11-17
 * @modified
 * ______________________________________________________________________________________________________
 * ******************************************************************************************************
*/
global with sharing class MCOnline_DeleteAgreementServiceRecord implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) 
    {
        if(methodName.equals('madamIntegration'))
        {  
            madamIntegration(inputMap, outMap, options);
        }
        return true;
    }
    public static void madamIntegration(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        Map<String, Object> agreementNew = new Map<String, Object>();
        Map<String, Object> agreementOld = new Map<String, Object>();
        if(inputMap != null)
        {
            if(inputMap.containsKey('agreementNew') && inputMap.containsKey('agreementOld'))
            {
                agreementNew = (Map<String, Object>)inputMap.get('agreementNew');
                agreementOld = (Map<String, Object>)inputMap.get('agreementOld');
                deleteAgreementServiceRecord(agreementOld, outMap, options, '');
                insertAgreementServiceRecord(agreementNew, outMap, options, 'Update');
            }
            else if(inputMap.containsKey('agreementNew'))
            {
                agreementNew = (Map<String, Object>)inputMap.get('agreementNew');
                insertAgreementServiceRecord(agreementNew, outMap, options, 'Insert');
            }
            else if(inputMap.containsKey('agreementOld'))
            {
                agreementOld = (Map<String, Object>)inputMap.get('agreementOld');
                deleteAgreementServiceRecord(agreementOld, outMap, options, 'Delete');
            }
            else
            {
                return;
            }
        }
    }
    public static void deleteAgreementServiceRecord(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options, String action)
    {
        System.debug(JSON.serialize(inputMap));
        Set<String> storeAgrDetails = new Set<String>();
        Map<String, Object> agreement = new Map<String, Object>();
        List<Object> servicesList = new List<Object>();
        Map<String, Object> agreementData = new Map<String, Object>();
        agreement = (Map<String, Object>)inputMap.get('agreement');
        //outMap.clear();
        Boolean flag = false;
        
        if(agreement != null)
        {
            servicesList = (List<Object>)agreement.get('services');
            agreementData = (Map<String, Object>)agreement.get('agreementData');
        }

        String agreementNumber = (!String.isBlank(String.valueOf(agreementData.get('agreementNumber')))) ? String.valueOf(agreementData.get('agreementNumber')) : '';

        if(agreementNumber == null || String.isBlank(agreementNumber))
        {
            outMap.clear();
            outMap.put('error', 'AgreementNumber is Mandatory AMANDA');
            outMap.put('status', 'FAILURE');
            return;
        }
        
        if(servicesList.size() > 0)
        {
            for(Object obj: servicesList)
            {
                Map<String, Object> services = (Map<String,Object>)obj;
                if(services != null)
                {

                    String agreementServiceCode = (!String.isBlank(String.valueOf(services.get('agreementServiceCode')))) ? String.valueOf(services.get('agreementServiceCode')) : '';
                    String agreementServiceType = (!String.isBlank(String.valueOf(services.get('agreementServiceType')))) ? String.valueOf(services.get('agreementServiceType')) : '';
                    String agreementSubscriptionType = (!String.isBlank(String.valueOf(services.get('agreementSubscriptionType')))) ? String.valueOf(services.get('agreementSubscriptionType')) : '';

                    storeAgrDetails.add(agreementNumber+''+agreementServiceCode+''+agreementServiceType+''+agreementSubscriptionType);
                }
            }
        }
        List<MCOnline_Agreement_Services_Temp_data__c> agrList = new List<MCOnline_Agreement_Services_Temp_data__c>();
        if(storeAgrDetails.size() > 0)
        {
            agrList = [Select id from MCOnline_Agreement_Services_Temp_data__c Where MCOnline_UniqueAgreementIdentifier__c IN :storeAgrDetails];
        }
        
        if(agrList.size() > 0)
        {
            flag = true;
            Database.delete(agrList, false);
        }
        if(flag)
        {
            outMap.put('status', 'SUCCESS');
        }else
        {
            outMap.put('status', 'FAILURE');
        }
        Set<String> IdList = new Set<String>();
        if(agrList.size() > 0)
        {
            for(MCOnline_Agreement_Services_Temp_data__c temp: agrList)
            {
                IdList.add(String.valueOf(temp.Id));
            }
            outMap.put('Id', IdList);
        }
        outMap.put('action', action);
        outMap.put('agreementNumber', agreementNumber);
        
    }
    public static void insertAgreementServiceRecord(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options, String action)
    {
        Map<String, Object> agreement = new Map<String, Object>();
        List<Object> servicesList = new List<Object>();
        Set<String> storeAgrDetails = new Set<String>();
        Map<String, Object> agreementData = new Map<String, Object>();
        agreement = (Map<String, Object>)inputMap.get('agreement');
        //outMap.clear();
        Boolean flag = false;
        
        if(agreement != null)
        {
            servicesList = (List<Object>)agreement.get('services');
            agreementData = (Map<String, Object>)agreement.get('agreementData');
        }

        String agreementNumber = (!String.isBlank(String.valueOf(agreementData.get('agreementNumber')))) ? String.valueOf(agreementData.get('agreementNumber')) : '';

        if(agreementNumber == null || String.isBlank(agreementNumber))
        {
            outMap.clear();
            outMap.put('error', 'AgreementNumber is Mandatory AMANDA');
            outMap.put('status', 'FAILURE');
            return;
        }
        if(servicesList.size() > 0)
        {
            for(Object obj: servicesList)
            {
                Map<String, Object> services = (Map<String,Object>)obj;
                if(services != null)
                {

                    String agreementServiceCode = (!String.isBlank(String.valueOf(services.get('agreementServiceCode')))) ? String.valueOf(services.get('agreementServiceCode')) : '';
                    String agreementServiceType = (!String.isBlank(String.valueOf(services.get('agreementServiceType')))) ? String.valueOf(services.get('agreementServiceType')) : '';
                    String agreementSubscriptionType = (!String.isBlank(String.valueOf(services.get('agreementSubscriptionType')))) ? String.valueOf(services.get('agreementSubscriptionType')) : '';

                    storeAgrDetails.add(agreementNumber+''+agreementServiceCode+''+agreementServiceType+''+agreementSubscriptionType);
                }
            }
        }
        List<MCOnline_Agreement_Services_Temp_data__c> agrList = new List<MCOnline_Agreement_Services_Temp_data__c>();
        if(storeAgrDetails.size() > 0)
        {
            agrList = [Select id from MCOnline_Agreement_Services_Temp_data__c Where MCOnline_UniqueAgreementIdentifier__c IN :storeAgrDetails];
        }
        
        if(agrList.size() > 0)
        {
            Database.delete(agrList, false);
        }
        
        List<MCOnline_Agreement_Services_Temp_data__c> tempDataList = new List<MCOnline_Agreement_Services_Temp_data__c>();
        if(servicesList.size() > 0)
        {
            for(Object obj: servicesList)
            {
                Map<String, Object> services = (Map<String,Object>)obj;
                MCOnline_Agreement_Services_Temp_data__c agree = new MCOnline_Agreement_Services_Temp_data__c();
                if(services != null)
                {
                    agree.MCOnline_Agreement_number__c = agreementNumber;
                    agree.MCOnline_Agreement_Status__c = String.valueOf(agreementData.get('agreementStatus'));
                    agree.MCOnline_Service_availability__c = String.valueOf(services.get('agreementServiceAvailability'));
                    agree.MCOnline_Service_code__c = String.valueOf(services.get('agreementServiceCode'));
                    agree.MCOnline_Service_Contract_ID__c = String.valueOf(agreementData.get('contractId'));
                    agree.MCOnline_Service_status__c = String.valueOf(services.get('agreementServiceStatus'));
                    agree.MCOnline_Service_type__c = String.valueOf(services.get('agreementServiceType'));
                    agree.MCOnline_Subscription_type_code__c = String.valueOf(services.get('agreementSubscriptionType'));
                    agree.MCOnline_Subscription_type_Status__c = String.valueOf(services.get('agreementSubscriptionTypeStatus'));
                    tempDataList.add(agree);
                }
            }
        }
        if(tempDataList.size() > 0)
        {
            flag = true;
            Database.insert(tempDataList, false);
        }
        if(flag)
        {
            outMap.put('status', 'SUCCESS');
        }else
        {
            outMap.put('status', 'FAILURE');
        }
        Set<String> IdList = new Set<String>();
        if(tempDataList.size() > 0)
        {
            for(MCOnline_Agreement_Services_Temp_data__c temp: tempDataList)
            {
                IdList.add(String.valueOf(temp.Id));
            }
            outMap.put('Id', IdList);
        }
        outMap.put('action', action);
        outMap.put('agreementNumber', agreementNumber);
    }
}