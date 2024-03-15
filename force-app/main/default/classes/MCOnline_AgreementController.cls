global with sharing class MCOnline_AgreementController implements vlocity_cmt.VlocityOpenInterface{ 
  
  global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
    
    if(methodName.equals('GetEnvironmentVariables'))
    {
        outMap.put('sessionId', UserInfo.getSessionId());
        outMap.put('baseUrl', System.Label.BaseUrl);
        
    }else if(methodName.equals('ProcessCatalogOfferJSON'))
    {
        MCOnline_AgreementServices.ProcessCatalogOfferJSON(inputMap, outMap, options);
  
    }else if(methodName.equals('ProcessOfferDetailsJSON'))
    {
        MCOnline_AgreementServices.ProcessOfferDetailsJSON(inputMap, outMap, options);
    }
    else if(methodName.equals('ProcessOfferDetailsJSON_new'))
    {
        MCOnline_AgreementServices.ProcessOfferDetailsJSON_new(inputMap, outMap, options);
    }
    else if(methodName.equals('ProcessAccountManagementJSON'))
    {
        MCOnline_AgreementServices.ProcessAccountManagementJSON(inputMap, outMap, options);
    }
    else if(methodName.equals('ProcessAccountManagementJSON_New'))
    {
        MCOnline_AgreementServices.ProcessAccountManagementJSON_New(inputMap, outMap, options);
    }
    else if(methodName.equals('ProcessOfferDetailsJSON_V2'))
    {
        MCOnline_AgreementServices.ProcessOfferDetailsJSON_V2(inputMap, outMap, options);
    }
    else if(methodName.equals('ProcessOfferDetailsJSON_V2ErrorTest'))
    {
        MCOnline_AgreementServices.ProcessOfferDetailsJSON_V2ErrorTest(inputMap, outMap, options);
    }
    else if(methodName.equals('GetCatalog'))
    {
        outMap.put('Catalog', String.Valueof(((Map<string,object>)inputMap.get('options')).get('Catalog')));
    }
    return true;
  
  }
  
}