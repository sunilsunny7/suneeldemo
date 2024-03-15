global class MCOnline_DeleteBasket_V4 implements vlocity_cmt.VlocityOpenInterface2 {
    public static String APIFunctunality = 'DeleteBasket';
    public static List<MCOnline_Basket__c> parameters=new List<MCOnline_Basket__c>();
    public static Boolean result = true;
    public static String error_message,basketName,parentBasketId,BasktID,Id;
    public static List<Id> basketIDs = new List<Id>(); // List to store the IDs
    public static Map<string,set<string>> MiniBasketMap = new Map<string,set<string>>();
    public static Map<String,Map<string,set<string>>> MiniBasketUnreserve = new Map<String,Map<string,set<string>>>();
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        try { 
            if(methodName.equalsIgnoreCase('DeleteBasketGroup')) {
                deleteBasketGroup(inputMap, outMap);
            }
            else {
                result = false;
            }
        }catch(Exception e) 
        {
            error_message= e.getMessage() +' '+e.getLineNumber();
            outMap.put('Error', e.getStackTraceString());
            outMap.put('StatusCode', 500);
            outMap.put('ErrorResponse', MCOnline_Utility.generateError('','UNKNOWN_ERROR','custom', inputMap,'',parameters,APIFunctunality));
            MCOnline_Utility.logError(error_message,'500','MCONLINE_deleteBasket_V4,MCOnline_DeleteBasket_V4.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
        }
        return result;
    }
    
    private static void deleteBasketGroup(Map<String,Object> inputMap, Map<String,Object> outMap){
        if(inputMap.containsKey('itemBasketName')){
            basketName = String.valueOf(inputMap.get('itemBasketName')); // fetching the input basket name
        }
        else
        {
          basketName = String.Valueof(((Map<string,object>)inputMap.get('options')).get('itemBasketName'));//fetching the input basket name
        }
        boolean hasError = false;
        if(String.isBlank(basketName)){
            hasError = true;
            outMap.put('ErrorResponse', MCOnline_Utility.generateError('','NO_INPUT_BASKET_NAME','custom', inputMap,'',parameters,APIFunctunality));
            outMap.put('StatusCode', 400);
        }
        else
        {  
            // deletion for child baskets with related child baskets along with number unreservation
            if(basketName.startswith('BAS'))
            {
                List<MCOnline_Basket__c> miniBaskets = [Select Id, MCOnline_AttributeJSON__c,Basket_Line_Relation_Id__c from MCOnline_Basket__c where Name=:basketName WITH SECURITY_ENFORCED];// getting the basket relation ID of the input basket
                if(miniBaskets.size() == 0)
                {
                    hasError = true;
                    outMap.put('ErrorResponse', MCOnline_Utility.generateError('','INVALID_BASKET_NAME','custom', inputMap,'',parameters,APIFunctunality));
                    outMap.put('StatusCode', 400);
                    return;
                }    
                if(String.isBlank(miniBaskets[0].Basket_Line_Relation_Id__c))
                {
                    Basket basketToForResponse = new Basket(); // creating an instance of wrapper class
                    basketToForResponse.id = miniBaskets[0].Id;
                    basketIDs =  unreserveMSISDN(miniBaskets);
                    MCOnline_Utility.logError(String.valueOf(outMap.get('StatusCode')), String.valueOf(outMap.get('StatusCode')),'DeleteBasket','Apex', 'Apex Error',basketName,basketName,'MiniBasket','DeleteBasket');
                    Database.DeleteResult[] deleteResult=Database.delete(miniBaskets,false);
                    basketToForResponse.success = true;
                    outMap.put('Result', JSON.serialize(basketToForResponse));
                    outMap.put('StatusCode', 200);
                }
                else
                {
                    List<MCOnline_Basket__c> miniBasketList = [SELECT Name, MCOnline_ParentBasket__c, Basket_Line_Relation_Id__c, TSCID__c, MCOnline_AttributeJSON__c from  MCOnline_Basket__c where  Basket_Line_Relation_Id__c=:miniBaskets[0].Basket_Line_Relation_Id__c WITH SECURITY_ENFORCED]; // fetching all the mini baskets corresponding to the parent basket
                    if(miniBasketList.size()>0){
                        basketIDs =  unreserveMSISDN(miniBasketList);
                    }
                    if(basketIDs.size()>0)
                    {
                        Basket basketToForResponse= new Basket();
                        basketToForResponse.id=miniBaskets[0].Id;
                        Database.DeleteResult[] deleteResult=Database.delete(miniBasketList,false);
                        outMap.put('Result', JSON.serialize(basketToForResponse));
                        outMap.put('StatusCode', 200);
                        MCOnline_Utility.logError(String.valueOf(outMap.get('StatusCode')), String.valueOf(outMap.get('StatusCode')),'DeleteBasket','Apex', 'Apex Error',basketName,basketName,'MiniBasket','DeleteBasket');
                    }
                }
            }
            else if(basketName.startswith('MBAS'))
            {
                List<MCOnline_Basket__c> miniBasketList = [SELECT Name, MCOnline_ParentBasket__c, Basket_Line_Relation_Id__c, TSCID__c, MCOnline_AttributeJSON__c from  MCOnline_Basket__c where MCOnline_ParentBasket__r.Name =:basketName WITH SECURITY_ENFORCED];
                if(miniBasketList.size()==0)
                {
                    hasError = true;
                    outMap.put('ErrorResponse', MCOnline_Utility.generateError('','INVALID_BASKET_NAME','custom', inputMap,'',parameters,APIFunctunality));
                    outMap.put('StatusCode', 400);
                    return;
                }
                else
                {
                    basketIDs =  unreserveMSISDN(miniBasketList);
                    if(basketIDs.size()>0){
                        Basket basketToForResponse= new Basket();
                        basketToForResponse.id=miniBasketList[0].MCOnline_ParentBasket__c;
                        Database.DeleteResult[] deleteResult=Database.delete(miniBasketList,false);
                        outMap.put('Result', JSON.serialize(basketToForResponse));
                        outMap.put('StatusCode', 200);
                        MCOnline_Utility.logError(String.valueOf(outMap.get('StatusCode')), String.valueOf(outMap.get('StatusCode')),'DeleteBasket','Apex', 'Apex Error',basketName,basketName,'ParentBasket','DeleteBasket');
                    }
                    if(!String.isblank(miniBasketList[0].MCOnline_ParentBasket__c)){
                        database.delete(miniBasketList[0].MCOnline_ParentBasket__c,false);
                    }
                }
            }
        }
    }
    
    public static List<Id> unreserveMSISDN(List<MCOnline_Basket__c> baskets){
        String tscId;
        Set<String> msisdnSet = new Set<String>();
        for(MCOnline_Basket__c basketSFObj : baskets)
        {
            basketIDs.add(basketSFObj.id);
            tscId=basketSFObj.TSCID__c;
            Map<String,Object> productsMap = (Map<String,Object>)JSON.deserializeUntyped(basketSFObj.MCOnline_AttributeJSON__c);  
            List<Object> prodList = (List<Object>)JSON.deserializeUntyped(JSON.serialize(productsMap.get('products'))); 
            for(Object productObj : prodList)
            { 
                Map<String,Object> productMap = (Map<String,Object>)productObj;
                Map<String,Object> attributeMap = (Map<String,Object>)productMap.get('attributes'); 
                if(attributeMap != null && attributeMap.get('MSISDN') != null)
                { 
                    String msisdn = String.valueOf(attributeMap.get('MSISDN'));
                    msisdnSet.add(msisdn); 
                }
            }
        }
        if(msisdnSet.size()>0)
        {
            for(String msisdn:msisdnSet)
            {
                MCOnline_NumberUnReservation_V2.UnReservationResponseWrapper response = MCOnline_NumberUnReservation_V2.UnreserveMsisdn(new Set<String>{msisdn}, tscId);
            }
        }
        return basketIDs;
    }
   public class Basket{
        public string id{get;set;}
        public boolean success {get; set;}
    }
}