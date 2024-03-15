@isTest
public class Test_MC_ExportExcelHardwareSubscripton {
	testMethod public static void getMobilRecords(){
        User user; 
        System.runAs(new User(Id = Userinfo.getUserId())){
        	user = Test_DataFactory.createAdminUser();
        	user.Bypass_VR__c = true;
        	insert user;
        }
        System.runAs(user){
            Account acc = Test_DataFactory.createOneAccount();
          	insert acc;
            List<Mobilabonnemang__c> mbObjList = new List<Mobilabonnemang__c>();
            Mobilabonnemang__c mbObj = new Mobilabonnemang__c();
            mbObj.Allowed_To_Bind__c = 'NEJ';
            mbObj.Subsidized_Subscription__c = 'JA';
            mbObj.Binding_Time_Left__c = '831 dagar';
            mbObj.Agreement__c = '78000311';
            mbObj.Category__c = 'Mobila talabonnemang';
            mbObj.GPRS_Service_Allowance__c = '';
            mbObj.MSISDN__c = '46705076687';
            mbObj.Account__c = String.ValueOf(acc.id);
            mbObj.Subscription_Id__c = '0705076687';
            mbObj.Offering_Name__c = '95';
            mbObj.CommitmentEndDate__c = '2023-04-30';
            mbObj.CommitmentStartDate__c = '2020-04-30';
            mbObj.CommitmentLength__c = '36';
            mbObj.Start_Date__c = '20200429';
            mbObj.Subscription_Type__c = 'VOICE';
            mbObj.TeliaSE_Subscription_Name__c = 'Jobbmobil 25 GB Ram';
            mbObj.TeliaSE_User_Name__c = 'Test 4, AB';
            mbObj.Last_Used_Model__c= 'Iphone X';
            mbObj.Roaming_Service_Descr__c = 'Res Österut,Till utlandet företag	';
            mbObjList.add(mbObj);
            Mobilabonnemang__c mbObj1 = new Mobilabonnemang__c();
            mbObj1.Allowed_To_Bind__c = 'NEJ';
            mbObj1.Subsidized_Subscription__c = 'JA';
            mbObj1.Binding_Time_Left__c = '831 dagar';
            mbObj1.Agreement__c = '78000311';
            mbObj1.Category__c = 'Mobila talabonnemang';
            mbObj1.GPRS_Service_Allowance__c = '';
            mbObj1.MSISDN__c = '46705076687';
            mbObj1.Account__c = String.ValueOf(acc.id);
            mbObj1.Subscription_Id__c = '0705076687';
            mbObj1.Offering_Name__c = '95';
            mbObj1.CommitmentEndDate__c = '2023-04-30';
            mbObj1.CommitmentStartDate__c = '2020-04-30';
            mbObj1.CommitmentLength__c = '36';
            mbObj1.Start_Date__c = '20200429';
            mbObj1.Subscription_Type__c = 'VOICE';
            mbObj1.TeliaSE_Subscription_Name__c = 'Jobbmobil 25 GB Ram';
            mbObj1.TeliaSE_User_Name__c = 'Test 4, AB';
            mbObj1.Last_Used_Model__c= 'Iphone X';
            mbObj1.Roaming_Service_Descr__c = 'Res Österut,Till utlandet företag	';
            mbObjList.add(mbObj1);
            Mobilabonnemang__c mbObj2 = new Mobilabonnemang__c();
            mbObj2.Allowed_To_Bind__c = 'NEJ';
            mbObj2.Subsidized_Subscription__c = 'JA';
            mbObj2.Binding_Time_Left__c = '831 dagar';
            mbObj2.Agreement__c = '78000311';
            mbObj2.Category__c = 'Mobila talabonnemang';
            mbObj2.GPRS_Service_Allowance__c = '';
            mbObj2.MSISDN__c = '46705076687';
            mbObj2.Account__c = String.ValueOf(acc.id);
            mbObj2.Subscription_Id__c = '0705076687';
            mbObj2.Offering_Name__c = '95';
            mbObj2.CommitmentEndDate__c = '2023-04-30';
            mbObj2.CommitmentStartDate__c = '2020-04-30';
            mbObj2.CommitmentLength__c = '36';
            mbObj2.Start_Date__c = '20200429';
            mbObj2.Subscription_Type__c = 'VOICE';
            mbObj2.TeliaSE_Subscription_Name__c = 'Jobbmobil 25 GB Ram';
            mbObj2.TeliaSE_User_Name__c = 'Test 4, AB';
            mbObj2.Last_Used_Model__c= 'Iphone X';
            mbObj2.Roaming_Service_Descr__c = 'Res Österut,Till utlandet företag	';
            mbObjList.add(mbObj2);
            insert mbObjList;
            string refinedString = '<?xml version=\"1.0\" encoding=\"UTF-8\"?><?mso-application progid=\"Excel.Sheet\"?><ss:Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:x=\"urn:schemas-microsoft-com:office:excel\" xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\" xmlns:html=\"http://www.w3.org/TR/REC-html40\"><ss:Styles><ss:Style ss:ID=\"st1\" ss:Name=\"Normal\"><ss:Font ss:Bold=\"1\"/><ss:Alignment  ss:Horizontal=\"Left\"  ss:Vertical=\"Center\"/><ss:Interior ss:Color=\"#C7C7C1\" ss:Pattern=\"Solid\"/></ss:Style><ss:Style ss:ID=\"st2\"><ss:Alignment ss:WrapText=\"1\" ss:Horizontal=\"Left\"  ss:Vertical=\"Center\"/></ss:Style><ss:Style ss:ID=\"st3\"><ss:Alignment ss:Horizontal=\"Left\"  ss:Vertical=\"Center\"/></ss:Style><ss:Style ss:ID=\"st4\"><ss:Font ss:Size=\"14\"  ss:Bold=\"1\"/><ss:Alignment ss:Horizontal=\"Center\"  ss:Vertical=\"Center\"/></ss:Style></ss:Styles><ss:Worksheet ss:Name=\"SubscriptionInfo\"><ss:Table ss:StyleID=\"st2\"  x:FullColumns=\"1\" x:FullRows=\"1\"><ss:Column ss:Width=\"120\"/><ss:Column ss:Width=\"250\"/><ss:Column ss:Width=\"300\"/><ss:Row><ss:Cell ss:StyleID=\"st1\"><ss:Data ss:Type=\"String\" >Nummer</ss:Data></ss:Cell><ss:Cell ss:StyleID=\"st1\"><ss:Data ss:Type=\"String\" >Namn</ss:Data></ss:Cell><ss:Cell ss:StyleID=\"st1\"><ss:Data ss:Type=\"String\" >Produkt</ss:Data></ss:Cell><ss:Cell ss:StyleID=\"st1\"><ss:Data ss:Type=\"String\" >Bindningstid slutdatum</ss:Data></ss:Cell><ss:Cell ss:StyleID=\"st1\"><ss:Data ss:Type=\"String\" >Kan bindas om JA/NEJ</ss:Data></ss:Cell><ss:Cell ss:StyleID=\"st1\"><ss:Data ss:Type=\"String\" >Växeltjänst JA/NEJ</ss:Data></ss:Cell><ss:Cell ss:StyleID=\"st1\"><ss:Data ss:Type=\"String\" >Modell</ss:Data></ss:Cell><ss:Cell ss:StyleID=\"st1\"><ss:Data ss:Type=\"String\" >IMEI</ss:Data></ss:Cell><ss:Cell ss:StyleID=\"st1\"><ss:Data ss:Type=\"String\" >Roamingtjänster</ss:Data></ss:Cell></ss:Row><ss:Row><ss:Cell><ss:Data ss:Type=\"String\">0705076687</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">HILLSTA HUS OCH FASTIGHETER, AB</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Jobbmobil 25 GB Ram</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">2021-03-30</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">JA</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">78000311</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Iphone X</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">46705076687</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Res Österut,Till utlandet företag</ss:Data></ss:Cell></ss:Row><ss:Row><ss:Cell><ss:Data ss:Type=\"String\">0705076686</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Test 4, AB</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Jobbmobil 40 GB Ram</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">2021-03-03</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">JA</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">78000311</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Iphone XS</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">46705076686</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Res Österut</ss:Data></ss:Cell></ss:Row><ss:Row><ss:Cell><ss:Data ss:Type=\"String\">0705076685</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Test 3, AB</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Jobbmobil 120 GB Ram</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">2022-04-29</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">NEJ</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">78000311</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Iphone 8</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">46705076685</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Till utlandet företag</ss:Data></ss:Cell></ss:Row><ss:Row><ss:Cell><ss:Data ss:Type=\"String\">0705076684</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Test 2, AB</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Jobbmobil Obegränsad</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">2023-04-20</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">NEJ</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">78000311</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Iphone X1</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">46705076684</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Till utlandet företag</ss:Data></ss:Cell></ss:Row><ss:Row><ss:Cell><ss:Data ss:Type=\"String\">0705076683</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Test 1, AB</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Jobbmobil 1 GB Ram</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">2020-07-10</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">NEJ</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">78000311</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Iphone X</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">46705076683</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Till utlandet företag</ss:Data></ss:Cell></ss:Row><ss:Row><ss:Cell><ss:Data ss:Type=\"String\">0705076682</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Test 7, AB</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Jobbmobil 3 GB Ram</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">2020-06-11</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\"></ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">78000311</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">Iphone 7</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\">46705076682</ss:Data></ss:Cell><ss:Cell><ss:Data ss:Type=\"String\"></ss:Data></ss:Cell></ss:Row></ss:Table><WorksheetOptions xmlns=\"urn:schemas-microsoft-com:office:excel\"><Selected/><ProtectObjects>False</ProtectObjects><ProtectScenarios>False</ProtectScenarios></WorksheetOptions></ss:Worksheet></ss:Workbook>';
            ContentVersion cVersion = new ContentVersion();
        	cVersion.ContentLocation = 'S';
        	cVersion.PathOnClient = 'Mobilt bestånd-Vamsi_test-2021-02-18 00:00:00';
        	cVersion.Origin = 'H'; //C-Content Origin. H-Chatter Origin.
        	cVersion.OwnerId = userinfo.getUserId();
        	cVersion.Title = 'Mobilt bestånd-Vamsi_test-2021-02-18 00:00:00';
        	cVersion.VersionData = Blob.valueof(refinedString); //File content
        	Insert cVersion;
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.LinkedEntityId = acc.id;
            cdl.ContentDocumentId = conDocument; //Add ContentDocumentId
       		cdl.ShareType = 'I'; //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        	cdl.Visibility = 'AllUsers';
       	    
            insert cdl;
            TeliaSE_ExportExcelHardwareSubscripton.excelConvert(acc.Id);
        }        
    }
}