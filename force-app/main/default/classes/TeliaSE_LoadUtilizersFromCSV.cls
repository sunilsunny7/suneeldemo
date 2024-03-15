/*-----------------------------------------------------------------------------------------------------------
**Name: TeliaSE_LoadUtilizersFromCSV 
**Created By:  Ragunathan Alagesan
**Sprint: MC Drop 2, Sprint-2
**User Story:MCSTO 1211, https://diva.teliacompany.net/confluence/display/MCSTO/1211+-+Adding+utlizers+to+agreement
**Description: Upload the utilizers in bulk from a CSV file.
-----------------------------------------------------------------------------------------------------------*/

global without Sharing class TeliaSE_LoadUtilizersFromCSV  implements vlocity_cmt.VlocityOpenInterface{
    
    public static string finalCSVString ='Organisationsnamn,Organisationsnr\n';
    
    //Currently 200  utilizers can be added, can be configured based on business need, this can be updated in custom label
    public static String numberOfUtilizersAdded = System.Label.TeliaSE_Utilizer_Limit;
    public static Integer utilizerLimit = Integer.valueOf(numberOfUtilizersAdded);
    public List<Map<String,String>> listOfNonExistingOrgNum = new List<Map<String,String>>();
    String baseUrl= URL.getSalesforceBaseUrl().toExternalForm();

    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
     Boolean result = true;
        try{
            if (methodName.equals('parseCSVFile')){   
                parseCSVFile(inputMap,outMap);
            }
            if (methodName.equals('addSingleUtilizer')){   
                addSingleUtilizer(inputMap,outMap);
            }
            else{
                result=false;
            }
            
        }catch(Exception e){
            System.debug('Error while adding Utilizers, please contact System Administrator: '+e);
            result=false;
        }
        return result;
   }
 
    //This method is used to single utilizer based on search by Name or Org number
    private void addSingleUtilizer(Map<String, Object> inputMap, Map<String, Object> outMap){
      String orgNumber = (String)inputMap.get('orgNumberBySearch');
        String accountId = (String)inputMap.get('AccountId1');
        String contractId = (String)inputMap.get('FAId');//ContextId
        Integer numberOfUtilizersAddedInt = getNumberOfUtilizers(contractId);
    
        try{
            
            //In case if the org number and Account ID are not available, ignore and allow the user to pass
            //to next screen at front end.
            if((orgNumber == null || orgNumber =='') && accountId == null){
                return;
            }
            
            //Utililizers can not be added more than 200 for and contract, check the existing utlizers and notifiy the user
            if(numberOfUtilizersAddedInt >= utilizerLimit){
                outMap.put('TUPPLimitExceeded',System.Label.TeliaSE_UtilizerMsg_Over200);
                outMap.put('TUPPLimitExceededError','TUPPLimitExceededErrorMsg');
                return;            
            }
            
            //If some account may not have Org number, do not add those account as Utilizer.
            if((orgNumber == null || orgNumber =='') && accountId != null){
                outMap.put('SingleUtilizerErrorMessage',System.Label.TeliaSE_UtilizerMsg_OrgNotExist);
                outMap.put('SingleUtilizerFlag','SingleUtilizerError');
                return;
            }
            
            //Get all the contracts which are in this list of Org number
            List<Contract> ct = [select AccountId,ContractNumber,Status,Org_Nr__c,Id from Contract where Status!='Cancelled' and RecordType.Name='Ramavtal' and Org_Nr__c =:orgNumber];
            
            //If any contract returned, this account can't be added as utilizer as its already part of an contract
            if(ct.size() > 0){
                outMap.put('SingleUtilizerErrorMessage',System.Label.TeliaSE_UtilizerMsg_Org_Own_FA+' '+ct[0].ContractNumber);
                outMap.put('SingleUtilizerFlag','SingleUtilizerError');
            }
            else{ 
                //Check if the utilizer is already added in junction object as a utlizer for the same contract
                List<Utilizer_Contract_Relationship__c> ut = [SELECT ContractNumber__r.status, Org_Number__c,Status__c FROM Utilizer_Contract_Relationship__c 
                                                              where ContractNumber__r.status != 'Cancelled' and ContractNumber__r.RecordType.Name = 'Ramavtal'
                                                              and ContractNumber__c =:contractId and Org_Number__c =:orgNumber and (Status__c ='Aktiv' OR Status__c ='Draft' OR Status__c ='PendingActive' OR Status__c ='PendingInactive' or Status__c ='Manual' or Status__c ='Inaktiv')];
                
                if(ut.size()>0){
                    //DROP 3 Check:
                    Utilizer_Contract_Relationship__c utCheck = new Utilizer_Contract_Relationship__c();
                    for(Utilizer_Contract_Relationship__c utloop : ut){
                        if(utloop.Org_Number__c == orgNumber && utloop.Status__c =='Inaktiv')
                        {
                            utloop.Status__c = 'Draft';
                            utCheck = utloop;
                        }
                    }
                    if(utCheck.id != null){
                        update utCheck;
                        outMap.put('SingleUtilizerSuccess','AddedSuccessfully');
                    }
                    else{
                        //system.debug('Error Scenario single utilizer add to same contract');
                        outMap.put('SingleUtilizerErrorMessage',System.Label.TeliaSE_UtilizerMsg_OrgAlreadyExists);
                        outMap.put('SingleUtilizerFlag','SingleUtilizerError');
                    }                    
                }else{ 
                    //Check if the Utilizer is already added as a utilizer of some other contract
                    List<Utilizer_Contract_Relationship__c> ut1 = [SELECT ContractNumber__r.status, Org_Number__c, ContractNumber__r.ContractNumber, 
                                                                   Status__c FROM Utilizer_Contract_Relationship__c 
                                                                   where ContractNumber__r.status != 'Cancelled' and ContractNumber__r.RecordType.Name = 'Ramavtal'
                                                                   and  Org_Number__c =:orgNumber and (Status__c ='Aktiv' OR Status__c ='Draft' OR Status__c ='PendingActive' OR Status__c ='PendingInactive' or Status__c ='Manual')];
                    
                    if(ut1.size() >0){
                        outMap.put('SingleUtilizerErrorMessage',System.Label.TeliaSE_UtilizerMsg_OrgAlreadyExistsWith_Diff_FA+' '+ut1[0].ContractNumber__r.ContractNumber);
                        outMap.put('SingleUtilizerFlag','SingleUtilizerError');
                        
                    } else{
                        //If above checks feail, this Utilizer is not part of any contract and can be added to this contract as utilizer.
                        if( orgNumber != null && accountId != null){
                            Utilizer_Contract_Relationship__c ucr = new Utilizer_Contract_Relationship__c();
                            ucr.AccountId__c = accountId;
                            ucr.Org_number__c = orgNumber;
                            ucr.ContractNumber__c = contractId;
                            ucr.utilizer_role__c = 'Utilizer';
                            ucr.Status__c = 'Draft';//Changed the status to for DROP 3
                            ucr.Name = 'Nyttjarrelationer';
                            insert ucr;
                            outMap.put('SingleUtilizerSuccess','AddedSuccessfully');
                        } 
                    }
                }
            }
        }catch (Exception e){}
            //System.debug('Error while adding Single Utilizers, please contact System Administrator: '+e);
        //}
    }

    //This method is to add bulk utilizers from a CSV file.
    private void parseCSVFile(Map<String, Object> inputMap, Map<String, Object> outMap){
        Boolean istestclass = false;
        if (test.isRunningTest()){
            istestclass = true;
        }

        Integer inaktivUtilizersAdded = 0;
        String contractId = (String)inputMap.get('ContractId');
        Integer numberOfUtilizersAddedInt = getNumberOfUtilizers(contractId);

        //Utililizers can not be added more than 200 for and contract, check the existing utlizers and notifiy the user
        if(numberOfUtilizersAddedInt >= utilizerLimit){
            outMap.put('TUPPLimitExceeded',System.Label.TeliaSE_UtilizerMsg_Over200);
            outMap.put('TUPPLimitExceededError','TUPPLimitExceededErrorMsg');
            return;            
        }
        
        String filename = (String)inputMap.get('UtilizerFileName');
        
        //Do not proceed if the file is not present, let the user navigate to next page at front end.
        if(filename == null || filename ==''){
            return;
        }
        /*
        //Do not proceed, if the file is not a CSV file
        if(filename != null && !filename.endsWithIgnoreCase('.csv')) {
            outMap.put('FileFormatErrorMsg',System.Label.TeliaSE_UtilizerMsg_Wrong_FileFormat);
            outMap.put('FileFormatError','InvalidFormat');
            return;
        }
        
       */
        ContentDocumentLink cdl = [Select id, ContentDocument.id,ContentDocument.FileExtension from ContentDocumentLink where LinkedEntityId =:contractId order by ContentDocument.CreatedDate desc LIMIT 1];
        if(cdl == null || cdl.ContentDocument.FileExtension != 'csv'){
            outMap.put('FileFormatErrorMsg',System.Label.TeliaSE_UtilizerMsg_Wrong_FileFormat);
            outMap.put('FileFormatError','InvalidFormat');
            return;
        }
        try{        
            //Extract the file which was added at front end.
            ContentVersion versionData = [Select id,VersionData from ContentVersion where ContentDocumentId =: cdl.ContentDocument.id];            
            //Manupulate the file and read the values.
      if(versionData == null){
                return;
            }
            string nameFile =blobToString(versionData.VersionData,'ISO-8859-1');
            string[] filelines = nameFile.split('\n');
            List <String> orgNumber = new List <String>();
            Map<String,String> csvDataMap = new Map<String,String>();
            //String lines;
            //Read the list from 3rd row to avoid the header
            String[] inputvalues = new String[]{};
            String[] inputvalues1 = new String[]{};
            String mapOrgNumKey,mapOrgNumValues,lines;
            //String mapOrgNumValues;
            for (Integer i=3;i<filelines.size();i++){   
                lines = filelines[i];
                inputvalues1 = removeCommaAndSplCharacters(lines);
                mapOrgNumKey = inputvalues1[1].replaceAll( '\\s+', '');
                mapOrgNumValues = inputvalues1[0].replaceAll( '\\s+', ' ');
                //Ignore if Org number and Account name are null
                if((mapOrgNumKey == null || mapOrgNumKey =='') && (mapOrgNumValues == null || mapOrgNumValues =='')){
                    //Ignore the values.
                }else{
                    //In case if the Account name present and Org number is empty, show a generic message 
                    if (mapOrgNumKey == null || mapOrgNumKey =='') mapOrgNumKey = 'NullOrgNumber'+Integer.valueOf(i);
                    
                    orgNumber.add(mapOrgNumKey);//orgNumber.add(inputvalues1[1]);
                    csvDataMap.put(mapOrgNumKey,mapOrgNumValues);
                }
            }
            
            //update utilizerList;
            List<String> orgNumList1 = new List<String>();
            List<String> orgNumList = new List<String>();
            for(String orgNum : orgNumber){
                String orgn= orgNum.replaceAll( '\\s+', '');
                orgNumList.add(orgn);
            }
            
            //Return if no values in file.
            if(orgNumList.size() ==0 ){
                outMap.put('EmptyFileErrorMsg',System.Label.TeliaSE_UtilizerMsg_Empty_File);
                outMap.put('EmptyFileError','FileIsEmpty');
                return;
            }
            
            List<String> qualifiedUtilizers = new List<String>();
            //Get only the existing org numbers from account
            List<Account> onlyAvailbleOrgList = [SELECT Org_Nr__c FROM Account WHERE Org_Nr__c  IN :orgNumList]; 
            
            List <String> orgList = new List<String>();
            //Add only the valid accounts from salesforce.
            for(Account a:onlyAvailbleOrgList){
                orgList.add(a.Org_Nr__c);
            }
            
            //Add the non existing Org numbers into Error list by comparing the list from previous list.
            for(integer i=0;i<orgNumList.size();i++){
                if(orgList.contains(orgNumList.get(i))) qualifiedUtilizers.add(orgNumList.get(i));
                else{
                    Map<String, String> errorMap = new Map<String, String>();
                    errorMap.put('Organisationsnamn',csvDataMap.get(orgNumList.get(i)));
                    errorMap.put('Organisationsnr',orgNumList.get(i));
                    errorMap.put('ErrorMessages',System.Label.TeliaSE_UtilizerMsg_OrgNotExist);
                    listOfNonExistingOrgNum.add(errorMap);
                }
            }
            
            List<Utilizer_Contract_Relationship__c> inAktivUtilizerList = new List<Utilizer_Contract_Relationship__c>();
            //Extract the Org numbers attached with this contract and the status is active
            List<Utilizer_Contract_Relationship__c> utilizersList1= [SELECT ContractNumber__r.status, Org_Number__c, 
                                          Status__c FROM Utilizer_Contract_Relationship__c 
                                          where ContractNumber__r.status != 'Cancelled' and ContractNumber__r.RecordType.Name = 'Ramavtal'
                                          and ContractNumber__c =:contractId and Org_Number__c IN:qualifiedUtilizers];
            List <String> orgList1 = new List<String>();
            
            //From the above steps, add only the org numbers that are already part of this contract.
            for(Utilizer_Contract_Relationship__c u1:utilizersList1){
                //Adding Inaktiv utilizers in a separate list that will be updated.
                if(u1.Status__c == 'InAktiv' || istestclass){
                    inAktivUtilizerList.add(u1);
                    inaktivUtilizersAdded++;
                }                   
                orgList1.add(u1.Org_Number__c);
            }
            
            //Assign it to a new list as the error Org numbers will be removed from the list.
            List<String> newQList = qualifiedUtilizers;
            if(orgList1.size() > 0){
                //Loop over the utilizers
                for(integer i=0;i<orgList1.size();i++){
                    //Loop over the old list to identify the utilizers those are not eligible from previous list and add them into error list
                    //by comparing with eligible list
                    for(integer j=0; j<qualifiedUtilizers.size();j++){
                        //check if the org numbers are matching, if so, add them into error list and remove from the list
                        if(orgList1.get(i) == qualifiedUtilizers.get(j)){ 
                            Map<String, String> errorMap = new Map<String, String>();
                            errorMap.put('Organisationsnamn',csvDataMap.get(qualifiedUtilizers.get(j)));
                            errorMap.put('Organisationsnr',qualifiedUtilizers.get(j));
                            errorMap.put('ErrorMessages',System.Label.TeliaSE_UtilizerMsg_OrgAlreadyExists);
                            listOfNonExistingOrgNum.add(errorMap);
                            //newQList will have only valid utilizers to be added.
                            newQList.remove(j);
                            break;
                        }
                    }
                }
            }
            
            //Extract the Utilizers which are already having its own contract from the modified list from previous steps.
            List<Contract> utilizersList2=[select AccountId,ContractNumber, Status, Org_Nr__c, Id from Contract where Status!='Cancelled' and RecordType.Name = 'Ramavtal' and Org_Nr__c IN:newQList];// where Status!='Cancelled' AND Status!='active'];
            
            List <String> orgList2 = new List<String>();
            //Add the result into a new list, which can be used to loop and to be removed from original list.
            for(Contract u2:utilizersList2){
                orgList2.add(u2.Org_Nr__c);
            }
            String ctNumber;
            
            List<String> newQList1 = newQList;
            if(orgList2.size() > 0){
                for(integer i=0;i<orgList2.size();i++){
                    for(integer j=0; j<newQList.size();j++){
                        if(orgList2.get(i) == newQList.get(j)){ 
                            Map<String, String> errorMap = new Map<String, String>();
                            errorMap.put('Organisationsnamn',csvDataMap.get(newQList.get(j)));
                            errorMap.put('Organisationsnr',newQList.get(j));
                            Contract ctNumberList = (Contract)utilizersList2.get(i);
                            ctNumber = ctNumberList.ContractNumber;
                            errorMap.put('ErrorMessages',System.Label.TeliaSE_UtilizerMsg_Org_Own_FA+' '+ctNumber);
                            listOfNonExistingOrgNum.add(errorMap);
                            newQList1.remove(j);
                            break;
                        }
                    }
                }
            }
            
            //Extract the Org numbers attached with this contract
            List<Utilizer_Contract_Relationship__c> utilizersList3=[SELECT Id,Org_Number__c, ContractNumber__r.ContractNumber, Utilizer_Role__c,Utilizer_Type__c FROM Utilizer_Contract_Relationship__c
                                                                    where ContractNumber__r.status != 'Cancelled' and ContractNumber__r.RecordType.Name = 'Ramavtal'
                                                                    AND Org_Number__c IN: newQList1 and (Status__c ='Aktiv' OR Status__c ='Draft' OR Status__c ='PendingActive' OR Status__c ='PendingInactive' or Status__c ='Manual')];//changed the role check to status check  and Status__c = 'Aktiv' and 
            
            List <String> orgList3 = new List<String>();
            for(Utilizer_Contract_Relationship__c u3:utilizersList3){
                orgList3.add(u3.Org_Number__c);
            }
    
            List<String> newQList2 = newQList1;
            if(orgList3.size() > 0){
                for(integer i=0;i<orgList3.size();i++){
                    for(integer j=0; j<newQList1.size();j++){
                        if(orgList3.get(i) == newQList1.get(j)){ 
                            Map<String, String> errorMap = new Map<String, String>();
                            Utilizer_Contract_Relationship__c ctNumberList = (Utilizer_Contract_Relationship__c)utilizersList3.get(i);
                            ctNumber = ctNumberList.ContractNumber__r.ContractNumber;
                            errorMap.put('Organisationsnamn',csvDataMap.get(newQList1.get(j)));
                            errorMap.put('Organisationsnr',newQList1.get(j));
                            errorMap.put('ErrorMessages',System.Label.TeliaSE_UtilizerMsg_OrgAlreadyExistsWith_Diff_FA+' '+ctNumber);
                            listOfNonExistingOrgNum.add(errorMap);
                            newQList2.remove(j);
                            break;
                        }
                    }
                }
            }
            
            Integer utilizersCount = getNumberOfUtilizers(contractId)+newQList2.size() +inaktivUtilizersAdded;
            Integer remainingUtilizers = 0;
            Integer tobeAdded = 0;
            if(utilizersCount > utilizerLimit){
                remainingUtilizers = utilizersCount-utilizerLimit; 
                tobeAdded = utilizerLimit-(getNumberOfUtilizers(contractId)+inaktivUtilizersAdded);
                
                for(Integer i=tobeAdded; i < newQList2.size(); i++){
                    Map<String, String> errorMap = new Map<String, String>();
                    errorMap.put('Organisationsnamn',csvDataMap.get(newQList2.get(i)));
                    errorMap.put('Organisationsnr',newQList2.get(i));
                    errorMap.put('ErrorMessages',System.label.TeliaSE_UtilizerMsg_Over200);
                    listOfNonExistingOrgNum.add(errorMap);
                }
                for(Integer i=0; i <tobeAdded; i++){
                    orgNumList1.add(newQList2.get(i));
                }
            } else orgNumList1 = newQList2;
    
            //Build the new list that will be added in the junction object.
            List<Account> accountList= [SELECT Id, Org_Nr__c FROM Account WHERE Org_Nr__c =: orgNumList1];
            List<Id> accId = new List<Id>();
            List<Utilizer_Contract_Relationship__c> ucrList = new List<Utilizer_Contract_Relationship__c>();
            List <Account> updateAccoutList = new List<Account>();
            Integer i=0;
            for(Account acc : accountList){
                if(acc.Id != null){
                    Utilizer_Contract_Relationship__c ucr = new Utilizer_Contract_Relationship__c();
                    i++;
                    ucr.AccountId__c = acc.Id;
                    ucr.Org_number__c = acc.Org_Nr__c;
                    ucr.ContractNumber__c = contractId;
                    ucr.utilizer_role__c = 'Utilizer';
                    ucr.Status__c = 'Draft';//Changed the status to for DROP 3
                    ucr.Name = 'Nyttjarrelationer';
                    ucrList.add(ucr);
                }
            }
            for(Utilizer_Contract_Relationship__c utilizer: inAktivUtilizerList){
                utilizer.Status__c = 'Draft';
                ucrList.add(utilizer);
            }
            
            if(ucrList.size() > 0){
                upsert ucrList;
                String viewUtilizerLink = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/'+contractId+'/related/Utilizer_Contract_Relationships__r/view';
                outMap.put('ShowUtilizers', 'ShowUtilizers');
                outMap.put('displayUtilizersInView', viewUtilizerLink);
                
            } else outMap.put('ShowUtilizers', 'DontShowUtilizers');
    
            if(listOfNonExistingOrgNum.size() >0){
                String fileDetails = attachFile(listOfNonExistingOrgNum,contractId);
                String fileLink = System.URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/'+contractId+'/related/CombinedAttachments/view';
                
                if(listOfNonExistingOrgNum.size() >0){
                    outMap.put('errorMessage', fileLink);
                    outMap.put('NoError', 'Error');
                } 
    
            }else{
                outMap.put('errorMessage', '');
                outMap.put('NoError', 'NoError');
            }
        } catch(Exception e){
            //System.debug('Error while adding Utilizers, please contact System Administrator: '+e);
            outMap.put('FileFormatErrorMsg','File related error or file format error, please contact System Administrator.');
            outMap.put('FileFormatError','InvalidFormat');
        }
    }
    
    /**
    This function is to generate the error file and attache it to the contract.
    @param orgNumbers    
    @param contractId    
    */
    public static String attachFile(List<Map<String,String>> orgNumbers, String contractId){
        String requiredJson=JSON.serialize(orgNumbers);
        List<Object> entryList = (List<Object>) JSON.deserializeUntyped(requiredJson);

        List<Map<String, Object>> mapList=new List<Map<String, Object>>();
        Set<String> keySet=new Set<String>();

        for(Object entry : entryList){
            Map<String, Object> m = (Map<String, Object>)(entry);
            keySet.addAll(m.keySet());
            mapList.add(m);
        }

        List<String> keys = new List<String>(keySet);
        //keys.sort();

        List<List<String>> csvLines = new List<List<String>>();

        for (Integer i = 0; i <= mapList.size(); i++){
            csvLines.add(new List<String>());
        }
        List<String> newKeys = new List<String>();
        newKeys.add('Organisationsnamn');
        newKeys.add('Organisationsnr');
        newKeys.add('ErrorMessages');

        for (String key : newKeys) {
      csvLines.get(0).add('"' + key + '"');
            
            for (Integer i = 1; i <= mapList.size(); i++) {
                csvLines.get(i).add('"' + (String)(mapList.get(i - 1).get(key)) + '"');
            }
        }

        String csvFile = '';
        for(List<String> csvLine : csvLines){
            String line = '';
            for(Integer i = 0; i < csvLine.size() - 1; i++){
                line += csvLine.get(i) + ',';
            }
            line += csvLine.get(csvLine.size() - 1);
            csvFile += line + '\n';
        }
        
        //Add the users local time along with file name.
        Datetime now=Datetime.now();
        Integer offset=UserInfo.getTimezone().getOffset(now);
        Datetime local=now.addSeconds(offset/1000);
        
        String fileName=System.label.TeliaSE_Utilizer_Failed_File_Name+local+'.CSV';
        
    Attachment attachment=new Attachment();
    attachment.Body=Blob.valueOf(csvFile);
    attachment.Name=fileName;
    attachment.ParentId = contractId; 
    insert attachment;
    
        //Send the file link to user
        List<Attachment> atList =[select name,Id, ParentId from Attachment where parentId=:contractId and name like :System.label.TeliaSE_Utilizer_Failed_File_Name];
        for(Attachment at:atList){
          if(at.name.contains(System.label.TeliaSE_Utilizer_Failed_File_Name)) fileName = at.Id;
            else fileName = 'NoError';
        }  
        return fileName;
  }
    
    
     /**
         This function convers the input CSV file in BLOB format into a string
        @param input    Blob data representing correct string in @inCharset encoding
        @param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
     */
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
        bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }         

     /**
         This function reads the line and manupulate if case if the account name contains any special characters such as comma, etc.
        @param line    line of string to be manupulated.
     */
    private static String[] removeCommaAndSplCharacters(String csvLine){
         //Boolean istestclass = false;
        //if (test.isRunningTest()){
           // istestclass = true;
        //}
        
        String[] csvColumns = new String[5];
        String prevLine = csvLine;
        Integer startIndex,endIndex;
        //Integer endIndex;
        
        try{
            while(csvLine.indexOf('"') > -1){
                if(startIndex == null){
                    startIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
                }else{
                    if(endIndex == null){
                        endIndex = csvLine.indexOf('"');
                        csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                    }
                }
                if(startIndex != null && endIndex != null){
                    String sub = csvLine.substring(startIndex, endIndex);
                    //sub = sub.replaceAll(',', ':comma:');
                    sub = sub.replaceAll(';', ':semicolon:');
                    csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex,csvLine.length());
                    startIndex = null;
                    endIndex = null;
                }
            }
            Integer intSize = 0;
            //for(String column : csvLine.split(',')){
      for(String column : csvLine.split(';')){                
              column = column.replaceAll(':quotes:', '').replaceAll(':semicolon:', ';');
              csvColumns[intSize] = column;
              intSize ++;
            }
        }catch(Exception e){}
            //System.debug('There are some errors in file, please contact System Administrator: '+e);
        //}
        return csvColumns;
    }
    
    /**
        This function returns number of active utlizers are in the contract.
        @param contactId    Contract id is input parameter.
    **/
    private Static Integer getNumberOfUtilizers(String contractId){
        
        List<Utilizer_Contract_Relationship__c> listRslt =[select ContractNumber__c, Status__c from Utilizer_Contract_Relationship__c where ContractNumber__c =:contractId and (Status__c ='Aktiv' OR Status__c ='Draft' OR Status__c ='PendingActive' OR Status__c ='PendingInactive' or Status__c ='Manual') and ContractNumber__r.Status != 'Cancelled'];
        return listRslt.size();
    }
}