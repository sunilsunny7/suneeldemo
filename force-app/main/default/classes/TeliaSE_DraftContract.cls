global without sharing class TeliaSE_DraftContract implements vlocity_cmt.VlocityOpenInterface 
{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
     Boolean result = true;
        try
        {
            if(methodname.equals('deleteOldPortfolio'))
            {
            	deleteOldPortfolio(inputMap,outMap);
            }
        }
    	catch(Exception e)
        {
            System.debug('exception: '+e);
            outMap.put('Error','Error');
            result = false;
        }
        return result;

}
    public static void deleteOldPortfolio(Map<String,Object> inputMap,Map<String,Object> outMap)
    {
        System.debug(inputMap);    
     String quoteId = (String)inputMap.get('QuoteID');
  	 //quoteId = '0Q03N0000004Oh4SAE';      
     List<QuoteLineItem> qliList=new List<QuoteLineItem>();
        //set<string> Prodcod = TeliaSE_PortfolioIdentifiers__c.getAll().Keyset();
        List<TeliaSE_PortfolioIdentifiers__c> ProdIdList  = TeliaSE_PortfolioIdentifiers__c.getAll().Values();
       
        //SELECT Id, TeliaSE_Root_Product__c, vlocity_cmt__ProductHierarchyPath__c FROM QuoteLineItem where quoteid in ('0Q03N0000004OPtSAM') AND (NOT vlocity_cmt__ProductHierarchyPath__c LIKE '%01t1p0000081yLUAAY%') AND (NOT vlocity_cmt__ProductHierarchyPath__c LIKE '%01t3N000000Y7rxQAC%')
        
        String productCodeIDString ='' ;
        for( Integer i = 0; i<ProdIdList.size(); i++){
            if(i < ProdIdList.size() - 1){
                //(NOT vlocity_cmt__ProductHierarchyPath__c LIKE '%01t1p0000081yLUAAY%')
                productCodeIDString+='((vlocity_cmt__ProductHierarchyPath__c LIKE \'%'+ProdIdList[i].ProductId__c+'%\') OR ';
                System.debug('(vlocity_cmt__ProductHierarchyPath__c LIKE \'%'+ProdIdList[i].ProductId__c+'%\') AND ');
            }else{
                productCodeIDString+='(vlocity_cmt__ProductHierarchyPath__c LIKE \'%'+ProdIdList[i].ProductId__c+'%\'))';
                System.debug('(vlocity_cmt__ProductHierarchyPath__c LIKE \'%'+ProdIdList[i].ProductId__c+'%\')');
            }
        }
        String qliQuery=queryBuilder('QuoteLineItem');
          //System.debug(JSON.serialize(qliQuery));
        //qliQuery+=' FROM QuoteLineItem WHERE '+'quoteid=\'' + String.escapeSingleQuotes(quoteId)+'\' AND vlocity_cmt__ProductHierarchyPath__c AND '+productCodeIDString;
        qliQuery+=' FROM QuoteLineItem WHERE '+'quoteid=\'' + String.escapeSingleQuotes(quoteId)+'\' AND '+productCodeIDString;
  
    //    System.debug(' FROM QuoteLineItem WHERE '+'quoteid=\'' + String.escapeSingleQuotes(quoteId)+'\' AND '+productCodeIDString);
     //   Integer batch=0;
        list<QuoteLineItem> itemsData =  Database.query(qliQuery);
        System.debug(itemsData.size());
        deleteQuoteLineItems(itemsData);
                 
          
	
    }

    public static void deleteQuoteLineItems(List<QuoteLineItem> itemsData)
        {
         list<QuoteLineItem> itemsDataBatch = new list<QuoteLineItem>();
         Integer batch=0;
       	 if(itemsData.size()<100)
        {
            delete itemsData;
        }
        else
        {
            
            for(integer record=0;record<itemsData.size();record++)           
            { 
                batch++;
				itemsDataBatch.add(itemsData.get(record));
                if(batch>99)
				{
					batch = 0;
                    delete itemsDataBatch;
                    itemsDataBatch.clear();
				}
            }
        }
        }
    
    
     //return dynamic query for the Object    
    private static String queryBuilder(String obj)
    {
        SObjectType quoteObj = Schema.getGlobalDescribe().get(obj);
        Map<String,Schema.SObjectField> objfields = quoteObj.getDescribe().fields.getMap();
        String query = 'Select ';
        Boolean firstField = true;
        List<Sobject> quoteList=new List<Sobject>();
        
        for (String field : objfields.keySet())
        {
            if(firstField)
                query += field;
            else{
                query +=' , ';
                query += field;
            }
            
            firstField = false;
        }
        return query;
    }
}