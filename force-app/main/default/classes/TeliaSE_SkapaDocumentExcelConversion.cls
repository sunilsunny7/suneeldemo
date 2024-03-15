global without Sharing class TeliaSE_SkapaDocumentExcelConversion implements vlocity_cmt.VlocityOpenInterface2 {

    String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outputMap, Map < String, Object > options) {
        if (methodName.equals('excelConvert')) {
            excelConvert(inputMap, outputMap);
        }
        return true;
    }

    private void excelConvert(Map < String, Object > inputMap, Map < String, Object > outputMap) {
        Id contractId = (Id) inputMap.get('id');
        string excelXML = prepareHeaderAndStyles();
        excelXML += prepareWorkSheet(inputMap);
        excelXML += '</ss:Workbook>';

        String docTitle = 'Orderunderlag-' + inputMap.get('Business') + '-' + inputMap.get('ContractNumber') + '.xls';
        //remove null values to be printed as empty in excel
        String refinedString = excelXML.replace('null', '');
        List < ContentDocumentLink > cdl = new List < ContentDocumentLink > ();
        cdl = [Select Id from ContentDocumentLink where LinkedEntityId =: contractId AND ContentDocument.Title like 'Orderunderlag%'];
        if (cdl.size() > 0) {
            try {
                delete cdl;
            } catch (Exception e) {
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
        try {
            Insert cVersion;
        } catch (Exception e) {
            System.debug('The following exception has occurred when inserting cVersion: ' + e.getMessage());
        }
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cVersion.Id].ContentDocumentId;
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument; //Add ContentDocumentId
        cDocLink.LinkedEntityId = contractId;
        cDocLink.ShareType = 'I'; //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        cDocLink.Visibility = 'AllUsers';
        try {
            Insert cDocLink;
        } catch (Exception e) {
            System.debug('The following exception has occurred when inserting doclink: ' + e.getMessage());
        }
        String downloadLink = baseUrl + '/sfc/servlet.shepherd/version/download/' + cVersion.Id;
        outputMap.put('DocLink', downloadLink);
    }

    public static string prepareWorkSheet(Map < String, Object > data) {
        string jsonstring = Json.serialize(data);
        System.debug('jsonstring' + jsonstring);
        JsonParser JSONreqbody = (JsonParser) JSON.deserialize(jsonstring, JsonParser.class);
        System.debug('::JSONreqbody' + JSONreqbody);

        List < String > sMDUIPTVName = JSONreqbody.MDUIPTVName;
        String strMDUIPTVName = '';
        for (String s1: sMDUIPTVName) {
            strMDUIPTVName += s1 + '&#10;';
        }
        
        List < String > sMDUCollIPTVName = JSONreqbody.MDUCollIPTV;
        String strMDUCollIPTVName = '';
        if(JSONreqbody.MDUCollIPTV != null){ 
            for (String s: sMDUCollIPTVName) {   
                strMDUCollIPTVName += s + '&#10;';  
            }
        }
        
        
        List < String > sMDUCOAXTVName = JSONreqbody.MDUCOAXTVName;
        String strMDUCOAXTVName = '';
        for (String s2: sMDUCOAXTVName) {
            strMDUCOAXTVName += s2 + '&#10;';
        }

        List < String > sMDUIPTVNDFName = JSONreqbody.MDUIPTVNDFName;
        String strMDUIPTVNDFName = '';
        for (String s3: sMDUIPTVNDFName) {
            strMDUIPTVNDFName += s3 + '&#10;';
        }


        List < String > sMDUCHT1707Name = JSONreqbody.MDUCHT1707Name;
        String strMDUCHT1707Name = '';
        for (String s4: sMDUCHT1707Name) {
            strMDUCHT1707Name += s4 + '&#10;';
        }

        List < String > sMDUCHW1707Name = JSONreqbody.MDUCHW1707Name;
        String strMDUCHW1707Name = '';
        for (String s5: sMDUCHW1707Name) {
            strMDUCHW1707Name += s5 + '&#10;';
        }
        
        List < String > sMDUSHName = JSONreqbody.MDUSHName;
        String strMDUSHName = '';
        for (String s6: sMDUSHName) {
            strMDUSHName += s6 + '&#10;';
        }
        
        string s = '<ss:Worksheet ss:Name="Orderunderlag">';
        s += '<ss:Table ss:StyleID="st2"  x:FullColumns="1" x:FullRows="1"><ss:Column ss:Width="120"/><ss:Column ss:Width="250"/><ss:Column ss:Width="300"/>';

        // header row START ==================>
        s += '<ss:Row><ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >Informationstyp/Sektion</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >Namn</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st1"><ss:Data ss:Type="String" >Information</ss:Data></ss:Cell>';
        s += '</ss:Row>';
        // header row END ==================>
        // DATA ROWS

        //************************************************************General****************************************************************

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Allmänt' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Typ av affär' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.General.TypeOfBusiness + '</ss:Data></ss:Cell></ss:Row>';
        
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Allmänt' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'WBS-nummer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.General.WBSnumber + '</ss:Data></ss:Cell></ss:Row>';
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Allmänt' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Offerttyp' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.General.OfferType + '</ss:Data></ss:Cell></ss:Row>';
        //add here
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Allmänt' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Varumärke' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.General.Brand1 + '</ss:Data></ss:Cell></ss:Row>';


        //************************************************************Kundinformation****************************************************************

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Säljare' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.SellerName1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Säljare - Telefonnummer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.SellerPhone1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Säljare - Epost' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.SellerEmail1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Avtalspart' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.Business1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'KO-nummer/avtalsnummer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.KONumber + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Organisationsnummer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.OrgNumber1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Namn ut mot kund' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell ss:StyleID="st3"><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.Business1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Beställare hos avtalspart - Namn, Telefon, Adress, E-post' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.ClientContactDetails.ContactName1 + '&#10;' + JSONreqbody.Orderunderlag.Customer_Information.ClientContactDetails.ContactEmail1 + '&#10;' + JSONreqbody.Orderunderlag.Customer_Information.ClientContactDetails.ContactPhone1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Fakturaadress 1' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.BillingAdress1.BillingStreet1 + ',' + JSONreqbody.Orderunderlag.Customer_Information.BillingAdress1.BillingPostalCode1 + ',' + '&#10;' + JSONreqbody.Orderunderlag.Customer_Information.BillingAdress1.BillingCity1 + ',' + '&#10;' + JSONreqbody.Orderunderlag.Customer_Information.BillingAdress1.BillingCountry1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Avtalsnummer Salesforce' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.ContractNumber1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Ursprungligt Avtalsnummer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.FiberBaseContractNumber1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Frånträdande kund' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.OutgoingCustomer + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Fakturaadress 2' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.BillingAdress2 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Frånträdande kund org.nr.' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.OutgoingCustomerOrgNr + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kontaktperson 1: Namn, Tel.nr., e-post & adress' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.ContactPerson1NameTelephoneEmailAdress + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kontaktperson 1 för:' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.ContactPerson1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kontaktperson 2: Namn, Tel.nr., e-post & adress' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.ContactPerson2NameTelephoneEmailAdress + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kontaktperson 2 för:' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.ContactPerson2 + '</ss:Data></ss:Cell></ss:Row>';



        /*

s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kontakt - fakturering' + '</ss:Data></ss:Cell>';
s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.BillingContact + '</ss:Data></ss:Cell></ss:Row>';

s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kontaktperson för leverans av hårdvara och kodkuvert (postadress)' + '</ss:Data></ss:Cell>';
s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.PostalAddress + '</ss:Data></ss:Cell></ss:Row>';

s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kontaktperson för marknadsmaterial' + '</ss:Data></ss:Cell>';
s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.ContactPersonMarketingMaterials + '</ss:Data></ss:Cell></ss:Row>';

s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kundinformation' + '</ss:Data></ss:Cell>';
s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kontaktperson för information om FS-tjänst' + '</ss:Data></ss:Cell>';
s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Customer_Information.AdditionalCustomerDetails.ContactPersonFSServicce + '</ss:Data></ss:Cell></ss:Row>'; */
        //******************************************************************Affären*******************************************************************************

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Ska lev. ske i etapper?' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.Stage + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Extern fiber' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.ExternalFiber + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Extern nätägare (Namn)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.ExternalOwnerName + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Avtalstid' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.ContractTerm1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Önskat leveransdatum (ej löfte)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.WishedDeliveryDate1 + '</ss:Data></ss:Cell></ss:Row>';
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Leveransperiod i avtalet' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.Promiseddeliverytime1 + ' månader' + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Önskat leveransdatum kabeltv (ej löfte)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.WishedDeliveryDateCoax1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Termineringsdatum' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.ContractTerminationDate1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Nyproduktion' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.NewProductionOfBuilding1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Inflyttningsdatum' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.OccupancyDate + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Hera-nummer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.HeraNo1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Bygga områdesnät' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.BuildAreaNetwork1 + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Befintligt fastighetsnät' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.Fastighetsnat1 + '</ss:Data></ss:Cell></ss:Row>';



        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Totalt antal portar (Fiber)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.FiberNumberOfPort1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Varav antal hushåll (Fiber)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.FiberNumberOfHouseholds1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Varav antal lokaler (Fiber)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.FiberNumberOfPremises1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Varav antal FS-portar (Fiber)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.FiberNumberOfOtherPorts1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Totalt antal portar (Koppar)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.KoperNumberOfPort1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Varav antal hushåll (Koppar)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.KoperNumberOfHouseholds1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Varav antal lokaler (Koppar)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.KoperNumberOfPremises1 + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Varav antal FS-portar (Koppar)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.KoperNumberOfOtherPorts1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Installationshjälp' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.TypeOfInstallationHelp1 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Lägenhetsnät (extrauttag)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.Is_MDULES1729 + '</ss:Data></ss:Cell></ss:Row>';

        //add field- Byte av Ström?
        //add field- Ska informationsbrev skickas?
        //******
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Byte av Ström?' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.ReplacingPower + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Ska informationsbrev skickas?' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.InformationLetterSent + '</ss:Data></ss:Cell></ss:Row>';
        //*****
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Affärsinformation' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Antal lgh med 1 enkeluttag' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Store.Quantity_MDULES1729 + '</ss:Data></ss:Cell></ss:Row>';

        //***********************************************************************Hårdvara**************************************************************************

       	s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Utbyte av switch (uppgradering 100 -> 1000Mbit)' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Hardware.SwitchReplacement1 + '</ss:Data></ss:Cell></ss:Row>';	

		
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Bredbandsswitch' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Hardware.BroadbandSwitch + '</ss:Data></ss:Cell></ss:Row>';
        
		
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Antal kollektiva BBS (enbart vid kollektiva tjänster)' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Hardware.NumberOfCollectiveBB_SCTSBroadbandSwitch + '</ss:Data></ss:Cell></ss:Row>';
          
   
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Antal MC (hela paketet)' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Hardware.NumberOfMCs_WholePackage + '</ss:Data></ss:Cell></ss:Row>';
          

		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Trådlös router' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Hardware.Name_HaleBOPHW + '</ss:Data></ss:Cell></ss:Row>';


		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Antal trådlös router (enbart vid kollektiva tjänster)' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Hardware.Quantity_HaleBOPHW + '</ss:Data></ss:Cell></ss:Row>';


		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Trådlös router - engångsavgift/styck (exkl. moms)' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Hardware.OTC_HaleBOPHW + '</ss:Data></ss:Cell></ss:Row>';
             
       
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Digitalbox' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + strMDUCHT1707Name + '</ss:Data></ss:Cell></ss:Row>';       
        
        
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Antal digitalboxar (enbart vid kollektiva tjänster)' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Hardware.Quantity_MDUCHT1707 + '</ss:Data></ss:Cell></ss:Row>';       
  
  
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Trådlös Tv' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + strMDUCHW1707Name + '</ss:Data></ss:Cell></ss:Row>';


		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Hårdvara' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + 'Antal Trådlös Tv' + '</ss:Data></ss:Cell>';
		s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Hardware.Quantity_MDUCHW1707+ '</ss:Data></ss:Cell></ss:Row>';
        
        //*************************************************************************************************************************************************

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Telia Bredbandshastighet' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.Name_MDUCOLBB + '</ss:Data></ss:Cell></ss:Row>';
        

 
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Telia Bredband - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.Quantity_MDUCOLBB + '</ss:Data></ss:Cell></ss:Row>';
        

   
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Telia Bredband - pris/port/mån (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.RCT_MDUCOLBB + '</ss:Data></ss:Cell></ss:Row>';
        
        

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Telia Bredband - Aktiveringstyp' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.CollectiveBroadbandActivationType + '</ss:Data></ss:Cell></ss:Row>';
        
        /******************** Halebop BB ********************/
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Halebop Bredbandshastighet' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.HalebopBB_Name + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Halebop Bredband - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.HalebopBB_Quantity + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Halebop Bredband - pris/port/mån (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.HalebopBB_RCT + '</ss:Data></ss:Cell></ss:Row>';
               
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Halebop Bredband - Aktiveringstyp' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.CollectiveHalebopBBandActivationType + '</ss:Data></ss:Cell></ss:Row>';
        
  
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'VOIP' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.Name_MDUCOLVOIP + '</ss:Data></ss:Cell></ss:Row>';
        
   
   
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'VOIP - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.Quantity_MDUCOLVOIP + '</ss:Data></ss:Cell></ss:Row>';
        
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'VOIP - pris/port/mån (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.RCT_MDUCOLVOIP + '</ss:Data></ss:Cell></ss:Row>';
        

 
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'VOIP - Aktiveringstyp' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.VOIPActivationType + '</ss:Data></ss:Cell></ss:Row>';
        
        
 
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'IPTV-paket' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + strMDUIPTVName + '</ss:Data></ss:Cell></ss:Row>';
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'IPTV - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.Quantity_MDUIPTV + '</ss:Data></ss:Cell></ss:Row>';
        
         
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'IPTV - pris/port/mån (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.RCT_MDUIPTV + '</ss:Data></ss:Cell></ss:Row>';
        
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'IPTV Aktiveringstyp' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.IPTVActivationType + '</ss:Data></ss:Cell></ss:Row>';
        
    
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Tvilling-paket' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + strMDUCollIPTVName + '</ss:Data></ss:Cell></ss:Row>';
        
            
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Tvilling - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.Quantity_MDU_CollIPTV_Twin_2119 + '</ss:Data></ss:Cell></ss:Row>';
        
         
 
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Tvilling - pris/port/mån (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.RCT_MDUCollIPTV_Twin_2119 + '</ss:Data></ss:Cell></ss:Row>';
        
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Tvilling - Aktiveringstyp' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.CollIPTVActivationType + '</ss:Data></ss:Cell></ss:Row>';
        
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Utländska kanaler (Grannlandskanaler)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + strMDUIPTVNDFName + '</ss:Data></ss:Cell></ss:Row>';
        

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Utländska kanaler – antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.Quantity_MDUIPTVNDF + '</ss:Data></ss:Cell></ss:Row>';
        
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Utländska kanaler pris/port/mån (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.RCT_MDUIPTVNDF + '</ss:Data></ss:Cell></ss:Row>';
        
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Utländska kanaler Aktiveringstyp' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.MDUIPTVNDFActivationType + '</ss:Data></ss:Cell></ss:Row>';

        //For IPTVB2B products
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'B2B-TV-paket' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.MDU_CollIPTVB2B_Name + '</ss:Data></ss:Cell></ss:Row>';
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'B2B-TV - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.MDU_CollIPTVB2B_Quantity + '</ss:Data></ss:Cell></ss:Row>';
                 
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'B2B-TV - pris/port/mån (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.MDU_CollIPTVB2B_RCT + '</ss:Data></ss:Cell></ss:Row>';
                
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'B2B-TV - Aktiveringstyp' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.CollectiveB2BActivationType + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt kabel-tv-paket' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + strMDUCOAXTVName + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt kabel-tv-paket – antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.Quantity_MDUCOAXTV + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kollektiv kabel-tv - pris/port/mån (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.RCT_MDUCOAXTV + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kollektiv kabel-tv - Aktiveringstyp' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.CollectiveCableTvActivationType + '</ss:Data></ss:Cell></ss:Row>';
       
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Smart Home' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + strMDUSHName + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Smart Home – antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.Quantity_MDUSH + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Smart Home - pris/port/mån (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.RCT_MDUSH + '</ss:Data></ss:Cell></ss:Row>';

        /*s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'SmartHome - engångsavgift (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.OTC_MDUSH + '</ss:Data></ss:Cell></ss:Row>';*/
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Smart Home - engångsavgift - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.Quantity_MDUSHOTC + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Kollektivt Aktivering' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Smart Home - engångsavgift/styck (exkl. moms)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.CollectiveActivation.OTC_MDUSH + '</ss:Data></ss:Cell></ss:Row>';
        
      //***********************************************************************FÄ-tjänster**************************************************************************
      
        if(JSONreqbody.Orderunderlag.FA_Services.OnetimePropertyOwner1 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Etableringsavgift (inkl fastighetsnät, områdesnät och installationshjälp)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.OnetimePropertyOwner1 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.OneTimeFeeTeliaPropertyManagement != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Engångsavgift Telia Fastighetsstyrning (kr)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.OneTimeFeeTeliaPropertyManagement + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFBA1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS BAS' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFBA1613 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFBA1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Bas - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFBA1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFBA1613!=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Bas - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFBA1613 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFE10AF1613 !=null){
        //added 6 new products
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra Access Fiber 10 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFE10AF1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFE10AF1613 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra Access Fiber 10 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFE10AF1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFE10AF1613 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra Access Fiber 10 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFE10AF1613 + '</ss:Data></ss:Cell></ss:Row>';
        }    

        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFE100AF1613 !=null)
		{
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra Access Fiber 100 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFE100AF1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFE100AF1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra Access Fiber 100 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFE100AF1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFE100AF1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra Access Fiber 100 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFE100AF1613 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSEXTRAAccessFiber1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra Access Fiber 2 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSEXTRAAccessFiber1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSEXTRAAccessFiber1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra Access Fiber 2 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSEXTRAAccessFiber1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSEXTRAAccessFiber1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra Access Fiber 2 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSEXTRAAccessFiber1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSWANAccess1001617 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN Access 100 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSWANAccess1001617 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSWANAccess1001617 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN Access 100 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSWANAccess1001617 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSWANAccess1001617 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN Access 100 Mbps- pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSWANAccess1001617 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSWANNatAccess101744 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN Nät 10 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSWANNatAccess101744 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSWANNatAccess101744 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN Nät 10 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSWANNatAccess101744 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSWANNatAccess101744!=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN Nät 10 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSWANNatAccess101744 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSWANNatAccess1001744 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN Nät 100 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSWANNatAccess1001744 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSWANNatAccess1001744 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN Nät 100 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSWANNatAccess1001744 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSWANNatAccess1001744 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN Nät 100 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSWANNatAccess1001744 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFBC1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Bas med BBS' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFBC1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFBC1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Bas med BBS - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFBC1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFBC1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Bas med BBS - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFBC1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFEA1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra 2 Mpbs' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFEA1613 + '</ss:Data></ss:Cell></ss:Row>';
        }    

        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFEA1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra 2 Mpbs - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFEA1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFEA1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra 2 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFEA1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFE10A1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra 10 Mpbs' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFE10A1613 + '</ss:Data></ss:Cell></ss:Row>';
        }    

        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFE10A1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra 10 Mpbs - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFE10A1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFE10A1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra 10 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFE10A1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFE100A1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra 100 Mpbs' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFE100A1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFE100A1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra 100 Mpbs - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFE100A1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFE100A1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Extra 100 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFE100A1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
     
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWA1613 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 0,5 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWA1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWA1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 0,5 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWA1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWA1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 0,5 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWA1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWA21613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 2 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWA21613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWA21613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 2 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWA21613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWA21613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 2 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWA21613 + '</ss:Data></ss:Cell></ss:Row>';
        }
            
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWA101613 != null){   
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 10 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWA101613 + '</ss:Data></ss:Cell></ss:Row>';
        }
         
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWA101613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 10 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWA101613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWA101613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 10 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWA101613 + '</ss:Data></ss:Cell></ss:Row>';
        }
         
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWA1001613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 100 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWA1001613 + '</ss:Data></ss:Cell></ss:Row>';
        }
         
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWA1001613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 100 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWA1001613 + '</ss:Data></ss:Cell></ss:Row>';
        }
         
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWA1001613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN 100 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWA1001613 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWC1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN med bbs 0,5 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWC1613 + '</ss:Data></ss:Cell></ss:Row>';
        }    

        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWC1613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN med bbs 0,5 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWC1613 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWC1613 != null){    
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN med bbs 0,5 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWC1613 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWC21613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN med bbs 2 Mbps' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFWC21613 + '</ss:Data></ss:Cell></ss:Row>';
        }
            
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWC21613 != null){    
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN med bbs 2 Mbps - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFWC21613 + '</ss:Data></ss:Cell></ss:Row>';
        }    
   
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWC21613 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS WAN med bbs 2 Mbps - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFWC21613 + '</ss:Data></ss:Cell></ss:Row>';
        }
         
        /******************** Halebop and Zitius Start ********************/
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSInternet2 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 2 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSInternet2 + '</ss:Data></ss:Cell></ss:Row>';
        }     
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSInternet2 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 2 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSInternet2 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSInternet2 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 2 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSInternet2 + '</ss:Data></ss:Cell></ss:Row>';
        }
               
	    if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSInternet10 != null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 10 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSInternet10 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSInternet10 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 10 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSInternet10 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSInternet10 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 10 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSInternet10 + '</ss:Data></ss:Cell></ss:Row>';
        }
		
        if( JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSInternet100 != null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 100 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSInternet100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSInternet100 != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 100 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSInternet100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSInternet100 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 100 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSInternet100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
		if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSInternet1000 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 1000 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSInternet1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSInternet1000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 1000 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSInternet1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSInternet1000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Internet 1000 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSInternet1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
		if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSIPVPN2 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 2 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSIPVPN2 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSIPVPN2 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 2 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSIPVPN2 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSIPVPN2 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 2 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSIPVPN2 + '</ss:Data></ss:Cell></ss:Row>';
        }
		
        if(JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSIPVPN10 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 10 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSIPVPN10 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSIPVPN10 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 10 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSIPVPN10 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSIPVPN10 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 10 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSIPVPN10 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if( JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSIPVPN100 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 100 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSIPVPN100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSIPVPN100 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 100 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSIPVPN100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSIPVPN100 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 100 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSIPVPN100 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if( JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSIPVPN1000 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 1000 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSIPVPN1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSIPVPN1000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 1000 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSIPVPN1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSIPVPN1000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS IP-VPN 1000 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSIPVPN1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSVPN2 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 2 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSVPN2 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSVPN2 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 2 Mbit/s  - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSVPN2 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSVPN2 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 2 Mbit/s  - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSVPN2 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if( JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSVPN10 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 10 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSVPN10 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSVPN10 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 10 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSVPN10 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSVPN10 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 10 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSVPN10 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSVPN100 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 100 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSVPN100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSVPN100 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 100 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSVPN100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSVPN100 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 100 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSVPN100 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if( JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSVPN1000 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 1000 Mbit/s' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFSVPN1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if( JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSVPN1000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 1000 Mbit/s - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFSVPN1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSVPN1000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS VPN 1000 Mbit/s - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFSVPN1000 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_100 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport 100' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_100 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport 100 - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_100 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport 100 - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_1000 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport 1000' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_1000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport 1000 - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_1000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport 1000 - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_10000 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport 10000' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_10000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_10000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport 10000 - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_10000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_10000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport 10000 - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_10000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_VPN100 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport VPN 100' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_VPN100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_VPN100 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport VPN 100 - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_VPN100 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_VPN100 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport VPN 100 - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_VPN100 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_VPN1000 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport VPN 1000' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_VPN1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_VPN1000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport VPN 1000 - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_VPN1000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_VPN1000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport VPN 1000 - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_VPN1000 + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_VPN10000 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport VPN 10000' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_FS_Etableringsport_VPN10000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_VPN10000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport VPN 10000 - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Etableringsport_VPN10000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_VPN10000 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Etableringsport VPN 10000 - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Etableringsport_VPN10000 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Name_FS_Nationellt_tillagg_2019 !=null){
		s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Nationellt tillägg' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_FS_Nationellt_tillagg_2019 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Nationellt_tillagg_2019 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Nationellt tillägg - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_FS_Nationellt_tillagg_2019 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Nationellt_tillagg_2019 !=null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Nationellt tillägg - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_FS_Nationellt_tillagg_2019 + '</ss:Data></ss:Cell></ss:Row>';
        }
        
		//******************** Halebop and Zitius End ********************//
        
        if(JSONreqbody.Orderunderlag.FA_Services.FullMeshOrHubSpooke != null){ 
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Full mesh eller Hub-spooke' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.FullMeshOrHubSpooke + '</ss:Data></ss:Cell></ss:Row>';
        }
        
        if(JSONreqbody.Orderunderlag.FA_Services.CentralPointAddress != null){    
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Centralpunktsadress' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.CentralPointAddress + '</ss:Data></ss:Cell></ss:Row>';
        }

        if(JSONreqbody.Orderunderlag.FA_Services.FNTnumber != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FNT-nummer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.FNTnumber + '</ss:Data></ss:Cell></ss:Row>';
        }    

        if(JSONreqbody.Orderunderlag.FA_Services.IsItANewBridge != null){
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Är det en ny nätbrygga?' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.IsItANewBridge + '</ss:Data></ss:Cell></ss:Row>';
        }
        /*
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Nät' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDU_FS_NAT_Access_1718 + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Nät - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDU_FS_NAT_Access_1718 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Nät - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDU_FS_NAT_Access_1718 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Nät med BBS' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Name_MDUFNC1718 + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Nät med BBS - antal portar' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.Quantity_MDUFNC1718 + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'FS Nät med BBS - pris/port/mån (ex moms) (giltig om antal portar >0)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.RCT_MDUFNC1718 + '</ss:Data></ss:Cell></ss:Row>';*/

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal (OBS! se flik SERVICE SPACER)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.ServiceAgreementServiceSpacer + '</ss:Data></ss:Cell></ss:Row>';
                 
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Antal portar (Fiber)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.ServiceAgreement_NumberOfPorts_FiberOrFTTH + '</ss:Data></ss:Cell></ss:Row>';
            

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - pris/port/mån (exkl moms) - totalt (Fiber)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.ServiceAgreement_PricePerMonthFiberOrFTTH + '</ss:Data></ss:Cell></ss:Row>';
        
        
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Antal portar (Koppar)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.ServiceAgreement_NumberOfPorts_CopperOrFTTB + '</ss:Data></ss:Cell></ss:Row>';
        
         
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - pris/port/mån (exkl moms) - totalt (Koppar)' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.ServiceAgreement_PricePerMonthCopperOrFTTB + '</ss:Data></ss:Cell></ss:Row>';
        
         
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal på kabel-tv' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.ServiceAgreementCableTV + '</ss:Data></ss:Cell></ss:Row>';
        
    
        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'FÄ-tjänster' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal på kabel-tv - pris/port/mån (exkl moms) - totalt eller per port?' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.FA_Services.ServiceAgreementCableTV_PricePerMonth + '</ss:Data></ss:Cell></ss:Row>';
       



        //*************************************************************************Övrigt************************************************************************


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Övrigt' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Kundägt nät?' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Other.Customer_OwnedNetwork + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Övrigt' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Produktkod' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Other.ProductCodeInAlpha + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Övrigt' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Stationsnamn' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Other.StationsName + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Övrigt' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Övrig information' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.Other.OtherInformation + '</ss:Data></ss:Cell></ss:Row>';

        //*************************************************************************Serviceavtal************************************************************************


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Ange specifik instruktion till den första tekniker som skickas till kunden vid feltypen "Ej länk"' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.InstructionsFor1stTechnicianUnlinkErrorType + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Finns det specifik information gällande detta avtal som inte ingår i övrig registrering och som ska presenteras för Telias handläggare i Billing-processen? ' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.InfoNotIncludedInRegistration + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Skriv in den specifika information som ska presenteras för Telias handläggare i Billing-processen' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.FurtherInfoForBilling + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Var anges uppgifter om Teknisk(a) kontaktperson(er) ? ' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.InfoAboutTechnicalContactPerson + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Ange EN gemensam kontaktväg för hela KO-avtalet' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.ONEcommonContactPathForEntireKOagreement + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Finns det information till  tekniker som är specifik för just detta KO-avtal?' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.InfoForTechniciansSpecifictoParticularKOagreement + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Ange den ytterligare information som för just detta specifika KO-avtal ska presenteras för tekniker som skickas till kunden' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.AdditionalInfoForTechnicians + '</ss:Data></ss:Cell></ss:Row>';


        //s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        // s += '<ss:Cell><ss:Data ss:Type="String">' + 'En eller flera kontaktpersoner för service?' + '</ss:Data></ss:Cell>';
        //s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.OneOrMoreContactPersonsForService + '</ss:Data></ss:Cell></ss:Row>';


        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Finns det specifik information för just detta avtal som ska presenteras för extern tjänsteleverantör för användande i Service/support-processen som ej framgår av övrig registrering?' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.InfoToExternalServiceProvider + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Skriv in den specifika information som ska presenteras för extern tjänsteleverantör för användande i Service/support-processen som ej framgår av övrig registrering?' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.AdditionalInfo_ServiceSupport + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Finns det specifik information i just detta avtal som ska presenteras för Telias handläggare i SA-processen?' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.SpecificInfoInAgreementTeliaOfficersSAprocess + '</ss:Data></ss:Cell></ss:Row>';

        s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Serviceavtal - Service Spacer' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + 'Skriv in den specifika information som ska presenteras för Telias handläggare i SA-processen' + '</ss:Data></ss:Cell>';
        s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.Orderunderlag.ServiceAgreement.SpecificInfoToTeliaAdministratorSAprocess + '</ss:Data></ss:Cell></ss:Row>';


        //******************************************************************************FLIT*******************************************************************


        if (jsonstring.contains('FlitDetailsList')) {
            integer length1 = JSONreqbody.FlitDetailsList.size();
            system.debug('#####' + length1);
            for (integer i = 0; i < length1; i++) {
                s += '<ss:Row><ss:Cell><ss:Data ss:Type="String">' + 'Flit' + '</ss:Data></ss:Cell>';
                s += '<ss:Cell><ss:Data ss:Type="String">' + 'Adressanslutning' + '&#10;' + 'Antal lägenheter' + '&#10;' + 'Price per adressanslutning (exkl. moms)' + '</ss:Data></ss:Cell>';
                s += '<ss:Cell><ss:Data ss:Type="String">' + JSONreqbody.FlitDetailsList[i].Address + '&#10;' + JSONreqbody.FlitDetailsList[i].NumberOfApartments + '&#10;' + JSONreqbody.FlitDetailsList[i].Price + '</ss:Data></ss:Cell></ss:Row>';
            }
        }
        //*************************************************************************************************************************************************


        s += '</ss:Table>';
        s += '<WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">';
        s += '<Selected/>';
        //s += '<DoNotDisplayGridlines/>';
        s += '<ProtectObjects>False</ProtectObjects>';
        s += '<ProtectScenarios>False</ProtectScenarios>';
        s += '</WorksheetOptions>';
        s += '</ss:Worksheet>';
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