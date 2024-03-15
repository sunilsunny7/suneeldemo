global class RequestClassWrapper {
    @AuraEnabled
    public String collectionMethod{get;set;}
    @AuraEnabled
    public String requested{get;set;}
    @AuraEnabled
    public String language{get;set;}
    @AuraEnabled
    public String customerRepresentative{get;set;}
    @AuraEnabled
    public String storeId{get;set;}
    @AuraEnabled
    public String campaignId{get;set;}
    @AuraEnabled
    public String customerIdentificationNumber{get;set;}
    @AuraEnabled
    public String customerProxy{get;set;}
    @AuraEnabled
    public List<purposes> purposes{get;set;}
    
    global class purposes{
        @AuraEnabled
        public String purpose{get;set;}
        @AuraEnabled
        public String status{get;set;}
        @AuraEnabled
        public String version{get;set;}
    }
}