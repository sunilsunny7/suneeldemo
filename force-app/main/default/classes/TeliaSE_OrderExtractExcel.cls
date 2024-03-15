/**
* @Author:      Rahul Kadam
* @Company:     Capgemini
* @Date:        6th Aug 2021
* @Description: TeliaSE_OrderExtractExcel class creates the actual order extract excel and is invoked from IP TeliaSE_MC_OrderExtract.
* @Epic:        MCSTO-6925 CO: Order Capture Data Extract
* History
* Modified  =    created new section(SLA C4 Available Address) to display SLA C4 Adress to Order extract file (LTAT-11938):- Lokesh
* Modified  =    Quantity is replaced by vlocity_cmt__EffectiveQuantity__c to diplay correct qunatity value in order extract file- [LTAT- 13360]:Lokesh 
<Date>         <Authors Name>      <Brief Description of Change>
* -------------------------------------------------------------------
*/
global class TeliaSE_OrderExtractExcel implements vlocity_cmt.VlocityOpenInterface{
    Public static Boolean isExistSLAC4= false;
    public static Id accountId ;
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output,Map<String, Object> options){
        Boolean result = true;
        
        try {
            if(methodName.equalsIgnoreCase('excelConvert')) {
                excelConvert(input, output);
            }else {
                result = false;
            }  
        }catch(Exception e) {  
            result = false;
        }        
        return result;
    }
    public static void excelConvert(Map<String, Object> input, Map<String, Object> output) {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm(); //fetch url of org
        string excelXML = prepareHeaderAndStyles(); // prepare style and initialize xml string
        String fileName = system.label.TeliaSE_COOrderExtractFileName;
        
        id faQuoteId = id.valueof((string)input.get('FAquoteId'));
        id contractId = id.valueof((string)input.get('contractId'));
        
        //Fetch account info from input
        string accountName = (string)input.get('accountName');
        string accountOrgNumber = (string)input.get('accountOrgNumber');
        string ownerName = (string)input.get('ownerName');
        string contractNumber = (string)input.get('contractNumber');
        string AgreementEndDate = (string)input.get('AgreementEndDate');
        string AgreementStartDate = (string)input.get('AgreementStartDate');
        list<string> inputAccountInfo = new list<string>{accountName, accountOrgNumber, ownerName, contractNumber, AgreementStartDate, AgreementEndDate };
            
        list<Quote> getQuoteId = [Select Id,OwnerId, accountid  FROM Quote WHERE (vlocity_cmt__ParentQuoteId__c =: faQuoteId AND TeliaSE_Record_Type_Name__c = 'Offer') ORDER BY CreatedDate DESC LIMIT 1];
        accountId = id.valueof((string)getQuoteId[0].get('accountid'));
        id quoteId = id.valueof((string)getQuoteId[0].get('Id'));
        id accountManagerId = id.valueOf((String)getQuoteId[0].get('OwnerId'));
        
        Date myDate = Date.today();
        fileName += '_'+myDate;
        String docTitle=fileName+'.xls';
        
        excelXML += excelFormatter(quoteId, contractId, accountManagerId, inputAccountInfo); 
        
        String refinedString = excelXML.replace('null', ''); // replaces null with space
        
        //Insert ContentVersion Document version
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = docTitle;
        cVersion.Origin = 'H'; //C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();
        cVersion.Title = docTitle;
        cVersion.VersionData = Blob.valueof(refinedString); //File content
        try{
            Insert cVersion;
        }
        catch(Exception e){
            //System.debug('The following exception has occurred when inserting cVersion: ' + e.getMessage());
        }
        
        String downloadLink = baseUrl + '/sfc/servlet.shepherd/version/download/' + cVersion.Id;
        output.put('downloadLink',downloadLink);
    }
    public static String excelFormatter(Id quoteId, Id contractId, Id ownerId,list<string> inputAccountInfo){
        string s = '<ss:Worksheet ss:Name="OrderExtract">';
        s += '<ss:Table ss:StyleID="st2"  x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth = "130"><ss:Column ss:Width="300"/><ss:Column ss:Width="150"/><ss:Column ss:Width="150"/>';
        //Invoke here grouping function
        List<QuoteLineItem> nonGroupingHeraProduct=[SELECT vlocity_cmt__QuoteGroupId__r.Name,vlocity_cmt__QuoteGroupId__r.vlocity_cmt__Description__c FROM QuoteLineItem  where (QuoteId =: quoteId AND vlocity_cmt__QuoteGroupId__r.Name != null)];
        set<String> sortingGroupSet= new set<String>();
        map<String, String> sortingGroupMap = new map<String, String>();
        
        AggregateResult[] distinctGroups = [SELECT vlocity_cmt__QuoteGroupId__r.Name groupName FROM QuoteLineItem  where (QuoteId =: quoteId AND vlocity_cmt__QuoteGroupId__r.Name != null) GROUP BY vlocity_cmt__QuoteGroupId__r.Name];
        for(QuoteLineitem qliObj : nonGroupingHeraProduct){
            sortingGroupSet.add(qliObj.vlocity_cmt__QuoteGroupId__r.vlocity_cmt__Description__c);
            sortingGroupMap.put(qliObj.vlocity_cmt__QuoteGroupId__r.vlocity_cmt__Description__c,qliObj.vlocity_cmt__QuoteGroupId__r.name);
        }
        List<QuoteLineItem> allQuoteLineItems = [Select Product2.Name, product2.productcode,vlocity_cmt__Product2Id__c,TeliaSE_Product_Object_Type__c,vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,vlocity_cmt__EffectiveQuantity__c,Quantity,TeliaSE_MC_Binding_Time__c, vlocity_cmt__QuoteGroupId__c,vlocity_cmt__QuoteGroupId__r.Name, TeliaSE_Type__c, vlocity_cmt__ParentItemId__c, id FROM QuoteLineItem where ((QuoteId =: quoteId ) AND ( TeliaSE_Product_Object_Type__c = 'Broadband Start Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Pro Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Plus Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Datanet Offering Spec' OR TeliaSE_Product_Object_Type__c = 'SD-WAN/Firewall Offering Spec' OR TeliaSE_Product_Object_Type__c = 'WIFI/LAN Offering Spec'  OR TeliaSE_Product_Object_Type__c = 'Connected Office Offer Spec'))];
        set<Id> proname = new set<Id>();
        for(QuoteLineItem ql :allQuoteLineItems){
            if(ql.vlocity_cmt__ParentItemId__c == null){
                proname.add(ql.vlocity_cmt__Product2Id__c);
            }
        }
        //List<QuoteLineItem> allQuoteLineItems = [Select Product2.Name,vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,Quantity,TeliaSE_MC_Binding_Time__c, vlocity_cmt__QuoteGroupId__c,vlocity_cmt__QuoteGroupId__r.Name, TeliaSE_Type__c, vlocity_cmt__ParentItemId__c, id FROM QuoteLineItem where ((QuoteId =: quoteId ) AND ( TeliaSE_Product_Object_Type__c = 'Broadband Start Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Pro Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Plus Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Datanet Offering Spec' OR TeliaSE_Product_Object_Type__c = 'SD-WAN/Firewall Offering Spec' OR TeliaSE_Product_Object_Type__c = 'WIFI/LAN Offering Spec'  OR TeliaSE_Product_Object_Type__c = 'Connected Office Offer Spec')) order by vlocity_cmt__ProductHierarchyPath__c];
        //Add new code 
        AggregateResult[] distinctRoots = [Select vlocity_cmt__ParentItemId__c Roots FROM QuoteLineItem where QuoteId =: quoteId AND MC_TeliaExcludeQuoteItem__c = false AND (vlocity_cmt__ParentItemId__c != null OR vlocity_cmt__ParentItemId__c  != '') GROUP BY vlocity_cmt__ParentItemId__c ];
        //set<id> rootItemId = new set<id>();
        set<String> rootItemId = new set<String>();
        for(integer i = 0; i < distinctRoots.size(); i++){
            //id getvalue = (id)distinctRoots[i].get('Roots');
            String getvalue = (String)distinctRoots[i].get('Roots');
            rootItemId.add(getvalue);
        }
        List<QuoteLineItem> rootQuoteLineItems = [Select Product2.Name,TeliaSE_Product_Object_Type__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__OneTimeCharge__c,Quantity,TeliaSE_MC_Binding_Time__c, vlocity_cmt__QuoteGroupId__c,vlocity_cmt__QuoteGroupId__r.Name, TeliaSE_Type__c, vlocity_cmt__ParentItemId__c, id FROM QuoteLineItem where QuoteId =: quoteId AND vlocity_cmt__AssetReferenceId__c IN : rootItemId  AND ( TeliaSE_Product_Object_Type__c = 'Broadband Start Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Pro Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Plus Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Datanet Offering Spec' OR TeliaSE_Product_Object_Type__c = 'SD-WAN/Firewall Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Connected Office Offer Spec' OR TeliaSE_Product_Object_Type__c = 'WIFI/LAN Offering Spec') order by vlocity_cmt__ProductHierarchyPath__c];
        //End of new code
        //List<QuoteLineItem> rootQuoteLineItems = [Select Product2.Name,vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,Quantity, vlocity_cmt__QuoteGroupId__c,vlocity_cmt__QuoteGroupId__r.Name, TeliaSE_Type__c, vlocity_cmt__ParentItemId__c, id FROM QuoteLineItem where ((QuoteId =: quoteId AND TeliaSE_Type__c = 'Offer' ) AND ( TeliaSE_Product_Object_Type__c = 'Broadband Start Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Pro Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Plus Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Datanet Offering Spec' OR TeliaSE_Product_Object_Type__c = 'SD-WAN/Firewall Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Connected Office Offer Spec' OR TeliaSE_Product_Object_Type__c = 'WIFI/LAN Offering Spec'))];
        List<QuoteLineItem> standaloneQuoteLineItem = [Select Product2.Name,vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,Quantity,vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__QuoteGroupId__c,vlocity_cmt__QuoteGroupId__r.Name,vlocity_cmt__ParentItemId__c, id, vlocity_cmt__Product2Id__c FROM QuoteLineItem where QuoteId =: quoteId AND  MC_TeliaExcludeQuoteItem__c = false AND vlocity_cmt__AssetReferenceId__c NOT IN : rootItemId  AND ( TeliaSE_Product_Object_Type__c = 'Broadband Start Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Pro Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Plus Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Datanet Offering Spec' OR TeliaSE_Product_Object_Type__c = 'SD-WAN/Firewall Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Connected Office Offer Spec' OR TeliaSE_Product_Object_Type__c = 'WIFI/LAN Offering Spec') AND (vlocity_cmt__ParentItemId__c = null OR vlocity_cmt__ParentItemId__c = '')AND Product2.Name != 'Hera XYZ' AND  TeliaSE_Offer_Type__c!='Non-SubscriptionOffering'];
        set<id> standaloneLineItemsset = new set<id>();
        for(integer i = 0; i < standaloneQuoteLineItem.size(); i++){
            id getvalue = (id)standaloneQuoteLineItem[i].get('vlocity_cmt__Product2Id__c');
            standaloneLineItemsset.add(getvalue);
        }
        string groupName = '';
        boolean groupFlag = false;
        boolean isGroupExist=false;
        if(nonGroupingHeraProduct.size()>0){
            for(QuoteLineItem qli:nonGroupingHeraProduct){
                if(qli.vlocity_cmt__QuoteGroupId__r.vlocity_cmt__Description__c!='NO_GROUP'){
                    isGroupExist=true;
                    break;
                }
                
            }
        }
        if( distinctGroups.Size() > 0 && isGroupExist==true){
            list<String> lstStr= new list<String>();
            lstStr.addAll(sortingGroupSet);          
            List<String> sortedString =orderExtractGroupSorting(lstStr);
            for(Integer i = 0; i < sortedString.Size(); i++){                
                groupName = sortingGroupMap.get(sortedString[i]);             
                s = groupQuoteLineItems(proname,quoteId, groupName, s, allQuoteLineItems,rootItemId,standaloneLineItemsset, contractId);
                groupFlag = true;
            }
        }
        else{
            //This logic is for un grouped line items
            s = nogroupQuoteLineItems(proname,quoteId, s, allQuoteLineItems, rootQuoteLineItems,rootItemId, standaloneLineItemsset,contractId);
        }  
        
        //Adding code for Account Information
        s = accountInformation(inputAccountInfo, ownerId,s);
        s += '</ss:Table>';
        s += '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">';
        s += '<Selected/>';
        //s += '<DoNotDisplayGridlines/>';
        s += '<ProtectObjects>False</ProtectObjects>';
        s += '<ProtectScenarios>False</ProtectScenarios>';
        s += '</WorksheetOptions>';
        s += '</ss:Worksheet>';
        s += addressTab( groupFlag, quoteId);
        s += '</ss:Workbook>';
        return s;
    }
    public static String groupQuoteLineItems(set<Id>proname,Id quoteId, String groupName, String s, List<QuoteLineItem> allQuoteLineItems, set<String> rootItemId,set<id> standaloneLineItemsset, Id ContractId){
         s += '<ss:Row>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+groupName+'</ss:Data></ss:Cell>';
        List<vlocity_cmt__QuoteMember__c> OffQLIAddr = [SELECT vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c, vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c,vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__ServicePointId__r.vlocity_cmt__ServicePointNumber__c FROM vlocity_cmt__QuoteMember__c where vlocity_cmt__QuoteGroupId__c  IN (Select vlocity_cmt__QuoteGroupId__c FROM QuoteLineItem where QuoteId =: quoteId AND vlocity_cmt__QuoteGroupId__r.Name =: groupName)];
        //Write here code to populate all the addresses
        String indexFlag = 'N';
        string addressConcatenation = '';
        for(vlocity_cmt__QuoteMember__c iqLI:OffQLIAddr){   
            String lat, lon, streetNr, city;
            lat = !String.ISBLANK(iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c)? 'Lat: '+iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c: '';
            lon = !String.ISBLANK(iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c)?', Long: '+ iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c: '';
            streetNr = !String.ISBLANK(iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c) ?' '+ iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c: '';
            city = !String.ISBLANK(iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c)?', '+ iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c: '';
      if( indexFlag == 'N'){
                    s += addColorToCell(4);
                    s += '<ss:Cell ss:Index="6" ss:StyleID="st1"><ss:Data ss:Type="String">'+iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c+streetNr+city+ ' '+lat+lon+'</ss:Data></ss:Cell>';
                    indexFlag = 'Y';
                }
                else
                    s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String">'+iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c+streetNr+city+ ' '+lat+lon+ '</ss:Data></ss:Cell>';
 
        }
        s += '</ss:Row>';
        //End of address code       
        //Below code will add Header
        set<String> headers = new set<String>{'Produkter','Engångsavgift','Månadsavgift','Antal', 'Binding Time'};
            Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Produkter','Product2.Name');
        headerMap.put('Engångsavgift','vlocity_cmt__OneTimeCharge__c');
        headerMap.put('Månadsavgift','vlocity_cmt__RecurringCharge__c');
        headerMap.put('Antal','Quantity');
        headerMap.put('Binding Time','Binding Time');
        //Below code prints header
        s += '<ss:Row>';
        for(String head:headers){
            s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+head+'</ss:Data></ss:Cell>';
        }
        s += addColorToCell(OffQLIAddr.size());
        s += '</ss:Row>';
        //boolean callfromRootLineItems = false;
        List<QuoteLineItem> rootQuoteLineItems1 = [Select vlocity_cmt__AssetReferenceId__c,Product2.Name,vlocity_cmt__EffectiveQuantity__c,TeliaSE_Product_Object_Type__c,vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,Quantity,TeliaSE_MC_Binding_Time__c, vlocity_cmt__QuoteGroupId__c,vlocity_cmt__QuoteGroupId__r.Name, TeliaSE_Type__c, vlocity_cmt__ParentItemId__c, id FROM QuoteLineItem where QuoteId =: quoteId AND vlocity_cmt__AssetReferenceId__c IN : rootItemId AND vlocity_cmt__QuoteGroupId__r.Name=:groupName AND ( TeliaSE_Product_Object_Type__c = 'Broadband Start Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Pro Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Plus Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Datanet Offering Spec' OR TeliaSE_Product_Object_Type__c = 'SD-WAN/Firewall Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Connected Office Offer Spec' OR TeliaSE_Product_Object_Type__c = 'WIFI/LAN Offering Spec') order by vlocity_cmt__ProductHierarchyPath__c];
        s += prepareXmlForStandalone(proname,groupName, standaloneLineItemsset, quoteId,rootQuoteLineItems1,allQuoteLineItems, contractId);
        return s;
    }
    public static String nogroupQuoteLineItems(set<Id>proname,Id quoteId, String s, List<QuoteLineItem> allQuoteLineItems, List<QuoteLineItem> rootQuoteLineItems,set<String> rootItemId,set<id> standaloneLineItemsset, Id contractId){
        s += '<ss:Row>';
        QuoteLineItem getServiceAccountId = [select vlocity_cmt__ServiceAccountId__c from QuoteLineItem where QuoteId=: quoteid Order by createddate desc limit 1];                                            
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >Adresser</ss:Data></ss:Cell>';
        List<vlocity_cmt__ServicePoint__c> OffQLIAddr = [SELECT vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c, vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c  FROM vlocity_cmt__ServicePoint__c WHERE vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =:getServiceAccountId.vlocity_cmt__ServiceAccountId__c ];
        //Write here code to populate all the addresses
        String indexFlag = 'N';
        string addressConcatenation = '';
        
        for(vlocity_cmt__ServicePoint__c iqLI:OffQLIAddr){          
            String lat, lon, streetNr, city;
            lat = !String.ISBLANK(iqLI.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c)? 'Lat: '+iqLI.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c: '';
            lon = !String.ISBLANK(iqLI.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c)?', Long: '+ iqLI.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c: '';
            streetNr = !String.ISBLANK(iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c) ?' '+ iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c: '';
            city = !String.ISBLANK(iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c)?', '+ iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c: '';
                if( indexFlag == 'N'){
                    s += addColorToCell(4);
                    s += '<ss:Cell ss:Index="6" ss:StyleID="st1"><ss:Data ss:Type="String">'+iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c+streetNr+city+ +' '+lat+lon+'</ss:Data></ss:Cell>';
                    indexFlag = 'Y';
                }
                else
                    s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String">'+iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c+streetNr+city+ ' '+lat+lon+ '</ss:Data></ss:Cell>';
                
            } //End of for loop
        s += '</ss:Row>';
        
        //Below code will add Header
        set<String> headers = new set<String>{'Produkter','Engångsavgift','Månadsavgift','Antal', 'Binding Time'};
            Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Produkter','Product2.Name');
        headerMap.put('Engångsavgift','vlocity_cmt__OneTimeCharge__c');
        headerMap.put('Månadsavgift','vlocity_cmt__RecurringCharge__c');
        headerMap.put('Antal','Quantity');
        headerMap.put('Binding Time','Binding Time');
        
        s += '<ss:Row>';
        // header row START ==================>
        for(String head:headers){
            s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+head+'</ss:Data></ss:Cell>';
        }
        s += '</ss:Row>';
        s += prepareXmlForStandalone(proname,'NA', standaloneLineItemsset, quoteId,rootQuoteLineItems,allQuoteLineItems, contractId);
        return s;
    }
    public static String accountInformation(list<string> inputAccountInfo, Id ownerId, String s){
        
        List<String> accHeaderInfo = new List<String>{'Account Name','Organisation number','Agreement signer (Avtalstecknare)','FA Contract(RAMAVTAL)', 'Contract agreement start time', 'Contract agreement end time'};
            
        s += '<ss:Row></ss:Row>';
        s += '<ss:Row>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String">Account Info</ss:Data></ss:Cell>';
        s += addColorToCell(10);
        s += '</ss:Row>';
        for(integer i = 0; i < accHeaderInfo.size(); i++){
            s += '<ss:Row>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +accHeaderInfo[i]+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +inputAccountInfo[i]+ '</ss:Data></ss:Cell>';
            s += '</ss:Row>';
        }
        
        s += '<ss:Row>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String">Account Manager</ss:Data></ss:Cell>';
        s += addColorToCell(10);
        s += '</ss:Row>';
        List<String> accManagerInfo = new List<String>{'Name','TeliaId','Email','Mobile'};
            List<User> accManager = [SELECT Name, Telia_Id__c, Email, MobilePhone FROM User WHERE Id =: ownerId ];
        String[] arrAccManager = new List<String>();
        for( User j:accManager) {
            arrAccManager.add(j.Name);
            arrAccManager.add(j.Telia_Id__c);
            arrAccManager.add(j.Email);
            arrAccManager.add(j.MobilePhone);
        }
        for(integer j = 0; j < accManagerInfo.size(); j++){
            s += '<ss:Row>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +accManagerInfo[j]+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +arrAccManager[j]+ '</ss:Data></ss:Cell>';
            s += '</ss:Row>';
        }
        //created new section(SLA C4 Available Address) to display SLA C4 Adress to Order extract file (LTAT-11938)
        if(isExistSLAC4){     
            s += '<ss:Row>';
            s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String">SLA C4 Tillgänglig Address</ss:Data></ss:Cell>';
            s += addColorToCell(10);
            s += '</ss:Row>';         
            List<vlocity_cmt__ServicePoint__c> lstServcePointSLA = [SELECT MC_IS_SLA_C4_Available__c , vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__PremisesId__r.vlocity_cmt__UnitNumber__c,vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                                                                    vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c, vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c
                                                                    FROM vlocity_cmt__ServicePoint__c WHERE vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =:accountId and MC_IS_SLA_C4_Available__c= true];
            for(vlocity_cmt__ServicePoint__c iqLI:lstServcePointSLA){
                s += '<ss:Row>';                
                //String checkStreetNumber = '';
                String lat, lon, streetNr, city, postalCode;
                lat = !String.ISBLANK(iqLI.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c)? 'Lat: '+iqLI.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c: '';
                lon = !String.ISBLANK(iqLI.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c)?', Long: '+ iqLI.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c: '';
                streetNr = !String.ISBLANK(iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c) ?','+ iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c: '';
                city = !String.ISBLANK(iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c)?' '+ iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c: '';
                postalCode = !String.ISBLANK(iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c)?' '+ iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c: '';
                String fullAddressSlaC4 = iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c+streetNr+city+' '+postalCode+lat+lon;
                s += '<ss:Cell><ss:Data ss:Type="String">' + fullAddressSlaC4 + '</ss:Data></ss:Cell>';                                 
                s += '</ss:Row>';               
            }
         
        }
        
        return s;
    }
    public static string prepareHeaderAndStyles() {
        string s = '<?xml version="1.0" encoding="UTF-8"?>';
        s += '<?mso-application progid="Excel.Sheet"?>';
        s += '<ss:Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"'; //+ '\n';
        s += ' xmlns:o="urn:schemas-microsoft-com:office:office"'; // + '\n';
        s += ' xmlns:x="urn:schemas-microsoft-com:office:excel"'; //+ '\n';
        s += ' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"'; //+ '\n';
        s += ' xmlns:html="http://www.w3.org/TR/REC-html40">';
        s += '<ss:Styles>';
        s += '<ss:Style ss:ID="st1" ss:Name="Normal">';
        s += '<ss:Font ss:Bold="1"/>';
        s += '<ss:Alignment  ss:Horizontal="Left"  ss:Vertical="Center"/>';
        s += '<ss:Interior ss:Color="#C7C7C1" ss:Pattern="Solid"/>';
        s += '</ss:Style>';
        s += '<ss:Style ss:ID="st2">';
        s += '<ss:Alignment ss:WrapText="1" ss:Horizontal="Left"  ss:Vertical="Center"/>';
        s += '</ss:Style>';
        s += '<ss:Style ss:ID="st3">';
        s += '<ss:Alignment ss:Horizontal="Left"  ss:Vertical="Center"/>';
        s += '</ss:Style>';
        s += '<ss:Style ss:ID="st4">';
        s += '<ss:Font ss:Size="14"  ss:Bold="1"/>';
        s += '<ss:Alignment ss:Horizontal="Left"  ss:Vertical="Center"/>';
        s += '</ss:Style>';
        s += '</ss:Styles>';
        return s;
    }
    public static string addColorToCell(integer addToCells){//Is invoked within row tag
        string cellTags = '';
        for(integer i = 0; i < addToCells; i++){
            if( cellTags == '' || cellTags == null){
                cellTags = '<ss:Cell ss:StyleID="st1"></ss:Cell>';
            }
            else{
                cellTags += '<ss:Cell ss:StyleID="st1"></ss:Cell>';
            }
        }
        return(cellTags);
    }
    public static string prepareXmlForStandalone(set<Id>proname,string grpName, set<id> standaloneLineItemsset, Id quoteId,List<QuoteLineItem> rootQuoteLineItems,List<QuoteLineItem> allQuoteLineItemsprev, Id contractId){//Is invoked within row tag
        Id heraProductGroupId = null;
        set<id> heraProdGroupId = new set<id>();
        map<Id, QuoteLineItem> HeraPrice = new map<Id, QuoteLineItem>();
        
        //MCSTO-11737: updated logic to query on CLI instead of productChildItem to fetch the rootProduct information.
        list<vlocity_cmt__ContractLineItem__c> rootProductCodes = [select vlocity_cmt__Product2Id__c , vlocity_cmt__QuoteLineItem__r.TeliaSE_Root_Product__r.name, vlocity_cmt__QuoteLineItem__r.TeliaSE_Root_Product__r.ProductCode, TeliaSE_Product_Object_Type__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__Product2Id__c  IN : proname and vlocity_cmt__ContractId__c =: contractId];
        set<string> rootCodeSet = new set<string>();
        string printCells = '';
        string parentName = '';
        String rootCode = '';
        String rootProductId = '';
        string objectType = '';
        for(vlocity_cmt__ContractLineItem__c s1: rootProductCodes){
            parentName = s1.vlocity_cmt__QuoteLineItem__r.TeliaSE_Root_Product__r.name;
            rootCode = s1.vlocity_cmt__QuoteLineItem__r.TeliaSE_Root_Product__r.ProductCode;
            rootProductId = s1.vlocity_cmt__QuoteLineItem__r.TeliaSE_Root_Product__c;
            objectType = s1.TeliaSE_Product_Object_Type__c;
            boolean flag1 = false;
            for( QuoteLineItem rootLineItem : rootQuoteLineItems){
                string rlItemId= (string)rootLineItem.TeliaSE_Product_Object_Type__c;
                if(rlItemId == objectType){
                    flag1 = true;
                }
            }
            if(rootCodeSet.contains(rootProductId)){
                //System.debug('Distinct Parent Product Already Present in Set');
            }else{
                rootCodeSet.add(rootProductId);
                List<QuoteLineItem> allQuoteLineItems = new list<QuoteLineItem>();
                if( grpName == 'NA' ){
                    allQuoteLineItems = [Select Product2.Name,Product2.ProductCode,vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,vlocity_cmt__EffectiveQuantity__c,quantity, id,TeliaSE_MC_Binding_Time__c,vlocity_cmt__ParentItemId__c  FROM QuoteLineItem where ((QuoteId =: quoteId ) AND ( TeliaSE_Product_Object_Type__c = 'Broadband Start Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Pro Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Plus Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Datanet Offering Spec' OR TeliaSE_Product_Object_Type__c = 'SD-WAN/Firewall Offering Spec' OR TeliaSE_Product_Object_Type__c = 'WIFI/LAN Offering Spec'  OR TeliaSE_Product_Object_Type__c = 'Connected Office Offer Spec') AND (vlocity_cmt__Product2Id__c IN (SELECT vlocity_cmt__ChildProductId__c  FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ChildProductId__c IN : standaloneLineItemsset AND vlocity_cmt__ParentProductId__c =:rootProductId)))];
                }
                else{
                    allQuoteLineItems = [Select Product2.Name, Product2.ProductCode,vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c,vlocity_cmt__EffectiveQuantity__c,Quantity, id,TeliaSE_MC_Binding_Time__c,vlocity_cmt__ParentItemId__c  FROM QuoteLineItem where ((QuoteId =: quoteId ) AND ( TeliaSE_Product_Object_Type__c = 'Broadband Start Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Pro Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Plus Offering Spec' OR TeliaSE_Product_Object_Type__c = 'Broadband Datanet Offering Spec' OR TeliaSE_Product_Object_Type__c = 'SD-WAN/Firewall Offering Spec' OR TeliaSE_Product_Object_Type__c = 'WIFI/LAN Offering Spec'  OR TeliaSE_Product_Object_Type__c = 'Connected Office Offer Spec') AND vlocity_cmt__QuoteGroupId__r.Name =:grpName AND (vlocity_cmt__Product2Id__c IN (SELECT vlocity_cmt__ChildProductId__c  FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ChildProductId__c IN : standaloneLineItemsset AND vlocity_cmt__ParentProductId__c =:rootProductId)))];   
                }
                if(allQuoteLineItems.size() > 0){
                    printCells += '<ss:Row>';
                    printCells += '<ss:Cell ss:StyleID="st4"><ss:Data ss:Type="String" >'+'Telia ' +parentName+'</ss:Data></ss:Cell>';
                    printCells += '</ss:Row>';
                }
                for(QuoteLineItem allQLI:allQuoteLineItems){
                    if(allQLI.Product2.Name == system.label.TeliaSE_COHeraProduct){
                        heraProductGroupId = (id)allQLI.vlocity_cmt__QuoteGroupId__c;
                        heraProdGroupId.add(heraProductGroupId);
                    }
                    else{
                        if(allQLI.Product2.ProductCode.contains('-SLA-C4')){
                            isExistSLAC4 = true;
                            
                        }
                        String recCh,oneChr;
                        recCh=thousandSeparatorRM(allQLI);
                        oneChr=thousandSeparatorOTC(allQLI);
                        printCells += '<ss:Row>';
                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +allQLI.Product2.Name+ '</ss:Data></ss:Cell>';
                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +oneChr+ ' kr</ss:Data></ss:Cell>';
                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +recCh+ ' kr</ss:Data></ss:Cell>';
                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +integer.valueOf(allQLI.vlocity_cmt__EffectiveQuantity__c)+ '</ss:Data></ss:Cell>';
                        if( allQLI.TeliaSE_MC_Binding_Time__c != null && allQLI.TeliaSE_MC_Binding_Time__c != ''){
                            printCells += '<ss:Cell><ss:Data ss:Type="String">' +integer.valueOf(allQLI.TeliaSE_MC_Binding_Time__c)+ '</ss:Data></ss:Cell>'; }
                        printCells += '</ss:Row>';
                    }
                }//End of for QuoteLineItem allQLI:allQuoteLineItems
                //Start logic fix 9676
                
                Boolean callfromRootLineItems = false;
                if(rootQuoteLineItems.size() > 0 ){
                    if(allQuoteLineItems.size() == 0 && flag1){
                        printCells += '<ss:Row>';
                        printCells += '<ss:Cell ss:StyleID="st4"><ss:Data ss:Type="String" >'+'Telia '+parentName+'</ss:Data></ss:Cell>';
                        printCells += '</ss:Row>';
                    }
                    callfromRootLineItems = true;
                    for( QuoteLineItem rootLineItem : rootQuoteLineItems){
                        string rlItemId= (string)rootLineItem.TeliaSE_Product_Object_Type__c;
                        if(rlItemId == objectType){
                            //id rootId = rootLineItem.id;
                            String rootAstRefId = rootLineItem.vlocity_cmt__AssetReferenceId__c;
                            printCells += '<ss:Row>';
                            printCells += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+rootLineItem.Product2.Name+'</ss:Data></ss:Cell>';
                            printCells += '</ss:Row>';
                            for(QuoteLineItem allLI:allQuoteLineItemsprev){
                                if(allLI.Product2.ProductCode.contains('-SLA-C4')){
                                    isExistSLAC4 = true;                                            
                                }   
                                String recCh,oneChr;
                            recCh=thousandSeparatorRM(allLI);
                            oneChr=thousandSeparatorOTC(allLI);
                                if(grpName!='NA'){
                                    if( allLI.vlocity_cmt__ParentItemId__c == rootAstRefId && allLI.vlocity_cmt__QuoteGroupId__r.Name == grpName){                                                                          
                                        
                                        printCells += '<ss:Row>';                                       
                                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +allLI.Product2.Name+ '</ss:Data></ss:Cell>';
                                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +oneChr+ ' kr</ss:Data></ss:Cell>';
                                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +recCh+ ' kr</ss:Data></ss:Cell>';
                                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +Integer.valueOf(allLI.vlocity_cmt__EffectiveQuantity__c)+ '</ss:Data></ss:Cell>';
                                        if( allLI.TeliaSE_MC_Binding_Time__c != null && allLI.TeliaSE_MC_Binding_Time__c != '')
                                            printCells += '<ss:Cell><ss:Data ss:Type="String">' +integer.valueOf(allLI.TeliaSE_MC_Binding_Time__c)+ '</ss:Data></ss:Cell>';
                                        printCells += '</ss:Row>';
                                    }
                                }else{
                                    if( allLI.vlocity_cmt__ParentItemId__c == rootAstRefId){
                                        printCells += '<ss:Row>';
                                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +allLI.Product2.Name+ '</ss:Data></ss:Cell>';
                                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +oneChr+ ' kr</ss:Data></ss:Cell>';
                                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +recCh+ ' kr</ss:Data></ss:Cell>';
                                        printCells += '<ss:Cell><ss:Data ss:Type="String">' +Integer.valueOf(allLI.vlocity_cmt__EffectiveQuantity__c)+ '</ss:Data></ss:Cell>';
                                        if( allLI.TeliaSE_MC_Binding_Time__c != null && allLI.TeliaSE_MC_Binding_Time__c != '')
                                            printCells += '<ss:Cell><ss:Data ss:Type="String">' +integer.valueOf(allLI.TeliaSE_MC_Binding_Time__c)+ '</ss:Data></ss:Cell>';
                                        printCells += '</ss:Row>';
                                    }
                                }
                            }//Ending printing of child line items
                        }
                    }
                }
                parentName = '';
                objectType ='';
            }
        }
        //Following code finds hera product
        List<QuoteLineItem> allHeraLineItem = new list<QuoteLineItem>();
        if( grpName == 'NA'){ //added ORDER BY for hera type sorting requirement LTAT-10027 23.6
            allHeraLineItem = [Select Product2.Name,vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,
                               vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,MC_HeraReferenceNumber__c,vlocity_cmt__RecurringCharge__c,
                               vlocity_cmt__QuoteMemberId__c, vlocity_cmt__OneTimeCharge__c,Quantity,vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__QuoteGroupId__c,vlocity_cmt__QuoteGroupId__r.Name,
                               TeliaSE_Type__c, vlocity_cmt__ParentItemId__c,id, vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c,vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c
                               FROM QuoteLineItem where (QuoteId =: quoteId  AND Product2.Name =:system.label.TeliaSE_COHeraProduct )  ORDER BY vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,MC_HeraType__c];
        }
        else{
            allHeraLineItem = [Select Product2.Name, vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,
                               vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__RecurringCharge__c,
                               vlocity_cmt__QuoteMemberId__c,MC_HeraReferenceNumber__c, vlocity_cmt__OneTimeCharge__c,Quantity,vlocity_cmt__EffectiveQuantity__c, vlocity_cmt__QuoteGroupId__c,
                               vlocity_cmt__QuoteGroupId__r.Name, vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c,vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,
                               TeliaSE_Type__c, vlocity_cmt__ParentItemId__c, id FROM QuoteLineItem where (QuoteId =: quoteId  AND Product2.Name =:system.label.TeliaSE_COHeraProduct  AND vlocity_cmt__QuoteGroupId__r.Name =:grpName )  ORDER BY vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,MC_HeraType__c];
        }
        if( allHeraLineItem.size() > 0){
            String heraConcatenate = '';
            String Recurringchrg1='' ;
            String OnetimeChrg1='' ;
            String lat, lon, streetNr, city;
            for(QuoteLineItem allHLI:allHeraLineItem){
                //LTAT-9997 23.5 -moved code from below to this loop to correct logic of displaying HERA information
                lat = !String.ISBLANK(allHLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c)? 'Lat: '+ allHLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c: '';
                lon = !String.ISBLANK(allHLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c)?', Long: '+ allHLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c: '';
                streetNr = !String.ISBLANK(allHLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c) ?' '+ allHLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c+ ' ': '';
                heraConcatenate = '<ss:Cell><ss:Data ss:Type="String">' +allHLI.vlocity_cmt__QuoteMemberId__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c+streetNr+lat+lon+ '  - Hera '+allHLI.MC_HeraReferenceNumber__c+'</ss:Data></ss:Cell>';   
                String recCh,oneChr;
                recCh=thousandSeparatorRM(allHLI);
                oneChr=thousandSeparatorOTC(allHLI);
                Recurringchrg1 = '<ss:Cell><ss:Data ss:Type="String">' +recCh+ ' kr'+'</ss:Data></ss:Cell>';
                OnetimeChrg1 = '<ss:Cell><ss:Data ss:Type="String">' +oneChr+' kr'+'</ss:Data></ss:Cell>';
                
                printCells += '<ss:Row>';
                printCells += heraConcatenate;
                printCells += OnetimeChrg1;
                printCells += Recurringchrg1; 
                printCells += '</ss:Row>';
            } 
        }
        return(printCells);
    } 
    public static string addressTab(boolean groupingFlag, Id quoteId){
        string addSheet = '<Worksheet ss:Name="Export Volymprislista Nätverkstjänste">';
        addSheet += '<ss:Table ss:StyleID="st2"  x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth = "130">';
        addSheet += '<ss:Column ss:Width="300"/>';
        addSheet += '<ss:Column ss:Width="150"/>';
        addSheet += '<ss:Column ss:Width="150"/>';
        //Populate header row
        //added for Coordinates  
        set<String> headers = new set<String>{'Gatuadress','Postnummer','Våningsplan/rumsnummer', 'Ort' , 'Latitude', 'Longitude'};
        addSheet += '<ss:Row>';
        for(String head:headers){
            addSheet += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+head+'</ss:Data></ss:Cell>';
        }
        addSheet += '</ss:Row>';
        // Add here logic
        if( groupingFlag ){
            List<vlocity_cmt__QuoteMember__c> OffQLIAddr = [SELECT vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,
                                                            vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,
                                                            vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__UnitNumber__c,vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c,
                                                            vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c 
                                                            FROM vlocity_cmt__QuoteMember__c where vlocity_cmt__QuoteGroupId__c  IN (Select vlocity_cmt__QuoteGroupId__c FROM QuoteLineItem where QuoteId =: quoteId)];
            
            for(vlocity_cmt__QuoteMember__c iqLI:OffQLIAddr){
                addSheet += '<ss:Row>';
                String checkStreetNummer='';
                if(iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c !=null){
                    checkStreetNummer= iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c + ',' + iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c;
                }
                else{
                    checkStreetNummer=iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c ;
                }
                
                addSheet += '<ss:Cell><ss:Data ss:Type="String">' +checkStreetNummer+ '</ss:Data></ss:Cell>';
                addSheet += '<ss:Cell><ss:Data ss:Type="String">' +iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c+ '</ss:Data></ss:Cell>';
                //addSheet += '<ss:Cell><ss:Data ss:Type="String">' +iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__ServicePointNumber__c+ '</ss:Data></ss:Cell>';
                addSheet += '<ss:Cell><ss:Data ss:Type="String">' +iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__UnitNumber__c+ '</ss:Data></ss:Cell>';
                addSheet += '<ss:Cell><ss:Data ss:Type="String">' +iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c+ '</ss:Data></ss:Cell>';
                //added for Coordinates
                addSheet += '<ss:Cell><ss:Data ss:Type="String">' + iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c + '</ss:Data></ss:Cell>';
        addSheet += '<ss:Cell><ss:Data ss:Type="String">' + iqLI.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c + '</ss:Data></ss:Cell>';
        addSheet += '</ss:Row>';
            }
        }
        else{
            QuoteLineItem getServiceAccountId = [select vlocity_cmt__ServiceAccountId__c from QuoteLineItem where QuoteId=: quoteid Order by createddate desc limit 1];
            List<vlocity_cmt__ServicePoint__c> OffQLIAddr = [SELECT vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,vlocity_cmt__PremisesId__r.vlocity_cmt__UnitNumber__c,
                                                             vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                                                             vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c
                                                             FROM vlocity_cmt__ServicePoint__c WHERE vlocity_cmt__PremisesId__r.vlocity_cmt__PropertyOwnerAccountId__c =:getServiceAccountId.vlocity_cmt__ServiceAccountId__c ];
            for(vlocity_cmt__ServicePoint__c iqLI:OffQLIAddr){
                addSheet += '<ss:Row>';
                
                String checkStreetNumber = '';
                if(iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c != null){
                    checkStreetNumber = iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c+ ',' + iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c;
                } else {
                    checkStreetNumber = iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c;
                }
                
                addSheet += '<ss:Cell><ss:Data ss:Type="String">' + checkStreetNumber + '</ss:Data></ss:Cell>';
                addSheet += '<ss:Cell><ss:Data ss:Type="String">' +iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c+ '</ss:Data></ss:Cell>';
                addSheet += '<ss:Cell><ss:Data ss:Type="String">' +iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__UnitNumber__c+ '</ss:Data></ss:Cell>';
                addSheet += '<ss:Cell><ss:Data ss:Type="String">' +iqLI.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c+ '</ss:Data></ss:Cell>';                   
                //added for Coordinates
        addSheet += '<ss:Cell><ss:Data ss:Type="String">' + iqLI.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c + '</ss:Data></ss:Cell>';
        addSheet += '<ss:Cell><ss:Data ss:Type="String">' + iqLI.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c + '</ss:Data></ss:Cell>';
        addSheet += '</ss:Row>';
            }
        }
        addSheet += '</ss:Table>';
        addSheet += '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">';
        addSheet += '<Selected/>';
        addSheet += '<ProtectObjects>False</ProtectObjects>';
        addSheet += '<ProtectScenarios>False</ProtectScenarios>';
        addSheet += '</WorksheetOptions>';
        addSheet += '</ss:Worksheet>';
        return addSheet;
        
    }
    public static List<String> orderExtractGroupSorting(List<String> listGroupMap) {
        Integer n = listGroupMap.size();
        String description1, description2;
        Integer groupIndex1, groupIndex2;
        for (Integer i = 0; i < n; i++) { 
            for (Integer j = 1; j < (n - i); j++) {
                groupIndex1 = Integer.valueOf(listGroupMap[j - 1].substringAfter('Group ').replaceAll('[^0-9]', ''));
                groupIndex2 = Integer.valueOf(listGroupMap[j].substringAfter('Group ').replaceAll('[^0-9]', ''));
                if (groupIndex1 > groupIndex2) {
                    String temp = listGroupMap[j - 1];
                    listGroupMap[j - 1] = listGroupMap[j];
                    listGroupMap[j] = temp;
                }
            }
        }
        return listGroupMap;
    }
    public static string thousandSeparatorRM(QuoteLineItem qli){
        Decimal thousSepRM = Math.roundToLong(qli.vlocity_cmt__RecurringCharge__c);
        String formatedAmtRM= thousSepRM.format();
        return formatedAmtRM;
    }  
    public static string thousandSeparatorOTC(QuoteLineItem qli){ 
        Decimal thousSepOTC=integer.valueOf(qli.vlocity_cmt__OneTimeCharge__c);
        string formatedAmtOTC =thousSepOTC.format();
        return formatedAmtOTC;
    }
}