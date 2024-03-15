@isTest
public class Test_Orderunderlag_controller {
    public static testmethod void Orderunderlag_controllerTest() {
        test.starttest();
        Account newA = test_DataFactory.createOneLargeStandardAccount();
        newA.Name = 'Testkknr';
        newA.Org_Nr__c = '5555555555';
        insert newA;
        Contract newC = new Contract();
        newC.Name = 'TestContract';
        newC.AccountId = newA.Id;
        newC.Agreement_KO_nr__c = '6765';
        newC.HERA_Number__c = '23232';
        insert newC;
        vlocity_cmt__VlocityTrackingEntry__c vt = new vlocity_cmt__VlocityTrackingEntry__c();
        vt.MCResponseJSON__c = '{"Affarsinformation":{"Avtalstid":5,"Heranummer":"","Leveranstid":"6","Nyproduktion":"Nej","Extern fiber":"Nej","Extern fiber (Namn)":"","stage":"","debit":"","Onskatleveransdatum":"2022-09-30","OnskatleveransdatumKabelTv":"","Inflyttningsdatum":"","Nedtagsdatum":"","Installationship":"","Byte":"","skickas":"Ja - Skickas som PDF till säljare och till Fastighetsägaren"},"Anslutning":{"totalantal":"","Koppar":[{"Koppar":"Koppar","antalportar":"","antalhushall":"","antallokaler":"","antalFSportar":""},{"Koppar":"Fiber","antalportar":"","antalhushall":"","antallokaler":"","antalFSportar":""}],"Fiber":[{"Koppar":"Koppar","tillagportar":"","nedtagportar":""},{"Koppar":"Fiber","tillagportar":"","nedtagportar":""}]},"FAtjanster":{"natbrygga?":"Nej","Etableringsavgift":90000,"Serviceavtal":"Nej","Nathyra":"Ja","Centralpunktsadress":"5","FNTnummer":"8","natbrygga":true,"Servicetyp":"Hub-spooke"},"Hardvara":{"Utbyte":"Nej","AntalMC":0,"AntalBredbandsswitch":"01","AntalRouter":0,"AntalTv-boxar":0,"AntalTradlos":0},"Kontaktpersoner":{"BestallareNamn":"test sunita test","BestallareTelefonnummer":"+46823323","BestallareEpost":"sunita.tudu@capgemini.com","Kontaktperson1Namn":"test sunita test","Kontaktperson1Telefonnummer":"+46823323","Kontaktperson1Epost":"sunita.tudu@capgemini.com","BestallareGatuadress":"","BestallarePostnummer":"","BestallarePostort":"","Kontaktperson1Gatuadress":"xds","Kontaktperson1Postnummer":"sdds","Kontaktperson1Postort":"sdds","Kontaktperson2Namn":"","Kontaktperson2Telefonnummer":"","Kontaktperson2Epost":"","Kontaktperson2Gatuadress":"","Kontaktperson2Postnummer":"","Kontaktperson2Postort":"","selectedRoles1":["För faktura","För leverans av boxar och kodkuvert","För bekräftelser och marknadsmaterial","För Fastighetsstyrning","För tillgång till switchrum","För Serviceavtal"],"selectedRoles2":["För Fastighetsstyrning"]},"Kundinformation":{"OwnerName":"Sunita Tudu","OwnerPhoneNumber":"+91 9096499148","OwnerEmail":"sunita.tudu@teliacompany.com","Avtalspart":"FiberTestAcc1","Organisationsnummer":"5565624151","KundSalavtalet":"Sunita Tudu","KundSalTelefonnummer":"+91 9096499148","KundSalEpost":"sunita.tudu@teliacompany.com","Namn ut mot kund":"FiberTestAcc1","kundFavtalspart":"","kundForgnummer":"","kundFKO-nummer":"","KO-nummer":"","KundAttentioninformation":"","KundFakturaadressC/O":"","KundFakturaadressReferenceinfo":"","KundGatuadress":"er","KundPostnummer":"sdfsd","KundPostort":"esd@dsfs.vco","Fakturametod":"Papper","FakturaadressEpostfaktura":""},"Produkter1":"","allmant1":{"Avtalsnummer":"02053754","Tidigare avtalsnummer":"","Brand":"Telia Fastighetsanslutning(XLAN)","offertype":"","typeofAffar":["Omförhandling","Överlåtelse"],"WBS":""},"flit":[{"adressanslutning":"","antalPortar":"","prisPerAdressanslutning":""}],"ovrigt":{"Kundagtnat":"","Produktkod":"","Stationsnamn":"","Ovriginformation":""},"serviceAvtal":{"aktiv_RHS1":"2","service_ip1":"qwewqe","service_ip2":"wewr","service_ip3":"ewrewr","service_ip4":"ewrewr","service_ip5":"erwer","service_ip6":"ewrwer","service_ip7":"werewr","service_ip8":"ewrewr","service_ip9":"erwer","service_ip10":"ewrwer","service_ip11":"ewrwerew","Nathyra_ip1":"ewrwe","Nathyra_ip2":"Månadsvis","Nathyra_ip3":"Nej","Nathyra_ip4":"ewrew","Nathyra_ip5":"ewrwer","aktiv_LHS1":"","aktiv_LHS2":"","aktiv_RHS2":"2","aktiv_LHS3":"","aktiv_RHS3":"2","aktiv_LHS4":"","aktiv_RHS4":"2","aktiv_LHS5":"","aktiv_RHS5":"2","aktiv_LHS6":"","aktiv_RHS6":"2","aktiv_LHS7":"","aktiv_RHS7":"2","passiv_LHS1":"","passiv_RHS1":"2","passiv_LHS2":"","passiv_RHS2":"2","passiv_LHS3":"","passiv_RHS3":"2","passiv_LHS4":"","passiv_RHS4":"2"}}';
        vt.Name= 'test';
        insert vt;
        Orderunderlag_controller c = new Orderunderlag_controller();
        
        PageReference myVfPage = Page.FiberOrderunderlagFullAllmant;
        Test.setCurrentPage(myVfPage);
        
        // Put Id into the current page Parameters
        ApexPages.currentPage().getParameters().put('id',newC.Id);
        Map < String, Object > inputMap = new Map < String, Object > ();
        Orderunderlag_controller.producker prod = new Orderunderlag_controller.producker();
        prod.Omforhandling = 'Test Wrapper';
        prod.activationtype='';
        prod.otc='';
        prod.productCode='';
        prod.price= 3.02;
        prod.quantity= 3;
        prod.addButton= true;
        prod.disablefield=false;
        prod.indexA ='A11';
        prod.indexB ='B11';
        prod.indexC ='C11';
        prod.indexD ='D11';
        prod.indexE ='E11';
        prod.indexF ='F11';
        prod.indexG ='G11';
        prod.rowIndex ='1';
       
        Orderunderlag_controller.flitWrap flit1 = new Orderunderlag_controller.flitWrap();
        flit1.adressanslutning ='test';
        flit1.Antal=9;
        flit1.price=9.8;
        flit1.addButton='true';
        
        flit1.indexA='A3';
        flit1.indexB='B3';
        flit1.indexC='C3';
        
        flit1.rowIndexFlit='3';

        Orderunderlag_controller oc = new Orderunderlag_controller();
        oc.previousContractLink = 'test';
        oc.orderContractdetails = newC;
        Orderunderlag_controller.order1 = inputMap;
        Orderunderlag_controller.vtemap = inputMap;
        
        Orderunderlag_controller.allmant = inputMap;
        Orderunderlag_controller.Kundinformation = inputMap;
        Orderunderlag_controller.Kontaktpersoner = inputMap;
        Orderunderlag_controller.Affarsinformation = inputMap;
        Orderunderlag_controller.anslutning = inputMap;
       
        Orderunderlag_controller.ovrigt = inputMap;
        Orderunderlag_controller.Hardvara = inputMap;
        Orderunderlag_controller.FAtjanster = inputMap;
        
        Orderunderlag_controller.serviceAvtal = inputMap;
        
        Database.DeleteResult results  = Database.delete(vt); 
    }
    
}