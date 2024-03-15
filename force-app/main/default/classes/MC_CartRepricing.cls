global without sharing class MC_CartRepricing implements vlocity_cmt.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options) {
        Boolean result = true;
        try{
            if(methodName.equalsIgnoreCase('updateFlag')){
                List<QuoteLineItem> qliList = MC_Sales_FrameworkPricingClass.valideraCallFrameworkPrice(inputMap,outMap);
                if(qliList!=null && qliList.size()>0){
                    options.put('frameworkQli',qliList);
                }
                if(String.valueOf(inputMap.get('quoteType')) != 'Inforhandling'){
                    MC_CartRepricing.updateFlag(inputMap,outMap,options); //priceFlag =true;
                }else{
                    update qliList;
                }
            }  else{
                result = false;
            }   
            
        }catch(Exception e){
            result = false;
        }
        return result;
    }
    public static void updateFlag(Map<String,Object> inputMap, Map<String,Object> outMap,Map<String,Object> options){
        String quoteId = (String)inputMap.get('Id');
        List<SObject> qItemList=new List<SObject>();
        qItemList=[select id,Quote.TeliaSE_Record_Type_Name__c,QuoteId,Quote.vlocity_cmt__ParentQuoteId__c,PricebookEntry.Product2.ProductCode,TeliaSE_MC_Customer_Requested_Price__c,vlocity_cmt__OneTimeCharge__c,TeliaSE_Floor_Percentage__c,TeliaSE_Ceiling_Price__c,vlocity_cmt__RecurringCharge__c,
                   TeliaSE_AM_Mandate_Percentage__c,TeliaSE_SM_Mandate_Percentage__c,TeliaSE_SD_Mandate_Percentage__c,TeliaSE_CM_Mandate_Percentage__c,
                   MC_OT_Floor_Percentage__c,MC_OT_AM_Mandate_Percentage__c,MC_OT_SM_Mandate_Percentage__c,MC_OT_SD_Mandate_Percentage__c,MC_OT_CM_Mandate_Percentage__c,
                   MC_OneTimeCharge__c,TeliaSE_MC_Customer_Requested_Percentage__c,TeliaSE_Approved__c,TeliaSE_Approved_Price__c,TeliaSE_Nullify_Check__c,MC_OT_Approved_Price__c,TeliaSE_Flag__c
                   from QuoteLineItem where quoteid= :quoteId and Product2.TeliaSE_Price_Flag__c=true];
        
        String recType = ((QuoteLineItem)qItemList[0]).Quote.TeliaSE_Record_Type_Name__c;
        String happyFace = System.Label.TeliaSE_HappyFace;
        String sadFace = System.Label.TeliaSE_SadFace;
        Set<id> setOfSadFaceUpdateFlag = new Set<id>(); //Added this as part of MCSTO-8370
        // added Query to get missing formula fields
        Map<ID, QuoteLineItem> qItemMap = new Map<ID, QuoteLineItem>((List<QuoteLineItem>)qItemList);
        List<QuoteLineItem> qlisToUpdate = new List<QuoteLineItem>();
        //verify MC Quote - SEUtility.isRecordTypeAvailable
        if(qItemList != null && qItemList.size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.MC, SEUtility.QUOTE, recType)){
            
            //List<SObject> qItemList = (List<SObject>)input.get('ItemList'));    
            User u = [Select Id,MassCustomized_Roles__c from User WHERE Id = :UserInfo.getUserId()];
            String roleString;
            if(u.MassCustomized_Roles__c != null){
                roleString = u.MassCustomized_Roles__c;
            }
            //SObject parent = (SObject)vlocity_cmt.PricingPlanService.getFromPricingContext('Parent');
            //List<SObject> qItemList = (List<SObject>)vlocity_cmt.PricingPlanService.getFromPricingContext('LineItemList');
            for(SObject qliItem : qItemList){
                QuoteLineItem qliObject = (QuoteLineItem)qliItem;
                //QuoteLineItem qliMapObject = qItemMap.get(qliObject.Id);
                String jobSurfProductCode = test.isRunningTest() ? 'MOB_SURF_BAS_V2':qliObject.PricebookEntry.Product2.ProductCode;
                if ((qliObject.TeliaSE_MC_Customer_Requested_Price__c!=null) || (qliObject.TeliaSE_MC_Customer_Requested_Percentage__c!=null && qliObject.TeliaSE_MC_Customer_Requested_Percentage__c!=0 ) || qliObject.vlocity_cmt__OneTimeCharge__c != null){
                    
                    Double floorPercentage = qliObject.TeliaSE_Floor_Percentage__c;
                    Double crpPercent = qliObject.TeliaSE_MC_Customer_Requested_Percentage__c;
                    Double ceilingPrice = qliObject.TeliaSE_Ceiling_Price__c;
                    Double recurCharge = qliObject.vlocity_cmt__RecurringCharge__c;
                    Double srMandPercnt = qliObject.TeliaSE_AM_Mandate_Percentage__c;
                    Double smMandPercnt = qliObject.TeliaSE_SM_Mandate_Percentage__c;
                    Double sdMandPercnt = qliObject.TeliaSE_SD_Mandate_Percentage__c;
                    Double cmMandPercnt = qliObject.TeliaSE_CM_Mandate_Percentage__c;
                    
                    Double oTfloorPercentage;// = qliObject.MC_OT_Floor_Percentage__c;
                    if(roleString == 'SalesRep'){
                        oTfloorPercentage = qliObject.MC_OT_AM_Mandate_Percentage__c;
                    }else if(roleString == 'SalesManager'){
                        oTfloorPercentage = qliObject.MC_OT_SM_Mandate_Percentage__c;
                    }else if(roleString == 'SalesDirector'){
                        oTfloorPercentage = qliObject.MC_OT_SD_Mandate_Percentage__c;
                    }else if(roleString == 'CommercialManager'){
                        oTfloorPercentage = qliObject.MC_OT_CM_Mandate_Percentage__c;
                    }else{
                        oTfloorPercentage = 0;
                    }
                    Double oneTimeCharge = qliObject.MC_OneTimeCharge__c;
                    Double otSRMandPercnt = qliObject.MC_OT_AM_Mandate_Percentage__c;
                    Double otSMMandPercnt = qliObject.MC_OT_SM_Mandate_Percentage__c;
                    Double otSDMandPercnt = qliObject.MC_OT_SD_Mandate_Percentage__c;
                    Double otCMMandPercnt = qliObject.MC_OT_CM_Mandate_Percentage__c;
                    
                    Double floorPrice,floorPer,oTfloorPrice,oTfloorPer;
                    oTfloorPrice =0;
                    oTfloorPer=0;
                    if (roleString == 'SalesRep'){
                        floorPrice = (recurCharge - (recurCharge*srMandPercnt/100));
                        if(floorPercentage!=null && floorPrice ==recurCharge){
                            floorPer = floorPercentage;
                        }else{
                            floorPer = srMandPercnt;
                        }
                        if(otSRMandPercnt != null )   
                        {
                            if(oneTimeCharge != null){
                                oTfloorPrice = (oneTimeCharge - (oneTimeCharge*otSRMandPercnt/100));
                            }
                        }
                        if(oTfloorPercentage!=null && oTfloorPrice ==oneTimeCharge){
                            oTfloorPer = oTfloorPercentage;
                        }else{
                            oTfloorPer = otSRMandPercnt;
                        }
                        
                    }else if (roleString == 'SalesManager'){
                        if(smMandPercnt != null){
                            floorPrice = (recurCharge - (recurCharge*smMandPercnt/100));
                        }
                        if(floorPercentage!=null && floorPrice ==recurCharge){
                            floorPer = floorPercentage;
                        }else{
                            floorPer = smMandPercnt;
                        }
                        If(otSMMandPercnt!= null)
                        {
                            if(oneTimeCharge != null){
                                oTfloorPrice = (oneTimeCharge - (oneTimeCharge*otSMMandPercnt/100));
                            }
                        }                    
                        if(oTfloorPercentage!=null && oTfloorPrice ==oneTimeCharge){
                            oTfloorPer = oTfloorPercentage;
                        }else{
                            oTfloorPer = otSMMandPercnt;
                        }
                    }else if (roleString == 'SalesDirector'){
                        floorPrice = (recurCharge - (recurCharge*sdMandPercnt/100));
                        
                        if(floorPercentage!=null && floorPrice ==recurCharge){
                            floorPer = floorPercentage;
                        }else{
                            floorPer = sdMandPercnt;
                        }
                        If(otSDMandPercnt!= null)
                        {
                            if(oneTimeCharge != null){
                                oTfloorPrice = (oneTimeCharge - (oneTimeCharge*otSDMandPercnt/100));
                            }
                        }
                        
                        if(oTfloorPercentage!=null && oTfloorPrice ==oneTimeCharge){
                            oTfloorPer = oTfloorPercentage;
                        }else{
                            oTfloorPer = otSDMandPercnt;
                        }
                    }else if (roleString == 'CommercialManager'){
                        floorPrice = (recurCharge - (recurCharge*cmMandPercnt/100));
                        
                        if(floorPercentage!=null && floorPrice ==recurCharge){
                            floorPer = floorPercentage;
                        }else{
                            floorPer = cmMandPercnt;
                        }
                        if(otCMMandPercnt!= null)
                        {
                            if(oneTimeCharge != null){
                                oTfloorPrice = (oneTimeCharge - (oneTimeCharge*otCMMandPercnt/100));
                            }
                        }
                        
                        if(oTfloorPercentage!=null && oTfloorPrice ==oneTimeCharge){
                            oTfloorPer = oTfloorPercentage;
                        }else{
                            oTfloorPer = otCMMandPercnt;
                        }
                    }else{
                        floorPrice = recurCharge;
                        floorPer = 0;
                        if(oneTimeCharge != null )
                        {
                            oTfloorPrice = oneTimeCharge;    
                        }
                        oTfloorPer = 0;
                    }
                    Double fprice;
                    if(floorPrice != null){
                        fprice = floorPrice.round();
                    }
                    Double otfprice = oTfloorPrice.round();
                    //List<QuoteLineItem> qliList = new List<QuoteLineItem>();
                    //qliList.add(qliObject);
                    Map<Id,QuoteLineItem> qliMap = new Map<Id,QuoteLineItem>();
                    qliMap.put(qliObject.Id,qliObject);
                    //if(TeliaSE_checkRecursive.runOnce()){
                    // if(!test.isRunningTest()){
                    if(!qliObject.PriceBookEntry.Product2.ProductCode.contains('MOB_CALL_TRAVEL') && !qliObject.PriceBookEntry.Product2.ProductCode.contains('MOB_SURF')) {
                        QuoteLineItem approvalFlagQli=new QuoteLineItem();
                        approvalFlagQli=MC_CartRepricing.updateApprovalFlag(qliObject,fprice,floorPer,otfprice,oTfloorPer);
                        if(approvalFlagQli!=null){
                            //System.debug(qliObject.Id);
                            //System.debug(qItemMap.get(qliObject.Id));
                            //System.debug(qlisToUpdate.indexOf(qItemMap.get(qliObject.Id)));
                            if(qlisToUpdate.indexOf(qItemMap.get(qliObject.Id)) !=-1){
                                qlisToUpdate.remove(qlisToUpdate.indexOf(qItemMap.get(qliObject.Id)));
                            }
                            qlisToUpdate.add(approvalFlagQli);
                            
                        }                        
                    }
                    // }//}
                }
                else if(qliObject.TeliaSE_MC_Customer_Requested_Price__c ==null && qliObject.TeliaSE_MC_Customer_Requested_Percentage__c == null && jobSurfProductCode.contains('MOB_SURF') == false && jobSurfProductCode.contains('MOB_CALL_TRAVEL') == false){
                    qliObject.TeliaSE_Flag__c = happyFace;
                }else if(qliObject.TeliaSE_MC_Customer_Requested_Percentage__c == 0 && qliObject.TeliaSE_MC_Customer_Requested_Price__c ==null)
                {
                    qliObject.TeliaSE_Flag__c = happyFace;
                }
                qlisToUpdate.add(qliObject);
            }//end of for loop            
            if(qlisToUpdate.size()>0){
                Set<QuoteLineItem> qliToUpdateSet=new Set<QuoteLineItem>();
                qliToUpdateSet.addAll(qlisToUpdate); 
                qlisToUpdate.clear();
                qlisToUpdate.addAll(qliToUpdateSet);
                //update qlisToUpdate;
            }
            if(options.containsKey('frameworkQli')){
                qlisToUpdate.addAll((List<QuoteLineItem>)options.get('frameworkQli'));
            }
            if(qlisToUpdate.size()>0){
                update qlisToUpdate;
            }
        }
    }
    
    public static  QuoteLineItem  updateApprovalFlag(QuoteLineItem qliItem, Double fPrice, Double floorPer,Double otfPrice, Double otfloorPer){
        //System.debug('Inside updateApprovalFlag');
        Double crp,floor,ceiling,approvedPrice, approvedPercent,otc,otapprovedPrice;
        String happyFace = System.Label.TeliaSE_HappyFace;
        String sadFace = System.Label.TeliaSE_SadFace;

        if(qliItem.TeliaSE_Approved__c != null && qliItem.TeliaSE_Nullify_Check__c == false){
            approvedPercent = qliItem.TeliaSE_Approved__c;
        }          
        //Ceiling Price
        if(qliItem.TeliaSE_Ceiling_Price__c!= null){
            ceiling = qliItem.TeliaSE_Ceiling_Price__c; 
        }
        //Null pointer check
        if(ceiling != null){//Requested Price Logic
            if(qliItem.TeliaSE_MC_Customer_Requested_Price__c !=null  ){
                crp = qliItem.TeliaSE_MC_Customer_Requested_Price__c;
            }              
            
            //Floor % Logic
            else if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c!=null) && (floorPer!=null) && (qliItem.TeliaSE_MC_Customer_Requested_Percentage__c!= 0)){
                
                if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c <= floorPer) && (approvedPercent == null) ){
                    qliItem.TeliaSE_Flag__c = happyFace; 
                    //flag = happyFace;
                }
                
                else if(qliItem.TeliaSE_MC_Customer_Requested_Percentage__c  <= approvedPercent){
                    qliItem.TeliaSE_Flag__c = happyFace;
                    //flag = happyFace;
                }
                else if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c > floorPer)  && (approvedPercent < qliItem.TeliaSE_MC_Customer_Requested_Percentage__c) ){
                    qliItem.TeliaSE_Flag__c = sadFace;  
                    //flag = sadFace;
                    qliItem.TeliaSE_Approved__c = null;
                }
                else if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c > floorPer)  && (approvedPercent == null) ){
                    qliItem.TeliaSE_Flag__c = sadFace; 
                    //flag = sadFace;
                }
            }
            //Floor price Logic 
            if(fPrice!=null){
                floor = fPrice;
            }
            //Approved Price
            if(qliItem.TeliaSE_Approved_Price__c != null && qliItem.TeliaSE_Nullify_Check__c == false ){
                approvedPrice = qliItem.TeliaSE_Approved_Price__c;
            }
            
            //Flag Logic
            if(crp!=null && floor!=null ){
                if(crp >= floor && crp <= ceiling && approvedPrice == null ){
                    qliItem.TeliaSE_Flag__c = happyFace; 
                    //flag = happyFace;
                }
                
                else if(crp  >= approvedPrice){
                    qliItem.TeliaSE_Flag__c = happyFace;
                    //flag = happyFace;
                }
                else if(crp < floor  && approvedPrice > crp ){
                    qliItem.TeliaSE_Approved_Price__c = null;
                    qliItem.TeliaSE_Flag__c = sadFace; 
                    //flag = sadFace;
                    // approvedPrice = null;
                }
                else if(crp < floor  && approvedPrice == null ){
                    qliItem.TeliaSE_Flag__c = sadFace;  
                    //flag = sadFace;
                }
            }
        }
        
        if(qliItem.MC_OT_Approved_Price__c != null && qliItem.TeliaSE_Nullify_Check__c == false){
            otapprovedPrice = qliItem.MC_OT_Approved_Price__c;
        }
        if(qliItem.vlocity_cmt__OneTimeCharge__c!= null){
            otc = qliItem.vlocity_cmt__OneTimeCharge__c; 
        }
        if(otc != null){
            if(otc >= otfPrice && otapprovedPrice == null && ((qliItem.TeliaSE_Approved_Price__c == qliItem.TeliaSE_MC_Customer_Requested_Price__c)||(qliItem.TeliaSE_MC_Customer_Requested_Price__c == qliItem.vlocity_cmt__RecurringCharge__c)) &&((qliItem.TeliaSE_Approved__c == qliItem.TeliaSE_MC_Customer_Requested_Percentage__c)|| qliItem.TeliaSE_MC_Customer_Requested_Percentage__c == null)){
                qliItem.TeliaSE_Flag__c = happyFace; 
            }else if(otc  >= otapprovedPrice && qliItem.TeliaSE_Flag__c == happyFace){
                qliItem.TeliaSE_Flag__c = happyFace;
            }else if(otc  >= otapprovedPrice && qliItem.TeliaSE_Flag__c == sadFace){
                qliItem.TeliaSE_Flag__c = sadFace;
            }else if(otc < otfPrice  && otapprovedPrice > otc ){
                qliItem.MC_OT_Approved_Price__c = null;
                qliItem.TeliaSE_Flag__c = sadFace; 
            }else if(otc < otfPrice  && otapprovedPrice == null ){
                qliItem.TeliaSE_Flag__c = sadFace;  
                //flag = sadFace;
            }
        }        
        return qliItem;
    }
}