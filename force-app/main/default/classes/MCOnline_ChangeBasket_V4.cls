global with sharing class MCOnline_ChangeBasket_V4 implements vlocity_cmt.VlocityOpenInterface {
    static Trim_GetOfferDetails__mdt finalNodeslist = [Select MCONL_Attributes_to_Remove__c from Trim_GetOfferDetails__mdt];
    static String finalNodeslistStr=finalNodeslist.MCONL_Attributes_to_Remove__c;
    static List<String> finalNodeslistStrtolist = finalNodeslistStr.split(',');
    static Set<String> finalNodes= new Set<String>(finalNodeslistStrtolist);
    static List<Product2> fieldsToAdd = [select vlocity_cmt__AttributeMetadata__c, ProductCode,Ordering_Flag__c from Product2] ;
    public static List<MCOnline_Basket__c> parameters=new List<MCOnline_Basket__c>();
    public static Map<String, String> storeInput = new Map<String, String>();
    public static Map<String, Object> remotemethodResponse = new Map<String, Object>();
    public static Map<String, Object> productConfigMap = new Map<String, Object>();        
    public static Boolean result = true,isManagedFlow=false,isChangeBasket = true,hasError = false;
    public static List<id> BasketIds = new List<id>();
    public static List<String> Baskets = new List<String>();
    static String APIFUNCTIONALITY='ChangeBasket';
    public static String parentId,User,AgreementId,TSCID,Catalog,cartContextKey,errorCode,error_message,basketName;

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('itemBasketName'));           
        Parameters = [select Account__c, MCOnline_ParentBasket__r.Admin__c, MCOnline_Catalog__c, TSCID__c, MCOnline_ParentBasket__r.AgreementId__c  from MCOnline_Basket__c  where Name =: basketName ];
        if(Parameters.size()>0){
          User = String.Valueof(Parameters[0].MCOnline_ParentBasket__r.Admin__c);
          AgreementId = String.Valueof(Parameters[0].MCOnline_ParentBasket__r.AgreementId__c);
          TSCID = String.Valueof(Parameters[0].TSCID__c);
        }
        try { 
            if(methodName.equalsIgnoreCase('deleteBasket')){
                deleteBasket(inputMap, outMap);
            }
            else if (methodName.equalsIgnoreCase('Unreserve')){
                Unreserve(inputMap,outMap);
            }
            else if (methodName.equalsIgnoreCase('basketValidity')){
                basketValidity(inputMap,outMap);
            }
            else if (methodName.equalsIgnoreCase('addtobasket_remotemethod')){
                Map<String, Object> options1 = (Map<String, Object>)inputMap.get('options');
                
                options1.put('users', String.Valueof(Parameters[0].MCOnline_ParentBasket__r.Admin__c));
                options1.put('TSCID', String.Valueof(Parameters[0].TSCID__c));
                options1.put('Agreementid', String.Valueof(Parameters[0].MCOnline_ParentBasket__r.AgreementId__c));

                //Added by Binamra Guha
                 List<Object> tempList = (List<Object>)inputMap.get('productConfig'); 
                //MCOnline_AddToBasket_V5.removeItems(tempMap,fieldsToAdd, finalNodes, isManagedFlow, isChangeBasket);
                for(Object offers: tempList)
                {
                        Map<String, Object> tempMap = (Map<String, Object>)offers;
                        productConfigMap = tempMap;
                        Catalog = String.Valueof(Parameters[0].MCOnline_Catalog__c);
                cartContextKey = String.valueof(inputMap.get('contextKey'));
                // validate Icc_Number before caling remotemethod
                if(MCOnline_Utility.containsDuplicateIccNumber(productConfigMap,inputMap,'changeBasket')){
                    
                    errorCode = 'DUPLICATE_ICC_NUMBER';
                    outMap.put('ErrorResponse', MCOnline_Utility.generateError('',errorCode,'custom', inputMap, '',Parameters,APIFUNCTIONALITY));
                    outMap.put('StatusCode', 500); 
                }else{
                    remotemethodResponse=MCOnline_AddToBasket_V5.addtobasket_remotemethod(cartContextKey,JSON.serialize(productConfigMap),Catalog,isManagedFlow);
                    outMap=MCOnline_AddToBasket_V5.addToBasket_V3_NormalCallout(inputMap,remotemethodResponse, outMap,options,JSON.serialize(productConfigMap),BasketIds,Catalog,Parameters,isManagedFlow,storeInput,isChangeBasket);
               }
                }
            }
            else{
                result = false;
            }
        }
        catch(Exception e) {
            error_message= e.getMessage() +' '+e.getLineNumber();
            outMap.put('Error', e.getStackTraceString());
            outMap.put('StatusCode', 500);
            outMap.put('ErrorResponse', MCOnline_Utility.generateError('','UNKNOWN_ERROR','custom', inputMap,'',parameters,APIFUNCTIONALITY));
            MCOnline_Utility.logError(error_message,'500','MCOnline_ChangeBasket_V4,MCOnline_ChangeBasket_V4.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
        }
        if (result != false){
              if(storeInput != null){
                 createAsynchBasketsBatchV5 cls = new createAsynchBasketsBatchV5(storeInput, inputMap,TSCID,AgreementId,User,parentId);
                 Database.executeBatch(cls, 1);
               }
         }
         return result;
      }
    
    public static void Unreserve(Map<String,Object> inputMap, Map<String,Object> outMap){
    }
    
    /*  ********************************************************************************************************
LOGIC TO VALIDATE THE GIVEN BASKET
********************************************************************************************************* */
    public static void basketValidity(Map<String,Object> inputMap, Map<String,Object> outMap){
        basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('itemBasketName'));
        List<MCOnline_Basket__c> BsktId = [Select Id from MCOnline_Basket__c where Name=:basketName];
        //---- error handling for blank input start---// 
        if(String.isBlank(basketName)){
            hasError = true;
            outMap.put('ErrorResponse', MCOnline_Utility.generateError('','NO_INPUT_BASKET_NAME','custom', inputMap,'',parameters,APIFUNCTIONALITY));
            outMap.put('StatusCode', 400);  
        }
        //---- error handling for blank input stop---//   
        else{  
            //error handling for invalid basket Name-- start--//
            if(BsktId.size() ==0){
                hasError = true;
                outMap.put('ErrorResponse', MCOnline_Utility.generateError('','INVALID_BASKET_NAME','custom', inputMap,'',parameters,APIFUNCTIONALITY));
                outMap.put('StatusCode', 400);
            }
            //error handling for invalid basket Name-- stop--//
            else{
                if(hasError == false){           
                    outMap.put('StatusCode', 200);
                }
            }       
        }
    }//
    
    /*  ********************************************************************************************************
LOGIC TO DELETE THE BASKET
********************************************************************************************************* */
    public static void DeleteBasket(Map<String,Object> inputMap, Map<String,Object> outMap){
        basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('itemBasketName'));
        List<MCOnline_Basket__c> BsktId = [Select Id from MCOnline_Basket__c where Name=:basketName];
        Response basketResponse = new Response();
        basketResponse.id = BsktId[0].Id;
        delete BsktId;
        if(hasError==false){       
            basketResponse.success = true;
        }
        outMap.put('Result', JSON.serialize(basketResponse));
        outMap.put('StatusCode', 200);  
    }
    public class Response{
        public string id{get;set;}
        public boolean success {get; set;}  
    }
}