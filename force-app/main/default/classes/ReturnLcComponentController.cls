/**
 * Created by uly8476 on 2021-09-23.
 */

public with sharing class ReturnLcComponentController {
    @AuraEnabled(Cacheable=true)
    public static Id getLCQueueId(){
        List<Group> groups = [SELECT Id FROM Group WHERE Type = 'Queue' AND Name = 'Leadscentralen' LIMIT 1 ];
        return (groups.size() == 1) ? groups.get(0).Id : null;
    }
}