/*-----------------------------------------------------------------------------------------------------------
**Name        :        MC_ExportExcelB2BOrders
**Created By  :        Abhinav Gupta
**Release     :        23.9
**Description :        Apex Methods for generation for Excel document (LTAT-14200)
Modified to add some new field to Order extarct (LTAT-17284) by Lokesh, Release - 23.11
-----------------------------------------------------------------------------------------------------------*/
global class MC_ExportExcelB2BOrders {
    
    @AuraEnabled
    public static String excelConvert(String accId) {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm(); //fetch url of org
        String excelXML = prepareHeaderAndStyles(); // prepare style and initialize xml string
        String fileName = 'OrderExtract_';
        //Added new addons field in query-LTAT-17284
        List<MC_B2B_Order__c> b2bOrderList = [SELECT id, MC_Account__r.Name ,MC_Delivery_Date__c, MC_Order_Number__c,  MC_Ordered_By__c, MC_Orderer_Email__c, MC_Product_Info__c, MC_Promised_Date__c, MC_Requested_Delivery_Date__c,toLabel(MC_Order_Type__c), MC_Retailer_ID__c, MC_Source__c,MC_Channel__c, toLabel(MC_Order_Status__c),MC_Item_Quantity__c,
                                              toLabel(MC_Item_Status__c),MC_Item_Req_Del_Date__c,MC_Item_Promised_Date__c FROM MC_B2B_Order__c 
                                              WHERE MC_Account__c =: accId 
                                              ORDER BY MC_Order_Status__c,MC_Order_Number__c,MC_Main_Order_Item__c DESC];
        Date myDate = Date.today();
        fileName += b2bOrderList[0].MC_Account__r.Name+'-'+myDate;
        String docTitle=fileName+'.xls';
        excelXML += excelFormatter(b2bOrderList);
        String refinedString = excelXML.replace('null', '');
        
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
        return downloadLink;
    }
    
    public static string prepareHeaderAndStyles() {
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
        s += '<ss:Alignment ss:Horizontal="Center"  ss:Vertical="Center"/>';
        s += '</ss:Style>';
        s += '</ss:Styles>';
        return s;
    }
    //Added new mapping field in headers- LTAT-17284
    public static string excelFormatter(List<MC_B2B_Order__c> b2bOrderList){
        Set<String> headers = new Set<String>{'Ordernummer','Produkt','Status','Ordertyp','Utlovat leveransdatum','Önskat leveransdatum','Faktiskt leveransdatum','Beställare','Beställare epost','Källsystem','Kanal','Tillval Antal','Tillval Status','Tillval Utlovat leveransdatum','Tillval Önskat leveransdatum'};
            String s = '<ss:Worksheet ss:Name="Ordrar Info">';
        s += '<ss:Table ss:StyleID="st2"  x:FullColumns="1" x:FullRows="1"><ss:Column ss:Width="120"/><ss:Column ss:Width="250"/><ss:Column ss:Width="300"/>';
        s += '<ss:Row>';
        // header row START ==================>
        for(String head:headers){
            s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+head+'</ss:Data></ss:Cell>';
        }
        s += '</ss:Row>';
        // row data START ======Added 4 new items fields to extarct field value==============>
        for(MC_B2B_Order__c mob:b2bOrderList){
            s += '<ss:Row>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MC_Order_Number__c + '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MC_Product_Info__c+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MC_Order_Status__c+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MC_Order_Type__c + '</ss:Data></ss:Cell>';           
            s += '<ss:Cell><ss:Data ss:Type="String">' +String.valueOf(Date.valueOf(mob.MC_Promised_Date__c)) + '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +String.valueOf(Date.valueOf(mob.MC_Requested_Delivery_Date__c)) + '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +String.valueOf(Date.valueOf(mob.MC_Delivery_Date__c)) + '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MC_Ordered_By__c + '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MC_Orderer_Email__c + '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MC_Source__c + '</ss:Data></ss:Cell>';  
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MC_Channel__c + '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MC_Item_Quantity__c + '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MC_Item_Status__c + '</ss:Data></ss:Cell>';          
            s += '<ss:Cell><ss:Data ss:Type="String">' +String.valueOf(Date.valueOf(mob.MC_Item_Promised_Date__c)) + '</ss:Data></ss:Cell>';            
            s += '<ss:Cell><ss:Data ss:Type="String">' +String.valueOf(Date.valueOf(mob.MC_Item_Req_Del_Date__c)) + '</ss:Data></ss:Cell>';
            s += '</ss:Row>';
        }
        s += '</ss:Table>';
        s += '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">';
        s += '<Selected/>';
        //s += '<DoNotDisplayGridlines/>';
        s += '<ProtectObjects>False</ProtectObjects>';
        s += '<ProtectScenarios>False</ProtectScenarios>';
        s += '</WorksheetOptions>';
        s += '</ss:Worksheet>';
        s += '</ss:Workbook>';
        return s;        
    }
}