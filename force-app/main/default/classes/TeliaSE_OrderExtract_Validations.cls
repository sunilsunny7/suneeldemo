/**
 * @Author:      Rahul Kadam
 * @Company:     Capgemini
 * @Date:        6th Aug 2021
 * @Description: TeliaSE_OrderExtract_Validations class will perform validations before an CO order extract excel is create.
 * @Epic:        MCSTO-6925 CO: Order Capture Data Extract
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------------
*/

global without Sharing class TeliaSE_OrderExtract_Validations implements vlocity_cmt.VlocityOpenInterface{
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
     Boolean result = true;
        try
        {


            if (methodName.equals('faExistOrNot'))
            {   
                faExistOrNot(inputMap,outMap);

            }
            else 
            {
                result = false;
            }
        } 
        catch(Exception e)
        {
            System.debug('exception: '+e);
            result = false;
        }
        return result;
    }

	//Input is contractId
	public static void faExistOrNot(Map<String,Object> inputMap, Map<String,Object> outMap) {
		string coContractId = (String)inputMap.get('contextId');
        string coValidationFlag = 'True';
        system.debug(coContractId);
		Contract qut = [Select id, vlocity_cmt__QuoteId__r.TeliaSE_Record_Type_Name__c  from Contract where id=: coContractId ];
		if(qut.vlocity_cmt__QuoteId__r.TeliaSE_Record_Type_Name__c == 'Contract') {
			//To pick latest offer quote and check for CO product in it.
			list<Quote> getOfferQuote = [Select Id FROM Quote WHERE (vlocity_cmt__ParentQuoteId__c =: qut.vlocity_cmt__QuoteId__c AND TeliaSE_Record_Type_Name__c = 'Offer') ORDER BY CreatedDate DESC LIMIT 1];
			id offerQuoteId = id.valueof((string)getOfferQuote[0].get('Id'));
            List<QuoteLineItem> qliList = [select id, QuoteId,TeliaSE_Product_Object_Type__c from QuoteLineItem where (QuoteId =:offerQuoteId AND (TeliaSE_Product_Object_Type__c = 'Broadband Start Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Pro Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Plus Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Datanet Offering Spec' OR TeliaSE_Product_Object_Type__c = 'SD-WAN/Firewall Offering Spec' OR TeliaSE_Product_Object_Type__c = 'WIFI/LAN Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Connected Office Offer Spec')) ];
			system.debug(qliList.size());
			if( qliList.size() == 0){
				outMap.put('Error',System.Label.TeliaSE_COProductNotFound);
                coValidationFlag = 'False';
			}
		}
		else{
			outMap.put('Error',System.Label.TeliaSE_NoFAQuoteFound);
            coValidationFlag = 'False';
		}
        if(coValidationFlag == 'True'){
            outMap.put('Warning','Continue to download Order extract excel.');
        }
	}
}