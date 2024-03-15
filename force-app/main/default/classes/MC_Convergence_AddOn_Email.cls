//Class for sending email in convergence guided flow #MCSTO_7020

global without Sharing class MC_Convergence_AddOn_Email implements vlocity_cmt.VlocityOpenInterface{
global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
     boolean result=true;  
    try
        {
            if(methodname.equals('ConvergenceApprovalEmail'))
            {


                convergenceApprovalEmail(inputMap,outMap);
            }else{
                result=false;
            }
           
        } 
        catch(Exception e)
        {
            result=false;
            System.debug('exception: '+e);
          
        }
    return result;
   
       
    }
     private void convergenceApprovalEmail(Map<String, Object> inputMap, Map<String, Object> outMap){
         try{
              Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();

            String[] ccAddresses = new String[] {UserInfo.getUserEmail()};//Setting cc as the current logged in user(sales rep)
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName ='Addon_Tracking'];
            message.setTargetObjectId((Id)(inputMap.get('ContactId'))); //Setting to address as the contac id which has email address

              message.setUseSignature(false); 
              message.setBccSender(false); 
              message.setSaveAsActivity(false);
              message.setccAddresses(ccAddresses);
              message.setTemplateID(emailTemplate.Id);
              message.setWhatId(((Id)inputMap.get('AddOnBenefitId')));
              Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};

            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);//sending mail

         }catch(Exception e){
             System.debug('exception: '+e);
         }
            }
}