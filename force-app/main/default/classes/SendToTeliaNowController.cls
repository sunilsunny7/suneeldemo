public with sharing class SendToTeliaNowController {
    @AuraEnabled(cacheable=false)
    public static void startTeliaNowAPI(Id recordId) {
        SendToTeliaNowAPI.teliaNowAPIConnection(recordId);
    }
}