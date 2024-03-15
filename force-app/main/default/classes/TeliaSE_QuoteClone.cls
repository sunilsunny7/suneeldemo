/****************************************************************************************************************************
* @author                 Suneel Shivanna   suneel.g-shivanna@capgemini.com
* @modifiedBy             Suneel Shivanna   suneel.g-shivanna@capgemini.com
* @maintainedBy          
* @version                1.0
* @created                2019-05-11
* @modified               2019-05-11
******************************************************************************************************************************/

global without sharing class TeliaSE_QuoteClone implements vlocity_cmt.VlocityOpenInterface {
    global TeliaSE_QuoteClone(){}
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try
        {
            if (methodName.equals('cloneQuote'))
            {
                cloneQuote(inputMap,outMap);
            }
            else if(methodName.equalsignorecase('copyPrecheckData')){
                
                copyPrecheckData(inputMap,outMap);    
            }
            else if(methodName.equalsIgnoreCase('checkOldProducts')){//Adding tocheck for old version products
                checkOldProducts(inputMap,outMap);
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
            outMap.put('ErrorQuoteClone','Error');
            outMap.put('Errorlinenumber',e.getLineNumber());
            outMap.put('ErrorMessage',e.getMessage());   
        }
        return result;
    }
    
    public static void cloneQuote(Map<String, Object> inputMap, Map<String, Object> outMap)
    {
        try{
            String quoteId;
            String agreementId;
            String sales_flow_identifier;
            String renegotiationType=(String)inputMap.get('Type');
            String opportunityId=(String)inputMap.get('ContextId');
            String name;
            String madamId;
            String contractNumber;
            
            Map<String,Object> renegContractDetails = (Map<String,Object>) inputMap.get('ContractExtract');
            Map<String,Object> renegContractMap = (Map<String,Object>) renegContractDetails.get('Contract');
            Map<String,Object> renegQuoteDetails = (Map<String,Object>) renegContractMap.get('Quote');
            
            quoteId = (String)renegContractDetails.get('QuoteId');
            sales_flow_identifier=(String)inputMap.get('MCSalesFlowIdentifier');
            agreementId=(String)renegContractDetails.get('ContractId');
            name=(String)((Map<String,Object>)inputMap.get('Opportunity')).get('Name');
            
            String contractParentAgreement = (String)renegContractMap.get('ParentAgreement');
            string agreementNumber = String.valueOf(renegContractMap.get('AgreementNumber'));
            String quoteParentAgreement = (String)renegQuoteDetails.get('parentAgreement');
            
            madamId=agreementNumber == 'false' ? NULL:agreementNumber ;
            contractNumber=quoteParentAgreement !=null?quoteParentAgreement:contractParentAgreement;
            
            String query=queryBuilder('Quote');
            query+=' FROM Quote WHERE '+'id=\'' + String.escapeSingleQuotes(quoteId)+'\'';
            
            List<Quote> data=  Database.query(query);
            Quote quote=data.get(0);
            
            Quote quoteCloned=quote.Clone(false,true);
            quoteCloned.TeliaSWE_Primary_Quote__c=true;
            String quoteName=name!=null?name:quote.name;
            String clonedquoteName;
            if(quoteName.contains('Version'))
            {
                clonedquoteName=quoteName.remove(quoteName.substring(quoteName.lastIndexOf('n')+1,quoteName.length()));
                Integer versionNumber=Integer.valueOf(quoteName.substring(quoteName.lastIndexOf('n')+1,quoteName.length()));
                versionNumber++;
                clonedquoteName=clonedquoteName+versionNumber;
            }
            else
            {
                clonedquoteName=quoteName+'_RNGN_Version1';
            }
            quoteCloned.Name=clonedquoteName;
            quoteCloned.status=System.Label.TeliaSE_Draft;
            quoteCloned.TeliaSE_Agreement_Nr__c=madamId;
            quoteCloned.TeliaSE_Parent_Agreement__c=contractNumber;
            if(renegotiationType == null){
                quoteCloned.OpportunityId=opportunityId;
            }
            quoteCloned.TeliaSE_Type__c='Renegotiation';
            quoteCloned.TeliaSE_RenegotiatedAgreement__c=agreementId;
            quoteCloned.TeliaSE_RevisedAgreement__c = null;
            quoteCloned.TeliaSE_Locked__c=false;
            quoteCloned.TeliaSE_MC_Sales_Flow_Identifier__c=sales_flow_identifier;
            quoteCloned.TeliaSE_Autotask_QuoteId__c = null;
            quoteCloned.TeliaSE_MC_ApprovalFileLink__c = '#N/A';
            //MCSTO-3036, MCSTO-2085 - START
            string miniDebTPFunctionActive = (String)inputMap.get('miniDebTPFunctionActive');
            string miniDebTPAgreedPercentage = (String)inputMap.get('miniDebTPAgreedPercentage');
            string miniDebMobileWarningPercentage = (String)inputMap.get('miniDebMobileWarningPercentage');
            string miniDebTPWarningPercentage = (String)inputMap.get('miniDebTPWarningPercentage');
            string miniDebTPWarningActive = (String)inputMap.get('miniDebTPWarningActive');
            string miniDebMobileAgreedPercentage = (String)inputMap.get('miniDebMobileAgreedPercentage');
            string miniDebMobileFunctionActive = (String)inputMap.get('miniDebMobileFunctionActive');
            string miniDebMobileWarningActive = (String)inputMap.get('miniDebMobileWarningActive');
            
            quoteCloned.TeliaSE_MC_TP_FunctionActive__c =  String.isBlank(miniDebTPFunctionActive)? 'N' : miniDebTPFunctionActive;
            quoteCloned.TeliaSE_MC_TP_AgreedPercentage__c = miniDebTPAgreedPercentage;
            quoteCloned.TeliaSE_MC_TP_WarningActive__c = String.isBlank(miniDebTPWarningActive) ? 'N' : miniDebTPWarningActive;
            quoteCloned.TeliaSE_MC_TP_WarningPercentage__c = miniDebTPWarningPercentage;
            quoteCloned.TeliaSE_MC_Mobile_FunctionActive__c = String.isBlank(miniDebMobileFunctionActive) ? 'N' :miniDebMobileFunctionActive;
            quoteCloned.TeliaSE_MC_Mobile_AgreedPercentage__c = miniDebMobileAgreedPercentage;
            quoteCloned.TeliaSE_MC_Mobile_WarningActive__c = String.isBlank(miniDebMobileWarningActive) ? 'N':miniDebMobileWarningActive ;
            quoteCloned.TeliaSE_MC_Mobile_WarningPercentage__c = miniDebMobileWarningPercentage;
            //MCSTO-3036, MCSTO-2085 - END
            
            insert quoteCloned;
            List<QuoteLineItem> qliList=new List<QuoteLineItem>();
            
            String qliQuery=queryBuilder('QuoteLineItem');
            qliQuery+=', Product2.IsActive, Product2.vlocity_cmt__SellingEndDate__c';
            qliQuery+=' FROM QuoteLineItem WHERE '+'quoteid=\'' + String.escapeSingleQuotes(quoteId)+'\'' ;
            list<QuoteLineItem> itemsData =  Database.query(qliQuery);
            For(QuoteLineItem qli:itemsData)
            {
                if(qli.TeliaSE_Product_Object_Type__c!='CG Free Service Offer Spec' && (qli.Product2.vlocity_cmt__SellingEndDate__c == null || qli.Product2.vlocity_cmt__SellingEndDate__c > Date.today())){// Added if condition for US-MCSTO-8804
                    QuoteLineItem itemCopy = qli.clone(false,true);
                    itemCopy.vlocity_cmt__PriorQuoteLineItemId__c = qli.id;
                    itemCopy.TeliaSE_MC_Campaign_Id__c = null;
                    itemCopy.MC_RootPriceFlag__c = false;   
                    itemCopy.quoteId=quoteCloned.Id;   
                    //Added for TPP MCSTO-8146 AC3 - Aditi
                    itemCopy.MC_Line_Status__c = 'Existing';
                    //added code for assetref
                    itemCopy.vlocity_cmt__AssetReferenceId__c=null;
                    itemCopy.vlocity_cmt__RootItemId__c=null;
                    itemCopy.vlocity_cmt__ParentItemId__c =null;
                    qliList.add(itemCopy);
                }
            }
            
            //Removing terminated products in the list of qliItems
            List<vlocity_cmt__ContractLineItem__c> itemsData2 = [select id,TeliaSE_Product_Object_Type__c,vlocity_cmt__ProductCode__c from vlocity_cmt__ContractLineItem__c where (TeliaSE_Terminate_Date__c != null and vlocity_cmt__ContractId__c =: agreementId)];
            List<QuoteLineItem> qliList2=new List<QuoteLineItem>();
            Map<String,Integer> tempMap  =new Map<String,Integer>();
            For(vlocity_cmt__ContractLineItem__c cli:itemsData2)
            {
                if(cli.TeliaSE_Product_Object_Type__c!='CG Free Service Offer Spec'){
                    tempMap.put(cli.vlocity_cmt__ProductCode__c,1);
                }
            } 
            for(QuoteLineItem ql: qliList){
                if(tempMap.get(ql.TeliaSE_Product_Code__c) != 1){
                    qliList2.add(ql);
                }
            }
            if(qliList2.size()>0)
            {
                insert qliList2;
            }
            //Creating a map with key as old quoteLineItemId to new quoteLineItemId
            Map<id,id> newIds=new Map<id,id>();
            for(QuoteLineItem item:qliList2)
            {
                newIds.put(item.getCloneSourceId(),item.id);
            }
            cloneAdjustment(quoteId,quoteCloned.Id,newIds);
            
            outMap.put('options', quoteCloned.Id);     
        }catch(Exception e){
            system.debug('Error on TeliaSE_QuoteClone.cloneQuote : '+e.getStackTraceString());
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
    /*
* Clone the adjustment records  from Old FA Quote to new  FA Quote
*/
    
    private static void cloneAdjustment(String quoteId,String newQuoteId,Map<Id,Id> newItemIds)
    {
        String adjQuery=queryBuilder('vlocity_cmt__QuotePricingAdjustment__c');
        adjQuery+=' FROM vlocity_cmt__QuotePricingAdjustment__c WHERE '+'vlocity_cmt__QuoteId__c=\'' + String.escapeSingleQuotes(quoteId)+'\'' ;
        list<vlocity_cmt__QuotePricingAdjustment__c> itemsData =  Database.query(adjQuery);
        list<vlocity_cmt__QuotePricingAdjustment__c> adjList=new list<vlocity_cmt__QuotePricingAdjustment__c>();
        For(vlocity_cmt__QuotePricingAdjustment__c adj:itemsData)
        {
            vlocity_cmt__QuotePricingAdjustment__c itemCopy = adj.clone(false,true);
            itemCopy.vlocity_cmt__QuoteId__c  = newQuoteId;     
            itemCopy.vlocity_cmt__QuoteItemId__c=newItemIds.get(itemCopy.vlocity_cmt__QuoteItemId__c);
            adjList.add(itemCopy);
        }
        
        if(adjList.size()>0)
        {
            insert adjList;
        }
    }
    // This method will copy the precheck data of primary quote opportunity to the new opportunity created for renegotiation
    public static void copyPrecheckData(Map<String, Object> inputMap,Map<String, Object> outMap){
        try{
            string accountId;
            string opportunityId;
            opportunityId = (string)inputMap.get('ContextId');
            accountId = (string)inputMap.get('AccountId');
            //Added below query to prevent cloning of precheck on old opportunity
            List<MC_PreCheck_Result__c> checklist = [select id,Opportunity__r.IsPreChecked__c from MC_PreCheck_Result__c where Opportunity__c =:opportunityId with security_enforced];
            if(checklist.size()>0){
                if(checklist[0].Opportunity__r.IsPreChecked__c==false){
                    outMap.put('PrecheckAlreadyCloned',true);
                }else if(checklist[0].Opportunity__r.IsPreChecked__c==true){
                    outMap.put('PrecheckAlreadyCloned',false);
                }
            }
            else{
                List<Opportunity> oppList= [select id,name,CreatedDate, LastModifiedDate,account.FA_Contract__c from Opportunity where AccountId=:accountId and account.FA_Contract__r.status='Active' and account.TeliaSE_Utilzer_Role__c = 'Owner' and IsPreChecked__c=true with security_enforced Order By PrecheckDate__c DESC,CreatedDate DESC LIMIT 1 ];// Added Precheck condition and order by's for defect mcsto 9737
                if(oppList.size()>0 && oppList[0].id != opportunityId){
                    List<MC_PreCheck_Result__c> copiedPrecheckData = new List<MC_PreCheck_Result__c>();
                    List<MC_PreCheck_Result__c> precheckResults = [Select id,Name,MC_PriceAverageFlag__c,RecordType.Name,Opportunity__r.Id, Opportunity__r.IsPreChecked__c,Opportunity__r.PrecheckDate__c, MC_Product_Code__c,MC_Product_Bandwidth__c,Price__c,MC_QoS__c,MC_Max_SLA__c,MC_PriceParameter__c,MC_Max_Bandwidth__c,MC_Max_UploadSpeed__c,MC_Delivery_Time__c,MC_Delivery_Type__c,MC_ReturnCodeMessage__c,MC_ReturnCode__c,MC_AccessType_Name__c,MC_AccessType_Id__c,MC_Technology_Name__c,MC_TechnologyId__c,MC_Priority_Greater_Than_1GBPS__c,MC_Priority_Less_Than_1GBPS__c,MC_LineType__c,MC_AgreementId__c,MC_ContractType__c,MC_LanType__c,MC_Fiber_Length_to_Station__c,MC_Number_Of_Fiber_Pairs__c,MC_Fixed_Price_Area__c,RecordTypeId,MC_Parent_Info__c,Service_Point__c,Opportunity__c from MC_PreCheck_Result__c where Opportunity__c=:oppList[0].id with security_enforced];    
                    if(precheckResults!= null && precheckResults.size()>0){
                        Opportunity updateOpp = new Opportunity();
                        for(MC_PreCheck_Result__c precheckdata : precheckResults){
                            MC_PreCheck_Result__c copyPrecheckData = new MC_PreCheck_Result__c();
                            copyPrecheckData.Name = precheckdata.Name;
                            copyPrecheckData.MC_PriceAverageFlag__c = precheckdata.MC_PriceAverageFlag__c;
                            copyPrecheckData.MC_Product_Code__c = precheckdata.MC_Product_Code__c;
                            copyPrecheckData.MC_Product_Bandwidth__c = precheckdata.MC_Product_Bandwidth__c;
                            copyPrecheckData.Price__c = precheckdata.Price__c;
                            copyPrecheckData.MC_QoS__c = precheckdata.MC_QoS__c;
                            copyPrecheckData.MC_Max_SLA__c = precheckdata.MC_Max_SLA__c;
                            copyPrecheckData.MC_PriceParameter__c = precheckdata.MC_PriceParameter__c;
                            copyPrecheckData.MC_Max_Bandwidth__c = precheckdata.MC_Max_Bandwidth__c;
                            copyPrecheckData.MC_Max_UploadSpeed__c = precheckdata.MC_Max_UploadSpeed__c;
                            copyPrecheckData.MC_Delivery_Time__c = precheckdata.MC_Delivery_Time__c;
                            copyPrecheckData.MC_Delivery_Type__c = precheckdata.MC_Delivery_Type__c;
                            copyPrecheckData.MC_ReturnCodeMessage__c = precheckdata.MC_ReturnCodeMessage__c;
                            copyPrecheckData.MC_ReturnCode__c = precheckdata.MC_ReturnCode__c;
                            copyPrecheckData.MC_AccessType_Name__c = precheckdata.MC_AccessType_Name__c;
                            copyPrecheckData.MC_AccessType_Id__c = precheckdata.MC_AccessType_Id__c;
                            copyPrecheckData.MC_Technology_Name__c = precheckdata.MC_Technology_Name__c;
                            copyPrecheckData.MC_TechnologyId__c = precheckdata.MC_TechnologyId__c;
                            copyPrecheckData.MC_Priority_Greater_Than_1GBPS__c = precheckdata.MC_Priority_Greater_Than_1GBPS__c;
                            copyPrecheckData.MC_Priority_Less_Than_1GBPS__c = precheckdata.MC_Priority_Less_Than_1GBPS__c;
                            copyPrecheckData.MC_LineType__c = precheckdata.MC_LineType__c;
                            copyPrecheckData.MC_AgreementId__c = precheckdata.MC_AgreementId__c;
                            copyPrecheckData.MC_ContractType__c = precheckdata.MC_ContractType__c;
                            copyPrecheckData.MC_LanType__c = precheckdata.MC_LanType__c;
                            copyPrecheckData.MC_Fiber_Length_to_Station__c = precheckdata.MC_Fiber_Length_to_Station__c;
                            copyPrecheckData.MC_Number_Of_Fiber_Pairs__c = precheckdata.MC_Number_Of_Fiber_Pairs__c;
                            copyPrecheckData.MC_Fixed_Price_Area__c = precheckdata.MC_Fixed_Price_Area__c;
                            copyPrecheckData.RecordTypeId = precheckdata.RecordTypeId;
                            if(precheckdata.MC_Parent_Info__c == null && precheckdata.RecordType.Name=='Netfraga Response'){
                                copyPrecheckData.MC_Parent_Info__c = precheckdata.id;
                            }else{
                                copyPrecheckData.MC_Parent_Info__c = precheckdata.MC_Parent_Info__c;
                            }
                            copyPrecheckData.Service_Point__c = precheckdata.Service_Point__c;
                            copyPrecheckData.Opportunity__c = opportunityId;
                            copiedPrecheckData.add(copyPrecheckData);
                            //updateOpp.Id = opportunityId;
                            //updateOpp.IsPreChecked__c = precheckdata.Opportunity__r.IsPreChecked__c;
                            //updateOpp.PrecheckDate__c = precheckdata.Opportunity__r.PrecheckDate__c;
                        }
                        if(copiedPrecheckData.size()>0){
                            outMap.put('PrecheckCloneDone',true);
                            insert copiedPrecheckData;
                            //update updateOpp;
                            try{
                                updatelist(opportunityId,oppList[0].id);
                            }
                            catch(Exception e){
                                throw new QuoteCloneException(e.getStackTraceString());
                            }// calling method to update the parentinfo id of child records with the parent precheck record
                            
                        }else{
                            outMap.put('PrecheckCloneDone',true);
                        }
                    }else{
                        outMap.put('PrecheckCloneDone',false);
                    }
                    
                }else{
                    outMap.put('PrecheckCloneDone',false);
                }
            }   
        }
        Catch(Exception e)
        {
            throw new QuoteCloneException(e.getMessage()+e.getLineNumber()+e.getStackTraceString());
        }
    }
    
    public static void updatelist(string opportunityId,string oldoppid){
        
        List<MC_PreCheck_Result__c> newList =[select id,Name,Price__c,MC_Parent_Info__c from MC_PreCheck_Result__c where Opportunity__c =:opportunityId and RecordType.Name='Netfraga Response'];
        List<MC_PreCheck_Result__c> oldList =[select id,Name,MC_Parent_Info__c from MC_PreCheck_Result__c where Opportunity__c =:oldoppid and RecordType.Name='Netfraga Response' and MC_Parent_Info__c =null];                                             
        List<MC_PreCheck_Result__c> finallist = new List<MC_PreCheck_Result__c>();
        map<string,object> map1 = new map<string,object>();
        for(MC_PreCheck_Result__c itr1:oldList){         
            for(MC_PreCheck_Result__c itr2 :newList){
                if(itr1.id == itr2.MC_Parent_Info__c && itr2.Price__c==null){
                    // itr2.MC_Parent_Info__c= null;
                    map1.put(itr2.MC_Parent_Info__c,itr2.id);
                }
            }
        }
        for(MC_PreCheck_Result__c itr3 :newList){
            if(itr3.Price__c==null){
                itr3.MC_Parent_Info__c= null;
            }else{
                itr3.MC_Parent_Info__c = (string)map1.get(itr3.MC_Parent_Info__c);
            }
            finallist.add(itr3);
        }
        
        update finallist;
    }
    /*
Adding the logic to check if 1st version of mobile portfolio products are available in quote.
*/
    
    public static void checkOldProducts(Map<String, Object> inputMap, Map<String, Object> outMap){
        
        string quoteId;
        List<String> retiredProductIds = new List<String>();
        Boolean oldProductsPresent=true;//old products present
        quoteId = (string)inputMap.get('QuoteIDValue');
        List<QuoteLineItem> qli=new List<QuoteLineItem>();
        for (String tc: TeliaSE_PortfolioIdentifiers__c.getAll().keySet())
        {
            if(TeliaSE_PortfolioIdentifiers__c.getAll().get(tc).RetiredPortfolio__c != null)
            {
                retiredProductIds.add(TeliaSE_PortfolioIdentifiers__c.getAll().get(tc).RetiredPortfolio__c);
            }
        }
        
        qli= [select  vlocity_cmt__Product2Id__r.Name from QuoteLineItem
              where (vlocity_cmt__Product2Id__r.Id in :retiredProductIds)
              and vlocity_cmt__Product2Id__r.Family <>'Online Order' and QuoteId =:quoteId];
        if(qli.isEmpty()){
            oldProductsPresent=false;//Old products not present
        }
        outMap.put('oldProductsPresent', oldProductsPresent);  
    }
    
    public class QuoteCloneException extends Exception{}
}