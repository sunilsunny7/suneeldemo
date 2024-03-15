global class ApexDataContainer {
    @AuraEnabled
    global List<Purposes>purposes{get;set;}
    global class Purposes{
        @AuraEnabled
        public String fromSourceSystem{get;set;}
        @AuraEnabled
        public string purpose {get;set;}
        @AuraEnabled
        public string legalGround {get;set;}
        @AuraEnabled
        public string requested {get;set;}
        @AuraEnabled
        public string collectionMethod {get;set;}
        @AuraEnabled
        public string customerRepresentative {get;set;}
        @AuraEnabled
        public string storeId {get;set;}
        @AuraEnabled
        public string campaignId {get;set;}
        @AuraEnabled
        public List<Description> description {get;set;}
        @AuraEnabled
        public string version {get;set;}
        @AuraEnabled
        public string customerProxy {get;set;}
        @AuraEnabled
        public List<category> category {get;set;}
        @AuraEnabled
        public string status {
            get{
                system.debug('Get Entry : '+fromSourceSystem);
                if(collectionMethod == 'implicit' && fromSourceSystem ==null){
                    fromSourceSystem = 'C2B';
                    system.debug('Received Implicit');
                    return 'Approved_Implicit';
                }
                else{
                    return status;
                }
            } set;
        }
    }
    
    global class Description {
        @AuraEnabled
        public string language {get;set;}
        @AuraEnabled
        public string text {get;set;}
    }
    
    global class category {
        @AuraEnabled
        public string example {get;set;}
    }
    
}