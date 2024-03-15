//**********************************Change Version*****************************************************************************************************************
// Name             : AgreementSituationController 
// Description      : Case 1895 - Replaced '&' from account name because for the Account Name containing '&', the URL of new agreement situation was breaking        
// Modified By       : AM Team, S.S
// Modified Date     : 21/09/2016
//*****************************************************************************************************************************************************************
//**********************************Change Version*****************************************************************************************************************
// Description      : Changes done as part of case 2715    
// Modified By       : AM Team, S.S
// Modified Date     : 05/10/2017
//*****************************************************************************************************************************************************************

public class AgreementSituationController {
    public Account selectedAccount { get {return this.acc;} }
    public String selectedAgreementId { get; set; }
    public Boolean shouldRedirect { get; set; }
    public String url { get; set; }
    public Boolean isEditMode{get;set;}
    public Boolean isDisplayMode{get;set;}
    public List<Agreement_Situation__c> activeAgreements{get;set;}
    public  List<Agreement_Situation__c> insertagreementsituation;  
    public Decimal sumofsupplieronKKNR;
    private final Account acc;
    public Id accountId;
    
    public AgreementSituationController(ApexPages.StandardController stdController) {
        this.acc = (Account)stdController.getRecord();
        isEditMode = false;
        isDisplayMode = true;
        accountId = this.acc.Id;
        //Get the active agreements based on date
        activeAgreements = [
                SELECT Agreement_Category__c, 
                IT_spend__c,
                Comment__c,
                Start_Date__c,
                End_Date__c,
                Holdings__c, 
                KKnr__c,  
                Reminder_days_before__c,
                Potential__c,
                Option_1__c,
                Option_2__c,
                Reminder_Date__c,   
                Supplier__c,
                Yearly_Value__c,
                Share_of_Wallet__c,
                LastModifiedDate,
                Status__c,
                Reminder_2_days_before__c,
                Avtalssituationspost_aktiv__c
                FROM Agreement_Situation__c 
                WHERE KKnr__c = :this.acc.Id ORDER BY Agreement_Category__c ASC];  
     }  
    public Pagereference EditAgreementSituations(){
    isEditMode = true;
    isDisplayMode = false;
       return null; 
    }
    
    public Pagereference cancelAgreementSituation()
    {
        isEditMode = false;
        isDisplayMode = true;
        return null;
    }

    public PageReference save()
    {
        try
        { 
            insertagreementsituation = new List<Agreement_Situation__c>();
            sumofsupplieronKKNR = 0.00;
            for(Agreement_Situation__c agreesituation : activeAgreements)
            {      
                insertagreementsituation.add(agreesituation);               
                if((agreesituation.End_Date__c >= System.Today() && agreesituation.Supplier__c != null && agreesituation.End_Date__c != null) || ((agreesituation.Supplier__c =='Not applicable for the customer')) || (agreesituation.Supplier__c != null && agreesituation.End_Date__c >= System.Today()))  
                {
                    sumofsupplieronKKNR = 0.1 +sumofsupplieronKKNR;
                }
                    
            }
           
            if(insertagreementsituation.size() > 0 && insertagreementsituation != null)
            {
                upsert insertagreementsituation;
            }
            sumofsupplieronKKNR = (sumofsupplieronKKNR/13)*1000 ;
            
            Account acct = new Account();
            acct.Uppfyllnadsgrad_Avtalssituation__c = sumofsupplieronKKNR.setscale(2);
            acct.id = accountId; 
            update acct;
              
            return null;
        }
        catch(Exception e)
        { 
            ApexPages.addMessages(e);
            return null;
        }      
    } 
    
}