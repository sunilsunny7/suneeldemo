/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class is a Batchable class which interates on a list of Map<String, String>. Each element
* of the list is a configuration of the offer for which the addAfterConfig vlocity API is invoked
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Andrea Premarini <apremarini@salesforce.com>

* @modifiedBy     Simran Gupta <simran.gupta@capgemini.com>

* @maintainedBy   
* @version        1.0
* @created        2021-06-01
* @modified           
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class WarmupDCApiCacheBatch implements Database.Batchable<Map<String,String>>
{
    private List<Map<String,String>> inputList;
    private String catalogCode;
    private String productCode;
    private String jsonPayloadString;
    /* TODO TODO TODO
    * Make LOG_RESULTS and LOG_EXCEPTIONS configurable from custom label/settings depending on the approach
    * used on the rest of the environment
    */
    private Boolean LOG_RESULTS = true;    //Set this to true to enable logging of API call result
    private Boolean LOG_EXCEPTIONS = true;  //Set this to true to enable logging for API call error
    

    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * Costructor method of the batch, it is used to initialize the variables that are used from the
    * batch execution process
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  catalogCode                       catalog code of the offer
    * @param  productCode                       product code of the current offer
    * @param  inputList                         List containing all the configuration that are used to initialize the cache
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    public WarmupDCApiCacheBatch(String catalogCode, String productCode, List<Map<String,String>> inputList){
        this.inputList = inputList;
        this.catalogCode = catalogCode;
        this.productCode = productCode;

        List<WarmupCacheConfiguration__c> wccList = 
                        [SELECT OverFlowSequence__c, JSONPayload__c
                        FROM WarmupCacheConfiguration__c
                        WHERE CatalogCode__c = :catalogCode
                        AND ProductCode__c = :productCode
                        LIMIT 1];

        jsonPayloadString = '';

        for(WarmupCacheConfiguration__c wcc : wccList){
            jsonPayloadString+= wcc.JSONPayload__c;
        }
    }

    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * start method of the Batchable interface
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  info                              Database.BatchableContext
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    public Iterable<Map<String,String>> start(Database.BatchableContext BC)
    {
        return inputList;
    }

    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * execute method of the Batchable interface
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  info                              Database.BatchableContext
    * @param  configList                        List of configuration Maps
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    public void execute(Database.BatchableContext info, List<Map<String,String>> configList)
    {
        //System.debug('####Config 0 ' + configList.get(0));
        String configString = buildConfigString(configList.get(0));
        //System.debug('####Builded config');
        //System.debug(configString);
        try{
            Map<String, Object> output = invokeAPI(configString);

            //TODO if the actionEvent is null, it means that there is an error in the configuration
            //The error messages is contained in output --> result --> offerDetails --> messages
            //where messages is a list of Messages
            //The status code of the invokation is contained in output --> result --> offerDetails --> StatusCode
            Map<String, Object> res = (Map<String, Object>)output.get('result');
            system.debug('Output==>'+res.get('offerDetails'));
            if(LOG_RESULTS){
                logApiCallResult((String) output.get('actionEvent'), (String) output.get('cartContextKey'), configList.get(0), (Long) output.get('executionTime'));     
            }
        }catch (Exception e){
            if(LOG_EXCEPTIONS){
                logApiCallResult('EXCEPTION: ' + e.getMessage(), null, configList.get(0), null);     
            }
        }
    }

    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * finish method of the Batchable interface
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  info                              Database.BatchableContext
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    public void finish(Database.BatchableContext info) { }


    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * invokeAPI method: invokes the addAfterConfig API and returns the output map containing the results
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  configString                      String containing the offerDetails JSON Payload
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    private Map<String, Object> invokeAPI(String configString){        
        
        Map<String, Object> input = new Map<String, Object>();
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        
        String methodName = 'addAfterConfig';
        input.put('apiName','basketOperations');
        input.put('catalogCode', catalogCode);
        input.put('productConfig', (Map<String, Object>)JSON.deserializeUntyped(configString)); //this is the offerdetail string
        //input.put('offerDetailsMap', configString); //this is the offerdetail string
        input.put('methodName', 'addAfterConfig');
        input.put('requestURL', '/v3/catalogs/'+catalogCode+'/basket');
        //input.put('forceinvalidatecache','true');
        input.put('price', false);

        //remote action invocation
        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
        Long startTime = DateTime.now().getTime();
        if(!Test.isRunningTest()){
            appHandler.invokeMethod(methodName, input, output, options);
        }
        if(output.containskey('nexttransaction'))

         {

             Map<String, Object> next = (Map<String, Object>)output.get('nexttransaction');

             Map<String,Object> rest = (Map<String, Object>)next.get('rest');

             Map<String,Object> params = (Map<String, Object>)rest.get('params');

             String multiTransactionKey = (String)params.get('multiTransactionKey');

             input.put('multiTransactionKey',multiTransactionKey);

             if(!Test.isRunningTest()){

                 appHandler.invokeMethod(methodName, input, output, options);

             }

         }
        Long endTime = DateTime.now().getTime();
        System.debug('####output');
        System.debug(output);
        output.put('executionTime',(endTime - startTime));
        return output;
    }

    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * logApiCallResult is an utility method used to log on WarmupCacheLog__c custom object the 
    * result of the API calls
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  actionEvent                       actionEvent received in the output Map
    * @param  cartContextKey                    cartContextKey that has been generated for the current callout
    * @param  configMap                         map containing the parameters used for the current callout configuration
    * @param  executionTime                     total time taken by the API invokation
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    @TestVisible
    private void logApiCallResult(String actionEvent, String cartContextKey, Map<String,String> configMap, Long executionTime){
    String Offer = [SELECT ProductCode__c FROM WarmupCacheConfiguration__c WHERE CatalogCode__c = :catalogCode AND ProductCode__c = :productCode]?.ProductCode__c;
        WarmupCacheLog__c log = new WarmupCacheLog__c();
        log.ActionEvent__c = actionEvent;
        log.Offer__c = Offer;
        log.CartContextKey__c = cartContextKey;
        log.Configuration__c = JSON.serialize(configMap);
        log.ExecutionTime__c = executionTime;
        insert log;
    }

    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * buildConfigString, this method takes in input a configuration maps and substitute the tokens inside
    * the json Payload retrieved before.
    * Return the json offerdetails payload ready for the invokation of the addAfterConfig API
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  configMap                         map containing the parameters used for the current callout configuration
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    @TestVisible
    private String buildConfigString(Map<String,String> configMap){
        String configId = configMap.remove('configId');
        String jsonString = jsonPayloadString;

        for(String tokenName : configMap.keySet()){
            jsonString = jsonString.replace('"%'+tokenName+'%"', configMap.get(tokenName));
        }
        return jsonString;
    }
}