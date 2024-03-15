/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_OrderExtractExcel 
**Created By  :        Aditi Goyal
**Release     :        23.10
**Description :        Order extract excel generation
-----------------------------------------------------------------------------------------------------------*/
global class MC_OrderExtractExcel implements vlocity_cmt.VlocityOpenInterface{
    
    private static Integer noOfSites = 0;
    private static Map<String, String> objTypeMap = new Map<String, String>();
    private static final String endCell = '</ss:Data></ss:Cell>';
    private static final String beginCell = '<ss:Cell><ss:Data ss:Type="String">';
    private static Set<String> headers = new Set<String>{'Produkter','Engångsavgift','Månadsavgift','Antal','Bindningstid'};
    private static final List<String> coOfferTypes = new List<String>{'Broadband Start Offering Spec','Broadband Plus Offering Spec','Broadband Pro Offering Spec','Broadband Datanet Offering Spec','WIFI/LAN Offering Spec','SD-WAN/Firewall Offering Spec'};

        global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output,Map<String, Object> options){
            Boolean result = true;
            
            try {
                if(methodName.equalsIgnoreCase('generateExcel')) {
                    generateExcel(input, output);
                }else if(methodName.equalsIgnoreCase('checkOfferQuote')) {
                    checkOfferQuote(input, output);
                }else {
                    result = false;
                }  
            }catch(Exception e) {  
                System.debug('ExceptionMsg: '+e.getMessage());
                System.debug('ExceptionTrace: '+e.getStackTraceString());
                result = false;
            }        
            return result;
        }
    
    public void checkOfferQuote(Map<String,Object> inputMap, Map<String,Object> outMap){
        String contractId = (String)inputMap.get('contextId');
        Boolean isValid = true;
        Contract contract = [SELECT vlocity_cmt__QuoteId__c,vlocity_cmt__OpportunityId__c FROM Contract WHERE Id=:contractId];
        List<Quote> offerQ = [SELECT Id FROM Quote WHERE OpportunityId =:contract.vlocity_cmt__OpportunityId__c AND vlocity_cmt__ParentQuoteId__c =: contract.vlocity_cmt__QuoteId__c AND  Quote.Status != 'Cancelled' AND TeliaSE_Record_Type_Name__c = 'Offer' ORDER BY CreatedDate DESC LIMIT 1];
        if(!offerQ.isEmpty()){
            List<TeliaSE_SimplifiedQuoteLineItem__c> qlis = [select id from TeliaSE_SimplifiedQuoteLineItem__c where QuoteId__c =:offerQ[0].Id and QuoteId__r.Status != 'Cancelled' and QuoteId__r.TeliaSE_Record_Type_Name__c = 'Offer' and ProductType__c IN:coOfferTypes];
            if(qlis.isEmpty()){
                outMap.put('Error',System.Label.TeliaSE_COProductNotFound);
                isValid = false;
            }
        }
        else{
            outMap.put('Error',System.Label.TeliaSE_NoFAQuoteFound);
            isValid = false;
        }
        if(isValid){
            outMap.put('Warning',System.Label.MC_OrderExtractContinue);
        }
    }
    
    public void generateExcel(Map<String, Object> input, Map<String, Object> output) {
        String baseUrl = System.URL.getOrgDomainURL().toExternalForm(); //fetch url of org
        String fileName = System.Label.TeliaSE_COOrderExtractFileName;
        Id contractId = Id.valueof((String)input.get('ContractId'));
        
        String excelXML = prepareHeaderANDStyles(); // prepare style AND initialize xml String
        excelXML += createExcelContent(contractId); 
        String refinedString = excelXML.replace('null', ''); // replaces null with space
        
        Date myDate = Date.today();
        String docTitle = fileName += '_' + myDate +'.xls';

        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S';
        cVersion.PathOnClient = docTitle;
        cVersion.Origin = 'H'; //C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = userinfo.getUserId();
        cVersion.Title = docTitle;
        cVersion.VersionData = Blob.valueof(refinedString);
        try{
            insert cVersion;
        }
        catch(Exception e){
            System.debug('The following exception has occurred when inserting cVersion: ' + e.getMessage());
        }
        
        String downloadLink = baseUrl + '/sfc/servlet.shepherd/version/download/' + cVersion.Id;
        output.put('downloadLink',downloadLink);
    }
    
    public String createExcelContent(Id contractId){
        String s = '<ss:Worksheet ss:Name="OrderExtract">';
        s += '<ss:Table ss:StyleID="st2"  x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth = "130"><ss:Column ss:Width="300"/><ss:Column ss:Width="150"/><ss:Column ss:Width="150"/>';
        
        Set<String> groupSet= new Set<String>();
        Map<String, String> groupMap = new Map<String, String>();
        Boolean isGroupExist = false,isExistSLAC4= false;
        String offerQuoteId;
        Contract contract = [SELECT Id,vlocity_cmt__QuoteId__c,Account.Name,Account.Org_nr__c,vlocity_cmt__OpportunityId__c,ContractNumber,EndDate,StartDate,
                             Owner.Name,Owner.Telia_Id__c,Owner.Email,Owner.MobilePhone
                             FROM Contract 
                             WHERE Id =:contractId LIMIT 1];
        List<Quote> offerQ = [SELECT Id FROM Quote WHERE OpportunityId =: contract.vlocity_cmt__OpportunityId__c AND vlocity_cmt__ParentQuoteId__c =: contract.vlocity_cmt__QuoteId__c AND  Quote.Status != 'Cancelled' AND TeliaSE_Record_Type_Name__c = 'Offer' ORDER BY CreatedDate DESC LIMIT 1];
        if(offerQ.isEmpty()){
            return '';
        }
        List<TeliaSE_SimplifiedQuoteLineItem__c > allQuoteLineItems = [SELECT ProductName__c,QuoteId__c,TeliaSE_List_Price__c,TeliaSE_OnetimeCharge__c,TeliaSE_MC_Binding_Time__c,Product_Code__c,Quote_Group__c,Quote_Group__r.Name,ProductType__c,TeliaSE_Aggregated_Quantity__c,TeliaSE_Parent_ItemId__c,
                                                 TeliaSE_Offer_Type__c,Quote_Group__r.vlocity_cmt__Description__c,MC_HeraReferenceNumber__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                                 Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c
                                                 FROM TeliaSE_SimplifiedQuoteLineItem__c  
                                                 WHERE QuoteId__c =:offerQ[0].Id
                                                 AND QuoteId__r.Status != 'Cancelled' AND QuoteId__r.TeliaSE_Record_Type_Name__c = 'Offer'
                                                 AND (ProductType__c IN:coOfferTypes OR ProductType__c='Connected Office Offer Spec')
                                                 ORDER BY TeliaSE_Product_Hierarchy__c,Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,MC_HeraType__c];
        if(allQuoteLineItems.size()>0){
            offerQuoteId = allQuoteLineItems[0].QuoteId__c;
        }
        List<vlocity_cmt__QuoteMember__c> siteMembers = [SELECT vlocity_cmt__ServicePointId__r.MC_IS_SLA_C4_Available__c, vlocity_cmt__ServicePointId__c, vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__c,
                                                         vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c, vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,
                                                         vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                                                         vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__UnitNumber__c,
                                                         vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,
                                                         vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c,
                                                         vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c ,vlocity_cmt__QuoteGroupId__c,
                                                         vlocity_cmt__QuoteGroupId__r.vlocity_cmt__Description__c
                                                         FROM vlocity_cmt__QuoteMember__c 
                                                         WHERE vlocity_cmt__QuoteId__c=:offerQuoteId
                                                         ORDER BY vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c];
        List<vlocity_cmt__ContractLineItem__c> rootClis = [SELECT Name,TeliaSE_Product_Object_Type__c 
                                                           FROM vlocity_cmt__ContractLineItem__c
                                                           WHERE TeliaSE_Product_Object_Type__c IN:coOfferTypes
                                                           AND TeliaSE_ParentItemId__c = null
                                                           AND vlocity_cmt__ContractId__c =: contractId];
        for(vlocity_cmt__ContractLineItem__c cli : rootClis){
            objTypeMap.put(cli.TeliaSE_Product_Object_Type__c,cli.Name);
        }
        
        Map<String,List<TeliaSE_SimplifiedQuoteLineItem__c>> grpProdToChildMap = new Map<String,list<TeliaSE_SimplifiedQuoteLineItem__c >>();
        List<TeliaSE_SimplifiedQuoteLineItem__c> heraQLis = new List<TeliaSE_SimplifiedQuoteLineItem__c >();
        for(TeliaSE_SimplifiedQuoteLineItem__c qli :allQuoteLineItems){
            /*
            //LTAART-328: Commented the logic for Grouping scenarios
            if(qli.Quote_Group__c !=null && qli.Quote_Group__r.vlocity_cmt__Description__c!='NO_GROUP'){
                isGroupExist=true;
                groupSet.add(qli.Quote_Group__r.vlocity_cmt__Description__c);
                groupMap.put(qli.Quote_Group__r.vlocity_cmt__Description__c,qli.Quote_Group__r.name);
                
                List<TeliaSE_SimplifiedQuoteLineItem__c> childGrpList = new List<TeliaSE_SimplifiedQuoteLineItem__c>();
                if(grpProdToChildMap.containsKey(String.valueOf(qli.Quote_Group__r.vlocity_cmt__Description__c))){
                    childGrpList = grpProdToChildMap.get(String.valueOf(qli.Quote_Group__r.vlocity_cmt__Description__c)); 
                }
                childGrpList.add(qli);
                grpProdToChildMap.put(String.valueOf(qli.Quote_Group__r.vlocity_cmt__Description__c),childGrpList);
            }
            */
            if (qli.ProductType__c == 'Connected Office Offer Spec' && qli.Quote_Group__c !=null){
                heraQLis.add(qli);
            }
            if(qli.Product_Code__c.contains('-SLA-C4')){
                isExistSLAC4 = true;
            }
        }
        /*
        //LTAART-328: Commented the logic for Grouping scenarios
        if(isGroupExist){
            List<String> tempList= new list<String>();
            tempList.addAll(groupSet);          
            List<String> sortedGroups = sortGroups(tempList);
            for(Integer i = 0; i < sortedGroups.size(); i++){                
                String groupName = groupMap.get(sortedGroups[i]);             
                s = groupingScenario(s,groupName,grpProdToChildMap.get(sortedGroups[i]),siteMembers,heraQLis);
            }
        }else{
            
        }
        */
        s = nonGroupingScenario(s,allQuoteLineItems,siteMembers,heraQLis);
        s = accountInformation(s,contract);
        if(isExistSLAC4){
            s = slaC4Information(s,siteMembers);
        }
        s += '</ss:Table>';
        s += '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">';
        s += '<Selected/>';
        //s += '<DoNotDisplayGridlines/>';
        s += '<ProtectObjects>False</ProtectObjects>';
        s += '<ProtectScenarios>False</ProtectScenarios>';
        s += '</WorksheetOptions>';
        s += '</ss:Worksheet>';
        s += addressTab(siteMembers);
        s += '</ss:Workbook>';
        return s;
    }
    /*
    //LTAART-328: Commented the logic for Grouping scenarios
    public String groupingScenario(String s,String groupName,List<QuoteLineItem> groupQlis, List<vlocity_cmt__QuoteMember__c> siteMembers,List<QuoteLineItem> heraQLis){
        s += '<ss:Row>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+groupQlis[0].vlocity_cmt__QuoteGroupId__r.name +endCell;
        s = mapSiteInfo(s,String.valueOf(groupQlis[0].vlocity_cmt__QuoteGroupId__c),siteMembers);
        s += '</ss:Row>';
        s += '<ss:Row>';
        s = addHeaders(s);
        s += addColorToCell(noOfSites);
        s += '</ss:Row>';
        s += mapProducts(s,groupQlis);
        s += mapHeraLineItems(groupQlis[0].vlocity_cmt__QuoteGroupId__c,heraQlis);
        return s;
    }
    */
    public String nonGroupingScenario(String s,List<TeliaSE_SimplifiedQuoteLineItem__c> allQlis,List<vlocity_cmt__QuoteMember__c> siteMembers,List<TeliaSE_SimplifiedQuoteLineItem__c> heraQLis){
        s += '<ss:Row>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >Adresser</ss:Data></ss:Cell>';
        s = mapSiteInfo(s,'NonGrouping',siteMembers);
        s += '</ss:Row>';
        s += '<ss:Row>';
        s = addHeaders(s);
        //s += addColorToCell(siteMembers.size()-1);
        s += '</ss:Row>';
        s += mapProducts(s,allQlis);
        s += mapHeraLineItems('NonGrouping',heraQlis);
        return s;
    }
    
    public String mapSiteInfo(String s,String groupId,List<vlocity_cmt__QuoteMember__c> siteMembers){
        Integer index = 1;
        for(vlocity_cmt__QuoteMember__c site : siteMembers){
            if(groupId == 'NonGrouping' || site.vlocity_cmt__QuoteGroupId__c == groupId){
                String fullAddr = getAddressString(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                                   site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,
                                                   site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,null,
                                                   site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,
                                                   site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                if(index == 1){
                    s += addColorToCell(headers.size()-1);
                    s += '<ss:Cell ss:Index="'+(headers.size()+1)+'" ss:StyleID="st1"><ss:Data ss:Type="String">'+fullAddr+endCell;
                    index ++;
                }
                else
                    s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String">'+fullAddr+endCell;                
            }
        }
        noOfSites = index;
        return s;
    }
    
    public String mapProducts(String s,List<TeliaSE_SimplifiedQuoteLineItem__c> groupQlis){
        String printCells = '';
        String cellString = beginCell;
        for(String parent: objTypeMap.keySet()){
            Integer count = 0;
            for(TeliaSE_SimplifiedQuoteLineItem__c  qli : groupQlis){
                if(qli.ProductType__c == parent){
                    if(count==0){
                        printCells += '<ss:Row>';
                        printCells += '<ss:Cell ss:StyleID="st4"><ss:Data ss:Type="String" >'+'Telia ' +objTypeMap.get(parent)+endCell;
                        printCells += '</ss:Row>';
                        count ++;
                    }
                    printCells += '<ss:Row>';
                    if(qli.TeliaSE_Offer_Type__c=='Non-SubscriptionOffering'){
                        printCells += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String">' +qli.ProductName__c+ endCell;
                    }
                    else if(qli.TeliaSE_Offer_Type__c!='Non-SubscriptionOffering'){
                        printCells += cellString +qli.ProductName__c+ endCell;
                        printCells += cellString +toCurrency(qli.TeliaSE_OnetimeCharge__c)+ ' kr'+endCell;
                        printCells += cellString +toCurrency(qli.TeliaSE_List_Price__c)+ ' kr'+endCell;
                        printCells += cellString +Integer.valueOf(qli.TeliaSE_Aggregated_Quantity__c)+ endCell;
                        if(qli.TeliaSE_MC_Binding_Time__c != null){
                            printCells += cellString +Integer.valueOf(qli.TeliaSE_MC_Binding_Time__c)+ endCell; 
                        }  
                    }
                    printCells += '</ss:Row>';
                }
            }
        }
        return printCells;
    }
    
    public String mapHeraLineItems(String groupId,List<TeliaSE_SimplifiedQuoteLineItem__c> heraQlis){
        String printCells = '';
        for(TeliaSE_SimplifiedQuoteLineItem__c qli:heraQlis){
            if(groupId == 'NonGrouping' || qli.Quote_Group__c == Id.valueOf(groupId)){
                String fullAddr = getAddressString(qli.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                                   qli.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,
                                                   null,null, //city and postal code is not mapped for Hera addresses
                                                   qli.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,
                                                   qli.Quote_Member__r.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                printCells += '<ss:Row>';
                printCells += beginCell +fullAddr+' - Hera '+qli.MC_HeraReferenceNumber__c+endCell;
                printCells += beginCell +toCurrency(qli.TeliaSE_OnetimeCharge__c)+' kr'+endCell;
                printCells += beginCell +toCurrency(qli.TeliaSE_List_Price__c)+ ' kr'+endCell;
                printCells += '</ss:Row>';
            }
        }
        return printCells;
    }
    
    
    public String getAddressString(String streetAdd,String streetNr,String city,String postalCode,String lat,String lon){
        streetNr = String.isNotBlank(streetNr) ?' '+ streetNr: '';
        city = String.isNotBlank(city)?', '+ city: '';
        postalCode = String.isNotBlank(postalCode)?' '+ postalCode: '';
        lat = String.isNotBlank(lat)? 'Lat: '+lat: '';
        lon = String.isNotBlank(lon)?', Long: '+ lon: '';                
        String fullAddr = streetAdd+streetNr+city+postalCode+' '+lat+lon;               
        return fullAddr;
    }
    
    public String addressTab(List<vlocity_cmt__QuoteMember__c> siteMembers){
        String addSheet = '<Worksheet ss:Name="Export Volymprislista Nätverkstjänste">';
        addSheet += '<ss:Table ss:StyleID="st2"  x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth = "130">';
        addSheet += '<ss:Column ss:Width="300"/>';
        addSheet += '<ss:Column ss:Width="150"/>';
        addSheet += '<ss:Column ss:Width="150"/>';
        //commented for Coordinates revert  23.10
        //Set<String> addrHeaders = new Set<String>{'Gatuadress','Postnummer','Våningsplan/rumsnummer', 'Ort' , 'Latitud', 'Longitud'};
        Set<String> addrHeaders = new Set<String>{'Gatuadress','Postnummer','Våningsplan/rumsnummer', 'Ort'};
            addSheet += '<ss:Row>';
        for(String head:addrHeaders){
            addSheet += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+head+endCell;
        }
        addSheet += '</ss:Row>';
        for(vlocity_cmt__QuoteMember__c site:siteMembers){
            addSheet += '<ss:Row>';
            String streetAdd='';
            if(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c !=null){
                streetAdd= site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c + ',' + site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c;
            }
            else{
                streetAdd=site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c;
            }
            addSheet += beginCell +streetAdd+ endCell;
            addSheet += beginCell +site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c+ endCell;            
            addSheet += beginCell +site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__UnitNumber__c+ endCell;
            addSheet += beginCell +site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c+ endCell;
            addSheet += beginCell +site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c + endCell;
            addSheet += beginCell +site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c + endCell;
            addSheet += '</ss:Row>';
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
    
    public String accountInformation(String s,Contract contract){
        
        List<String> accHeaderInfo = new List<String>{'Account Name','Organisation number','Agreement signer (Avtalstecknare)','FA Contract(RAMAVTAL)', 'Contract agreement start time', 'Contract agreement end time'};
            List<String> accInfo = new List<String>{contract.Account.Name,contract.Account.Org_nr__c,contract.Owner.Name,contract.ContractNumber,String.valueOf(contract.StartDate),String.valueOf(contract.EndDate)};
                s += '<ss:Row></ss:Row>';
        s += '<ss:Row>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String">Account Info</ss:Data></ss:Cell>';
        s += addColorToCell(10);
        s += '</ss:Row>';
        for(Integer i = 0; i < accHeaderInfo.size(); i++){
            s += '<ss:Row>';
            s += beginCell +accHeaderInfo[i]+ endCell;
            s += beginCell +accInfo[i]+ endCell;
            s += '</ss:Row>';
        }
        s += '<ss:Row>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String">Account Manager</ss:Data></ss:Cell>';
        s += addColorToCell(10);
        s += '</ss:Row>';
        
        List<String> accManagerHeaders = new List<String>{'Name','TeliaId','Email','Mobile'};
            List<String> accManagerInfo = new List<String>{contract.Owner.Name,contract.Owner.Telia_Id__c,contract.Owner.Email,contract.Owner.MobilePhone};
                
                for(integer j = 0; j < accManagerHeaders.size(); j++){
                    s += '<ss:Row>';
                    s += beginCell +accManagerHeaders[j]+ endCell;
                    s += beginCell +accManagerInfo[j]+ endCell;
                    s += '</ss:Row>';
                }
        return s;
    }
    
    public String slaC4Information(String s, List<vlocity_cmt__QuoteMember__c> siteMembers){ //LTAT-11938  
        s += '<ss:Row>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String">SLA C4 Tillgänglig Address</ss:Data></ss:Cell>';
        s += addColorToCell(10);
        s += '</ss:Row>';         
        for(vlocity_cmt__QuoteMember__c site:siteMembers){
            if(site.vlocity_cmt__ServicePointId__r.MC_IS_SLA_C4_Available__c= true){
                s += '<ss:Row>';                
                String fullAddr = getAddressString(site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
                                                   site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__Address1__c,
                                                   site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
                                                   site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.vlocity_cmt__PostalCode__c,
                                                   site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Latitude__c,
                                                   site.vlocity_cmt__ServicePointId__r.vlocity_cmt__PremisesId__r.MC_Geolocation_Longitude__c);
                s += beginCell + fullAddr + endCell;                                 
                s += '</ss:Row>'; 
            }
        }
        return s;
    }
    /*
    //LTAART-328: Commented the logic for Grouping scenarios
    public List<String> sortGroups(List<String> groupList){
        Integer n = groupList.size();
        Integer groupIndex1, groupIndex2;
        for (Integer i = 0; i < n; i++) { 
            for (Integer j = 1; j < (n - i); j++) {
                groupIndex1 = Integer.valueOf(groupList[j - 1].subStringAfter('Group ').replaceAll('[^0-9]', ''));
                groupIndex2 = Integer.valueOf(groupList[j].subStringAfter('Group ').replaceAll('[^0-9]', ''));
                if (groupIndex1 > groupIndex2) {
                    String temp = groupList[j - 1];
                    groupList[j - 1] = groupList[j];
                    groupList[j] = temp;
                }
            }
        }
        return groupList;
    }
    */
    public String prepareHeaderANDStyles(){
        String s = '<?xml version="1.0" encoding="UTF-8"?>';
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
    public String addColorToCell(Integer addToCells){
        String cellTags = '';
        for(Integer i = 0; i < addToCells; i++){
            if( cellTags == '' || cellTags == null){
                cellTags = '<ss:Cell ss:StyleID="st1"></ss:Cell>';
            }
            else{
                cellTags += '<ss:Cell ss:StyleID="st1"></ss:Cell>';
            }
        }
        return(cellTags);
    }
    public String addHeaders(String s){
        for(String head:headers){
            s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+head+endCell;
        }
        return s;
    }
    public String toCurrency(Decimal charge){ //for thousand separator currency format
        Decimal thousSep = charge != null ? Math.roundToLong(charge) : null;
        String formattedCharge= thousSep != null ? thousSep.format() : null;
        return formattedCharge;
    }
}