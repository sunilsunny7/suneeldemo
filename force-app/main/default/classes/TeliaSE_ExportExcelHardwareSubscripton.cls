/**
 * Developer: Vamsi D
 * Description: Based on Account Id as a input, fetchs data from Mobilabonnemang__c and prepares a xls string and provides content document as downloadable link 
 * Epic: MCSTO-5756
 *
*/ 
public class TeliaSE_ExportExcelHardwareSubscripton {
    
    @AuraEnabled
    public static String excelConvert(String accId) {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm(); //fetch url of org
        string excelXML = prepareHeaderAndStyles(); // prepare style and initialize xml string
        String fileName = 'Mobilt bestånd-';
        
        List<Mobilabonnemang__c> moblist = [SELECT Id,Account__r.Name, Subscription_Id__c,TeliaSE_User_Name__c,TeliaSE_Subscription_Name__c,CommitmentEndDate__c,Subsidized_Subscription__c,Agreement__c,Last_Used_Model__c,MSISDN__c,Roaming_Service_Descr__c FROM Mobilabonnemang__c where Account__c = :accId];
        Date myDate = Date.today();
        fileName += moblist[0].Account__r.Name+'-'+myDate;
        String docTitle=fileName+'.xls';
        
        excelXML += excelFormatter(moblist); // based on moblist prepares data xml string
		
        //remove null values to be printed as empty in excel
        String refinedString = excelXML.replace('null', ''); // replaces null with space
        
        List<ContentDocumentLink> cdl= new List<ContentDocumentLink>();
        List<ContentDocument> cd = new List<ContentDocument>();
        cdl= [Select Id,ContentDocument.Id from ContentDocumentLink where LinkedEntityId =:accId AND ContentDocument.Title like 'Mobilt bestånd%'];
        for(ContentDocumentLink c: cdl){
            ContentDocument cc = new ContentDocument();
            cc.id = c.ContentDocument.Id;
            cd.add(cc);
        }       
        if(cdl.size()>0){
            try{
                delete cdl;
                delete cd;
            }catch(Exception e){
        		System.debug('The following exception has occurred when deleting: ' + e.getMessage());
        	}
        }
        //Insert ContentVersion
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
        System.debug('The following exception has occurred when inserting cVersion: ' + e.getMessage());
        }
        
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument; //Add ContentDocumentId
        cDocLink.LinkedEntityId = accId;
        cDocLink.ShareType = 'I'; //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';
        try{
       // Insert cDocLink;
        }
        catch(Exception e){
        System.debug('The following exception has occurred when inserting doclink: ' + e.getMessage());
        }
        
        String downloadLink = baseUrl + '/sfc/servlet.shepherd/version/download/' + cVersion.Id;
        return downloadLink;
    }

    
    
    public static String excelFormatter(List<Mobilabonnemang__c> moblist){
       
        
        Map<String,object> mobMap = new Map<String,object>();
        set<String> mobId = new set<String>();
        set<String> headers = new set<String>{'Nummer','Namn','Produkt','Bindningstid slutdatum','Kan bindas om JA/NEJ','Växeltjänst JA/NEJ','Modell','IMEI','Roamingtjänster'};
        
        Map<String,String> headerMap = new Map<String,String>();
        headerMap.put('Nummer','Subscription_Id__c');
        headerMap.put('Namn','TeliaSE_User_Name__c');
        headerMap.put('Produkt','TeliaSE_Subscription_Name__c');
        headerMap.put('Bindningstid slutdatum','CommitmentEndDate__c');
        headerMap.put('Kan bindas om JA/NEJ','Subsidized_Subscription__c');
        headerMap.put('Växeltjänst JA/NEJ','Agreement__c');
        headerMap.put('Modell','Last_Used_Model__c');
        headerMap.put('IMEI','MSISDN__c');
        headerMap.put('Roamingtjänster','Roaming_Service_Descr__c');
        
        string s = '<ss:Worksheet ss:Name="SubscriptionInfo">';
        s += '<ss:Table ss:StyleID="st2"  x:FullColumns="1" x:FullRows="1"><ss:Column ss:Width="120"/><ss:Column ss:Width="250"/><ss:Column ss:Width="300"/>';
		s += '<ss:Row>';
        // header row START ==================>
        for(String head:headers){
        	s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+head+'</ss:Data></ss:Cell>';
        }
        s += '</ss:Row>';
        for(Mobilabonnemang__c mob:moblist){
            s += '<ss:Row>';
          	s += '<ss:Cell><ss:Data ss:Type="String">' +mob.Subscription_Id__c+ '</ss:Data></ss:Cell>';
			s += '<ss:Cell><ss:Data ss:Type="String">' +mob.TeliaSE_User_Name__c+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.TeliaSE_Subscription_Name__c+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.CommitmentEndDate__c+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.Subsidized_Subscription__c+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.Agreement__c+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.Last_Used_Model__c+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.MSISDN__c+ '</ss:Data></ss:Cell>';
            s += '<ss:Cell><ss:Data ss:Type="String">' +mob.Roaming_Service_Descr__c+ '</ss:Data></ss:Cell>';
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
        s += '<ss:Alignment ss:Horizontal="Center"  ss:Vertical="Center"/>';
        s += '</ss:Style>';
        s += '</ss:Styles>';
        return s;
    }
}