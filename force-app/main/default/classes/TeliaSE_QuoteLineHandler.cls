public class TeliaSE_QuoteLineHandler {
    /*-----------------------------------------------------------------------------------------------------------
**Name        :        updateApprovalFlag
**Created By  :        Vaishali Srivastava
**Sprint      :        Sprint-4
**User Story  :        MCSTO-566 MCSTO-567
**Description :        Approval Flag update for customer Requested % and customer Requested Price
-----------------------------------------------------------------------------------------------------------*/
    /*public static  void  updateApprovalFlag1(List<QuoteLineItem> qLI,Map<Id,QuoteLineItem> oldMap,Map<Id,QuoteLineItem> newMap){
        
        Double crp,floor,ceiling,approvedPrice,crper,floorPer;
        String happyFace = System.Label.TeliaSE_HappyFace;
        String sadFace = System.Label.TeliaSE_SadFace;
        
        list <QuoteLineItem> ListqliItem = new list <QuoteLineItem>();
        
        for(QuoteLineItem qliItem : qLI){
            
            //Run code only if we have changed value in requested price or requested %
            if((oldMap.get(qliItem.Id).TeliaSE_MC_Customer_Requested_Price__c != newMap.get(qliItem.Id).TeliaSE_MC_Customer_Requested_Price__c)|| 
               (oldMap.get(qliItem.Id).TeliaSE_MC_Customer_Requested_Percentage__c !=newMap.get(qliItem.Id).TeliaSE_MC_Customer_Requested_Percentage__c))
            {
              
                if(qliItem.TeliaSE_Ceiling_Price__c != null){//Null pointer check for Ceiling Price
                    if(qliItem.TeliaSE_MC_Customer_Requested_Price__c != null){ //Requested Price Logic
                    
                        //Floor price Logic 
                        If(qliItem.TeliaSE_Floor_Price__c!=null){
                            if((newMap.get(qliItem.Id).TeliaSE_Floor_Price__c == qliItem.vlocity_cmt__RecurringCharge__c))
                            {
                                floor = oldMap.get(qliItem.Id).TeliaSE_Floor_Price__c;
                            }else{
                                floor = qliItem.TeliaSE_Floor_Price__c;
                            }
                        }
                         //Flag Logic for requested Price
                        if((qliItem.TeliaSE_MC_Customer_Requested_Price__c!=null) && (floor!=null) && (qliItem.TeliaSE_MC_Customer_Requested_Price__c!= 0)){
                            if((qliItem.TeliaSE_MC_Customer_Requested_Price__c >= floor) && (qliItem.TeliaSE_MC_Customer_Requested_Price__c <= qliItem.TeliaSE_Ceiling_Price__c) && (qliItem.TeliaSE_Approved_Price__c == null) ){
                                qliItem.TeliaSE_Flag__c = happyFace; 
                            }
                            
                            else if(qliItem.TeliaSE_MC_Customer_Requested_Price__c  >= qliItem.TeliaSE_Approved_Price__c){
                                qliItem.TeliaSE_Flag__c = happyFace;
                            }
                            else if((qliItem.TeliaSE_MC_Customer_Requested_Price__c < floor)  && (qliItem.TeliaSE_Approved_Price__c > qliItem.TeliaSE_MC_Customer_Requested_Price__c) ){
                                qliItem.TeliaSE_Flag__c = sadFace;
                            }
                            else if((qliItem.TeliaSE_MC_Customer_Requested_Price__c < floor)  && (qliItem.TeliaSE_Approved_Price__c == null) ){
                                qliItem.TeliaSE_Flag__c = sadFace;
                            }
                            
                        }else if(qliItem.TeliaSE_MC_Customer_Requested_Price__c == 0){
                            qliItem.TeliaSE_Flag__c = sadFace;
                          }
                    }else if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c == null) && (qliItem.TeliaSE_MC_Customer_Requested_Price__c == null)){
                            qliItem.TeliaSE_Flag__c = happyFace;
                          }
                    
                    //Flag Logic for requested Percentage
                    if(qliItem.TeliaSE_MC_Customer_Requested_Percentage__c!=null){
                         crp = qliItem.TeliaSE_Ceiling_Price__c - ((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c * qliItem.TeliaSE_Ceiling_Price__c)/100);
                        //Floor % Logic
                        if(qliItem.TeliaSE_Floor_Percentage__c != null){
                            //floor= ceiling - ((qliItem.TeliaSE_Floor_Percentage__c * ceiling)/100);
                            floorPer = qliItem.TeliaSE_Floor_Percentage__c;
                        }
                        //Floor % Logic 
                        If(qliItem.TeliaSE_Floor_Percentage__c !=null){
                            if((newMap.get(qliItem.Id).TeliaSE_Floor_Price__c == qliItem.vlocity_cmt__RecurringCharge__c))
                            {
                                floorPer = oldMap.get(qliItem.Id).TeliaSE_Floor_Percentage__c ;
                            }else{
                                floorPer = qliItem.TeliaSE_Floor_Percentage__c ;
                            }
                        }
                        if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c!=null) && (floorPer!=null) && (qliItem.TeliaSE_MC_Customer_Requested_Percentage__c!= 0)){
                           
                            if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c <= floorPer) && (qliItem.TeliaSE_Approved__c == null) ){
                                qliItem.TeliaSE_Flag__c = happyFace; 
                            }
                            
                            else if(qliItem.TeliaSE_MC_Customer_Requested_Percentage__c  <= qliItem.TeliaSE_Approved__c){
                                qliItem.TeliaSE_Flag__c = happyFace;
                            }
                            else if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c > floorPer)  && (qliItem.TeliaSE_Approved__c < qliItem.TeliaSE_MC_Customer_Requested_Percentage__c) ){
                                qliItem.TeliaSE_Flag__c = sadFace;  
                            }
                            else if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c > floorPer)  && (qliItem.TeliaSE_Approved__c == null) ){
                                qliItem.TeliaSE_Flag__c = sadFace;   
                            }
                            
                        }
                        else if((qliItem.TeliaSE_MC_Customer_Requested_Percentage__c == 0)){
                            qliItem.TeliaSE_Flag__c = happyFace;
                        }
                    }else if((qliItem.TeliaSE_MC_Customer_Requested_Price__c == null ) && (qliItem.TeliaSE_MC_Customer_Requested_Percentage__c == null)){
                          qliItem.TeliaSE_Flag__c = happyFace;
                          }
                    
                }
            }
        }
    }          */
    
    /*public static  void  updateTargetPrice(List<QuoteLineItem> qLI){        
        for(QuoteLineItem qliItem : qLI){
            if( qliItem.vlocity_cmt__RecurringCharge__c != null && qliItem.TeliaSE_Discount_Percentage__c != null){
                qliItem.TeliaSE_Target_Price__c = qliItem.vlocity_cmt__RecurringCharge__c - ((qliItem.vlocity_cmt__RecurringCharge__c/100) * qliItem.TeliaSE_Discount_Percentage__c );
            
            }else if( qliItem.vlocity_cmt__RecurringCharge__c != null){
                qliItem.TeliaSE_Target_Price__c = qliItem.vlocity_cmt__RecurringCharge__c;
            }
        }
    }*/ //Commented in R23.6 as its not being called from anywhere.

//MCSTO-8202  Improvement: Clarify Approvals  
   /* public static void roamingFlagMethod (List<QuoteLineItem> qliList,Map<Id,QuoteLineItem> oldMap,Map<Id,QuoteLineItem> newMap){
        
        for (QuoteLineItem qli:qliList){           
            if(qli.TeliaSE_Product_Code__c != null && (qli.TeliaSE_Product_Code__c.contains('MOB_CALL_TRAVEL') || qli.TeliaSE_Product_Code__c.contains('MOB_SURF_') )){

                if(!qli.TeliaSE_Flag__c.contains('TeliaSE_Happy_Face')){
                    if(oldMap.get(qli.Id).RoamingTillAddOns__c!=newMap.get(qli.Id).RoamingTillAddOns__c || oldMap.get(qli.Id).RoamingResAddOns__c !=newMap.get(qli.Id).RoamingResAddOns__c || oldMap.get(qli.Id).TeliaSE_PriceTypeCategory__c!=newMap.get(qli.Id).TeliaSE_PriceTypeCategory__c){
                        qli.TeliaSE_Flag__c= newMap.get(qli.Id).TeliaSE_Flag__c;
                    } 
                    else{
                        qli.TeliaSE_Flag__c= oldMap.get(qli.Id).TeliaSE_Flag__c;
                    }
                    //System.debug('prodcode>>>>>>>>'+qli.TeliaSE_Product_Code__c+ qli.TeliaSE_Flag__c);
                }                
            }          
        }       
    }*/ //commented as it is not needed anymore, commented in trigger as well

    /*-----------------------------------------------------------------------------------------------------------
**Name        :        updateCeilingPrice
**Created By  :        Vaishali Srivastava
**Sprint      :        Sprint-4
**User Story  :        MCSTO-566 MCSTO-567
**Description :        Ceiling Price Update
-----------------------------------------------------------------------------------------------------------*/
   public static  void  updateCeilingPrice(List<QuoteLineItem> qLI){
    
    List<string> statusList = new  List<string>();
    statusList.add('Sent For Approval');
    //statusList.add('Sent to Customer');
    statusList.add('Customer Approved');
    
        for(QuoteLineItem qliItem : qLI){
            
            
            if (qliItem.TeliaSE_Ceiling_Price__c == null && qliItem.vlocity_cmt__RecurringCharge__c != null && (qliItem.TeliaSE_Quote_RecordType__c  != 'Individual_Quote' || qliItem.TeliaSE_Quote_RecordType__c  != 'TeliaSE_Fiber_FA_Quote' || qliItem.TeliaSE_Quote_RecordType__c  != 'TeliaSE_Fiber_CA_Quote_of_FA' || qliItem.TeliaSE_Quote_RecordType__c  != 'TeliaSE_Fiber_CA_Quote'))
            {
               
                qliItem.TeliaSE_Ceiling_Price__c = qliItem.vlocity_cmt__RecurringCharge__c;
            }
            else if((qliItem.TeliaSE_Quote_RecordType__c  == 'Individual_Quote' || qliItem.TeliaSE_Quote_RecordType__c  == 'TeliaSE_Fiber_FA_Quote' || qliItem.TeliaSE_Quote_RecordType__c  == 'TeliaSE_Fiber_CA_Quote_of_FA' || qliItem.TeliaSE_Quote_RecordType__c  == 'TeliaSE_Fiber_CA_Quote') && statusList.contains(qliItem.Quote_Status__c) && system.Label.FiberProductMigration == 'false')
            {
                
                qliItem.addError('Cart is not editable when quote status is '+qliItem.Quote_Status__c);
            }
            
        }
    }
    
/*-----------------------------------------------------------------------------------------------------------
**Name        :        updateFiberFAPrice
**Sprint      :        Sprint-4A
**User Story  :        FIBE-1117
**Description :        To update FA Price(Child agreement quote using the frame agreement prices)
-----------------------------------------------------------------------------------------------------------*/
    public static void updateFiberFAPrice(List<QuoteLineItem> qList)
    {
        try{
            //verify FIBER Quote - SEUtility.isRecordTypeAvailable
            String recType = qList != null ? qList[0].TeliaSE_Quote_RecordType__c : null;
            if(recType != null && qList != null && qList.size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.FIBER, SEUtility.QUOTE, recType)){
                
                Set<Id> quoteId = new Set<Id>();
                for(QuoteLineItem q : qList){
                    quoteId.add(q.quoteId);
                }
                Set<Id> contractIds = new  Set<Id>();
                List<Quote> FAQuotes = [SELECT vlocity_cmt__FrameContractId__c 
                                        FROM Quote 
                                        WHERE TeliaSE_Record_Type_Name__c = 'TeliaSE_Fiber_CA_Quote_of_FA' 
                                        AND Id in :quoteId];
                for(Quote q : FAQuotes){
                    contractIds.add(q.vlocity_cmt__FrameContractId__c);
                }
                List<Contract> contractList = [SELECT Id, vlocity_cmt__QuoteId__c FROM Contract WHERE Id IN :contractIds];
                Set<Id> parentFAQuoteId = new  Set<Id>();
                for(Contract con : contractList){
                    parentFAQuoteId.add(con.vlocity_cmt__QuoteId__c);
                }
                
                //parentQliMap is containing Quote and related QuoteLineItem for Parent FA Quotes
                Map<Id, List<QuoteLineItem>> parentQliMap = new  Map<Id, List<QuoteLineItem>>();
                List<QuoteLineItem> parentQliList = new  List<QuoteLineItem>();
                
                //Query to fill Parent FA Quote 
                parentQliList = [SELECT Id, TeliaSE_Root_Product__c, quoteId, TeliaSE_Product_Code__c,vlocity_cmt__OneTimeCharge__c,Fiber_Customer_Requested_Price__c, vlocity_cmt__RecurringCharge__c, TeliaSE_Fiber_Frame_Agreement__c 
                                 FROM QuoteLineItem 
                                 WHERE quoteId in :parentFAQuoteId];
                for(QuoteLineItem q : parentQliList){
                    List<QuoteLineItem> qItems = new List<QuoteLineItem>();
                    if(parentQliMap.get(q.quoteId) != null){
                        qItems = parentQliMap.get(q.quoteId);
                        qItems.add(q);
                        parentQliMap.put(q.quoteId, qItems);
                    }else{
                        qItems.add(q);
                        parentQliMap.put(q.quoteId, qItems);
                    }
                }
                List<String> productCodeList = new  List<String>();
                for(QuoteLineItem q : qList){
                    productCodeList.add(q.TeliaSE_Product_Code__c );
                }
                List<QuoteLineItem> qliToBeUpdated = new List<QuoteLineItem>();
                //This is for before insert, newly inserted quotelineitem values are not reflecting on trigger.new
                for(Id qliId : parentQliMap.keySet()){
                    for(QuoteLineItem qt : qList){
                        for(QuoteLineItem qliObj : parentQliMap.get(qliId)){
                            if((qt.TeliaSE_Root_Product__c != null && qt.TeliaSE_Product_Code__c != null && qt.QuoteId != null) && (qt.TeliaSE_Product_Code__c == qliObj.TeliaSE_Product_Code__c && qt.TeliaSE_Root_Product__c == qliObj.TeliaSE_Root_Product__c) && quoteId.contains(qt.QuoteId)){
                                
                                if(qliObj.Fiber_Customer_Requested_Price__c != null && qliObj.Fiber_Customer_Requested_Price__c >= 0){
                                    qt.TeliaSE_Fiber_Frame_Agreement__c = qliObj.Fiber_Customer_Requested_Price__c;
                                }else{
                                    qt.TeliaSE_Fiber_Frame_Agreement__c = qliObj.vlocity_cmt__RecurringCharge__c;
                                }
                                if(qliObj.vlocity_cmt__OneTimeCharge__c != null && qliObj.vlocity_cmt__OneTimeCharge__c >= 0){
                                    qt.vlocity_cmt__OneTimeCharge__c = qliObj.vlocity_cmt__OneTimeCharge__c;
                                    qt.vlocity_cmt__EffectiveOneTimeTotal__c = qt.Quantity * qliObj.vlocity_cmt__OneTimeCharge__c;
                                }
                            }
                        }
                    }
                }
            } 
        }
        catch(Exception e){
             System.debug('Exeception :' + e);
        }
    }
    
    public static  void  updateFiberTotalRecurringCharge(List<QuoteLineItem> qLI){
        string recType = qLI != null ? qLI[0].TeliaSE_Quote_RecordType__c : null;
        if(recType != null && qLI != null && qLI.size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.FIBER, SEUtility.QUOTE, recType)){
           
        Id quoteId;
        if(qLI.size() > 0 ){
            quoteId = qLI[0].QuoteId;
        }
        
        List<QuoteLineItem> qLines;
        if(quoteId != null){
                qLines = [SELECT id,quantity, Fiber_Customer_Requested_Price__c, TeliaSE_Fiber_Frame_Agreement__c, vlocity_cmt__RecurringCharge__c 
                          FROM QuoteLineItem 
                          WHERE QuoteId = :quoteId];
        }
        
        Decimal totalRecCharges = 0;
        
        if(qLines.size() == 0){
                List<Quote> quotes = [SELECT id, TeliaSE_Fiber_Total_Recurring_Charges__c, vlocity_cmt__EffectiveRecurringTotal__c 
                                      FROM Quote 
                                      WHERE id = :quoteId];
            quotes[0].TeliaSE_Fiber_Total_Recurring_Charges__c = 0;
            update quotes;
                
        }
            Boolean flag = true;
        for(QuoteLineItem qliItem : qLines){
            if (qliItem.Fiber_Customer_Requested_Price__c != null && qliItem.Fiber_Customer_Requested_Price__c>=0){
                totalRecCharges = totalRecCharges + ( qliItem.Fiber_Customer_Requested_Price__c * qliItem.Quantity );
                flag = false;               
            }else if(qliItem.TeliaSE_Fiber_Frame_Agreement__c != null && qliItem.TeliaSE_Fiber_Frame_Agreement__c>=0){
                totalRecCharges = totalRecCharges + ( qliItem.TeliaSE_Fiber_Frame_Agreement__c * qliItem.Quantity );
                flag = false;
            }else if(qliItem.vlocity_cmt__RecurringCharge__c  != null){
                flag = false;
                totalRecCharges = totalRecCharges + ( qliItem.vlocity_cmt__RecurringCharge__c * qliItem.Quantity );
            }
        }
        
            List<Quote> quotes = [SELECT id, TeliaSE_Fiber_Total_Recurring_Charges__c FROM Quote WHERE id = :quoteId];
        quotes[0].TeliaSE_Fiber_Total_Recurring_Charges__c = totalRecCharges;
        update quotes;
    }    
    }
    
    
    public static void updateRootItem(Map<Id,QuoteLineItem> newMap)
    {
        String recType = newMap != null ? newMap.values()[0].TeliaSE_Quote_RecordType__c : null;
        if(recType != null && newMap != null && newMap.values().size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.FIBER, SEUtility.QUOTE, recType))
        {
            updateRootItemForFiber(newMap.keySet());
        }else
        {   //MCSTO-6916
            if(recType != null && newMap != null && newMap.values().size() > 0 && recType != 'Offer')
            {
                updateRootItemForMc(newMap.keySet());
            }
        }
    }
    
    @future
    public static void updateRootItemForMc(Set<Id> Ids)
    {
        updateRootProductId(Ids);
    }
    @future
    public static void updateRootItemForFiber(Set<Id> Ids)
    {
        updateRootProductId(Ids);
    }
    
    //@future
    public static void updateRootProductId(Set<Id> ids)
    { 
        Id rootItemId;
        Boolean noRoot;
        String salesType;
        String salesTypeLineItem;
        Set<String> rootIds=new Set<String>();
        Map<String,Id> rootItemsMap=new Map<String,Id>();
        Map<String,String> salesTypeMap=new Map<String,String>();
        List<QuoteLineItem> updateItems=new List<QuoteLineItem>();
        List<QuoteLineItem> items = [SELECT id,TeliaSE_MC_Sales_Type__c, vlocity_cmt__RootItemId__c FROM QuoteLineItem WHERE id=:ids FOR UPDATE];
        List<QuoteLineItem> rootItems = [SELECT id, TeliaSE_MC_Sales_Type__c, vlocity_cmt__Product2Id__c,vlocity_cmt__RootItemId__c FROM QuoteLineItem WHERE id =:ids AND vlocity_cmt__ParentItemId__c= NULL ];
        if(rootItems.size()<1)
        {
            for(QuoteLineItem item:items)
            {
                rootIds.add(item.vlocity_cmt__RootItemId__c);
            }
            //23.10 <<LTAART-356>> AssetReferenceId change - <<Sanjoli>>
            List<QuoteLineItem> roots = [SELECT id, TeliaSE_MC_Sales_Type__c,vlocity_cmt__Product2Id__c,vlocity_cmt__RootItemId__c FROM QuoteLineItem WHERE vlocity_cmt__AssetReferenceId__c =:rootIds];
            for(QuoteLineItem rootItem:roots)
            {   
                salesType = rootItem.TeliaSE_MC_Sales_Type__c;
                rootItemsMap.put(rootItem.vlocity_cmt__RootItemId__c,rootItem.vlocity_cmt__Product2Id__c);
                if(salesType != null && salesType != '') salesTypeMap.put(rootItem.vlocity_cmt__RootItemId__c,salesType);
            }
            for(QuoteLineItem item:items)
            {
                salesTypeLineItem = salesTypeMap.get(item.vlocity_cmt__RootItemId__c);
                item.TeliaSE_Root_Product__c=rootItemsMap.get(item.vlocity_cmt__RootItemId__c);
                if(salesTypeLineItem != null && salesTypeLineItem != '') item.TeliaSE_MC_Sales_Type__c=salesTypeLineItem;
                updateItems.add(item);
            }
            
        }
        else
        {    
            for(QuoteLineItem rootItem:rootItems)
            {
                salesType = rootItem.TeliaSE_MC_Sales_Type__c;

                rootItemsMap.put(rootItem.vlocity_cmt__RootItemId__c,rootItem.vlocity_cmt__Product2Id__c);
                if(salesType != null && salesType != '') salesTypeMap.put(rootItem.vlocity_cmt__RootItemId__c,salesType);
                
            }
            for(QuoteLineItem item:items)
            {   
                salesTypeLineItem = salesTypeMap.get(item.vlocity_cmt__RootItemId__c);
                
                item.TeliaSE_Root_Product__c=rootItemsMap.get(item.vlocity_cmt__RootItemId__c);
                if(salesTypeLineItem != null && salesTypeLineItem != '') item.TeliaSE_MC_Sales_Type__c=salesTypeLineItem;

                updateItems.add(item);
            }
        }
        if(TeliaSE_checkRecursive.runOnce()){
            update updateItems;
        }
    }
    
    public static void updateDiscount(Map<Id,QuoteLineItem> olditems,Map<Id,QuoteLineItem> newitems)
    {
        for(QuoteLineItem item:newitems.values())
        {
            if(olditems.get(item.id).Fiber_Customer_Requested_Price__c != item.Fiber_Customer_Requested_Price__c)
            {
                    Decimal discount= (((item.TeliaSE_Ceiling_Price__c - item.Fiber_Customer_Requested_Price__c )/item.TeliaSE_Ceiling_Price__c)*100).setScale(2, RoundingMode.HALF_UP);
                    item.TeliaSE_fiber_Rabatt__c=discount;
                        item.TeliaSE_Flag__c=System.Label.TeliaSE_SadFace;
            }
        }
    }
    
    public static void updateApprover(Map<Id,QuoteLineItem> olditems,Map<Id,QuoteLineItem> newitems){
        string recType = newitems != null ? newitems.values()[0].TeliaSE_Quote_RecordType__c : null;
        if(recType != null && newitems != null && newitems.values().size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.MC, SEUtility.QUOTE, recType))
        {
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();
           //Commmenting the logics for roaming addons,and jobbsurf addons since now they are framwrok pricing enabled(By Abhishek)
           /* List<TeliaSE_Roaming_Mandate__mdt> roamingMandateList = [SELECT  ApproverName__c,AddOnPricePlan__c 
                                                                     FROM TeliaSE_Roaming_Mandate__mdt];

                Map<String,String> roamingMandateMap = new Map<String,String>();
                if(roamingMandateList.size() > 0){
                    for(TeliaSE_Roaming_Mandate__mdt roam:roamingMandateList){
                        roamingMandateMap.put(roam.AddOnPricePlan__c,roam.ApproverName__c);
                    }
                }*/
            
            for(QuoteLineItem item:newitems.values()){
               // Introduced new field 'MC_Product_Negotiability_PriceEnabled__c' here to fix the issue LTAT-11161.
               if(item.MC_Product_Negotiability_PriceEnabled__c !=true) {
                    QuoteLineItem qli = new QuoteLineItem();
                    qli.id = item.Id;
                    if(item.vlocity_cmt__ParentItemId__c == null && item.TeliaSE_Offer_Type__c != 'SimpleAgreementOffering'){        
                        String approver;
                        if((item.TeliaSE_Minimum_Value_Commit__c != null && MC_CommercialNegotiation__c.getAll().get('MinimumCommitment').Default_Value__c != null) && !item.TeliaSE_Minimum_Value_Commit__c.equalsIgnoreCase(MC_CommercialNegotiation__c.getAll().get('MinimumCommitment').Default_Value__c)){
                            approver = MC_CommercialNegotiation__c.getAll().get('MinimumCommitment').Approved_By__c;
                        }
                        if(item.TeliaSE_Product_Object_Type__c != 'Broadband Plus Offering Spec' && item.TeliaSE_Product_Object_Type__c != 'Broadband Start Offering Spec' && item.TeliaSE_Product_Object_Type__c != 'Broadband Datanet Offering Spec' && item.TeliaSE_Product_Object_Type__c != 'Broadband Pro Offering Spec' && item.TeliaSE_Product_Object_Type__c != 'WIFI/LAN Offering Spec' && item.TeliaSE_Product_Object_Type__c != 'SD-WAN/Firewall Offering Spec'){//Added this if condition so that approver name is not populated for CO offerings. This is added as part of defect MCSTO-8096
                            if(approver != '' && approver != null){
                                if(approver == 'CommercialManager') {
                                    qli.MC_Approver__c = 'Commercial Management';
                                }else if(approver == 'SalesDirector') {
                                    qli.MC_Approver__c = 'Säljdirektör';
                                }else if(approver == 'SalesManager') {
                                    qli.MC_Approver__c = 'Säljchef';
                                }else {
                                    qli.MC_Approver__c = 'Säljare';
                                }
                            }
                        }//End of if block for CO specific products
                    }//End of if block
                    
                   /* else if(item.TeliaSE_Product_Code__c!= null && item.TeliaSE_Product_Code__c.contains('MOB_CALL_TRAVEL')){
                        String addon;
                        String approver;
        
                        if(item.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_EUROPE' ||item.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_OTHER' || item.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_OVERSEAS'){
                            addon = item.RoamingTillAddOns__c;
                        }else if(item.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_EAST' ||item.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_SOUTH' || item.TeliaSE_Product_Code__c == 'MOB_CALL_TRAVEL_WEST'){
                   addon = item.RoamingResAddOns__c;
                        }
                        approver = roamingMandateMap.get(addon);
                        if(approver != '' && approver != null){
                            if(approver == 'CommercialManager') qli.MC_Approver__c = 'Commercial Management';
                          else if(approver == 'SalesDirector') qli.MC_Approver__c = 'Säljdirektör';
                          else if(approver == 'SalesManager') qli.MC_Approver__c = 'Säljchef';
                          else qli.MC_Approver__c = 'Säljare';
                        }else{
                            qli.MC_Approver__c = 'Säljare';
                        }
                        
                    }*/
                    else if(item.MC_RTC_Approver__c == item.MC_OT_Approver__c){
                        qli.MC_Approver__c = item.MC_RTC_Approver__c;
                    }else if(item.MC_OT_Approver__c == 'Commercial Management' && (item.MC_RTC_Approver__c == 'Säljdirektör' || item.MC_RTC_Approver__c == 'Säljchef' || item.MC_RTC_Approver__c == 'Säljare')){
                        qli.MC_Approver__c = 'Commercial Management';
                    }else if(item.MC_OT_Approver__c == 'Säljdirektör' && (item.MC_RTC_Approver__c == 'Säljchef' || item.MC_RTC_Approver__c == 'Säljare')){
                        qli.MC_Approver__c = 'Säljdirektör';
                    }else if(item.MC_OT_Approver__c == 'Säljchef' && item.MC_RTC_Approver__c == 'Säljare'){
                        qli.MC_Approver__c = 'Säljchef';
                    }else if(item.MC_RTC_Approver__c == 'Commercial Management' && (item.MC_OT_Approver__c == 'Säljdirektör' || item.MC_OT_Approver__c == 'Säljchef' || item.MC_OT_Approver__c == 'Säljare')){
                        qli.MC_Approver__c = 'Commercial Management';
                    }else if(item.MC_RTC_Approver__c == 'Säljdirektör' && (item.MC_OT_Approver__c == 'Säljchef' || item.MC_OT_Approver__c == 'Säljare')){
                        qli.MC_Approver__c = 'Säljdirektör';
                    }else if(item.MC_RTC_Approver__c == 'Säljchef' && item.MC_OT_Approver__c == 'Säljare'){
                        qli.MC_Approver__c = 'Säljchef';
                    }else{
                        qli.MC_Approver__c = 'Säljare';
                    }
                    if(item.TeliaSE_MC_Campaign_Id__c != null && (item.TeliaSE_Product_Object_Type__c != 'Broadband Plus Offering Spec' && item.TeliaSE_Product_Object_Type__c != 'Broadband Start Offering Spec' && item.TeliaSE_Product_Object_Type__c != 'Broadband Datanet Offering Spec' && item.TeliaSE_Product_Object_Type__c != 'Broadband Pro Offering Spec')){
                        if(qli.MC_Approver__c == null || qli.MC_Approver__c == 'Säljare'){
                            qli.MC_Approver__c = 'Säljchef';
                        }
                    }
                    qliList.add(qli);
                }
                }
                update qliList;
        }
    }
    
    // Added new method for Defect MCSTO-5091
    public static void checkCT(Map<Id,QuoteLineItem> olditems,Map<Id,QuoteLineItem> newitems)
    {
        String recType = newitems != null ? newitems.values()[0].TeliaSE_Quote_RecordType__c : null;
        if(recType != null && newitems != null && newitems.values().size() > 0 && SEUtility.isRecordTypeAvailable(SEUtility.MC, SEUtility.QUOTE, recType))
        {
            Set<Id> quoteIdset = new Set<Id>(); 
            for(QuoteLineItem item:newitems.values())
            {
                //if(olditems.get(item.id).TeliaSE_MC_Campaign_Id__c != item.TeliaSE_MC_Campaign_Id__c && olditems.get(item.id).TeliaSE_MC_Campaign_Id__c != null && item.Quote_Status__c == 'Approved')
                if(olditems.get(item.id).TeliaSE_Minimum_Value_Commit__c != item.TeliaSE_Minimum_Value_Commit__c && olditems.get(item.id).TeliaSE_Minimum_Value_Commit__c != null && item.TeliaSE_Minimum_Value_Commit__c != '75' && item.Quote_Status__c == 'Approved')   
                {              
                    quoteIdset.add(item.QuoteId);   
                    
                }
                if(olditems.get(item.id).TeliaSE_MC_Campaign_Id__c != item.TeliaSE_MC_Campaign_Id__c && item.Quote_Status__c == 'Approved'){
                    quoteIdset.add(item.QuoteId);
                }
            }
            List<Quote> quoteToUpdate = new List<Quote>();
            list<Quote> quoteList = [Select id ,Status from Quote where id in: quoteIdset];
            if(quoteList.size()>0){
                for(Quote q : quoteList)
                {
                    q.Status = 'Draft';
                    quoteToUpdate.add(q);
                }
            }
            update quoteToUpdate;
        }
    }
    
    public static void updatePTAttribute(Map<Id,QuoteLineItem> newMap)
    {   
        QuotelineItem qli1 = new QUotelineItem();
        for(Id quotelineItemId : newMap.keySet())
        {
            qli1 = newmap.get(quotelineItemId);
        }
        if(newMap.values().size() > 0 && qli1.TeliaSE_Product_Code__c =='PT_PLUS')
        {
            HidePTPlusAttributes(newMap.keySet());
        }
    }
    
/* 
 * Adding this code to hide the Attributes of PT Plus Product in Offer Quote Cart
 */ 
    public static void HidePTPlusAttributes(Set<Id> Ids){        
        try{
            QuoteLineItem  ptList = [SELECT Id,vlocity_cmt__JSONAttribute__c 
                                     FROM QuoteLineItem 
                                     WHERE Quote.RecordType.DeveloperName = 'Offer' 
                                     AND Id =: Ids];
            if(ptList != null){
                Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(ptList.vlocity_cmt__JSONAttribute__c); 
                List<Object> o1 = (List<Object>)rawObj.get('ATT_CODE_TELIAMOBAGGR');
                List<Object> o3 = new List<Object>();
                Map<String,Object> lsstr = new Map<String,Object>();
                Boolean attributeStatus;
                Boolean flag = false;
                for(Object o2: o1)
                {
                    
                    lsstr = (Map<String,Object>)o2;
                    attributeStatus = (Boolean) lsstr.get('ishidden__c');
                    if(attributeStatus == false)
                    {
                        lsstr.put('ishidden__c',true);
                        flag=true;
                    } 
                    o3.add(lsstr);
                }
                if(flag == true)
                {
                    Map<String,Object> newMap = new Map<String,Object>();
                    newMap.put('ATT_CODE_TELIAMOBAGGR',o3);
                    String jsonMap=JSON.serialize(newMap);
                    ptList.vlocity_cmt__JSONAttribute__c = jsonMap;
                    update ptList;
                }
            }
        }
        catch (Exception e)
        {
        }
        
    } 
    
/**
 * Delete Adjustments
 * 
 */     
    public static void deleteAdjustments(List<QuoteLineItem> newQLI,List<QuoteLineItem> oldQLI){

        List<String> qpaIds = new List<String>();

        String quoteId;
        for(QuoteLineItem qli1 : newQLI){
            quoteId = qli1.QuoteId;
            for(QuoteLineItem qli2 : oldQLI){
                
                //for(vlocity_cmt__QuotePricingAdjustment__c quoteIt : quoteitm){
                if(qli1.Id == qli2.Id && (qli1.TeliaSE_Product_Object_Type__c == 'Touch Point Offer Spec') && String.isEmpty(qli1.vlocity_cmt__ParentItemId__c)){
                    if((qli1.TeliaSE_Base_Quantity__c != qli2.TeliaSE_Base_Quantity__c)||(qli1.TeliaSE_CommitmentPeriod__c != qli2.TeliaSE_CommitmentPeriod__c)){
                        qpaIds.add(qli1.vlocity_cmt__AssetReferenceId__c);
                        //delete [Select Id from vlocity_cmt__QuotePricingAdjustment__c where vlocity_cmt__QuoteId__c =:qli1.QuoteId and (vlocity_cmt__QuoteItemId__r.TeliaSE_Product_Object_Type__c  = 'Touch Point Offer Spec')]; 
                    }
                }
                else if(qli1.Id == qli2.Id && (qli1.TeliaSE_Product_Object_Type__c == 'ICT Offer Specification')){
                    if((qli1.TeliaSE_Base_Quantity__c != qli2.TeliaSE_Base_Quantity__c)||(qli1.TeliaSE_CommitmentPeriod__c != qli2.TeliaSE_CommitmentPeriod__c)){
                        //delete [Select Id from vlocity_cmt__QuotePricingAdjustment__c where vlocity_cmt__QuoteId__c =:qli1.QuoteId and (vlocity_cmt__QuoteItemId__r.TeliaSE_Product_Object_Type__c  = 'ICT Offer Specification' and vlocity_cmt__QuoteItemId__c =: qli1.Id)]; 
                        qpaIds.add(qli1.vlocity_cmt__AssetReferenceId__c);                    
                    }
                }
            }
        }
        
        if(qpaIds!= null && qpaIds.size()>0)
        {
            delete [SELECT Id FROM vlocity_cmt__QuotePricingAdjustment__c WHERE vlocity_cmt__QuoteId__c =:quoteId AND vlocity_cmt__QuoteItemId__r.vlocity_cmt__RootItemId__c IN: qpaIds];
        }
    }
}