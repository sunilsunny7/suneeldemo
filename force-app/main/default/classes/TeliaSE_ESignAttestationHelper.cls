/*-----------------------------------------------------------------------------------------------------------
**Name: TeliaSE_ESignAttestationHelper 
**Created By:  Ragunathan Alagesan
**Sprint: MC Drop 2, Sprint-2
**User Story:MCSTO 1212, https://diva.teliacompany.net/confluence/display/MCSTO/1212+-+Sign+and+Attestation-validation
**Description:  If an Opportunity value exceeds specific Limit, Agreement document shall be sent for signing 
**to additional signers for Small & Large customers.
-----------------------------------------------------------------------------------------------------------*/

global without Sharing class TeliaSE_ESignAttestationHelper implements vlocity_cmt.VlocityOpenInterface{

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try
        {
            if (methodName.equals('getAttestationContact'))
            {
                getAttestationContact(inputMap,outMap, options);
            }
            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {
            System.debug('Error in getting E-Sign Attestation details, please contact System Administrator: '+e);
            result = false;
        }
        return result;
    }
     /**
        Method to find out the correct E-sign attestation signer based on the opportunity value.
        @param inputMap    Input details from user.
    @param outMap      Output map to be returned to frontend.
    @param options     Any specific options to be used in Vlocity API calls.
    **/
    private static void getAttestationContact( Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        Map<String, Object> contractMap = (Map<String, Object>)inputMap;
        String teliaId,sellerRole,approverName,approverRoleName,approverRoleNameFrmMtx,currentRoleName, userId,contractId;
        Id approverId;
        Boolean isNotificationRequired = true;
        Map<String, Object> contactContractRoleMap = (Map<String, Object>)contractMap.get('ContactRole');
        
        if (contractMap != null){
            Map<String, Object> valueMap = (Map<String, Object>)contractMap.get('Contract');
            userId = (String)inputMap.get('userId');
            Integer totalValue = (Integer)valueMap.get('OpportunityTotalValue');
            contractId = (String)inputMap.get('ContextId');
            //Changed the approval logic to send it to user's manager 
      Boolean chkRole = true;
            Id usrIdforCheck = userId;
            List<MC_Business_Regional_Accounts_Matrix__mdt> approverList = [SELECT id,Is_Notification_Required__c,Roof_Approval_Lower_Range__c,roof_approval_value__c, MC_SFDC_Role__c FROM MC_Business_Regional_Accounts_Matrix__mdt where Roof_Approval_Lower_Range__c <=: totalValue AND roof_approval_value__c >=: totalValue];
             map<string,MC_Business_Regional_Accounts_Matrix__mdt> userRoleAccountMatrix = new map<string,MC_Business_Regional_Accounts_Matrix__mdt> ();
            MC_Business_Regional_Accounts_Matrix__mdt temp = new MC_Business_Regional_Accounts_Matrix__mdt();
            if(!(approverList.isEmpty())){
                for(MC_Business_Regional_Accounts_Matrix__mdt mtx:approverList){
          userRoleAccountMatrix.put(mtx.MC_SFDC_Role__c, (MC_Business_Regional_Accounts_Matrix__mdt) mtx);
                }
            }
            while(chkRole) {
                User getUserManager = getApproverUser(usrIdforCheck);
                approverName = getUserManager.Name;
                approverId = getUserManager.Id;
                approverRoleName = getUserManager.Manager.UserRole.Name;
                currentRoleName = getUserManager.UserRole.Name;
                usrIdforCheck = getUserManager.Manager.Id;
                teliaId = getUserManager.Telia_Id__c;
               
                //There will be always one value from the custom meta data, hence, assign the first value as SFDC role.
                if( userRoleAccountMatrix.get(currentRoleName) != null ){
                    temp = userRoleAccountMatrix.get(currentRoleName);
                    approverRoleNameFrmMtx = temp.MC_SFDC_Role__c;
                    isNotificationRequired = temp.Is_Notification_Required__c;
                }
                //Check if the current user role is matching wih approval matrix role, if so, break the loop
                if(approverRoleNameFrmMtx == currentRoleName) chkRole = false;
                //In case if the user is not having any manager, break loop, so that it will not go
                //into to an infinte loop
                if (usrIdforCheck == null) chkRole = false;
            }//End of while
      Id contactId;
             List<Contact> ctList = [select id, Telia_Id__c from Contact where Telia_Id__c =:teliaId];
            //Create contact role only if its configured to send notificaiton in Custom metadata type. Seller or Account managers need not to get any notification.
            if(isNotificationRequired){
                outMap.put('notificationRequired','Yes');
                
                if(ctList.size() > 0){
                    Contact cont = (Contact)ctList[0];
                    contactId = cont.Id;
                }    
                //Create a new Contract role, if not update the existing one to send the scrive document.
                if (contactContractRoleMap.get('Id') != '' && contactContractRoleMap.get('Id') != null) {
                    ContractContactRole newContactRole = new ContractContactRole();
                    newContactRole.Id = (Id)contactContractRoleMap.get('Id');
                    newContactRole.ContactId = contactId;
                    newContactRole.Role = 'Avtalsgranskare';
                    update newContactRole;
                } 
                else{
                    ContractContactRole newContactRole = new ContractContactRole();
                    newContactRole.ContractId = contractId;
                    newContactRole.ContactId = contactId;
                    newContactRole.Role = 'Avtalsgranskare';
                    insert newContactRole;
                }
            }
            else {  //Check whether the contact role is already added, delete the previously added role for some other user.
                    //This is to primarily for Account manager role.        
                    if (contactContractRoleMap.get('Id') != '' && contactContractRoleMap.get('Id') != null) {
                        ContractContactRole newContactRole = new ContractContactRole();
                            newContactRole.Id = (Id)contactContractRoleMap.get('Id');
                            delete newContactRole;
                    }        
                    outMap.put('notificationRequired','No');
            }
            outMap.put('roleBasedApproverId',approverId);
            outMap.put('roleBasedApproverName',approverName);
            outMap.put('teliaId',teliaId);
        }
    }
    /**
        This function returns the user details along with his/her manager's details.
        @param userId    User Id is input parameter.
    **/
    private static User getApproverUser(Id userId) {
        User approverUser;
        if (userId != null) {
     approverUser = [select id,Name, Role_ID_18__c,Telia_Id__c,UserRole.Name,UserRole.Id,Manager.Name,ManagerId, Manager.UserRole.Name 
                                                   from user where Id =:userId];
        }
        return approverUser;
    } 
}