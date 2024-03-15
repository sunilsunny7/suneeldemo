/**
About
-----
Description: LeadTriggerHandler on Lead
Create date: 26.10-2016

Update History
--------------
Created Mars 2017 - Vahraz Mostajir - Created. Added method setAccountToCase SAEN-2264
Updated Mars 2017 - Vahraz Mostajir - Updated. Added method linkFileToSubcase SAEN-2262
Updated Sept 2017 - AM Team - S.S - created method createmanualcasesharingforcasecreator SALEF-144
Updated Nov 2017 - AM Team - P.P - SALEF - 480 - created method -  setNamedSalesCoordinatorFromKKNR to set value on Named_Sales_Coordinator__c from KKNR Account 
Updated March 2018 - P.P - SALEF 933 - updated method createmanualcasesharingforcasecreator for Cases created from UI
Updated March 2018 - D.C - SALEF- 795 - Created. Added mothed createmanualopportunitysharingforcasecreator to provided edit access on Opp for Case owner user.
Updated May 2018 - P.P - SALEF-857 - Updated method createmanualcasesharingforcasecreator for sharing access for Account Owner, Telia SM and Opportunity Owner
Updated March 2019- Y.K - SALEF-1806 - Files from case to subcase - Updated linkFileToSubcase method
Updated April 2020 - P.S - SALEF-3239 - Updated method -updateParentStatus() - to comment the code for Closing Enterprise Case on closure of sub-case.
Issues / TODOs
--------------
*/

public class CaseTriggerHandler {
    
    /* * * * * * * * * * * * * * * * * * * * */
    /* * CaseTriggerHandler Trigger Calls  * */
    /* * * * * * * * * * * * * * * * * * * * */
    
    public static final String CASE_STATUS_CLOSED = 'Closed';
    public static final String CASE_STATUS_INPROGRESS = 'In Progress';
    public static final String CASE_STATUS_WAITING = 'Waiting';
    public static final String CASE_STATUS_NEW = 'New';
    
    public static final String QUEUE_VOLUME_DESIGN = 'Volume Design';
    public static final String QUEUE_SAT = 'SAT';
    
    private static boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public CaseTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    private static boolean acc_isExecuting = false;
    
    public void OnBeforeInsert(List<Case> newList, Map<ID, Case> newMap){
        System.debug('CaseTriggerHandler.OnBeforeInsert starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        setAccountFromSubject(newList);
        setFieldsinSubCase(newList);  //  V.A
        setNamedSalesCoordinatorFromKKNR(newList,null); // P.P
    }
    
    public void OnBeforeUpdate(List<Case> newList, Map<ID, Case> newMap, List<Case> oldList, Map<ID, Case> oldMap){
        System.debug('CaseTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);       
        setNamedSalesCoordinatorFromKKNR(newList,oldMap);    //P.P
    }
    
    public void OnAfterInsert(List<Case> newList, Map<ID, Case> newMap){
        System.debug('CaseTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);
        linkFileToSubcase(newList);
        updateParentStatus(newList);
        createmanualcasesharingforcasecreator(newList, null); //S.S
    }
    
    public void OnAfterUpdate(List<Case> newList, Map<ID, Case> newMap, List<Case> oldList, Map<ID, Case> oldMap){
        System.debug('CaseTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize);   
        updateParentStatus(newList);
        createmanualcasesharingforcasecreator(newList, oldMap); //S.S
        createmanualopportunitysharingforcasecreator(newList, oldMap); //D.C
    }
    
    public void OnAfterDelete(List<Case> oldList, Map<ID, Case> oldMap){
        System.debug('CaseTriggerHandler.OnAfterDelete starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize); 
    }
    
    public void OnAfterUndelete(List<Case> newList, Map<ID, Case> newMap){
        System.debug('CaseTriggerHandler.OnAfterUndelete starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize); 
        
    }    
    
    /* * * * * * * * * * * * * * * * * * * * * * */
    /* * CaseTriggerHandler Trigger Methods * */
    /* * * * * * * * * * * * * * * * * * * * * * */
    
    //Author: Vahraz Mostajir
    //We set the Account field on case if the subject is an orgnumber.
    public void setAccountFromSubject(List<Case> newList){
        
        Pattern patt = Pattern.compile('^.*\\b(\\d{6}\\-\\d{4})\\b.*|^.*\\b(\\d{10})\\b.*$');
        Set<String> orgs = new Set<String>();
        Map<String, Case> subjectCases = new Map<String, Case>();
        
        for(Case c :newList){
            if(SEUTility.getRecordTypeId('Enterprise') == c.RecordTypeId && !String.isEmpty(c.Subject) && c.Subject.length() > 8){
                Matcher match = patt.matcher(c.Subject);
                if(match.matches()){
                    String orgString = '';
                    if(match.group(2) == null){
                        orgString = match.group(1).replace('-','');
                    }else{
                        orgString = match.group(2);
                    }
                    orgs.add(orgString);
                    subjectCases.put(orgString, c);
                }
            }
        }
        
        Map<String, Account> accs = new Map<String, Account>();
        for(Account acc :[SELECT Id, Name, Org_Nr__c FROM Account WHERE Org_Nr__c IN :orgs]){
            accs.put(acc.Org_Nr__c, acc);
        }
        
        for(String orgString :subjectCases.keySet()){
            if(accs.get(orgString) != null){
                subjectCases.get(orgString).AccountId = accs.get(orgString).Id;
            }
        }
    }  
    
    // Author: Vahraz Mostajir
    public void updateParentStatus(List<Case> newList){
        Set<Id> parentIds = new Set<Id>();
        
        for(Case c :newList){
            if(c.ParentId != null && c.RecordTypeId == SEUTility.getRecordTypeId('Enterprise_Subcase')){
                parentIds.add(c.ParentId);
            }
        }
        
        if(!parentIds.isEmpty()){
            
            Map<Id, Case> parentMap =  new Map<Id, Case>([SELECT Status, Case_Group__c, Id, Notify_Queue__c FROM Case WHERE Id IN :parentIds]); 
            
            //ParentId, List of Subcases
            Map<Id, List<Case>> subCases = new Map<Id, List<Case>>();     
            
            //We map the subcases to parentcases
            for(Case c :[SELECT Id, ParentId, Status FROM Case WHERE ParentId IN :parentIds]){
                if(subCases.get(c.ParentId) == null){                    
                    subCases.put(c.ParentId, new List<Case>{c});
                }else{
                    subCases.get(c.ParentId).add(c);
                }  
            }
            
            for(Case parentCase :parentMap.values()){
                if(parentCase.Notify_Queue__c){
                    if(hasOpenCase(subCases.get(parentCase.Id)) && parentCase.Status != CASE_STATUS_CLOSED){
                        parentCase.Status = CASE_STATUS_WAITING;
                    }else{
                        
                        Case_Settings__c cs = Case_Settings__c.getInstance('General Case Settings');
                        parentCase.Status = CASE_STATUS_INPROGRESS;
                        
                        //Assign it to Volume Design
                        if(parentCase.Case_Group__c == QUEUE_VOLUME_DESIGN){
                            parentCase.OwnerId = cs.Volume_Design_Queue_Id__c;
                            
                            //Assign it to SAT
                        }else If(parentCase.Case_Group__c == QUEUE_SAT){
                            parentCase.OwnerId = cs.SAT_Queue_Id__c;
                        }
                    }
                }else{
                    if(hasOpenCase(subCases.get(parentCase.Id)) && parentCase.Status != CASE_STATUS_CLOSED){
                        parentCase.Status = CASE_STATUS_WAITING;
                    }/*else{         
parentCase.Status = CASE_STATUS_CLOSED;
}*/
                }          
            }
            
            update parentMap.values();
        }
    }
    
    public Boolean hasOpenCase(List<Case> caseList){
        for(Case c :caseList){
            if(c.Status != CASE_STATUS_CLOSED){
                return true;   
            }
        }        
        return false;
    }
    
    // Author: Vahraz Mostajir 
    // We clone file links, mail and attachments for subcases.
    public static void linkFileToSubcase(List<Case> newList){
        //ParentId, Subcases
        Map<Id, List<Case>> caseMap = new Map<Id, List<Case>>();
        
        //For some reason caseMap.keySet is not working in the soql statement so we create a set of parentIds instead
        Set<Id> parentIds = new Set<Id>();
        
        //Create map structure
        for(Case c :newList){
            if(c.RecordTypeId == SEUTility.getRecordTypeId('Enterprise_Subcase') && c.ParentId != null ){
                if(caseMap.get(c.ParentId) == null){
                    caseMap.put(c.ParentId, new List<Case>{c});
                }else{
                    caseMap.get(c.ParentId).add(c);
                }
                
                parentIds.add(c.ParentId);
            }
        }
        //Y.K - SALEF-1806 - Files from case to subcase
        if(!caseMap.keySet().isEmpty()){
            //Get links
            Set<Id> contentDocIds = new Set<Id>();
            List<ContentDocumentLink> contentDocIdListToSend1 = new List<ContentDocumentLink>();
            Map<string, string> mapStr= new map<string, string>();
            set<ContentDocumentLink> parentCaseCdl = new set<ContentDocumentLink> ([SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN :parentIds ]);
            for(ContentDocumentLink cdl :parentCaseCdl){                
                for(Case c :caseMap.get(cdl.LinkedEntityId)){                 
                    contentDocIds.add(cdl.ContentDocumentId);
                    mapStr.put(cdl.ContentDocumentId,c.Id);
                    
                }
            }
            // Get the files which has Send_to_Subcase__c as true
            Set<ContentVersion> contentVersions = new set<ContentVersion>([SELECT Id, Send_to_Subcase__c, ContentDocumentId FROM ContentVersion 
                                                                           WHERE ContentDocumentId IN :contentDocIds
                                                                           AND
                                                                           Send_to_Subcase__c = True]);
            
            Set<Id> contentDocIdsToSend = new Set<Id>();
            for(ContentVersion cv: contentVersions ){
                contentDocIdsToSend.add(cv.ContentDocumentId);
            }
            
            if(!contentDocIdsToSend.isEmpty())
            {
                Set <ContentDocumentLink> cdLinks1=new set <ContentDocumentLink>([SELECT Id,LinkedEntityId,ContentDocumentId , ShareType, Visibility FROM ContentDocumentLink WHERE ContentDocumentId IN :contentDocIdsToSend AND LinkedEntityId IN :parentIds]);
                
                
                for(ContentDocumentLink cl1:cdLinks1){
                    ContentDocumentLink clonedCdl = cl1.Clone();
                    clonedCdl.LinkedEntityId =mapStr.get(cl1.ContentDocumentId); //c.Id;
                    contentDocIdListToSend1.add(clonedcdl);
                }
            } 
            if(!contentDocIdListToSend1.isEmpty()){
                upsert contentDocIdListToSend1;
            }
            
            //For mapping attachments later
            Map<Id, EmailMessage> emailMap = new Map<Id, EmailMessage>();       
            
            for(EmailMessage em :[SELECT Id, ParentId, Subject, Status, HasAttachment, ContentDocumentIds, Incoming, Headers, FromAddress, ToAddress, FromName, HtmlBody, TextBody FROM EmailMessage WHERE ParentId IN :parentIds]){
                for(Case c :caseMap.get(em.ParentId)){
                    EmailMessage emailClone = em.Clone();
                    emailClone.ParentId = c.Id;
                    //added by C.M - to restrict the htmlbody upto 32000 characters
                    if(String.IsNotBlank(em.HtmlBody)){
                        em.HtmlBody.normalizeSpace(); 
                        if(em.HtmlBody.length()>32000)
                        {
                            String htmlBodyMin = em.HtmlBody.substring(0, 32000);
                            emailClone.HtmlBody=htmlBodyMin;
                        }
                    }
                    emailMap.put(em.Id, emailClone);
                }
            }
            
            if(!emailMap.isEmpty()){
                insert emailMap.values();
                
                List<Attachment> attachments = new List<Attachment>();
                
                for(Attachment att :[SELECT Id, Body, ContentType, Description, IsPrivate, OwnerId, Name, ParentId
                                     FROM Attachment WHERE ParentId IN :emailMap.keySet()]){
                                         
                                         Attachment attClone = att.clone();
                                         attClone.ParentId = emailMap.get(att.ParentId).Id;
                                         attachments.add(attClone);
                                     }
                
                if(!attachments.isEmpty()){
                    insert attachments;
                }
            }
        }
    } 
    
    // Author: Varma Alluri on 28.06.2017; SAEN-2319, populate parent field values to child when creating subcases
    Public void  setFieldsinSubCase(List<case> newList){
        Set<Id> parentIds = new Set<Id>();
        list<case> Parentcases = new  list<case>();
        for(Case c :newList){
            if(c.ParentId != null && c.RecordTypeId == SEUTility.getRecordTypeId('Enterprise_Subcase')){
                parentIds.add(c.ParentId);
            }
        }
        Id parentRtId = SEUTility.getRecordTypeId('Enterprise');
        if(!parentIds.isEmpty()){
            Parentcases = [select id,Recordtypeid,Case_Group__c,Category__c,Product_Area__c from case where id IN:parentIds and Recordtypeid=:parentRtId ];
        }
        if(Parentcases.size()>0){
            for(Case c :newList){
                for(Case pc :Parentcases){
                    if(c.ParentId == pc.id){
                        c.Case_Group__c = pc.Case_Group__c;
                        c.Category__c = pc.Category__c;
                        c.Product_Area__c = pc.Product_Area__c;
                    }
                }
            }
        }
    }
    
    public void createmanualcasesharingforcasecreator(List<Case> newList, Map<Id, Case> oldMap)
    {
        Set<String> webEmail = new Set<String>();
        List<User> userlist = new List<User>();
        List<CaseShare> caselist = new List<CaseShare>();
        Set<Id> caseCreatedBySet = new Set<Id>();
        Set<Id> caseSet = new Set<Id>();
        Set<Id> relevantUserId = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        List<Account> accList = new List<Account>();
        Set<Id> oppIdSet = new Set<Id>();
        List<Opportunity> opplist = new List<Opportunity>();
        List<caseShare> caseShareList= new List<CaseShare>();
        List<caseShare> caseShareDeleteList = new List<CaseShare>();
        Map<Id,Case> caseMap = new Map<id,case>();
        
        if(newList != null)
        {
            for(Case newcase : newList)
            {
                if(system.label.Real_Estate_Fiber_Case_RT == SEUTILITY.getRecordTypeDevName(newcase.RecordTypeId) || newcase.RecordTypeId == SEUTility.getRecordTypeId('Enterprise') || newcase.RecordTypeId == SEUTility.getRecordTypeId('Enterprise_Subcase'))
                {
                    if(oldMap == null || newcase.OwnerId != oldMap.get(newcase.Id).OwnerId && newcase.SuppliedEmail != Null)
                    {
                        webEmail.add(newcase.SuppliedEmail);
                    }
                }
                if(newcase.RecordTypeId == SEUTility.getRecordTypeId('Enterprise') || newcase.RecordTypeId == SEUTility.getRecordTypeId('Enterprise_Subcase'))
                {     
                    if(oldMap == null || newcase.OwnerId != oldMap.get(newcase.Id).OwnerId || newCase.Opportunity__c != oldMap.get(newCase.Id).Opportunity__c || newCase.AccountId != oldMap.get(newCase.id).AccountId){
                        caseSet.add(newCase.id);                   
                    }
                }
            }
        }
        if(caseSet.size()<>0){
            List<Case> newCaseList = [Select Id,OwnerId,CreatedById,Opportunity__c,Opportunity__r.OwnerId,AccountId,Account.ownerId,Account.Telia_Service_Manager__c FROM CASE WHERE ID IN: caseSet];
            if(newCaseList.size()>0){
                for(case cs:newCaseList){
                    caseMap.put(cs.id,cs);
                    if(oldMap == Null){
                        if(cs.Account.OwnerId != Null)
                            relevantUserId.add(cs.Account.OwnerId);
                        if(cs.Opportunity__r.OwnerId != Null)
                            relevantuserId.add(cs.Opportunity__r.OwnerId);
                        if(cs.Account.Telia_Service_Manager__c != null)
                            relevantUserId.add(cs.Account.Telia_Service_Manager__c); 
                    }
                    else{
                        if(cs.OwnerId != oldMap.get(cs.Id).OwnerId){
                            relevantuserid.add(cs.CreatedById); 
                            if(cs.Account.OwnerId != Null)
                                relevantUserId.add(cs.Account.OwnerId);
                            if(cs.Opportunity__r.OwnerId != Null)
                                relevantuserId.add(cs.Opportunity__r.OwnerId);
                            if(cs.Account.Telia_Service_Manager__c != null)
                                relevantUserId.add(cs.Account.Telia_Service_Manager__c);            
                        }
                        if(cs.AccountId != OldMap.get(cs.Id).AccountId){
                            accIdSet.add(oldMap.get(cs.id).AccountId);
                            if(cs.Account.OwnerId != Null)
                                relevantUserId.add(cs.Account.OwnerId);
                            if(cs.Account.Telia_Service_Manager__c != null)
                                relevantUserId.add(cs.Account.Telia_Service_Manager__c);  
                        }
                        if(cs.Opportunity__c != OldMap.get(cs.Id).Opportunity__c){
                            oppidSet.add(oldMap.get(cs.id).Opportunity__c);
                            if(cs.Opportunity__r.OwnerId != Null)
                                relevantuserId.add(cs.Opportunity__r.OwnerId);
                        }
                    }
                }
            }
        }
        if(relevantuserId.size()>0){
            for(Id uId:relevantuserId){
                for(case c:newList){
                    if(uid != c.OwnerId){                     
                        CaseShare cs = new CaseShare();
                        cs.CaseAccessLevel = 'Read';
                        cs.CaseId = c.Id;
                        cs.UserOrGroupId =  uId;
                        caseList.add(cs);
                    }
                }
            }
        }
        if(accIdSet.size()>0){
            accList = [SELECT Id,OwnerId, Telia_Service_Manager__c FROM Account WHERE ID IN: accIdSet];
        }
        if(oppIdSet.size()>0){
            oppList= [SELECT Id, OwnerId FROM OPportunity WHERE ID IN: oppIdSet];
        }
        if(caseSet.size()<>0 && (accIdSet.size() >0) || oppidSet.size()>0){
            for(CaseShare csr:[Select id,RowCause, CaseAccessLevel, CaseId, UserOrGroupId FROM CaseShare WHERE CaseId IN: CaseSet AND RowCause = 'Manual' AND CaseAccessLevel = 'Read']){
                if((csr.userOrGroupId != caseMap.get(csr.CaseId).CreatedById) && (csr.userOrGroupId != caseMap.get(csr.CaseId).Account.OwnerId) && (csr.userOrGroupId != caseMap.get(csr.CaseId).Account.Telia_Service_Manager__c) && (csr.userOrGroupId != caseMap.get(csr.CaseId).Opportunity__r.OwnerId)){
                    caseShareDeleteList.add(csr);
                }
            }
        }
        if(webEmail != null){
            userlist = [Select id, email from user where email in: webEmail];
            if(userlist != null){
                for(Case c : newlist){
                    for(user u : userlist){
                        if(u.id != c.OwnerId){
                            CaseShare cs = new CaseShare();
                            cs.CaseAccessLevel = 'Read';
                            cs.CaseId = c.Id;
                            cs.UserOrGroupId =  u.Id;
                            caseList.add(cs);
                        }
                    }
                }
            }
        }
        Database.SaveResult[] csList;
        if(caseList != null){          
            csList = Database.insert(caseList, false);
        }
        if(csList != null){
            for(Database.SaveResult sr : csList){
                if(sr.isSuccess()){
                }
                else{
                    if(sr.getErrors() != null){
                        for(Database.Error err : sr.getErrors()){
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            }
        }
        if(CaseShareDeleteList.size()>0){
            try{
                delete caseShareDeleteList;
            }
            catch(exception e){
                
            }
        }
    }   
    
    
    //AUTHOR - D.C.   for SALEF - 795
    //This method will provide edit access on opportunity record to its case owner which will be a user and not queue. 
    public void createmanualopportunitysharingforcasecreator(List<Case> newList, Map<Id, Case> oldMap){
        List<User> userlist = new List<User>();
        String userPrefix = User.sObjectType.getDescribe().getKeyPrefix();
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        if(newList != null){
            for(Case c : newList) {
                if(c.Opportunity__c != null && c.Case_Owner__c != null)  {
                    if( String.valueOf(c.OwnerId).substring(0,3) == userPrefix){
                        OpportunityShare opptyshare = new OpportunityShare();
                        opptyshare.OpportunityId = c.Opportunity__c;
                        opptyshare.OpportunityAccessLevel = 'Edit';
                        opptyshare.UserOrGroupId = c.OwnerId;
                        opptyshare.RowCause = 'Manual';
                        oppShares.add(opptyshare);
                        
                        
                    }
                    if(oldMap != null && c.OwnerId != oldMap.get(c.Id).OwnerId){
                        OpportunityShare opptyshare = new OpportunityShare();
                        opptyshare.OpportunityId = c.Opportunity__c;
                        opptyshare.OpportunityAccessLevel = 'Read';
                        opptyshare.UserOrGroupId = oldMap.get(c.Id).OwnerId;
                        opptyshare.RowCause = 'Manual';
                        oppShares.add(opptyshare);
                        
                        
                    }
                    
                }        
            }
        }
        Database.SaveResult[] opListrev;
        if(oppShares != null)
        {
            opListrev = Database.insert(oppShares, false);
        }
        if(opListrev != null)
        {
            for (Database.SaveResult srrev : opListrev) 
            {
                if (srrev.isSuccess()) 
                {
                    System.debug('Successfully oppty share. OpportunityShare ID: ' + srrev.getId());
                }
                else 
                {
                    if(srrev.getErrors() != null)
                    {
                        for(Database.Error err : srrev.getErrors()) 
                        {
                            System.debug('The following error has occurred.');                   
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                    }
                }
            }
        }
    }
    
    //AUTHOR - P.P
    // for SALEF - 480
    private static void setNamedSalesCoordinatorFromKKNR(List<Case> newCaseList,Map<Id,Case> oldMap){
        Set<Case> caseWithAccountSet = new Set<Case>();
        Set<Case> caseWOAccountSet = new Set<Case>();
        List<Id> accIdList = new List<Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        
        for(case c:newCaseList){
            if(SEUtility.getRecordTypeId('Enterprise') == c.RecordTypeId){
                if(oldMap == NULL){
                    if(c.Accountid != NULL){
                        caseWithAccountSet.add(c);
                        accIdList.add(c.AccountId);
                    }
                }
                else if(oldMap.get(c.Id) != NULL && oldMap.get(c.Id).AccountId != c.AccountId){
                    if(c.AccountId!= NULL){
                        caseWithAccountSet.add(c);
                        accIdList.add(c.AccountId);                
                    }
                    else{
                        caseWOAccountSet.add(c);
                    }
                }
            }
        }
        if(accIdList.size()>0){
            accMap = new Map<Id,Account>([SELECT Id,ParentId,Parent.Named_Sales_Coordinator__c FROM Account WHERE ID IN: accIdList]);
        }
        
        if(accMap.size()>0)
        {     //case with account list?
            for(Case c:newCaseList){
                if(caseWithAccountSet.contains(c)){
                    if(c.AccountId != NULL && accMap.get(c.Accountid).ParentId != NULL && accMap.get(c.AccountId).Parent.Named_Sales_Coordinator__c != Null){
                        string accNSC = accMap.get(c.AccountId).Parent.Named_Sales_Coordinator__c;
                        if(accNSC != NULL){
                            c.Named_Sales_Coordinator__c = accNSC;
                        }
                    }
                }
                if(caseWOAccountSet.contains(c)){
                    c.Named_Sales_Coordinator__c = NULL;
                }
            }
        } 
    }
}