/**
 * @Author:      Kia Tahilramani
 * @Company:     Capgemini
 * @Date:        11th Nov, 2021
 * @Description: TeliaSE_COAddressValidation
 * @Jira ticket: MCSTO-8929
 * History
 * <Date>           <Authors Name>      <Brief Description of Change>
 * -------------------------------------------------------------------
*/
global class TeliaSE_COAddressValidation implements vlocity_cmt.VlocityOpenInterface{
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output,Map<String, Object> options){
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('downloadExcelSampleFile')) {
                    downloadExcelSampleFile(input, output);
            }else {
                result = false;
            }  
        }catch(Exception e) {  
            System.debug('exception: '+e);
            result = false;
        }        
        return result;
    }
    public static void downloadExcelSampleFile(Map<String, Object> input, Map<String, Object> output) {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm(); //fetch url of org
        string excelXML = prepareHeaderAndStyles(); // prepare style and initialize xml string
        String fileName = 'addressLista';
        
        Date myDate = Date.today();
        fileName += '_'+myDate;
        String docTitle=fileName+'.xls';
        
        excelXML += excelFormatter(); 
     
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
        System.debug('The following exception has occurred when inserting cVersion: ' + e.getMessage());
        }
            
        String downloadLink = baseUrl + '/sfc/servlet.shepherd/version/download/' + cVersion.Id;
        output.put('downloadLink',downloadLink);
    }
    public static String excelFormatter(){
        
        string s = '<ss:Worksheet ss:Name="Sheet1">';
        
        //custom label for error message in excel 
       //added for Coordinates 
       String ErrMessage1= System.label.MC_ErrorMsgforCoordinate; 
       String ErrMessage2= System.label.MC_ErrorMsgforAddress;


        s += '<ss:Table ss:StyleID="st2"  x:FullColumns="1" x:FullRows="1" ss:DefaultColumnWidth = "150"><ss:Column ss:Width="300"/><ss:Column ss:Width="150"/><ss:Column ss:Width="150"/>';
         //commented for Coordinates revert 23.10
       //set<String> headers = new set<String>{'Välj','Ort','Postnummer','Gata','Gatunummer', 'Ingång', 'Lokal/Lgh Nr','Latitud','Longitud'};
      
       set<String> headers = new set<String>{'Ort','Postnummer','Gata','Gatunummer', 'Ingång', 'Lokal/Lgh Nr'};

        //Below code prints header
        s += '<ss:Row>';
        for(String head:headers){
            s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+head+'</ss:Data></ss:Cell>';
        }
        s += '</ss:Row>';
        //s+= second ROW to 101 rows 
        s += '</ss:Table>';
        s += '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">';
        s += '<Selected/>';
        //s += '<DoNotDisplayGridlines/>';
        s += '<ProtectObjects>False</ProtectObjects>';
        s += '<ProtectScenarios>False</ProtectScenarios>';
        s += '</WorksheetOptions>';

        //commented for Coordinates revert 23.10
       /* //added drop list to select address/coordinate in first cell -- Priya Rani (17-11-2022)
        s += '<DataValidation xmlns="urn:schemas-microsoft-com:office:excel"> <Range>R2C1:R994C1</Range> <Type>List</Type> <CellRangeList /> <Value>"Address,Coordinate"</Value> </DataValidation>';        
        // added formula on cell for selecting address -- priya Rani (17-11-2022)
        s += '<DataValidation xmlns="urn:schemas-microsoft-com:office:excel"><Range>R2C2:R194C7</Range><Type>Custom</Type><Qualifier>Between</Qualifier><Min>IF(RC1="Address",TRUE,FALSE)</Min><ComboHide /><ErrorMessage>'+ ErrMessage1 + '</ErrorMessage></DataValidation>';
        //added formula on cell for selecting coordinates -- priya Rani (17-11-2022)
        s += '<DataValidation xmlns="urn:schemas-microsoft-com:office:excel"><Range>R2C8:R194C10</Range><Type>Custom</Type><Qualifier>Between</Qualifier><Min>IF(RC1="Coordinate",TRUE,FALSE)</Min><ComboHide /><ErrorMessage>'+ ErrMessage2 +'</ErrorMessage></DataValidation>';*/
       
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