/* Author: Varma Alluri on 04.04.2017                                                                                                                                                                                      
Description: Jira Ticket: SAEN-2252; AttachmentTrigger calls this Handler populating a custom checkbox field (HasAttachment__c)
on the subcase to TRUE or FALSE depending on if attachments or attachments on Email exists on the subcase or not. */

public class AttachmentTriggerHandler {
    public static void OnafterInsert(List<Attachment> newList){
        attCheckSubcasestoUpdateInsert(newList);
        attCheckSubcasestoUpdateEmailsInsert(newList);
        
    } 
    public static void OnafterDelete(List<Attachment> newList){
        attCheckSubcasestoUpdateDelete(newList);
        attCheckSubcasestoUpdateEmailsDelete(newList);
    }
    
    Public static void attCheckSubcasestoUpdateInsert(List<Attachment> newList)
    {
        Id recTypeId = SEUTility.getRecordTypeId('Enterprise_Subcase');
        string csprfx= Case.SObjectType.getDescribe().getKeyPrefix();
        Set<ID> caseIds=new Set<ID>();
        
        for(Attachment att:newList){               
            if(string.valueOf(att.ParentId).startsWith(csprfx) ){
                caseIds.add(att.ParentId);
            }
        }
        
        List<Case> csToUpdate=new List<Case>();
        for(case cs:[Select Id,HasAttachment__c,RecordTypeId, (SELECT Id, Name FROM Attachments), (SELECT Id FROM ContentDocumentLinks) FROM Case where RecordTypeId=:recTypeId and ID IN:caseIds])
        {         
            if((cs.Attachments.Size()>0 || cs.ContentDocumentLinks.Size()>0)&& cs.HasAttachment__c==false) 
            {
                cs.HasAttachment__c=True; 
                csToUpdate.add(cs);
            } 
        }
        if(!csToUpdate.isEmpty()){
            Try{
                update csToUpdate;
            }catch(exception e){
                system.debug('exception=='+e);
            }
        }
    }
    Public static void attCheckSubcasestoUpdateDelete(List<Attachment> newList)
    {
        Id recTypeId = SEUTility.getRecordTypeId('Enterprise_Subcase');
        string csprfx= Case.SObjectType.getDescribe().getKeyPrefix();
        Set<ID> caseIds=new Set<ID>();
        
        for(Attachment att:newList){               
            if(string.valueOf(att.ParentId).startsWith(csprfx)){
                caseIds.add(att.ParentId);
            }
        }
        
        List<Case> csToUpdate=new List<Case>();
        for(case cs:[Select Id,HasAttachment__c,RecordTypeId, (SELECT Id, Name FROM Attachments), (SELECT Id FROM ContentDocumentLinks) FROM Case where RecordTypeId=:recTypeId and ID IN:caseIds])
        {             
            if(cs.Attachments.Size()==0 && cs.HasAttachment__c==True && cs.ContentDocumentLinks.Size()==0) 
            {
                cs.HasAttachment__c=false; 
                csToUpdate.add(cs);
            }             
        }
        if(!csToUpdate.isEmpty()){
            Try{
                update csToUpdate;
            }catch(exception e){
                system.debug('exception=='+e);
            }
        }
    } 
    public static void  attCheckSubcasestoUpdateEmailsInsert(list<attachment> newList){
        Id recTypeId = SEUTility.getRecordTypeId('Enterprise_Subcase');
        string csprfx= emailmessage.SObjectType.getDescribe().getKeyPrefix();
        
        Set<ID> emailIds=new Set<ID>();
        for(Attachment att:newList){               
            if(string.valueOf(att.ParentId).startsWith(csprfx)){
                emailIds.add(att.ParentId);
            }
        }
        Set<ID> caseIds=new  Set<ID>();
        list<emailmessage> emails = [select id,ParentId from emailmessage where id IN:emailIds ];
        
        for(emailmessage e : emails) {
            caseIds.add(e.parentid);
        }
        
        List<Case> csToUpdate=new List<Case>();
        for(case cs:[Select Id,HasAttachment__c,RecordTypeId,(SELECT id,HasAttachment From emailmessages where HasAttachment=true),(SELECT Id, Name FROM Attachments), (SELECT Id FROM ContentDocumentLinks) FROM Case where RecordTypeId=:recTypeId and ID In:caseIds])
        { 
            if((cs.Attachments.Size()>0 || cs.ContentDocumentLinks.Size()>0 || cs.emailmessages.size()>0) && cs.HasAttachment__c==false) 
            {
                cs.HasAttachment__c=True;
                csToUpdate.add(cs);
            } 
        }
        if(!csToUpdate.isEmpty()){
            Try{
                update csToUpdate;
            }catch(exception e){
                system.debug('exception=='+e);
            }
        }
    }
    public static void  attCheckSubcasestoUpdateEmailsDelete(list<attachment> newList){
        Id recTypeId = SEUTility.getRecordTypeId('Enterprise_Subcase');
        
        string csprfx= emailmessage.SObjectType.getDescribe().getKeyPrefix();
        Set<ID> emailIds=new Set<ID>();
        for(Attachment att:newList){               
            if(string.valueOf(att.ParentId).startsWith(csprfx)){
                emailIds.add(att.ParentId);
            }
        }
        
        Set<ID> caseIds=new  Set<ID>();
        list<emailmessage> emails = [select id,ParentId from emailmessage where id IN:emailIds ];
        for(emailmessage e : emails) {
            caseIds.add(e.parentid);
        }   
        
        List<Case> csToUpdate=new List<Case>();
        for(case cs:[Select Id,HasAttachment__c,RecordTypeId,(SELECT id,HasAttachment From emailmessages where HasAttachment=true),(SELECT Id, Name FROM Attachments), (SELECT Id FROM ContentDocumentLinks) FROM Case where RecordTypeId=:recTypeId and ID In:caseIds])
        {
            if(cs.Attachments.Size()==0 && cs.HasAttachment__c==True && cs.ContentDocumentLinks.Size()==0 && cs.emailmessages.size()==0 ) 
            {
                cs.HasAttachment__c=false; 
                csToUpdate.add(cs);
            } 
        }
        if(!csToUpdate.isEmpty()){
            Try{
                update csToUpdate;
            }catch(exception e){ 
                system.debug('exception=='+e);
            }
        }
    }
}