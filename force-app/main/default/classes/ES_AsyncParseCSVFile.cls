/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* This class is a queueable class which parses the CSV Configuration file that is received as String
* into the Costructor. For each row of the CSV a configuration Map is created and stored inside a List
* that will be used as input of the batch job
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Andrea Premarini <apremarini@salesforce.com>
* @modifiedBy     
* @maintainedBy   
* @version        1.0
* @created        2021-06-01
* @modified       
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class ES_AsyncParseCSVFile implements Queueable {
    private String productCode;
    private String catalogCode;
    private String contentString;
    private Integer batchNumber;
    
    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * Costructor method of the class, it is used to initialize the variables that are from the execution
    * of the class
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  catalogCode                       catalog code of the offer
    * @param  productCode                       product code of the current offer
    * @param  contentString                     String containing the content of the CSV File
    * @param  batchNumber                       Number of batches that will be run in parallel
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    public ES_AsyncParseCSVFile(String productCode,String catalogCode,String contentString, Integer batchNumber){
        this.productCode = productCode;
        this.catalogCode = catalogCode;
        this.contentString = contentString;
        this.batchNumber = batchNumber;
    }
    
    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * execute method of the Queueable interface, parses the CSV file and prepares the configuration
    * list to launch the Batch Jobs
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  catalogCode                       catalog code of the offer
    * @param  productCode                       product code of the current offer
    * @param  inputList                         List containing all the configuration that are used to initialize the cache
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    public void execute(QueueableContext context) {
        List<String> configurationList = parseContent(contentString); 
        warmupCache(productCode, catalogCode, configurationList, batchNumber);           
    }


    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * parseContent method, parses the String contianing the csv file and returns a List of string,
    * each element of the list corresponds to a configuration row of the CSV file (just the column
    * containing the Product code List)
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  contentFile                       String containing the CSV file
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    private static List<String> parseContent(String contentFile){
        System.debug('##### Before Split');
        List<String> fileLines = new List<String>();
        
        String LINE_SEPARATOR = '\n';
        Integer endPos = contentFile.indexOf(LINE_SEPARATOR);

        System.debug('EndPos: ' + endPos);
        Boolean isHeader = true;
        List<String> configurationList = new List<String>();

        while(!String.isEmpty(contentFile)){
            String row;
            if(endPos == -1){
                row = contentFile;
                System.debug('Last Row: ' + row);
            }else{
                row = contentFile.subString(0, endPos);
            }
            System.debug('Row: ' + row);
            if(!isHeader){
                List<String> cols = row.split(',');
                configurationList.add(cols.get(1).trim());
                System.debug('Config added!');
                if(endPos == -1){
                    System.debug('All configuration loaded - Exit from loop');
                    break;
                }
            }
            contentFile = contentFile.subString(endPos + LINE_SEPARATOR.length(), contentFile.length());    
            endPos = contentFile.indexOf(LINE_SEPARATOR);  
            isHeader=false;
            System.debug('EndPos: ' + endPos);
        }
        return configurationList;
    }

    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * warmupCache method, this methods receive in input the list of configurations and invokes a number of batches
    * depending on the input parameter
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  catalogCode                       catalog code of the offer
    * @param  prodCode                          product code of the current offer
    * @param  productsConfigurationList         list of String containing the list of products separated by ';'       
    * @param  batchNumber                       total number of batches that will be launched in parallel (1-5)
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    public static void warmupCache(String prodCode, String catalogCode, List<String> productsConfigurationList, Integer batchNumber){

        WarmupCacheConfiguration__c configuration = [SELECT Id, TokenList__c 
        FROM WarmupCacheConfiguration__c
        WHERE ProductCode__c = :prodCode 
        AND CatalogCode__c = :catalogCode LIMIT 1];

        List<Map<String,String>> configurationsList = retrieveConfigurationList(configuration.TokenList__c, productsConfigurationList);
        System.debug('@@@AP Config L: ' + configurationsList.size());
        if(batchNumber == 1){
            if(!Test.isRunningTest()){
                Database.executeBatch(new WarmupDCApiCacheBatch(catalogCode, prodCode, configurationsList),1);
            }
        }else{ //Multiple Batch Execution
            Map<Integer, List<Map<String,String>>> splittedConfigurationMap = new Map<Integer, List<Map<String,String>>>();
            for(Integer i=0; i<batchNumber; i++){
                splittedConfigurationMap.put(i, new List<Map<String,String>>());
            }

            do{
                for(Integer i=0; i<batchNumber; i++){
                    splittedConfigurationMap.get(i).add(configurationsList.remove(0));
                    if(configurationsList.size() == 0){
                        break;
                    }
                }
            }while (configurationsList.size() > 0);
            for(Integer key : splittedConfigurationMap.keySet()){
                System.debug('@@@AP ' + key + ' size: ' +splittedConfigurationMap.get(key).size());
                if(!Test.isRunningTest()){
                    Database.executeBatch(new WarmupDCApiCacheBatch(catalogCode, prodCode, splittedConfigurationMap.get(key)),1);
                }
            }

        }
        
    }

    /** 
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    * retrieveConfigurationList method, received as input the tokenList retrieved by WarmupCacheConfiguration__c record and
    * the list of configuration. Returns as output a list of maps, each map contains as key all the tokens inside the token list,
    * and the values depends on the configuration: if a product is present the value is 1, else is 0.
    * ──────────────────────────────────────────────────────────────────────────────────────────────    
    * @param  tokenList                         contains the token present in the JSON Payload, autogenerated by the trigger
    * @param  productsConfigurationList         List of configurations, each String is a list of product code separated by ';'
    * ───────────────────────────────────────────────────────────────────────────────────────────── 
    */
    private static List<Map<String,String>> retrieveConfigurationList(String tokenList, List<String> productsConfigurationList){
        List<Map<String,String>> configurationsList = new List<Map<String,String>>();
        List<String> tokens = tokenList.split(';');  
        Map<String,String> emptyConfigMap = new Map<String,String>();
        for(String token : tokens){
            emptyConfigMap.put(token,'0');
        }

        for(String productsListString : productsConfigurationList){
            List<String> productList = productsListString.split(';');
            Map<String,String> newConfigMap = new Map<String,String>(emptyConfigMap);
            for(String productCode : productList){
                productCode = productCode.replace('.','_');
                newConfigMap.put('Q_'+productCode.trim(),'1');
            }
            System.debug('newConfigMap: ' + newConfigMap);
            configurationsList.add(newConfigMap);
        }
        return configurationsList;

    }
}