trigger WarmupCacheConfigurationTrigger on WarmupCacheConfiguration__c (before insert, before update) {

    if(trigger.isBefore && trigger.isInsert){
        parseJsonToken(trigger.New);
    }else if(trigger.isBefore && trigger.isUpdate){
        parseJsonToken(trigger.New);
    }
    
    
    private void parseJsonToken(List<WarmupCacheConfiguration__c> wccList){
        for(WarmupCacheConfiguration__c wcc : wccList){
            if(wcc.JSONPayload__c != null){
                Pattern p = Pattern.compile('%([-|\\w|\\d]+)%');
                Matcher m = p.matcher(wcc.JSONPayload__c);
                
                System.debug(m.groupCount());
                String tokenList = '';
                while (m.find())
                {
                    tokenList += m.group(1)+';';
                }
                System.debug(tokenList);
                wcc.tokenList__c = tokenList;
                SYSTEM.debug(tokenList.length());
            }
        
        }
    }

}