/**
About
-----
Description: AutoDirectController for the Auto Direct Action for both Lightning and Classic.
Create date: 31.10.2016

Update History
--------------
Created Dev 2016 - V.M 

Issues / TODOs
--------------     
*/



global class CaseOwnershipActionController{
    
    private static Boolean HasError { get; set; }
    private static List<String> ErrorMsgs { get; set; }
    
    public class ActionStatus{
        public String ErrorMessages {get; set;}
        public String SuccessMessage {get; set;}
        public Boolean IsSuccess {get; set;}
    }
    
    //For Salesforce Lightning
    @AuraEnabled
    public static String getResult(String caseId){
        return processRecord(caseId); 
    }
    
    private static String processRecord(String caseId){
        Case c = [SELECT Id, OwnerId FROM Case WHERE Id = :caseId  LIMIT 1];
        ErrorMsgs = new List<String>();
        HasError = False;
        
        if(c.OwnerId != UserInfo.getUserId()){
                 c.OwnerId = UserInfo.getUserId();
        }else{
            HasError = True;
            ErrorMsgs.add(Label.Case_Already_Owner);
        }
   
        if(!HasError){
            try{
                update c;
            }catch(System.DmlException e){
                HasError = True;
                ErrorMsgs.add(e.getDmlMessage(0));
            } 
        }
        
        ActionStatus actionStatus = new ActionStatus();
        
        If(HasError){
            actionStatus.IsSuccess = False;
            actionStatus.ErrorMessages =  string.join(ErrorMsgs,'\n');
        }else{
            actionStatus.IsSuccess = True;
            actionStatus.SuccessMessage = Label.Case_Success_Message;
        }
        return JSON.serialize(actionStatus);
    }        
}