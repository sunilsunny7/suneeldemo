global class TeliaSE_COPreCheckExcelDownload implements vlocity_cmt.VlocityOpenInterface{
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
        String fileName = 'precheckResults';
        
        Object results = input.get('FullSiteProductList');
        String docTitle=fileName+'.xls';
        excelXML += excelFormatter(input); // based on moblist prepares data xml string
        //remove null values to be printed as empty in excel
        String refinedString = excelXML.replace('null', ''); // replaces null with space
        
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
            //System.debug('The following exception has occurred when inserting cVersion: ' + e.getMessage());
        }        
        String downloadLink = baseUrl + '/sfc/servlet.shepherd/version/download/' + cVersion.Id;
        
        //return downloadLink;
        output.put('downloadLink',downloadLink);
    }  
    public static String excelFormatter(Map<String, Object> input){  
        Map<String,Integer> prodChildCountMap = new Map<String,Integer>();
        List<object> prodlistMap = (List<Object>)input.get('ProductList'); //All products
        List<Map<String,Object>> PdtNameMap = new List<Map<String,Object>>();
        String productFamily = String.valueOf(input.get('productFamily'));
        Map<String,Object> parentChildMap = new Map<String,Object>();
        for(object obj :  prodlistMap){
            Map<String,Object> eachparent = (Map<String,Object>)obj;
            try{
                List<Object> childList = (List<Object>)eachparent.get('Child');
                prodChildCountMap.put((String)eachparent.get('Name'),childList.size());
                List<String> pdtnameList= new List<String>();
                Map<String,Object> pd = new Map<String,Object>();
                pd.put('Name', eachparent.get('Name'));
                pd.put('Code', eachparent.get('ProductCode'));
                for(Object child : childList)
                {
                    Map<String,Object> childpdt=(Map<String,Object>)child;
                    pdtnameList.add((String)childpdt.get('Name'));
                }
                parentChildMap.put(String.valueOf(eachparent.get('ProductCode')),pdtnameList); //added for prod issue fix 23.4
                pd.put('Child',pdtnameList);
                PdtNameMap.add(pd);
            }catch(Exception e){
                //System.debug('exception :'+e);
            }
        }
        List<Object> sitelist = (List<Object>)input.get('FullSiteProductList');
        //Boolean b2bToggle= Boolean.valueOf(System.Label.B2BSolution_Toggle);
        Set<String> headers = new set<String>();
        Set<String> headerCodes = new set<String>();
        if(productFamily == 'B2B'){
            headers = new set<String>{'Site', 'Datanet' , 'Bredband Pro Företag','Bredband Företag'};
            headerCodes = new set<String>{'B2B-DATANET' , 'B2B-BBPRO','B2B-BBF'};
        }
        else{
            headers = new set<String>{'Site', 'Datanet','Bredband Plus' , 'Bredband Pro','Bredband Start'}; 
            headerCodes = new set<String>{'CO-DATANET' ,'CO-BBPLUS', 'CO-BBPRO','CO-BBSTART'};
        }
        
        String s = '<ss:Worksheet ss:Name="SubscriptionInfo">';
        s += '<ss:Table ss:StyleID="st2"  x:FullColumns="1" x:FullRows="1"><ss:Column ss:Width="120"/><ss:Column ss:Width="250"/><ss:Column ss:Width="300"/>';
        s += '<ss:Row>';
        
        for(String head:headers){
            String displayHeader = head <>'Site'? 'Telia '+ head: head;
            if(prodChildCountMap.get(head) != null){
                Integer total = Integer.valueOf(prodChildCountMap.get(head)) - 1;
                s += '<ss:Cell ss:StyleID="st1" ss:MergeAcross= "'+total+'"><ss:Data ss:Type="String" >'+displayHeader+'</ss:Data></ss:Cell>';
                
            }else{
                s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+displayHeader+'</ss:Data></ss:Cell>';
            }
        }
        s += '</ss:Row>';
        s += '<ss:Row>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+'    '+ '</ss:Data></ss:Cell>';
        for(String head:headers){
            for(Object obj :  prodlistMap){
                Map<String,Object> eachparent = (Map<String,Object>)obj;
                if((String)eachparent.get('Name') == head && headerCodes.contains((String)eachparent.get('ProductCode')) ){
                    List<Object> childList = (List<Object>)eachparent.get('Child');
                    for(Object obj1:childList){
                        Map<String,Object> childs = (Map<String,Object>)obj1;
                        String PdtName = (String)childs.get('Name');
                        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >'+PdtName+ '</ss:Data></ss:Cell>';
                    }
                }
            }
        }
        
        s += '</ss:Row>';
        Integer iterator= 0;
        List<Object> AveragePrice = new List<Object>(); 
        for(Object sitemap : sitelist){
            Map<String,Object> eachsiteMap = (Map<String,Object>)sitemap;
            Map<String,Object> Sites = (Map<String,Object>)eachsiteMap.get('Sites');
            List<Object> AdjustmentPrice = new List<Object>(); 
            String lat, lon, streetNr, city;
            lat = !String.ISBLANK((String)Sites.get('Lat'))? 'Lat: '+ Sites.get('Lat'): '';
            lon = !String.ISBLANK((String)Sites.get('Long'))?', Long: '+ Sites.get('Long'): '';
            streetNr = !String.ISBLANK((String)Sites.get('StreetNr')) ?', '+ Sites.get('StreetNr'): '';
            city = !String.ISBLANK((String)Sites.get('City'))?', '+ Sites.get('City'): '';
            s += '<ss:Row>';
           
            s += '<ss:Cell><ss:Data ss:Type="String">'+Sites.get('StreetName') +streetNr+city+ ' '+lat+lon +'&#10;'+ '</ss:Data></ss:Cell>';
            List<object> products = (List<object>)eachsiteMap.get('Products');
            for(String head:headerCodes){ //added as part of prod issue fix 23.4
               
                for(Object obj1: products){
                    Map<string,object> prod = (Map<string,object>)obj1;
                    if((String)prod.get('ProductCode') == head){
                        
                        List<String> pdtnameList2 = (List<String>)parentChildMap.get((String)prod.get('ProductCode')); //changed as part of prod issue fix 23.4
                        List<object> data = (List<object>)prod.get('Data');
                        for(String str:pdtnameList2){
                            Integer flag=0;
                            for(Object dd: data){
                                Map<String,Object> d = (Map<string,object>)dd;
                                if(d.get('Name') == str){
                                    flag=1;
                                    s += '<ss:Cell ><ss:Data ss:Type="String">' ;
                                    if( d.get('ErrorCode')  !=null){
                                        Integer ErrorCode = Integer.valueOf((String)d.get('ErrorCode'));
                                        if( ErrorCode == 000 ){
                                            if(d.get('Type') !=null){
                                                s += 'Tjänstetyp: ' + d.get('Type') +'&#10;' ; 
                                            }
                                            if(d.get('ProductBandwidth') !=null){
                                                s += 'Bandwidth: ' + d.get('ProductBandwidth') +'&#10;' ; 
                                            }
                                            if(d.get('LineType') !=null){
                                                s+='Linjetyp: ' +d.get('LineType')  +'&#10;' ;
                                            }
                                            if(d.get('Name') !=null){
                                                s+='Name: ' +d.get('Name')  +'&#10;' ;
                                            }
                                            if(d.get('TechnologyId') !=null){
                                                s+='Teknologi-ID: ' + d.get('TechnologyId') + '&#10;';
                                            }
                                            if(d.get('TechnologyName') !=null){
                                                s+='Teknologi-namn: ' + d.get('TechnologyName') +'&#10;';
                                            }
                                            if(d.get('AccessTypeId') !=null){
                                                s+='Accesstyp-ID : ' + d.get('AccessTypeId') +'&#10;';
                                            }
                                            if( d.get('AccessTypeName') !=null){
                                                s+='Accesstyp-namn: ' +d.get('AccessTypeName') +'&#10;';
                                            }
                                            if(d.get('MaxDownloadSpeed') !=null){
                                                s+='Nedströmshastighet :' + d.get('MaxDownloadSpeed') +'&#10;';
                                            }
                                            if(d.get('MaxUploadSpeed') !=null){
                                                s+='Uppströmshastighet :' + d.get('MaxUploadSpeed') +'&#10;';
                                            }
                                            if(d.get('maxSLA') != null){
                                                s+= 'Max SLA: ' + d.get('maxSLA') +'&#10;';
                                            }
                                            if(d.get('MaxQos') != null){
                                                s+= 'Max QoS: ' + d.get('MaxQos') +'&#10;';
                                            }
                                            if( d.get('PriceParameter')!=null){
                                                s+= 'P/T-värde: ' + d.get('PriceParameter')+'&#10;';
                                            }
                                            if(  d.get('DeliveryTime')!=null){
                                                s+= 'Möjlig leveransdatum: ' + d.get('DeliveryTime') +'&#10;';
                                            }
                                            if(d.get('KONumber') !=null){
                                                s+='Avtalsnummer: ' + d.get('KONumber') +'&#10;';
                                            }
                                            if( d.get('LanType')!=null){
                                                s+= 'LAN-typ : ' + d.get('LanType') +'&#10;';
                                            }
                                            if( d.get('PriorityLessThanGBPS')!=null){
                                                s+= 'Prioritet : ' + d.get('PriorityLessThanGBPS') +'&#10;';
                                            }
                                            if( d.get('ErrorCode')  !=null){
                                                s+='Felkod : 0' +'&#10;';
                                            }
                                            if( d.get('ErrorMessage')!=null){
                                                s+= 'Felmeddelande : ' + d.get('ErrorMessage') +'&#10;';
                                            }
                                            if( d.get('FiberPair') !=null){
                                                s+='Fastprisområde : ' + d.get('FiberPair') +'&#10;';
                                            }
                                            if( d.get('FiberLength')!=null){
                                                s+='Fiberlängd : ' + d.get('FiberLength') +'&#10;';
                                            }
                                            if(d.get('FixedPriceArea') !=null){
                                                s+='Fiberpar : ' + d.get('FixedPriceArea') +'&#10;';
                                            }
                                            
                                            AdjustmentPrice.add(d.get('Price'));
                                        }
                                        else if(ErrorCode == 988){
                                            
                                            if(d.get('Type') !=null){
                                                s += 'Tjänstetyp: ' + d.get('Type') +'&#10;' ; 
                                            }
                                            if(d.get('ProductBandwidth') !=null){
                                                s += 'Bandwidth: ' + d.get('ProductBandwidth') +'&#10;' ; 
                                            }
                                            if(d.get('LineType') !=null){
                                                s+='Linjetyp: ' +d.get('LineType')  +'&#10;' ;
                                            }
                                            if(d.get('TechnologyId') !=null){
                                                s+='Teknologi-ID: ' + d.get('TechnologyId') + '&#10;';
                                            }
                                            if(d.get('TechnologyName') !=null){
                                                s+='Teknologi-namn: ' + d.get('TechnologyName') +'&#10;';
                                            }
                                            if(d.get('AccessTypeId') !=null){
                                                s+='Accesstyp-ID : ' + d.get('AccessTypeId') +'&#10;';
                                            }
                                            if( d.get('AccessTypeName') !=null){
                                                s+='Accesstyp-namn: ' +d.get('AccessTypeName') +'&#10;';
                                            }
                                            if(d.get('MaxDownloadSpeed') !=null){
                                                s+='Nedströmshastighet :' + d.get('MaxDownloadSpeed') +'&#10;';
                                            }
                                            if(d.get('MaxUploadSpeed') !=null){
                                                s+='Uppströmshastighet :' + d.get('MaxUploadSpeed') +'&#10;';
                                            }
                                            if(d.get('maxSLA') != null){
                                                s+= 'Max SLA: ' + d.get('maxSLA') +'&#10;';
                                            }
                                            if(d.get('MaxQos') != null){
                                                s+= 'Max QoS: ' + d.get('MaxQos') +'&#10;';
                                            }
                                            if( d.get('PriceParameter')!=null){
                                                s+= 'P/T-värde: ' + d.get('PriceParameter')+'&#10;';
                                            }
                                            if(  d.get('DeliveryTime')!=null){
                                                s+= 'Möjlig leveransdatum: ' + d.get('DeliveryTime') +'&#10;';
                                            }
                                            if(d.get('KONumber') !=null){
                                                s+='Avtalsnummer: ' + d.get('KONumber') +'&#10;';
                                            }
                                            if( d.get('LanType')!=null){
                                                s+= 'LAN-typ : ' + d.get('LanType') +'&#10;';
                                            }
                                            if( d.get('PriorityLessThanGBPS')!=null){
                                                s+= 'Prioritet : ' + d.get('PriorityLessThanGBPS') +'&#10;';
                                            }
                                            if( d.get('ErrorCode')  !=null){
                                                s+='Felkod : 0' +'&#10;';
                                            }
                                            if( d.get('FiberPair') !=null){
                                                s+='Fastprisområde : ' + d.get('FiberPair') +'&#10;';
                                            }
                                            if( d.get('FiberLength')!=null){
                                                s+='Fiberlängd : ' + d.get('FiberLength') +'&#10;';
                                            }
                                            if(d.get('FixedPriceArea') !=null){
                                                s+='Fiberpar : ' + d.get('FixedPriceArea') +'&#10;';
                                            }
                                            if( d.get('ErrorMessage')!=null){
                                                s+= 'Felmeddelande : ' + d.get('ErrorMessage') +'&#10;';
                                            }
                                            
                                            AdjustmentPrice.add(99999);
                                        }
                                        else{                                            
                                            if( d.get('ErrorMessage')!=null){
                                                s+= 'Felmeddelande : ' + d.get('ErrorMessage') +'&#10;';
                                            }
                                            
                                            Decimal dummy = 99999;
                                            AdjustmentPrice.add(dummy);
                                        }
                                        
                                        if(iterator == 0){
                                            Map<String,Object> average = new Map<String,Object>();
                                            if(d.get('averages') !=null){
                                                average = (Map<String,Object>)d.get('averages');
                                                AveragePrice.add(average.get('averagePrice'));
                                            }else{
                                                String NA = 'NA';
                                                AveragePrice.add(NA);
                                            }
                                            
                                        }
                                    }
                                    s+='</ss:Data></ss:Cell>';    //product details here
                                    break;
                                }
                            } 
                        }
                        break;
                    }
                }
            }
            s += '</ss:Row>';
            s += '<ss:Row>';
            s += '<ss:Cell><ss:Data ss:Type="String">'+'Månadsavgift'+'</ss:Data></ss:Cell>';
            for(Object price:AdjustmentPrice){
                if((Decimal)price == 99999){
                    s += '<ss:Cell ><ss:Data ss:Type="String"></ss:Data></ss:Cell>';
                }else{
                    s += '<ss:Cell ><ss:Data ss:Type="String">' ;
                    s+= (Decimal)price ; 
                    s+='</ss:Data></ss:Cell>';
                }
            }
            s += '</ss:Row>';
            iterator++;
        }
        s += '<ss:Row>';
        s += '<ss:Cell><ss:Data ss:Type="String">'+'Average Price'+'</ss:Data></ss:Cell>';
        for(Object avgPrice: AveragePrice){
            s += '<ss:Cell ><ss:Data ss:Type="String">';
            s+= avgPrice;
            s+='</ss:Data></ss:Cell>';
        }
        s += '</ss:Row>';
        s += '</ss:Table>';
        s += '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">';
        s += '<Selected/>';
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
    public class FullSiteProductList {
        public List<Products> Products;
        public Sites Sites;
        public Integer Servicepoint;
    }
    public class Products {
        public List<Data_X> Data;
        public String ProductName;
    }
    public class Data_X {
        public String LineType;
        public String ErrorMessage;
        public Boolean Checkpoint;
        public String Name;
        public Integer maxbandwidth;
        public String Type;
        public String DeliveryTime;
        public String ContractType;
        public Integer ProductBandwidth;
        public String PriceParameter;
        public Boolean PriceAvgFlag;
        public String maxSLA;
    }
    public class Sites {
        public String StreetNr;
        public String City;
        public String GateNumber;
        public String PostalCode;
        public String StreetName;
        public String Aptno;
    }
}