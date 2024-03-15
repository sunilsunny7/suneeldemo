/**
* @Author:      Sanjoli Agrawal
* @Company:     Capgemini
* @Date:        25 Oct, 2021
* @Description: This class is the controller class to feed the value to TPP Excel VF pages.
* ----------------------------------------------------------------------------------------------------------------------------------------------
*/

public class GenerateTPPExtractController{
    
    public static list<TPPOrderExtract__c> finalTPPOrderExtract{get;set;}
    public static list<Utilizer_Contract_Relationship__c> UTContRel{get;set;}
    public  Contract contract{get;set;}
    public list<TPPOrderExtract__c> sampleExtract{get;set;}
    public list<TPPOrderExtract__c> orderExtract{get;set;}
    public List<map<String, Object>> UTContRel1{get;set;}
    public List<ContractContactRole> ContractcontactRel{get;set;}
    public List<Contact> Contractcontact{get;set;}
    public list<vlocity_cmt__ContractLineItem__c>  contractLineItem{get;set;}
    public list<Utilizer_Contract_Relationship__c>  utilizerContractRel{get;set;}
    public String xmlHeader{get;set;}
    public static String existingquan {get;set;}
    public static String huvudnummer{get;set;}
    public static String namn{get;set;}
    public static DateTime generateDateGMT{get;set;}
    public static String mobilnummer{get;set;}
    public static String epost{get;set;}
    public static String avtalstid{get;set;}
    public static String ramavstalnummer{get;set;}
    public static String avstalstart{get;set;}
    public static String orgName{get;set;}
    public static String orgNummer{get;set;}
    public static String address{get;set;}
    public static String postalCode{get;set;}
    public static String city{get;set;}
    public static String BestallarName{get;set;}
    public static String telefon{get;set;}
    public static String email{get;set;}
    public static String mobAgreementNr{get;set;}
    public static String generateDate{get;set;}
    
    public GenerateTPPExtractController(){
        generateDateGMT = DateTime.now();
        generateDate = generateDateGMT.format('yyyy-MM-dd HH:mm');
        //Date d= String.valueOfGMT(generateDate);
        String message = System.currentPagereference().getParameters().get('ContractID');
        System.debug('message==>'+message);
        try{
            system.debug('StartOrderTPPExtract');
            xmlHeader = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>';
            ContractcontactRel= [SELECT id,contractid,role,contactid  FROM ContractContactRole WHERE (ContractId =:message AND Role = 'Avtalstecknare')];
            
            system.debug('size'+ContractContactRel.size());
            if(ContractContactRel.size()>0){
                system.debug('ContractcontactRel.contactId'+ContractcontactRel[0]+ContractcontactRel[0].contactId);
                Contractcontact= [SELECT id,name,email, MobilePhone FROM Contact WHERE (Id =: ContractcontactRel[0].contactId)];
            }
            utilizerContractRel=[select Id,  Name, AccountId__c,AccountId__r.name, AccountId__r.BillingStreet, AccountId__r.BillingPostalCode, AccountId__r.BillingCity, ContractNumber__c, Org_Number__c, Utilizer_Contract_Name__c, Utilizer_Role__c, MC_Daughter_Company_Flag__c, MC_Include_Initial_Order_Flag__c  from Utilizer_Contract_Relationship__c where ContractNumber__c =:message];
            contractLineItem= [select id,vlocity_cmt__ContractId__r.TeliaSE_Parent_Agreement__c,TeliaSE_Product_Object_Type__c,TeliaSE_Start_Date__c,TeliaSE_MC_Customer_Requested_Price__c,vlocity_cmt__ContractId__r.Agreement_Nr__c,
                               vlocity_cmt__ContractId__r.StartDate, vlocity_cmt__QuoteLineItem__r.MC_Initial_Order_Quantity__c,
                               vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c,vlocity_cmt__Product2Id__r.ProductCode, vlocity_cmt__Quantity__c,
                               TeliaSE_Base_Quantity__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__OneTimeCharge__c , TeliaSE_CommitmentPeriod__c, 
                               vlocity_cmt__ContractId__r.Framework_Agreement_Number__c, Account_Name__c,vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.TeliaSE_MC_Signing_Contact__r.Name , 
                               vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.TeliaSE_MC_Signing_Contact__r.MobilePhone ,vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.TeliaSE_MC_Signing_Contact__r.Email,
                               vlocity_cmt__ContractId__r.Org_Nr__c, vlocity_cmt__ContractId__r.Owner.Name,vlocity_cmt__ContractId__r.Owner.MobilePhone,
                               vlocity_cmt__ContractId__r.Owner.Email, vlocity_cmt__ContractId__r.Account.BillingCity, vlocity_cmt__ContractId__r.Account.BillingPostalCode, vlocity_cmt__ContractId__r.Account.BillingStreet  
                               from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c =: message and TeliaSE_Product_Object_Type__c ='TouchPoint Plus Offer Spec' ];
            //contract=[select id,Framework_Agreement_Number__c, Account.name,vlocity_cmt__OpportunityId__r.TeliaSE_MC_Signing_Contact__r.Name, vlocity_cmt__OpportunityId__r.TeliaSE_MC_Signing_Contact__r.MobilePhone,vlocity_cmt__OpportunityId__r.TeliaSE_MC_Signing_Contact__r.Email,Org_Nr__c, Owner.Name, Owner.MobilePhone, Owner.Email  from Contract where Id ='8005E000003tPRf'];
            //ContractcntctRole=[ select id, Contact.name, Role from ContractContactRole where ContractId =:message];
            system.debug('contractLineItem'+contractLineItem);
            
            sampleExtract = [SELECT ProductName__c,ExistingQuantity__c,ServiceCode__c, ProductCode__c, Quantity__c, OneTimeCharge__c, RecurringCharge__c, SerialNo__c from TPPOrderExtract__c order by SerialNo__c];
            orderExtract = new list<TPPOrderExtract__c>();
            finalTPPOrderExtract = new list<TPPOrderExtract__c>();
            UTContRel = new List<Utilizer_Contract_Relationship__c>();
            
            
            for(TPPOrderExtract__c eLI:sampleExtract){
                system.debug('eli=='+eli);
                if(contractLineItem!=null){
                    for(vlocity_cmt__ContractLineItem__c cLI:contractLineItem){
                        if(cLI != null && eLI.ProductCode__c == cLI.vlocity_cmt__Product2Id__r.ProductCode){
                            eLI.Quantity__c = cLI.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c!=NULL?cLI.vlocity_cmt__QuoteLineItem__r.TeliaSE_MC_FACallOffQuantity__c:0;
                            eLI.OneTimeCharge__c = Integer.valueOf(cLI.vlocity_cmt__OneTimeCharge__c);
                            eLI.RecurringCharge__c = cLI.TeliaSE_MC_Customer_Requested_Price__c!=NULL?cLI.TeliaSE_MC_Customer_Requested_Price__c:Integer.valueOf(cLI.vlocity_cmt__RecurringCharge__c);
                            eLI.ExistingQuantity__c= cLI.vlocity_cmt__QuoteLineItem__r.MC_Initial_Order_Quantity__c!=NULL?cLI.vlocity_cmt__QuoteLineItem__r.MC_Initial_Order_Quantity__c:0 ;
                            avstalstart=String.valueOf(cLI.TeliaSE_Start_Date__c); 
                            
                            
                            //huvudnummer=cLI.Account_Name__c;
                            namn=cLI.vlocity_cmt__ContractId__r.Owner.Name;
                            
                            mobilnummer=cLI.vlocity_cmt__ContractId__r.Owner.MobilePhone;
                            epost=cLI.vlocity_cmt__ContractId__r.Owner.Email;
                            if(cLI.TeliaSE_CommitmentPeriod__c!=NULL){
                                avtalstid= cLI.TeliaSE_CommitmentPeriod__c;
                            }
                            ramavstalnummer=cLI.vlocity_cmt__ContractId__r.TeliaSE_Parent_Agreement__c;
                            orgName=cLI.Account_Name__c;
                            orgNummer=cLI.vlocity_cmt__ContractId__r.Org_Nr__c;
                            mobAgreementNr=cLI.vlocity_cmt__ContractId__r.Agreement_Nr__c;
                            //BestallarName=cLI.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.TeliaSE_MC_Signing_Contact__r.Name;
                            //BestallarName= Contractcontact.Contact.name;
                            //telefon=cLI.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.TeliaSE_MC_Signing_Contact__r.MobilePhone;
                            //telefon=Contractcontact.contact.MobilePhone;
                            //email=cLI.vlocity_cmt__ContractId__r.vlocity_cmt__OpportunityId__r.TeliaSE_MC_Signing_Contact__r.Email;
                            //email= Contractcontact.contact.Email;
                            address=cLI.vlocity_cmt__ContractId__r.Account.BillingStreet; 
                            system.debug('address==>'+ address );
                            postalCode=cLI.vlocity_cmt__ContractId__r.Account.BillingPostalCode;
                            city= cLI.vlocity_cmt__ContractId__r.Account.BillingCity; 
                            
                        }
                    }
                }
                system.debug('FinalList=='+finalTPPOrderExtract);
                finalTPPOrderExtract.add(eLI); 
                system.debug('address==>'+ address );
                
            }
            if(Contractcontact.size()>0){
                BestallarName= Contractcontact[0].name;
                
                telefon=Contractcontact[0].MobilePhone;
                
                email= Contractcontact[0].Email;
            }
            
            system.debug('namn : ' + namn);
            system.debug('Final List : ' + finalTPPOrderExtract);
        }
        catch(Exception e){
            System.debug('exception'+ e.getStackTraceString());
        }
        
    }
}