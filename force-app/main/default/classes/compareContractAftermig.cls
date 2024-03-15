public class compareContractAftermig {
    public static void compare(List<String> QuoteIdList){
        Map<String,object> outMap = new Map<String,object>();
        Map<String,String> cliproductMap = new Map<String,String>();
        String BackupContractName = '_Backup1';
        String orginalContract,Backupcontract;
        Map<String,String> backupcontractIdMap = new Map<String,String>();
        Map<String,String> migratdContractIdMap = new Map<String,String>();
        List<String> contractIdList = new List<String>();
        Map<String,String> contractStatusMap = new Map<String,String>();
        List<Contract> contractList= new List<Contract>();
        contractList = [Select id,Name,status,vlocity_cmt__QuoteId__c from Contract where vlocity_cmt__QuoteId__c in: QuoteIdList];
        
        if(contractList.size() > 0){
            for(Contract con:contractList){          
                contractIdList.add(con.Id);
                contractStatusMap.put(con.Id,con.status);
                if(con.Name != null && con.Name.contains(BackupContractName)){
                    Backupcontract = con.Id;
                    backupcontractIdMap.put(con.vlocity_cmt__QuoteId__c,con.Id);
                }
                else if(con.status != 'Cancelled' && con.status != 'Rejected'){
                    orginalContract = con.Id;
                    migratdContractIdMap.put(con.vlocity_cmt__QuoteId__c,con.Id);
                }
            }
        }
        List<vlocity_cmt__ContractLineItem__c> CombinedCLIList = new List<vlocity_cmt__ContractLineItem__c>();
        CombinedCLIList = [Select id,Name,vlocity_cmt__Product2Id__c,vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c,vlocity_cmt__ContractId__c, vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c, TeliaSE_ParentItemId__c,vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__RecurringTotal__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeTotal__c, TeliaSE_MC_Customer_Requested_Percentage__c, TeliaSE_MC_Customer_Requested_Price__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__c in : contractList and ((vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c != null and vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c = 'Mobile Offer Specification') or (vlocity_cmt__Product2Id__r.TeliaSE_Offer_Type__c != null and vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c = 'Broadband Offer Specification') or (vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c != 'Mobile Offer Specification' and vlocity_cmt__Product2Id__r.TeliaSE_Object_Type_Name__c != 'Broadband Offer Specification'))];
        Map<String,vlocity_cmt__ContractLineItem__c> combinedcliMap = new Map<String,vlocity_cmt__ContractLineItem__c>();
        Map<String,String> combinedCLIConMap = new Map<String,String>();
        for(vlocity_cmt__ContractLineItem__c c: CombinedCLIList){
            cliproductMap.put(c.id,c.vlocity_cmt__Product2Id__c);
            combinedcliMap.put(c.id,c);
            combinedCLIConMap.put(c.id,c.vlocity_cmt__ContractId__c);
        }
        Map<String,List<vlocity_cmt__ContractLineItem__c>> separatedConCLIMap = new Map<String,List<vlocity_cmt__ContractLineItem__c>>();
        for(String con:contractIdList){
            List<vlocity_cmt__ContractLineItem__c> separatedCLi= new List<vlocity_cmt__ContractLineItem__c>();
            for(String cli : combinedCLIConMap.keySet() ){
                if(con == combinedCLIConMap.get(cli)){
                    separatedCLi.add(combinedcliMap.get(cli));
                }
            }
            separatedConCLIMap.put(con,separatedCLi);
        }
        for(String qutId : QuoteIdList){
            List<Map<String,object>> outList = new List<Map<String,object>>();
            Map<String,String> newprodNameMap = new Map<String,String>();
            Map<String,String> backupprodNameMap = new Map<String,String>();
            Map<String,object> responseMap = new Map<String,object>(); 
            Map<String,String> backupprodIdMap = new Map<String,String>();
            Map<String,String> newprodIdMap = new Map<String,String>();
            
            Set<String> backupparent = new set<String>();
            Set<String> newparent = new set<String>();
            Set<String> backupparent1 = new set<String>();
            Set<String> newparent1 = new set<String>();
            Set<String> backupConId = new set<String>();
            set<String> backupprodid = new set<String>();
            set<String> newprodid = new set<String>();
            set<String> backupprodid1 = new set<String>();
            set<String> newprodid1 = new set<String>();
            Set<String> newConId = new set<String>();
            
            
            String backupcon = backupcontractIdMap.get(qutId);
            String migcon = migratdContractIdMap.get(qutId);
            System.debug(backupcon+'<-->'+migcon);
            if(migcon == null){
                responseMap.put(qutId,'doesnt have a migrated contract');
            }
            if(backupcon == null){
                responseMap.put(qutId,'doesnt have a backup contract');
            }
            if(migcon != null && backupcon != null){
                List<vlocity_cmt__ContractLineItem__c> migConList = new List<vlocity_cmt__ContractLineItem__c>();
                migConList = separatedConCLIMap.get(migcon);
                if(migConList.size() == 0){
                    responseMap.put(migcon,'migrated contract doesnt have items');
                }
                List<vlocity_cmt__ContractLineItem__c> backupConList = new list<vlocity_cmt__ContractLineItem__c>();
                backupConList = separatedConCLIMap.get(backupcon);
                if(backupConList.size() == 0){
                    responseMap.put(backupcon,'backup contract doesnt have items');
                }
                if(backupConList.size() > 0 && migConList.size() > 0){
                    for(vlocity_cmt__ContractLineItem__c cli : backupConList){
                       // System.debug('cli-->'+cli);
                        backupprodNameMap.put(cliproductMap.get(cli.Id),cli.Name);
                        if(cli.TeliaSE_ParentItemId__c == null){
                            backupparent.add(cli.vlocity_cmt__Product2Id__c);
                            backupparent1.add(cli.vlocity_cmt__Product2Id__c);
                        }
                        else{
                            backupConId.add(cli.id);
                            backupprodIdMap.put(cli.id,cli.vlocity_cmt__Product2Id__c);
                            backupprodid.add(cli.vlocity_cmt__Product2Id__c);
                            backupprodid1.add(cli.vlocity_cmt__Product2Id__c);
                        }
                    }
                    for(vlocity_cmt__ContractLineItem__c cli : migConList){
                        newprodNameMap.put(cli.vlocity_cmt__Product2Id__c,cli.Name);
                        if(cli.TeliaSE_ParentItemId__c == null){
                            newparent.add(cli.vlocity_cmt__Product2Id__c);
                            newparent1.add(cli.vlocity_cmt__Product2Id__c);
                        }
                        else{
                            newConId.add(cli.id);
                            newprodIdMap.put(cli.id,cli.vlocity_cmt__Product2Id__c);
                            newprodid.add(cli.vlocity_cmt__Product2Id__c);
                            newprodid1.add(cli.vlocity_cmt__Product2Id__c);
                        }
                    }
                    
                    if(backupparent.size() != newparent.size()){
                        for(String objId : backupparent){
                            if(newparent.contains(objId)){
                                newparent1.remove(objId);
                            }
                        }
                        if(newparent1.size() > 0){
                            Map<String,String> parentNameMap = new Map<String,String>();
                            for(String s:newparent1){
                                parentNameMap.put(s,newprodNameMap.get(s));
                            }
                            responseMap.put('added Parents',parentNameMap);
                        }
                        for(String objId : newparent){
                            if(backupparent.contains(objId)){
                                backupparent1.remove(objId);
                            }
                        }
                        if(backupparent1.size() > 0){
                            Map<String,String> parentNameMap = new Map<String,String>();
                            for(String s:backupparent1){
                                parentNameMap.put(s,backupprodNameMap.get(s));
                            }
                            responseMap.put('missing in backup Contract',parentNameMap);
                        }
                    }
                    for(String objId : backupprodid){
                        if(newprodid.contains(objId)){
                            newprodid1.remove(objId);
                        }
                    }
                    if(newprodid1.size() > 0){
                        Map<String,String> parentNameMap = new Map<String,String>();
                        for(String s:newprodid1){
                            parentNameMap.put(s,newprodNameMap.get(s));
                        }
                        responseMap.put('added in orginal contract',parentNameMap);
                    }
                    for(String objId : newprodid){
                        if(backupprodid.contains(objId)){
                            backupprodid1.remove(objId);
                        }
                    }
                    if(backupprodid1.size() > 0){
                        Map<String,String> parentNameMap = new Map<String,String>();
                        for(String s:backupprodid1){
                            parentNameMap.put(s,backupprodNameMap.get(s));
                        }
                        responseMap.put('deleted products',parentNameMap);
                    }
                    //Prices comparsion
                   
                    Map<String,String> PriceChangesfound = new Map<String,String>();
                    System.debug('newprodIdMap-->'+json.serialize(newprodIdMap));
                    for(vlocity_cmt__ContractLineItem__c bcli : backupConList){
                        for(vlocity_cmt__ContractLineItem__c mcli : migConList){    
                            System.debug('bb'+backupprodIdMap.get(bcli.id));
                            System.debug('oo'+newprodIdMap.get(mcli.id));
                            if(backupprodIdMap.get(bcli.id) == newprodIdMap.get(mcli.id)){
                                if((bcli.vlocity_cmt__RecurringCharge__c == mcli.vlocity_cmt__RecurringCharge__c) && (bcli.vlocity_cmt__RecurringTotal__c == mcli.vlocity_cmt__RecurringTotal__c) && (bcli.vlocity_cmt__OneTimeCharge__c == mcli.vlocity_cmt__OneTimeCharge__c) && (bcli.vlocity_cmt__OneTimeTotal__c == mcli.vlocity_cmt__OneTimeTotal__c) && (bcli.TeliaSE_MC_Customer_Requested_Percentage__c == mcli.TeliaSE_MC_Customer_Requested_Percentage__c) && (bcli.TeliaSE_MC_Customer_Requested_Price__c == mcli.TeliaSE_MC_Customer_Requested_Price__c)){            
                                    System.debug('prices were good'+bcli.Name);
                                }else{
                                    PriceChangesfound.put(bcli.Name,bcli.id);
                                }
                            }
                        }
                    }
                    if(PriceChangesfound.keyset().size() > 0){
                        responseMap.put('Price Changes found',PriceChangesfound);
                    }
                }
                if(responseMap.keyset().size() > 0){
                    outList.add(responseMap); 
                }           
                if(outList.size() > 0){
                    outMap.put(qutId,outList);
                }
            }
        }
        System.debug('outMap-->'+json.serialize(outMap));
    }
    
    //compare between QLI and CLI
    public static void compareQuotetoContract(Set<String> quoteList){
        Map<String,object> finalMap = new Map<String,Object>();
        Map<String,object> finaldupMap = new Map<String,Object>();
        Map<String,object> finalnoConMap = new Map<String,Object>();
        Map<String,String> contractStatus = new Map<String,String>();
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        List<vlocity_cmt__ContractLineItem__c> cliList = new List<vlocity_cmt__ContractLineItem__c>();
        List<Contract> backupCon = new List<Contract>();
        qliList = [Select id,QuoteId, Quote.Status,Quote.Owner.Name,TeliaSE_MC_Campaign_Id__c, vlocity_cmt__Product2Id__c,vlocity_cmt__Product2Id__r.Name,vlocity_cmt__RecurringCharge__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__OneTimeCharge__c, vlocity_cmt__OneTimeTotal__c, TeliaSE_MC_Customer_Requested_Percentage__c, TeliaSE_MC_Customer_Requested_Price__c,  TeliaSE_Approved_Price__c, 
        //TeliaSE_Base_Quantity__c,
        TeliaSE_CommitmentPeriod__c, TeliaSE_Minimum_Value_Commit__c,TeliaSE_SubsidisedVoice__c from QuoteLineItem where QuoteId in: quoteList and Quote.Status != 'Cancelled'];
        cliList = [Select id,Name,vlocity_cmt__Product2Id__c,TeliaSE_MC_Campaign_Id__c, vlocity_cmt__ContractId__c,vlocity_cmt__ContractId__r.Status, vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c, TeliaSE_QuoteItemId__c, TeliaSE_MasterQuote__c, TeliaSE_Minimum_Value_Commit__c, TeliaSE_CommitmentPeriod__c, TeliaSE_SubsidisedVoice__c, 
        //TeliaSE_Base_Quantity__c,
        vlocity_cmt__RecurringCharge__c, vlocity_cmt__RecurringTotal__c, vlocity_cmt__OneTimeTotal__c, vlocity_cmt__OneTimeCharge__c, TeliaSE_MC_Customer_Requested_Percentage__c, TeliaSE_MC_Customer_Requested_Price__c, TeliaSE_ParentItemId__c from vlocity_cmt__ContractLineItem__c where vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c in: quoteList and TeliaSE_MasterQuote__c = false and vlocity_cmt__ContractId__r.Status !='Cancelled' and vlocity_cmt__ContractId__r.Status != 'Rejected' and vlocity_cmt__ContractId__r.Contract_Record_Type__c = 'Ramavtal'];
        backupCon = [Select id,vlocity_cmt__ParentContractId__c,vlocity_cmt__QuoteId__c from contract where vlocity_cmt__QuoteId__c in: quoteList and name like '%_Backup1%'];
        
        Map<String,QuoteLineItem> combinedQliMap = new Map<String,QuoteLineItem>();
        Map<String,String> combinedQuoteQLIMap = new map<String,String>();
        Map<String,String> combinedQLINameMap = new map<String,String>();
        for(QuoteLineItem qli : qliList){
            combinedQuoteQLIMap.put(qli.id,qli.QuoteId);
            combinedQliMap.put(qli.Id,qli);
            combinedQLINameMap.put(qli.Id, qli.vlocity_cmt__Product2Id__r.Name);
        }    
        system.debug('combinedQLINameMap'+json.serialize(combinedQLINameMap));
        Map<String,vlocity_cmt__ContractLineItem__c> combinedCliMap = new Map<String,vlocity_cmt__ContractLineItem__c>();
        Map<String,String> combinedContractCLIMap = new map<String,String>();
        Map<String,String> cliQliMap = new Map<String,String>();
        Map<String,String> cliQuoteMap = new Map<String,String>();
        Set<String> contractIdSet = new set<String>();
        for(vlocity_cmt__ContractLineItem__c cli : cliList){
            combinedContractCLIMap.put(cli.id,cli.vlocity_cmt__ContractId__c);
            combinedCliMap.put(cli.id,cli);
            contractIdSet.add(cli.vlocity_cmt__ContractId__c);
            cliQliMap.put(cli.id,cli.TeliaSE_QuoteItemId__c);
            cliQuoteMap.put(cli.vlocity_cmt__ContractId__c,cli.vlocity_cmt__ContractId__r.vlocity_cmt__QuoteId__c);
            contractStatus.put(cli.vlocity_cmt__ContractId__c,cli.vlocity_cmt__ContractId__r.Status);
        }
        System.debug('cliQliMap'+cliQliMap);
        set<string> bquote = new set<String>();
        set<String> bcontract = new set<String>();
        for(contract bcon : backupCon){
            bquote.add(bcon.vlocity_cmt__QuoteId__c);
            bcontract.add(bcon.vlocity_cmt__ParentContractId__c);
        }
        
        // remove already migrated quote and contract
        set<String> updatedQuoteIdSet = new set<String>();
        updatedQuoteIdSet = quoteList;
        updatedQuoteIdSet.removeAll(bquote);
        set<String> updatedContractIdSet = new set<String>();
        updatedContractIdSet = contractIdSet;
        updatedContractIdSet.removeAll(bcontract);
        
        //seperate ContractLineItems for Contract
        Map<String,List<vlocity_cmt__ContractLineItem__c>> contractCLIMap = new Map<String,List<vlocity_cmt__ContractLineItem__c>>();
        Map<String,set<String>> clilIdQLIMap = new Map<String, set<String>>();
        Map<String,String> conQuoteMap = new Map<String,String>();
        
        for(String c: updatedContractIdSet){
            List<vlocity_cmt__ContractLineItem__c> cliSeparatedlist = new List<vlocity_cmt__ContractLineItem__c>();
            set<String> cliIdqliList = new set<String>();
            for(String cli : combinedContractCLIMap.keySet()){
                if(c == combinedContractCLIMap.get(cli)){
                    cliSeparatedlist.add(combinedCliMap.get(cli));
                    conQuoteMap.put(c,cliQuoteMap.get(c));
                    cliIdqliList.add(cliQliMap.get(cli));
                }
            }
            contractCLIMap.put(c,cliSeparatedlist);
            clilIdQLIMap.put(c,cliIdqliList);
        }      
        System.debug('clilIdQLIMap'+clilIdQLIMap);
        //search for duplicate contracts on Quote (i.e., two valid contracts other than cancelled or rejected status)
        Set<string> onQuoteDupConFound = new Set<String>();
        Map<String, List<String>> quotecondupMap = new Map<String, List<String>>();
        List<String> noContractOnQuote = new List<String>();
        Map<String,String> quoteToContractIdMap = new Map<String,String>();
        for(String q:updatedQuoteIdSet){
            List<String> quoteconid = new List<String>();
            for(String c : updatedContractIdSet){               
                if(q == conQuoteMap.get(c)){
                    quoteconid.add(c);
                    quoteToContractIdMap.put(q,c);
                }
            }
            //check for duplicate contracts on Quote
            if(quoteconid.size() > 1){
                quotecondupMap.put(q,quoteconid);
                onQuoteDupConFound.add(q);
            }
            // check for quote which doesnt have valid contract
            else if(quoteconid.size() == 0){                
                noContractOnQuote.add(q);
            }
        }
        if(quotecondupMap.keySet().size() > 0 ){
            finaldupMap.put('found quote with duplicate contracts',quotecondupMap);
            finaldupMap.put('Total Size',quotecondupMap.keySet().size());
        }
        if(noContractOnQuote.size() > 0){
            finalnoConMap.put('found quote with no Contracts',noContractOnQuote);
        }
        updatedQuoteIdSet.removeAll(onQuoteDupConFound);
        updatedQuoteIdSet.removeAll(noContractOnQuote);
        //seperate QuoteLineItems for Quotes
        Map<String,List<QuoteLineItem>> quoteQLIMap = new Map<String,List<QuoteLineItem>>();
        Map<String,set<String>> quoteIdQuoteMap = new Map<String, set<String>>();
        
        for(String q: updatedQuoteIdSet){
            List<QuoteLineItem> qliSeparatedlist = new List<QuoteLineItem>();
            List<String> quoteconid = new List<String>();
            set<String> qliIdQuoteList = new set<String>();
            for(String qli : combinedQuoteQLIMap.keySet()){
                if(q == combinedQuoteQLIMap.get(qli)){
                    qliSeparatedlist.add(combinedQliMap.get(qli));
                    qliIdQuoteList.add(qli);
                }
            }
            quoteQLIMap.put(q,qliSeparatedlist);
            quoteIdQuoteMap.put(q,qliIdQuoteList);
        }
        for(String q : updatedQuoteIdSet){
            Map<String,object> finalMap3 = new Map<String,Object>();
            List<QuoteLineItem> loopQLIList = new List<QuoteLineItem>();
            loopQLIList = quoteQLIMap.get(q);
            set<String> loopqliId = new set<String>();
            set<String> loopqliId1 = new set<String>();
            loopqliId = quoteIdQuoteMap.get(q).clone();
            loopqliId1 = quoteIdQuoteMap.get(q).clone();
            String loopConId = quoteToContractIdMap.get(q);
            System.debug('loopConId'+loopConId);
            List<vlocity_cmt__ContractLineItem__c> loopCLI = new List<vlocity_cmt__ContractLineItem__c>();
            loopCLI = contractCLIMap.get(loopConId);
            set<String> loopqliCli = new set<String>();
            set<String> loopqliCli1 = new set<String>();
            loopqliCli = (clilIdQLIMap.get(loopConId)).clone();
            loopqliCli1 = (clilIdQLIMap.get(loopConId)).clone();
            
            System.debug('loopqliCli-->'+loopqliCli.size());   
            loopqliCli1.removeAll(loopqliId);
            
            if(loopqliCli1.size() > 0){
                finalMap3.put('found in CLI not in QLI',loopqliCli1);
            }
            System.debug('loopqliCli-->'+loopqliCli.size());   
            System.debug('loopqliId1-->'+loopqliId1.size()); 
            
            loopqliId1.removeAll(loopqliCli);
            
            System.debug('loopqliId'+loopqliId.size()+' '+json.serialize(loopqliId));
            System.debug('loopqliId1'+'--'+loopqliId1.size()+' '+json.serialize(loopqliId1));
            
            if(loopqliId1.size() > 0){
                System.debug('loopqliId1-->'+loopqliId1.size());
                Map<String,String> qliMap1 = new Map<String,String>();
                for(String s : loopqliId1){
                    qliMap1.put(s,combinedQLINameMap.get(s));
                }
                finalMap3.put('found in QLI not in CLI',qliMap1);
            }
            Map<String,List<string>> foundChangeParentMap = new Map<String,List<String>>();
            Map<String,List<string>> foundChangeChildMap = new Map<String,List<String>>();
            for(vlocity_cmt__ContractLineItem__c initcli : loopCLI){
                if(initcli.TeliaSE_ParentItemId__c == null){
                    QuoteLineItem initqli = new QuoteLineItem();
                    initqli = combinedQliMap.get(initcli.TeliaSE_QuoteItemId__c);
                    
                    List<String> changefoundonParent = new List<String>();
                    if(initqli == null){
                        changefoundonParent.add('qli not found');
                    }else{
                    if(initcli.TeliaSE_Minimum_Value_Commit__c != initqli.TeliaSE_Minimum_Value_Commit__c){
                        changefoundonParent.add('TeliaSE_Minimum_Value_Commit__c');
                    }
                    if(initcli.TeliaSE_CommitmentPeriod__c != initqli.TeliaSE_CommitmentPeriod__c){
                        changefoundonParent.add('TeliaSE_CommitmentPeriod__c');
                    }
                    if(initcli.TeliaSE_SubsidisedVoice__c != initqli.TeliaSE_SubsidisedVoice__c){
                        changefoundonParent.add('TeliaSE_SubsidisedVoice__c');
                    }
                   // if(initcli.TeliaSE_Base_Quantity__c != initqli.TeliaSE_Base_Quantity__c){
                       // changefoundonParent.add('TeliaSE_Base_Quantity__c');
                   // }
                    if(initcli.vlocity_cmt__RecurringCharge__c != initqli.vlocity_cmt__RecurringCharge__c){
                        changefoundonParent.add('vlocity_cmt__RecurringCharge__c');
                    }
                    if(initcli.vlocity_cmt__RecurringTotal__c != initqli.vlocity_cmt__RecurringTotal__c){
                        changefoundonParent.add('vlocity_cmt__RecurringTotal__c');
                    }
                    if(initcli.vlocity_cmt__OneTimeCharge__c != initqli.vlocity_cmt__OneTimeCharge__c){
                        changefoundonParent.add('vlocity_cmt__OneTimeCharge__c');
                    }
                     if(initcli.vlocity_cmt__OneTimeTotal__c != initqli.vlocity_cmt__OneTimeTotal__c){
                        changefoundonParent.add('vlocity_cmt__OneTimeTotal__c');
                    }
                    if(initcli.TeliaSE_MC_Customer_Requested_Price__c != initqli.TeliaSE_MC_Customer_Requested_Price__c){
                        changefoundonParent.add('TeliaSE_MC_Customer_Requested_Price__c');
                    }
                    if(initcli.TeliaSE_MC_Customer_Requested_Percentage__c != initqli.TeliaSE_MC_Customer_Requested_Percentage__c){
                        changefoundonParent.add('TeliaSE_MC_Customer_Requested_Percentage__c');
                    }
                    if(changefoundonParent.size() > 0){
                        String cliIdName = initcli.Name+' '+initcli.Id;
                        foundChangeParentMap.put(cliIdName,changefoundonParent);
                    }
                    }
                }
                else{
                    QuoteLineItem initqli = new QuoteLineItem();
                    initqli = combinedQliMap.get(initcli.TeliaSE_QuoteItemId__c);
                    List<String> changefoundonChild = new List<String>();
                    if(initqli == null){
                        changefoundonChild.add('qli not found');
                    }else{
                    
                    if(initcli.vlocity_cmt__RecurringCharge__c != initqli.vlocity_cmt__RecurringCharge__c){
                        changefoundonChild.add('vlocity_cmt__RecurringCharge__c');
                    }
                    if(initcli.vlocity_cmt__RecurringTotal__c != initqli.vlocity_cmt__RecurringTotal__c){
                        changefoundonChild.add('vlocity_cmt__RecurringTotal__c');
                    }
                    if(initcli.vlocity_cmt__OneTimeCharge__c != initqli.vlocity_cmt__OneTimeCharge__c){
                        changefoundonChild.add('vlocity_cmt__OneTimeCharge__c');
                    }
                    if(initcli.vlocity_cmt__OneTimeTotal__c != initqli.vlocity_cmt__OneTimeTotal__c){
                        changefoundonChild.add('vlocity_cmt__OneTimeTotal__c');
                    }
                    if(initcli.TeliaSE_MC_Customer_Requested_Price__c != initqli.TeliaSE_MC_Customer_Requested_Price__c){
                        changefoundonChild.add('TeliaSE_MC_Customer_Requested_Price__c');
                    }
                    if(initcli.TeliaSE_MC_Customer_Requested_Percentage__c != initqli.TeliaSE_MC_Customer_Requested_Percentage__c){
                        changefoundonChild.add('TeliaSE_MC_Customer_Requested_Percentage__c');
                    }
                    if(initcli.TeliaSE_MC_Campaign_Id__c != initqli.TeliaSE_MC_Campaign_Id__c){
                        changefoundonChild.add('TeliaSE_MC_Campaign_Id__c');
                    }   
                    if(changefoundonChild.size() > 0){
                        String cliIdName = initcli.Name+' '+initcli.Id;
                        foundChangeChildMap.put(cliIdName,changefoundonChild);
                    }

                }
                if(foundChangeParentMap.keyset().size() > 0){
                    finalMap3.put('found Changes in parent',foundChangeParentMap);
                }
                if(foundChangeChildMap.keyset().size() > 0){
                    finalMap3.put('found Changes in child',foundChangeChildMap);
                }
            }
            if(finalMap3.keyset().size() > 0){
                finalMap3.put('Contract Status',contractStatus.get(loopConId));
                finalMap3.put('ContractId',loopConId);
                finalMap.put(q,finalMap3);
            }
            //finalMap.put(q,finalMap3);
        }
        }
        finalMap.put('total count',finalMap.Size());
        
        System.debug('finalMap-->'+json.serialize(finalMap));
        System.debug('finaldupMap-->'+json.serialize(finaldupMap));
        System.debug('finalnoConMap-->'+json.serialize(finalnoConMap));
        System.debug('quote with no contract-->'+noContractOnQuote.size());
    }
}