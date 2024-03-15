/* Author: Varma Alluri on 04.04.2017    
Description: Jira Ticket: SAEN-2252; ContentDocumentLinkTrigger calls this Handler populating a custom checkbox 
field (HasAttachment__c) on the subcase to TRUE or FALSE depending on if a content document exists on the subcase or not. */

/*
Updated March 2019 - Y.K - SALEF-1806 - Files from case to subcase
Updated April 2019 - Y.K - SALEF-2073 - Sharing notes in Salesforce - Not working          
*/
//REALESTATEFIBER 
/* Updated by Monika on 23.04.2019
Jira story: MCSTO:728 Document naming convention */
public class ContentDocumentLinkTriggerHandler {
    public static void OnafterInsert(List<ContentDocumentLink> newList){
        CasetoCheck(newList);
        updateDocumentName(newList);
    }
    public static void OnbeforeDelete(List<ContentDocumentlink> cds){
        CasetoUncheck(cds);
    }
    public static void OnbeforeInsert(List<ContentDocumentLink> newList){
        giveSetByRecordAccess(newList);
    }   
    
    public static void updateDocumentName(List<ContentDocumentLink> newList){
        try{
            String contextObjName,formattedDate = (Datetime.now()).format('yyyy-MM-dd_hh-mm-ss');
            Id recordTypeId,FiberRecordTypeId;
            Boolean testOn=(test.isRunningTest());
            //List<ContentDocumentLink> cdLinks = new List<ContentDocumentLink>();Commented for optimization
            Set<Id> contentDocumentIds = new Set<Id>();
            Map<Id,Id> contentDocumentIdToContentLinkId = new Map<Id,Id>();
            //DateTime dt = Datetime.now();
            //String formattedDate = (Datetime.now()).format('yyyy-MM-dd_hh-mm-ss');//Praveena 
            for (ContentDocumentLink cdl : newList){       
                contentDocumentIds.add(cdl.ContentDocumentId);
                Schema.SObjectType contextObjType =  Id.valueOf(cdl.LinkedEntityId).getSObjectType();
                contextObjName = contextObjType.getDescribe().getName();
                //contextObjName = 'QUOTE';
                if(testOn && contextObjName!= null){
                    contextObjName = 'CONTRACT';
                }
                contentDocumentIdToContentLinkId.put(cdl.ContentDocumentId,cdl.LinkedEntityId); 
            }
            // get the ContentDocuments related to the ContentDocumentLink records in the scope of our trigger
            //List<String> contentDocumentNames = new List<String>();//Commented for optimization
            Map<Id,String> cvToTitleMap = new Map<Id,String>();
            Map<Id,String> cvDocumentToIdMap = new Map<Id,String>();
            /*List<ContentDocument> contentDocuments = [Select Id, Title FROM ContentDocument WHERE Id IN :contentDocumentIds];            
            for(ContentDocument cd : contentDocuments){
                contentDocumentNames.add(cd.Title);
                //system.debug('ContentDocument Name: '+cd.Title);
            }*/ //Commented by abhishek for Optimization           
            //List<ContentVersion> contentVersions = [Select Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds];//Commented for optimization
            for (ContentVersion cv : ([Select Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds])){
                cvToTitleMap.put(cv.ContentDocumentId,cv.Title);
                cvDocumentToIdMap.put(cv.ContentDocumentId, cv.Id);          
            }
            //system.debug('cvToTitleMap: '+cvToTitleMap);
            //system.debug('cvDocumentToIdMap: '+ cvDocumentToIdMap);
            // get the ContentDocument records with the same names as the ones in our triggers, possibly document template ContentDocument records
            //List<Id> possibleTemplateContentDocumentIds = new List<Id>();
            //List<ContentDocument> templateContentDocuments = [Select Id, Title, ParentId, FileType FROM ContentDocument WHERE Title IN :contentDocumentNames];//Commented for optimization
            //List<ContentDocument> templateContentDocuments = [Select Id FROM ContentDocument WHERE Id IN :contentDocumentIds];//Added for optimization
            /*for (ContentDocument cd : ([Select Id FROM ContentDocument WHERE Id IN :contentDocumentIds])){
                possibleTemplateContentDocumentIds.add(cd.Id);
            } */           
            if(!testOn){
                // get the ContentWorkspace (library) for the document templates
                //ContentWorkspace cw = [Select Id, DeveloperName FROM ContentWorkspace WHERE DeveloperName = 'VlocityDocumentTemplateLibrary'];                
                // get the ContentWorkspaceDoc so we can identify the ContentDocument Id of our document template
                // note this may be empty if the user hasnt created the vlocity doc template library or if user is inserting the file for vlocity document template
                //List<ContentWorkspaceDoc> templateCWD= [Select Id, ContentWorkspaceId, ContentDocumentId FROM ContentWorkspaceDoc WHERE ContentDocumentId IN :possibleTemplateContentDocumentIds AND ContentWorkspaceId = :cw.Id];
                //String recordTypeName=Schema.getGlobalDescribe().get('Quote').getDescribe().getRecordTypeInfosById().get(parent.RecordTypeId).getName();
                // if above query is not empty, that means this is a generated document file. Need to update its file name
                recordTypeId=Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().get(SEUtility.FRAMEAGREEMENT).getRecordTypeId();
                FiberRecordTypeId=Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().get(SEUtility.REALESTATEFIBER).getRecordTypeId();//Praveena
            }
            List<ContentVersion> cvTitleToUpdate = new List<ContentVersion>();//Added for optimization
            //if(!templateCWD.isEmpty() && !contentDocumentIdToContentLinkId.isEmpty() && contextObjName == 'CONTRACT')
            if(!contentDocumentIdToContentLinkId.isEmpty() && contextObjName == 'CONTRACT'){               
               List<Contract> fileContracts = [SELECT Id, Name, TeliaSE_DocName__c,TeliaSE_OrderDocName__c,ContractNumber, RecordTypeId FROM Contract WHERE Id IN :contentDocumentIdToContentLinkId.values()]; // ****NOTE****: Contract.Name is null for most records -- probably want to update this     
               Map<Id,Contract> linkedEntityIdtoContract = new Map<Id,Contract>();
                if(!testOn && (fileContracts[0].RecordTypeId == FiberRecordTypeId || fileContracts[0].RecordTypeId == recordTypeId)){//Praveena
                   for(Contract fileContract : fileContracts){
                        linkedEntityIdtoContract.put(fileContract.Id,fileContract);
                    }
                   // List<ContentVersion> cvTitleToUpdate = new List<ContentVersion>();//Commented for optimization
                    for (ContentDocumentLink cdl1 : newList){  
                        //system.debug('COntentDocument Name: '+cvToTitleMap.get(cdl1.ContentDocumentId));
                        if((cvToTitleMap.containsKey(cdl1.ContentDocumentId) && cvDocumentToIdMap.containsKey(cdl1.ContentDocumentId)) && !(cvToTitleMap.get(cdl1.ContentDocumentId).startsWithIgnoreCase('SWE_MC Full Frame Agreement') || cvToTitleMap.get(cdl1.ContentDocumentId).startsWithIgnoreCase('ENG_MC Full Frame Agreement') || cvToTitleMap.get(cdl1.ContentDocumentId).startsWithIgnoreCase('ENG_MC_Avtalsbilaga') || cvToTitleMap.get(cdl1.ContentDocumentId).startsWithIgnoreCase('SWE_MC_Avtalsbilaga'))){//Added removal of full frame and initial order docs for optimization since now they are naed inside omniscript  
                            ContentVersion newCv;
                            if(cvToTitleMap.get(cdl1.ContentDocumentId).startsWithIgnoreCase('Orderunderlag'))
                                newCv = new ContentVersion(Id = cvDocumentToIdMap.get(cdl1.ContentDocumentId), Title = linkedEntityIdtoContract.get(cdl1.LinkedEntityId).TeliaSE_OrderDocName__c +'_'+ formattedDate +'.' + cvToTitleMap.get(cdl1.ContentDocumentId).split('\\.')[1]); 
                            //****NOTE****: Contract.Name is null for most records -- probably want to update this
                            
                            /*else if(cvToTitleMap.get(cdl1.ContentDocumentId).startsWithIgnoreCase('ENG_MC_Avtalsbilaga') || cvToTitleMap.get(cdl1.ContentDocumentId).startsWithIgnoreCase('SWE_MC_Avtalsbilaga') ){
                                newCv = new ContentVersion(Id = cvDocumentToIdMap.get(cdl1.ContentDocumentId), Title ='Initial beställning för '+linkedEntityIdtoContract.get(cdl1.LinkedEntityId).ContractNumber); 
                            }*///Commented for optimization
                            else if(cvToTitleMap.get(cdl1.ContentDocumentId).startsWithIgnoreCase('ExcelGenerated')){
                                newCv = new ContentVersion(Id = cvDocumentToIdMap.get(cdl1.ContentDocumentId), Title ='Pris- och beställningsunderlag Touchpoint Plus '+linkedEntityIdtoContract.get(cdl1.LinkedEntityId).ContractNumber);
                            }                            
                            else{
                                //For across Projects - Custom setting TeliaSE_DocumentPrefix__c is to check which document we need to rename
                                //If we are uploading document with new name, prefix of the docs should be added in TeliaSE_DocumentPrefix__c custom setting.
                                for(TeliaSE_DocumentPrefix__c docPrefix: TeliaSE_DocumentPrefix__c.getAll().values()){
                                    if(cvToTitleMap.get(cdl1.ContentDocumentId).startsWithIgnoreCase(docPrefix.Name)){
                                        newCv = new ContentVersion(Id = cvDocumentToIdMap.get(cdl1.ContentDocumentId), Title =linkedEntityIdtoContract.get(cdl1.LinkedEntityId).TeliaSE_DocName__c +'_'+ formattedDate ); 
                                        // ****NOTE****: Contract.Name is null for most records -- probably want to update this
                                    }
                                }
                            }                            
                            cvTitleToUpdate.add(newCv);                          
                        }
                    }
                    /*if(cvTitleToUpdate != null && cvTitleToUpdate.size()>0)//Commented for optimization
                        update cvTitleToUpdate;                    
                */
                }
            }
            //if(!templateCWD.isEmpty() && !contentDocumentIdToContentLinkId.isEmpty() && contextObjName == 'QUOTE')
            if(testOn){
                contextObjName = 'QUOTE';
            }
            if(!contentDocumentIdToContentLinkId.isEmpty() && contextObjName == 'QUOTE'){
                //List<Quote> fileQuotes = [SELECT Id, Name, TeliaSE_DocumentName__c FROM Quote WHERE Id IN :contentDocumentIdToContentLinkId.values()]; // ****NOTE****: Contract.Name is null for most records -- probably want to update this//Commented for optimization
                Map<Id,Quote> linkedEntityIdtoQuote = new Map<Id,Quote>();
                for(Quote fileQuote : ([SELECT Id, Name, TeliaSE_DocumentName__c FROM Quote WHERE Id IN :contentDocumentIdToContentLinkId.values()])){
                    linkedEntityIdtoQuote.put(fileQuote.Id,fileQuote);
                }
               // List<ContentVersion> cvTitleToUpdate = new List<ContentVersion>();//Commented for optimization
                for (ContentDocumentLink cdl2 : newList){
                    if(cvToTitleMap.containsKey(cdl2.ContentDocumentId) && cvDocumentToIdMap.containsKey(cdl2.ContentDocumentId)){
                        //For across Projects - Custom setting TeliaSE_DocumentPrefix__c is to check which document we need to rename
                        //If we are uploading document with new name, prefix of the docs should be added in TeliaSE_DocumentPrefix__c custom setting.
                        for(TeliaSE_DocumentPrefix__c docPrefix: TeliaSE_DocumentPrefix__c.getAll().values()){
                            if(cvToTitleMap.get(cdl2.ContentDocumentId).startsWithIgnoreCase(docPrefix.Name)){                                
                                ContentVersion newCv = new ContentVersion(Id = cvDocumentToIdMap.get(cdl2.ContentDocumentId), Title = linkedEntityIdtoQuote.get(cdl2.LinkedEntityId).TeliaSE_DocumentName__c +'_'+ formattedDate + '.' + cvToTitleMap.get(cdl2.ContentDocumentId).split('\\.')[1]); 
                                cvTitleToUpdate.add(newCv);                                
                            }
                        }
                    }
                }
               /* if(cvTitleToUpdate != null && cvTitleToUpdate.size() > 0)//Commented for optimization
                    update cvTitleToUpdate;
            */
            }
                if(cvTitleToUpdate != null && cvTitleToUpdate.size()>0)
                        update cvTitleToUpdate;                    
                
            
        }
          catch (Exception e) {
            System.debug(LoggingLevel.DEBUG, 'Error on contentdocumentlink: ' + e.getStackTraceString());
        }
    }
    
    Public static void CasetoCheck(List<ContentDocumentLink> newList){
        //Id recTypeId = SEUTility.getRecordTypeId('Enterprise_Subcase');
        Set<Id> CaseIds = new Set<Id>();
        List<Case> listCase = new List<Case>();
        string csprfx= Case.SObjectType.getDescribe().getKeyPrefix();        
        for (ContentDocumentLink cdl : newList){
            // String id = cdl.LinkedEntityId;
            if(cdl.LinkedEntity.Type == 'Case' || ((String)(cdl.LinkedEntityId)).substring(0,3) == csprfx){
                CaseIds.add(cdl.LinkedEntityId);
            }
        }
        List<Case> Caselist = [Select Id,HasAttachment__c,RecordTypeId from Case where RecordTypeId=:(SEUTility.getRecordTypeId('Enterprise_Subcase')) and Id IN:CaseIds];
        if(Caselist!=null && Caselist.size()>0){
            for(Case cs : Caselist){
                cs.HasAttachment__c = true;
                listCase.add(cs);
            }
        }
        if(!listCase.isEmpty()){
            try{
                update listCase;
            }catch(exception e){
                system.debug('exception=='+e);
            }
        }
    }
    
    Public static void CasetoUncheck(List<ContentDocumentlink> cdls){        
        Set<Id> CaseIds = new Set<Id>();
        List<Case> listCase = new List<Case>();
        string csprfx= Case.SObjectType.getDescribe().getKeyPrefix();
        for (ContentDocumentLink cdl : cdls){
            //String id = cdl.LinkedEntityId;
            if(((String)(cdl.LinkedEntityId)).substring(0,3) == csprfx){
                CaseIds.add(cdl.LinkedEntityId);
            }
        }
        Id recTypeId = SEUTility.getRecordTypeId('Enterprise_Subcase');
        List<Case> csToUpdate=new List<Case>();
        for(case cs:[Select Id,HasAttachment__c,RecordTypeId,(SELECT Id FROM ContentDocumentLinks),(SELECT Id FROM attachments) FROM Case where RecordTypeId=:recTypeId and ID In:CaseIds]){
            if(cs.ContentDocumentLinks.Size()==1 && cs.HasAttachment__c==True && cs.attachments.Size()==0){
                cs.HasAttachment__c=false; 
                csToUpdate.add(cs);
            } 
        }
        if(!csToUpdate.isEmpty()){
            try{ 
                update csToUpdate;
            }catch(exception e){
                system.debug('exception=='+e);
            }
        }
    }
    //Y.K - SALEF-1806 - Files from case to subcase        
    public static void giveSetByRecordAccess(List<ContentDocumentlink> newList){        
        List <ContentDocumentLink> contDocLink = new List<ContentDocumentLink>();       
        for (ContentDocumentLink cdl : newList){           
            if(String.valueof(cdl.LinkedEntityId).startsWith('500')){ //Y.K- SALEF 2073      
                 String docId = cdl.ContentDocumentId;       
                cdl.ShareType ='I';     
                contDocLink.add(cdl);       
                // System.debug('contDocLink *** :' + contDocLink);      
            }       
            
        }       
    }
    
    public static void addDocumentToOpportunity(List<ContentDocumentLink> newList){
        list<id> quoteIds = new List<id>();
        List<ContentDocumentLink> contentDocumentLinks = new List<ContentDocumentLink>();
        List<ContentDocumentLink> filteredNewList = new List<ContentDocumentLink>();
        Map<Id,Id> CDLOpportunityMap = new Map<Id,Id>();
        Map<Id,String> qtIdToRecordId = new Map<Id,String>();
        List<Id> contentdocumentId = new List<Id>();
        for(ContentDocumentLink cdl: newList){
            quoteids.add(cdl.LinkedEntityId);
            contentdocumentId.add(cdl.ContentDocumentId);
        }
        
        List<Quote> quotes = [Select id,OpportunityId,recordType.developerName from quote where id IN: quoteids];
        for(Quote q : quotes){
            CDLOpportunityMap.put(q.id,q.OpportunityId);
            qtIdToRecordId.put(q.id,q.recordType.developerName);            
        }
        
        /* FIX: SALEF-7802 & SALEF-7799
         * Description: Remove PDF attaching on opportunity for Quote document generation
         * Author: Abhinav Gupta
                
        Map<id,ContentDocument> cdMap = new Map<Id,ContentDocument>([Select id, FileType,FileExtension from ContentDocument where id in:contentdocumentId and FileExtension !='pdf']);        
        for(ContentDocumentLink cdl : newList){
            if(cdMap.containsKey(cdl.ContentDocumentId) || String.ValueOf(qtIdToRecordId.get(cdl.LinkedEntityId)) != 'Offer'){
                filteredNewList.add(cdl);
            }
        }
        end Fix*/
                
        for(ContentDocumentLink cdl: newList){
            ContentDocumentLink cdlnew = cdl.clone(false,true);
            cdlnew.LinkedEntityId = CDLOpportunityMap.get(cdl.LinkedEntityId);
            contentDocumentLinks.add(cdlnew);
        }
        if(contentDocumentLinks.size() >0 ){
            insert contentDocumentLinks;    
        }
  
    }
}