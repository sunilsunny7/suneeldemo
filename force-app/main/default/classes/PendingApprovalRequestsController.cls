public without sharing class PendingApprovalRequestsController {

    //Wrapper class to store the column values of data table
    public class SubmittedRecordsWrapper {
        @AuraEnabled public Id workItemId;
        @AuraEnabled public String recordId;
        @AuraEnabled public String relatedTo;
        @AuraEnabled public String recordName;
        @AuraEnabled public String SubmittedBy;
        @AuraEnabled public Date SubmittedDate;
        @AuraEnabled public String AccountName;
        @AuraEnabled public String SubmitterManager;
    }

    @AuraEnabled
    public static List < SubmittedRecordsWrapper > getSubmittedRecords(String pageSize, String pageNumber) {
        List < SubmittedRecordsWrapper > lstSubmissionWrapper = new List < SubmittedRecordsWrapper > ();
        quote[] qte;
        User[] u;
          Integer psize = Integer.valueOf(pageSize);
                  System.debug('page size:' +psize);

        Integer pnumber = Integer.valueOf(pageNumber)-1;
        List<ProcessInstance> approvalid = new List<ProcessInstance>();
        
        approvalid = getApprovalUtils('myapp');
          
           
        //Process instance stores the info of records submitted for approval,
        // Process instance work item are the records an approver sees while approving/rejecting, Process instance step stores approved/rejected record including approva;/rejection comments
        for (ProcessInstance ps: [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate, createdby.TeliaSE_Role_based_Approver__c,
                (SELECT ID FROM WorkItems WHERE OriginalActorId =: UserInfo.getUserId() and createdby.TeliaSE_Role_based_Approver__c =: UserInfo.getUserId() ),
                (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance where status = 'pending' and id IN : approvalid limit:Integer.valueOf(psize) OFFSET :(psize*pnumber)+1 ]){
          
            if (!ps.WorkItems.isEmpty()) {

                SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
                objSubmittedRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                //objSubmittedRecordsWrapper.recordId = ps.TargetObjectId;

                qte = [select id, account.name from Quote where id =: ps.TargetObjectId limit 1];
                //objSubmittedRecordsWrapper.AccountName = qte.account.name;
                objSubmittedRecordsWrapper.recordId = ps.WorkItems[0].Id;
                objSubmittedRecordsWrapper.recordName = ps.TargetObject.Name;
                //objSubmittedRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
                if(qte.size() > 0)
                objSubmittedRecordsWrapper.relatedTo = qte[0].account.name;
                objSubmittedRecordsWrapper.SubmittedDate = Date.newInstance(ps.CreatedDate.year(), ps.CreatedDate.month(), ps.CreatedDate.day());
                if (!ps.steps.isEmpty()) {
                    objSubmittedRecordsWrapper.SubmittedBy = ps.steps[0].OriginalActor.Name;
                    u = [select id,name,TeliaSE_Role_based_Approver__c,TeliaSE_Role_based_Approver__r.name from user where id =:ps.steps[0].OriginalActorId limit 1];
                    if(u.size() > 0)
                    objSubmittedRecordsWrapper.SubmitterManager = u[0].TeliaSE_Role_based_Approver__r.name; 
                     //objSubmittedRecordsWrapper.submittedById = ps.steps[0].OriginalActorid;
                    lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
                }
            }
        }

        return lstSubmissionWrapper;
    }
    
    @AuraEnabled
    public static List < SubmittedRecordsWrapper > getSubmittedRecordsAll(String pageSize, String pageNumber) {
        List < SubmittedRecordsWrapper > lstSubmissionWrapper = new List < SubmittedRecordsWrapper > ();
        quote[] qte;
        User[] u;
        Integer psize = Integer.valueOf(pageSize);
        System.debug('page size:' +psize);
        Integer pnumber = Integer.valueOf(pageNumber)-1;
        
        List<ProcessInstance> approvalid = new List<ProcessInstance>();
        
        approvalid = getApprovalUtils('allapp');
        //Process instance stores the info of records submitted for approval,
        // Process instance work item are the records an approver sees while approving/rejecting, Process instance step stores approved/rejected record including approva;/rejection comments
        for (ProcessInstance ps: [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate, createdby.TeliaSE_Role_based_Approver__c,
                (SELECT ID FROM WorkItems WHERE OriginalActorId =: UserInfo.getUserId()),
                (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance where status = 'pending' and Id IN : approvalid limit:Integer.valueOf(psize) OFFSET :(psize*pnumber)+1]){

            if (!ps.WorkItems.isEmpty()) {

                SubmittedRecordsWrapper objSubmittedRecordsWrapper = new SubmittedRecordsWrapper();
                objSubmittedRecordsWrapper.workItemId = ps.WorkItems[0].Id;
                //objSubmittedRecordsWrapper.recordId = ps.TargetObjectId;

                qte = [select id, account.name from Quote where id =: ps.TargetObjectId limit 1];
                objSubmittedRecordsWrapper.recordId = ps.WorkItems[0].Id;
                objSubmittedRecordsWrapper.recordName = ps.TargetObject.Name;
                //objSubmittedRecordsWrapper.relatedTo = getObjectName(ps.TargetObjectId);//get the object name using the record id
                if(qte.size() > 0)
                objSubmittedRecordsWrapper.relatedTo = qte[0].account.name;
                objSubmittedRecordsWrapper.SubmittedDate = Date.newInstance(ps.CreatedDate.year(), ps.CreatedDate.month(), ps.CreatedDate.day());
                if (!ps.steps.isEmpty()) {
                
                    objSubmittedRecordsWrapper.SubmittedBy = ps.steps[0].OriginalActor.Name;
                    u = [select id,name,TeliaSE_Role_based_Approver__c,TeliaSE_Role_based_Approver__r.name from user where id =:ps.steps[0].OriginalActorId limit 1];
                    if(u.size() > 0)
                    objSubmittedRecordsWrapper.SubmitterManager = u[0].TeliaSE_Role_based_Approver__r.name; 
                    // objSubmittedRecordsWrapper.submittedById = ps.steps[0].OriginalActorid;
                    lstSubmissionWrapper.add(objSubmittedRecordsWrapper);
                }
            }
        }

        return lstSubmissionWrapper;
    }

    public static String getObjectName(String recordId) {
        //To get the label of the object name using Schema methods
        String keyPrefix = recordId.subString(0, 3);
        String objectName = '';
        Map < String, Schema.SObjectType > sobjectTypeMap = Schema.getGlobalDescribe();
        for (String obj: sobjectTypeMap.keySet()) {
            Schema.DescribeSObjectResult sobjectResult = sobjectTypeMap.get(obj).getDescribe();
            if (sobjectResult.getKeyPrefix() == keyPrefix) {
                objectName = sobjectResult.getLabel();
                break;
            }
        }
        return objectName;
    }


    @AuraEnabled
    public static String processRecords1(String workItemIds, String processType, String comments) {
        String message = '';
        Integer recordsProcessed = 0;
        String actionname = processType == 'approve' ? 'Approve' : 'Reject';
        system.debug('lstWorkItemIds' + workItemIds);

        Approval.ProcessWorkitemRequest objWorkItemRequest = new Approval.ProcessWorkitemRequest();
        //objWorkItemRequest.setComments('The request has been '+actionname);
        objWorkItemRequest.setComments(comments);
        objWorkItemRequest.setAction(actionname); //approve or reject
        objWorkItemRequest.setWorkitemId(workItemIds);
        try {
            Approval.ProcessResult wrkProcessResult = Approval.process(objWorkItemRequest);
            if (wrkProcessResult.isSuccess()) {
                recordsProcessed++;

            } else {
                //for(Database.Error error : wrkProcessResult.getErrors()){
                message += wrkProcessResult.getErrors()[0].getMessage();
                //}
            }
            if (recordsProcessed != 0 && actionname == 'Approve') {
                message = 'Quote was ' + actionname + 'd';

            } else {
                message = 'Quote was ' + actionname + 'ed';
            }
        } catch (Exception e) {
            Integer occurence;
            message = e.getMessage();
            if (e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                occurence = message.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
                message = message.mid(occurence, message.length());
                occurence = message.lastIndexOf(':');
                message = message.mid(0, occurence);
            } else {
                message += e.getMessage();
            }
            //message += e.getMessage();
        }
        system.debug('message:-' + message);
        return message;

    }
    
    @AuraEnabled
    public static Integer getRecordsCount(String operation) {
    if(operation == 'myapp'){
      
      integer count = 0;
      /*for (ProcessInstance ps: [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate, createdby.TeliaSE_Role_based_Approver__c,
                (SELECT ID FROM WorkItems WHERE OriginalActorId =: UserInfo.getUserId() and createdby.TeliaSE_Role_based_Approver__c =: UserInfo.getUserId()),
                (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance where status = 'pending']){
                  if (!ps.WorkItems.isEmpty())
                count++;
                }*/
                
          List<ProcessInstance> approvalid = new List<ProcessInstance>();
        
        approvalid = getApprovalUtils('myapp');    
        for (ProcessInstance ps:  approvalid ){
        count++;
                }
               
      if(count != 0){
                return count-1 ;
                }else{
                return count;
                }
      }else{
       integer count1 = 0;
         /*for (ProcessInstance ps: [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate, createdby.TeliaSE_Role_based_Approver__c,
                (SELECT ID FROM WorkItems WHERE OriginalActorId =: UserInfo.getUserId()),
                (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance where status = 'pending' ]){
                
                if (!ps.WorkItems.isEmpty())
                ++count1;
                }*/
          List<ProcessInstance> approvalid = new List<ProcessInstance>();
                approvalid = getApprovalUtils('allapp');    
        for (ProcessInstance ps:  approvalid ){
        count1++;
                }
                if(count1 != 0){
                return count1-1 ;
                }else{
                return count1;
                }
      }
      }
      public static List<ProcessInstance> getApprovalUtils(String operation){
        List<ProcessInstance> ps1 = new List<ProcessInstance>();
        if(operation == 'myapp'){
        for (ProcessInstance psid:  [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate, createdby.TeliaSE_Role_based_Approver__c,
                (SELECT ID FROM WorkItems WHERE OriginalActorId =: UserInfo.getUserId() and createdby.TeliaSE_Role_based_Approver__c =: UserInfo.getUserId() ),
                (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance where status = 'pending']){
                 if (!psid.WorkItems.isEmpty()) {
                ps1.add(psid);
                }
                }
          return ps1;
      }
      else {
      
      for (ProcessInstance psid: [SELECT Id, TargetObjectId, TargetObject.Name, CreatedDate, createdby.TeliaSE_Role_based_Approver__c,
                (SELECT ID FROM WorkItems WHERE OriginalActorId =: UserInfo.getUserId()),
                (SELECT OriginalActor.Name FROM Steps WHERE StepStatus = 'Started') FROM ProcessInstance where status = 'pending' ]){
                if (!psid.WorkItems.isEmpty()) {
                ps1.add(psid);
                }
                }
          return ps1;
        
      }
      }
      
}