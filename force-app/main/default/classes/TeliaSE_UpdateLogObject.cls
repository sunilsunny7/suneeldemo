/**
* @author: Dipanwita Dutta
* @date:  11 Jan 2019
* @description:   @Description: Class to insert log details into log Object
* @name : TeliaSE_UpdateLogObject
*
*<Changes>
*<Date>           <Authors Name>          <Brief Description of Change>
*/
public class TeliaSE_UpdateLogObject {
    public static void updateLog(String resultDetail,String resultMessage, String CLASS_NAME, String requestBody){
        /*
        // getting error details from the responseMap
		String result, resultDesc, resultDetail, resultMessage;
        result = (String)responseBodyMap.get('result'); 
        resultMessage = (String)responseBodyMap.get('resultMessage'); 
		resultDetail = (String)responseBodyMap.get('resultDetail');
        */
        // logging the error into Log Object
		TeliaSE_Log__c logDetails = new TeliaSE_Log__c();
		logDetails.Result_Header__c = resultDetail;
        logDetails.Result_Message__c = resultMessage;
        //logDetails.Result_Status__c = resultDetail;
        logDetails.Class_Name__c = CLASS_NAME;
        logDetails.Webservice_Name__c = CLASS_NAME;
        logDetails.Request__c = requestBody;
        
		insert logDetails;
        System.debug('logDetails-->'+logDetails.Id);
        
    }
}