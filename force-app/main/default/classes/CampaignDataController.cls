public class CampaignDataController {
    
    public class KeyValue{
        @AuraEnabled
        public String Key { get; set; }   
        @AuraEnabled
        public String Value { get; set; }
    }
    
    
    //Fetches the campaign specific data from CallActivity
    @AuraEnabled
    public static List<KeyValue> getCampaignData(String callActivityId){
        
        Call_Activity__c ca = [SELECT Campaign_Data__c FROM Call_Activity__c WHERE Id = :callActivityId LIMIT 1];
        List<KeyValue> keyValues = new List<KeyValue>();
        
        if(ca != null){
            String[] rows = ca.Campaign_Data__c.split('\\;');
            
            for(String row :rows){
                String[] col = row.split('\\:');
                if(col.size() == 2){
                           KeyValue kv = new KeyValue();
                kv.Key = col[0];
                kv.Value = col[1];
                keyValues.add(kv);
                }
         
            }
            
        }
        
        return keyValues;
    }
}