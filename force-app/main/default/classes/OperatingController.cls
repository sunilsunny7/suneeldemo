public class OperatingController {
    
    public ID recordID;
    public boolean warningMsg {get;set;}
    public String dateDisplay {get;set;}
    public OperatingController(ApexPages.StandardController controller) {
        warningMsg = false;
        dateDisplay = '';
        recordID = controller.getID();
        system.debug('recordId-'+recordID);
        Opportunity oppObj = [select Id,Account.Consent_Updated__c,Account.CM_Final_Traffic_Marketing__c,Account.CM_Final_Traffic_Service_Network__c from Opportunity where Id =:recordID LIMIT 1];
        system.debug('Marketing:-'+oppObj.Account.CM_Final_Traffic_Marketing__c+'Service:-'+oppObj.Account.CM_Final_Traffic_Service_Network__c);
        If(oppObj.Account !=null){
            dateDisplay =  oppObj.Account.Consent_Updated__c !=null ? oppObj.Account.Consent_Updated__c: '';
            /*if(String.isNotBlank(localdate)){
                 =  localdate.substring(0,10);
            }*/
            if(dateDisplay != '')
            dateDisplay = dateDisplay.substring(0,19);
            dateDisplay = dateDisplay.replace('T', ' T');
            if(oppObj.Account.CM_Final_Traffic_Marketing__c !=null && oppObj.Account.CM_Final_Traffic_Service_Network__c !=null){
                if(oppObj.Account.CM_Final_Traffic_Marketing__c != 'Implicit' && oppObj.Account.CM_Final_Traffic_Service_Network__c != 'Implicit'){
                    system.debug('###Not Implicit'+oppObj.Account.Consent_Updated__c);
                    if(String.isNotBlank(oppObj.Account.Consent_Updated__c)){
                        Date consentDate = Date.newInstance(
                            Integer.valueOf(oppObj.Account.Consent_Updated__c.subString(0,4)), 
                            Integer.valueOf(oppObj.Account.Consent_Updated__c.subString(5,7)),
                            Integer.valueOf(oppObj.Account.Consent_Updated__c.subString(8,10)));
                        system.debug('consentDate-'+consentDate.addDays(90));
                        if(system.now() > consentDate.addDays(90) && (oppObj.Account.CM_Final_Traffic_Marketing__c !='approved' || oppObj.Account.CM_Final_Traffic_Service_Network__c !='approved')){
                            system.debug('%%%Warning');
                            warningMsg = true;
                        }
                    }
                }else{
                    system.debug('%%%Implicit');
                    warningMsg = true;
                }
            }else{
                system.debug('%%%Blank');
                warningMsg = true;
            }
        }
    }
}