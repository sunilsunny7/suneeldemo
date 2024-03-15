public class TeliaSE_RoamingAddOnComponent {
    
    @AuraEnabled        
    public static String getPathStatus(String quoteId){
        Quote qt = [select Status,id from Quote where Id =:quoteId];
        return qt.Status;
    }
    public String resAddOn {get; set;} 
    public String tillAddOn {get; set;} 
    public String productName {get; set;}
    public String productCode {get; set;}
    public String approverNameStr{  
        get {return generateApproverName(productName, resAddOn, tillAddOn);}
    } 
    public String getTillEuopaSMPrice{  
        get{return getSMMandatePrice(productCode);}
    } 
    /*
public String getTGFSMPrice{  
get  
{  
return getSMMandatePrice(productName);  
}} 
public String getTUFSMPrice{  
get  
{  
return getSMMandatePrice(productName);  
}} 
public String getResOSMPrice{  
get  
{  
return getSMMandatePrice(productName);  
}} 

public String getResSSMPrice{  
get  
{  
return getSMMandatePrice(productName);  
}} 
public String getResVSMPrice{  
get  
{  
return getSMMandatePrice(productName);  
}} 
*/    
    public static String getSMMandatePrice(String productCode){  
        String smPrice = '';
        List<TeliaSE_Roaming_Mandate__mdt> mandateList = [select ResOsterutPris__c, ResSoderutPris__c, ResVasterutPris__c, TillEuropaPris__c,TillGrannlandPris__c, TillUtlandPris__c from TeliaSE_Roaming_Mandate__mdt where Is_SM_Mandate_Price__c ='Yes'];        
        for(TeliaSE_Roaming_Mandate__mdt mandate:mandateList){
            if(productCode!= null && productCode == 'MOB_CALL_TRAVEL_WEST' && mandate.ResOsterutPris__c != null){
                smPrice = mandate.ResOsterutPris__c+' kr';
                break;
            }
            if(productCode!= null && productCode == 'MOB_CALL_TRAVEL_SOUTH' && mandate.ResSoderutPris__c != null){
                smPrice = mandate.ResSoderutPris__c+' kr';
                break;
            }
            if(productCode!= null && productCode == 'MOB_CALL_TRAVEL_EAST' && mandate.ResVasterutPris__c != null){
                smPrice = mandate.ResVasterutPris__c+' kr';
                break;
            }
            if(productCode!= null && productCode == 'MOB_CALL_TRAVEL_EUROPE' && mandate.TillEuropaPris__c != null){
                smPrice = mandate.TillEuropaPris__c+' kr';
                break;
            }
            if(productCode!= null && productCode == 'MOB_CALL_TRAVEL_OTHER' && mandate.TillGrannlandPris__c != null){
                smPrice = mandate.TillGrannlandPris__c+' kr';
                break;
            }
            if(productCode!= null && productCode == 'MOB_CALL_TRAVEL_OVERSEAS' && mandate.TillUtlandPris__c != null){
                smPrice = mandate.TillUtlandPris__c+' kr';
                break;
            }
        }
        return smPrice;
    }
    
    public static String generateApproverName(String productName, String resAddOn, String tillAddOn){  
        String appoverName='',addOns;
        if(productName != null){            
            if(productName.contains('Till')) addOns = tillAddOn;
            else if(productName.contains('Res')) addOns = resAddOn;
            List<TeliaSE_Roaming_Mandate__mdt> mandateList = [select  ApproverName__c from TeliaSE_Roaming_Mandate__mdt where AddOnPricePlan__c =:addOns];            
            if(mandateList.size() > 0){  
                //mandateList[0].ApproverName__c;
                if(mandateList[0].ApproverName__c == 'CommercialManager')appoverName = 'Commercial Management';
                else if(mandateList[0].ApproverName__c == 'SalesDirector')appoverName = 'Säljdirektör';
                else if(mandateList[0].ApproverName__c == 'SalesManager')appoverName = 'Säljchef';
                else appoverName = '';
            }  
        }
        return appoverName;  
    }      
    
    //Added by Roshan Singh on 30-03-2022 for showing cart validation message on Quote
    @AuraEnabled        
    public static String getQuotecartVal(String quoteId){
        String Confirm;
        Quote qt = [select id,MC_CartRepriceRequired__c,TeliaSE_MC_Sales_Flow_Identifier__c,TeliaSE_Record_Type_Name__c from Quote where Id =:quoteId];
        if(qt.MC_CartRepriceRequired__c && qt.TeliaSE_MC_Sales_Flow_Identifier__c != 'Inforhandling' && qt.TeliaSE_Record_Type_Name__c == 'Contract'){
           Confirm = 'Success';
        }
        return Confirm;
    }
}