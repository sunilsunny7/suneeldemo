public class JsonParser {
    public list < String > MDUIPTVName;
    public list < String > MDUCollIPTV;
    public list < String > MDUIPTVNDFName;
    public list < String > MDUCOAXTVName;
    public list < String > MDUCHT1707Name;
   // public list < String > MDUCOLBBName;
    public list < String > MDUCHW1707Name;
    public list < String > MDUSHName;
    public String coverage{get;set;}
    public list<FlitDetailsList> FlitDetailsList{get;set;}

    public Orderunderlag Orderunderlag;
    
    /*public OrderUnderlag_FLIT OrderUnderlag_FLIT{get;set;}
    public class OrderUnderlag_FLIT{
        //public list<FlitDetails> FlitDetails{get;set;}
        public FlitDetails FlitDetails{get;set;}
   }*/
    public class FlitDetailsList{
        public String Address{get;set;}
        public String NumberOfApartments{get;set;}
        public String Price{get;set;}
    }
  /* public class FlitDetails{
        public String Address{get;set;}
        public String NumberOfApartments{get;set;}
        public String Price{get;set;}
    }*/
    
    public class Store {
        public String TypeOfInstallationHelp1;
        public String Is_MDULES1729;
        public String KoperNumberOfPremises1;
        public String KoperNumberOfHouseholds1;
        public String KoperNumberOfOtherPorts1;
        public String KoperNumberOfPort1;
        public String Quantity_MDULES1729;
        public String FiberNumberOfOtherPorts1;
        public String FiberNumberOfPremises1;
        public String FiberNumberOfPort1;
        public String FiberNumberOfHouseholds1;
        public String BuildAreaNetwork1;
        public String HeraNo1;
        public String Fastighetsnat1;
        public String NewProductionOfBuilding1;
        public String ExternalFiber;
        public String ExternalOwnerName;
        public String ContractTerm1;
        public String OccupancyDate;
        public String WishedDeliveryDate1;

        public String Promiseddeliverytime;

		public String Promiseddeliverytime1;

        public String Stage;
        public String WishedDeliveryDateCoax1;
        public String SurfZone;
        public String ContractTerminationDate1;
        public String ReplacingPower;
        public String InformationLetterSent;
    }
    public class Orderunderlag {
        public Hardware Hardware;
        public CollectiveActivation CollectiveActivation;
        public Store Store;
        public FA_Services FA_Services;
        public Customer_Information Customer_Information;
        public Other Other;
        public General General;
        public ServiceAgreement ServiceAgreement;
    }
    public class ServiceAgreement {
        public String OneOrMoreContactPersonsForService;
        public String InfoForTechniciansSpecifictoParticularKOagreement;
        public String ONEcommonContactPathForEntireKOagreement;
        public String AdditionalInfoForTechnicians;
        public String InfoAboutTechnicalContactPerson;
        public String InfoToExternalServiceProvider;
        public String InfoNotIncludedInRegistration;
        public String SpecificInfoToTeliaAdministratorSAprocess;
        public String InstructionsFor1stTechnicianUnlinkErrorType;
        public String SpecificInfoInAgreementTeliaOfficersSAprocess;
        public String AdditionalInfo_ServiceSupport;
        public String FurtherInfoForBilling;
    }
    public class Other {
        public String Customer_OwnedNetwork;
        public String ProductCodeInAlpha;
        public String OtherInformation;
        public String StationsName{get;set;}
    }
    public class Hardware {
        public String NumberOfCollectiveBB_SCTSBroadbandSwitch;
        public String SwitchReplacement1;
        public String BroadbandSwitch;
        public String NumberOfMCs_WholePackage;
        public String Name_MDUCHT1707;
        public String Quantity_MDUCRF5370;
        public String Quantity_MDUCHT1707;
        public String Name_MDUCHW1707;
        public String Quantity_MDUCHW1707;
        public String Name_HaleBOPHW;
        public integer Quantity_HaleBOPHW;
        public decimal OTC_HaleBOPHW;

    }
    public class General {
        public String OfferType;
        public String TypeOfBusiness;
        public String WBSnumber;

        public String Brand1;

        
    }
    public class FA_Services {
        public String Quantity_MDUFEA1613;
        public String Quantity_MDUFWA21613;
        public String Name_MDUFWA21613;
        public String RCT_MDUFWA21613;
        public String RCT_MDUFWA1613;
        public String Name_MDUFWA101613;
        public String Quantity_MDUFWA1613;
        public String Quantity_MDUFWA101613;
        public String Name_MDUFWA1613;
        public String RCT_MDUFWA101613;
        public String RCT_MDUFE100A1613;
        public String Name_MDUFWA1001613;
        public String Quantity_MDUFE100A1613;
        public String Quantity_MDUFWA1001613;
        public String Name_MDUFE100A1613;
        public String RCT_MDUFWA1001613;
        public String RCT_MDUFE10A1613;
        public String Name_MDUFWC1613;
        public String Quantity_MDUFE10A1613;
        public String Quantity_MDUFWC1613;
        public String Name_MDUFE10A1613;
        public String RCT_MDUFWC1613;
        public String RCT_MDUFEA1613;
        public String Name_MDUFWC21613;
        public String Name_MDUFEA1613;
        public String Quantity_MDUFWC21613;
        public String RCT_MDUFBC1613;
        public String RCT_MDUFWC21613;
        public String Quantity_MDUFBC1613;
        public String FullMeshOrHubSpooke;
        public String Name_MDUFBC1613;
        public String CentralPointAddress;
        public String RCT_MDUFBA1613;
        public String FNTnumber;
        public String Quantity_MDUFBA1613;
        public String IsItANewBridge;
        public String Name_MDUFBA1613;
        public String Quantity_MDU_FS_NAT_Access_1718;
        public String OneTimeFeeTeliaPropertyManagement;
        public String RCT_MDU_FS_NAT_Access_1718;
        public String Name_MDU_FS_NAT_Access_1718;
        public String OnetimePropertyOwner1;
        public String Name_MDUFNC1718;
        public String ServiceAgreement_PricePerMonthFiberOrFTTH;
        public String ServiceAgreement_NumberOfPorts_FiberOrFTTH;
        public String ServiceAgreement_NumberOfPorts_CopperOrFTTB;
        public String ServiceAgreementServiceSpacer;
        public String ServiceAgreement_PricePerMonthCopperOrFTTB;
        public String RCT_MDUFNC1718;
        public String ServiceAgreementCableTV;
        public String Quantity_MDUFNC1718;
        public String ServiceAgreementCableTV_PricePerMonth;
        //
        public String Name_MDUFSWANNatAccess1001744;
        public String Quantity_MDUFSWANNatAccess1001744;
        public String RCT_MDUFSWANNatAccess1001744;
        public String Name_MDUFSWANNatAccess101744;
        public String Quantity_MDUFSWANNatAccess101744;
        public String RCT_MDUFSWANAccess1001617;
        public String Name_MDUFSWANAccess1001617;
        public String Quantity_MDUFSWANAccess1001617;
        public String RCT_MDUFSWANNatAccess101744;
        public String Name_MDUFSEXTRAAccessFiber1613;
        public String Quantity_MDUFSEXTRAAccessFiber1613;
        public String RCT_MDUFSEXTRAAccessFiber1613;
        public String Name_MDUFE100AF1613;
        public String Quantity_MDUFE100AF1613;
        public String RCT_MDUFE100AF1613;
        
        public String Name_MDUFE10AF1613;
        public String Quantity_MDUFE10AF1613;
        public String RCT_MDUFE10AF1613;
       
        //Halebop and Zitius 
    	public String Name_MDUFSInternet2;
    	public String Quantity_MDUFSInternet2;
        public String RCT_MDUFSInternet2;
        
        public String Name_MDUFSInternet10;
    	public String Quantity_MDUFSInternet10;
        public String RCT_MDUFSInternet10;
       
        public String Name_MDUFSInternet100;
    	public String Quantity_MDUFSInternet100;
        public String RCT_MDUFSInternet100;
        
        public String Name_MDUFSIPVPN2;
    	public String Quantity_MDUFSIPVPN2;
        public String RCT_MDUFSIPVPN2;
        
        public String Name_MDUFSIPVPN10;
    	public String Quantity_MDUFSIPVPN10;
        public String RCT_MDUFSIPVPN10;
        
        public String Name_MDUFSIPVPN100;
    	public String Quantity_MDUFSIPVPN100;
        public String RCT_MDUFSIPVPN100;
        
        public String Name_MDUFSIPVPN1000;
    	public String Quantity_MDUFSIPVPN1000;
        public String RCT_MDUFSIPVPN1000;
        
        public String Name_MDUFSVPN2;
    	public String Quantity_MDUFSVPN2;
        public String RCT_MDUFSVPN2;
        
        public String Name_MDUFSVPN10;
    	public String Quantity_MDUFSVPN10;
        public String RCT_MDUFSVPN10;
       
        public String Name_MDUFSVPN100;
    	public String Quantity_MDUFSVPN100;
        public String RCT_MDUFSVPN100;
        
        public String Name_MDUFSVPN1000;
    	public String Quantity_MDUFSVPN1000;
        public String RCT_MDUFSVPN1000;
        
        public String Name_FS_Etableringsport_100;
    	public String Quantity_FS_Etableringsport_100;
        public String RCT_FS_Etableringsport_100;
        
        public String Name_FS_Etableringsport_1000;
    	public String Quantity_FS_Etableringsport_1000;
        public String RCT_FS_Etableringsport_1000;
		
        public String Name_FS_Etableringsport_10000;
    	public String Quantity_FS_Etableringsport_10000;
        public String RCT_FS_Etableringsport_10000;
        
        public String Name_FS_Etableringsport_VPN100;
    	public String Quantity_FS_Etableringsport_VPN100;
        public String RCT_FS_Etableringsport_VPN100;
		
        public String Name_FS_Etableringsport_VPN1000;
    	public String Quantity_FS_Etableringsport_VPN1000;
        public String RCT_FS_Etableringsport_VPN1000;
        
        public String Name_FS_Etableringsport_VPN10000;
    	public String Quantity_FS_Etableringsport_VPN10000;
        public String RCT_FS_Etableringsport_VPN10000;
        
        public String Name_FS_Nationellt_tillagg_2019;
    	public String Quantity_FS_Nationellt_tillagg_2019;
        public String RCT_FS_Nationellt_tillagg_2019;
        
        public String Name_MDUFSInternet1000;
    	public String Quantity_MDUFSInternet1000;
        public String RCT_MDUFSInternet1000;
    }
    public class Customer_Information {
        public AdditionalCustomerDetails AdditionalCustomerDetails;
        public String Business1;
        public String KONumber;
        public String SellerEmail1;
        public String OrgNumber1;
        public String SellerPhone1;
        public ClientContactDetails ClientContactDetails;
        public String SellerName1;
        public BillingAdress1 BillingAdress1;
    }
    public class CollectiveActivation {
    
        public String Name_MDUCOLBB;
        public String Quantity_MDUCOLBB;
        public String RCT_MDUCOLBB;
        public String CollectiveBroadbandActivationType;
        
        
        public String Name_MDUCOLVOIP;
        public String Quantity_MDUCOLVOIP;
        public String RCT_MDUCOLVOIP;
        public String VOIPActivationType;
        
        public String Name_MDUIPTV;
        public String Quantity_MDUIPTV;
        public Decimal RCT_MDUIPTV;
        public String IPTVActivationType;
        
        public String Name_MDU_CollIPTV_Twin_2119;
        public String Quantity_MDU_CollIPTV_Twin_2119;
        public Decimal RCT_MDUCollIPTV_Twin_2119;
        public String CollIPTVActivationType;
        
        public String Name_MDUIPTVNDF;
        public String Quantity_MDUIPTVNDF;
        public String RCT_MDUIPTVNDF;
        public String MDUIPTVNDFActivationType;      

        public String Name_MDUCOAXTV;
        public String Quantity_MDUCOAXTV;
        public String RCT_MDUCOAXTV;        
        public String CollectiveCableTvActivationType;
        
        public String Name_MDUSH;
        public String Quantity_MDUSH;
        public String RCT_MDUSH;  
        public String Quantity_MDUSHOTC;
        public String OTC_MDUSH;
        
        public String ExistingCableTv;
        
        public String Name_HALEBOPBB;
        public String HalebopBB_Name;
        public String HalebopBB_RCT;
        public String HalebopBB_Quantity;
        public String CollectiveHalebopBBandActivationType;
                
        public String MDU_CollIPTVB2B_Name;
        public String MDU_CollIPTVB2B_Quantity;
        public Decimal MDU_CollIPTVB2B_RCT;
        public String CollectiveB2BActivationType;
                
        public String CollectiveBroadbandActivationTypeHalbop;       

    }
    public class ClientContactDetails {
        public String ContactEmail1;
        public String ContactName1;
        public String ContactPhone1;
    }
    public class BillingAdress1 {
        public String BillingCountry1;
        public String BillingPostalCode1;
        public String BillingCity1;
        public String BillingStreet1;
        public String BillingState1;
    }
    public class AdditionalCustomerDetails {
        public String PostalAddress;
        public String OutgoingCustomer;
        public String BillingAdress2;
        public String BillingContact;
        public String OutgoingCustomerOrgNr;
        public String FiberBaseContractNumber1;
        public String ContactPersonMarketingMaterials;
        public String ContractNumber1;
        public String ContactPersonFSServicce;
        public String ContactPerson2;
        public String ContactPerson1;
        public String ContactPerson2Name;
        public String ContactPerson1Name;
        public String ContactPerson2NameTelephoneEmailAdress;
        public String ContactPerson1NameTelephoneEmailAdress;
    }
}