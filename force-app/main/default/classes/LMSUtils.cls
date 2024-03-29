/*
Copyright (c) 2014, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors
    may be used to endorse or promote products derived from this software
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
public with sharing class LMSUtils{

    private static User userDetails;
    private static SObject networkDetails;

    public static void addSuccessMessage(String message){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,message));
    }

    public static void addErrorMessage(String message){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,message));
    }

    public static void addGenericUnknownErrorMessage(String message){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,System.Label.ALMS_Generic_Error_Message+' : '+message));
    }

    public static void logException(Exception e,String context){
        System.debug('*** C : '+context);
        System.debug(logginglevel.INFO, '*** M : '+e.getMessage());
        System.debug(logginglevel.INFO, '*** L : '+e.getLineNumber());
        System.debug(logginglevel.INFO, '*** ST : '+e.getStackTraceString());
    }

    public static String getMinutesToHours(Integer mins){
        String result = '';
        if(mins != null){
            if(mins > 59){
                result = ((Integer)(Math.floor(mins/60)))+' '+System.Label.ALMS_Hours_Abbreviation+' '+Math.round((dblMOD((mins/60.0).doubleValue(),(1.0).doubleValue())*60.0))+' '+System.Label.ALMS_Minutes_Abbreviation;
            }else{
                result = mins+' '+System.Label.ALMS_Minutes_Abbreviation;
            }
        }

        return result;
    }

    private static Double dblMOD(Double num1, Double num2){
        Double c = 0;
        Double result;
        result = num1 / num2;
        c = Math.floor(result);
        result = num1 - (num2 * c);
        return result;
    }

    //refactor to accept sobject and put on utility class
    public static Set<Id> objectListToIdSet(List<SObject> sobjects){
        Set<Id> results = new Set<Id>();
        for(SObject so : sobjects){
            if(so.Id != null)
                results.add(so.Id);
        }
        return results;
    }

    public static Boolean isAdminUser(){

        Id currentUserId = UserInfo.getUserId();

        //No need to enforce CRUD/FLS here as this is a utility method that just returns true if the user has the admin perm set
        List<PermissionSetAssignment> userPerms = [select Id
                                                        ,AssigneeId
                                                        ,PermissionSetId
                                                        from PermissionSetAssignment
                                                        where PermissionSet.Name = 'LMS_Admin'
                                                        and AssigneeId = :currentUserId];
        if(userPerms.size()>0){
            return true;
        }else{
            return false;
        }

    }

    public static Boolean isValidLMSUser(Id userId){
        //No need to enforce CRUD/FLS here as this is a utility method that just returns true if the user has the admin perm set

        List<User> activeUsers = [select Id from User where IsActive = true and Id = :userId];

        if(activeUsers.size() == 0){
          return false;
        }

        List<PermissionSetAssignment> userPerms = [select Id
                                                        from PermissionSetAssignment
                                                        where PermissionSet.Name IN ('LMS_Admin','LMS_User','LMS_External_User')
                                                        and AssigneeId = :userId];
        if(userPerms.size()>0){
            return true;
        }else{
            return false;
        }
    }

    public static Boolean isMobileDevice(){
        if(ApexPages.currentPage() != null && ApexPages.currentPage().getHeaders() != null){
            Map<String, String> headers = ApexPages.currentPage().getHeaders();
            String userAgent = headers.get('User-Agent')!=null?headers.get('User-Agent'):'';
            String device = headers.get('device')!=null?headers.get('device'):'';
            Boolean isIPhone = (userAgent.contains('iPhone') || device == 'mobile');
            Boolean isIPad = (userAgent.contains('iPad'));
            Boolean isAndroid = (userAgent.contains('Android'));
            return isIPhone || isIPad || isAndroid;
        }else{
            return false;
        }
    }

    public static Set<Id> getLMSPermSets(){
        Set<Id> result = new Set<Id>();
        for(PermissionSet ps : [select id from PermissionSet where name in ('LMS_Admin','LMS_User')]){
            result.add(ps.Id);
        }
        return result;
    }

    public static String getPackageNamespace(){
        return SObjectType.Learning__c.Name.substringBefore('Learning__c');
    }

    public static String getNamespacePrefix(){
        return getPackageNamespace().replaceAll('__','');
    }

    public static Id getUserAccountId(){
        User u = getUserDetails();
        return u.AccountId;
    }

    public static Boolean isPortalUser(){
        User u = getUserDetails();
        return u.AccountId != null;
    }

    public static User getUserDetails(){
        if(userDetails == null || Test.isRunningTest() ){
            userDetails = [select Id
                                ,ContactId
                                ,AccountId
                                from User
                                where id = :UserInfo.getUserId()];
        }
        return userDetails;
    }

    public static SObject getNetworkDetails(){
        Id networkId = getCurrentNetworkId();
        if(networkId == null){
            return null;
        }else{
            if(networkDetails == null){
                List<SObject> results = Database.query('select Id,UrlPathPrefix from Network where Id = :networkId');
                networkDetails = results.get(0);
            }
        }
        return networkDetails;
    }

    public static Boolean hasCommunities(){
        try{
            Integer networkCount = Database.countQuery('select count() from Network');
            if(networkCount > 0){
                return true;
            }
        }catch(Exception e){}
        return false;
    }

    public static Id getCurrentNetworkId(){
        return Network.getNetworkId();
    }

    public static String getCurrentNetworkURLPath(){
        if(getCurrentNetworkId() == null){
            return null;
        }
        SObject n = getNetworkDetails();
        String urlPathPrefix = n.get('UrlPathPrefix')!=null?(String)n.get('UrlPathPrefix'):'';
        return urlPathPrefix;
    }

    public static String updateURLCommunityPath(String urlPath){
        if(getCurrentNetworkId() != null){
            String networkURLPath = getCurrentNetworkURLPath();
            if(!String.isBlank(networkURLPath)){
                urlPath = '/'+getCurrentNetworkURLPath()+urlPath;
            }
        }
        return urlPath;
    }

    public static String updateURLCommunityPath(String urlPath, String communityName){
        if(!String.isBlank(communityName)){
            urlPath = '/'+communityName+urlPath;
        }
        return urlPath;
    }

    public static String getTrainingPlanDetailRetURL(Map<String, String> params){
        if(String.isBlank(params.get('tpid'))){
            return null;
        }
        PageReference tempRef = Page.TrainingPlanDetail;
        tempRef.getParameters().put('id',params.get('tpid'));
        tempRef.getParameters().put('sectionId',params.get('tpsid'));
        tempRef.getParameters().put('itemId',params.get('tpitid'));
        return tempRef.getUrl();
    }

    public static String getCurrentInstance(){
        URL baseUrl = URL.getSalesforceBaseUrl();
        if(baseUrl == null){
            return null;
        }
        String host = baseUrl.getHost();
        String vfDomain = '.visual.force.com';
        Boolean isVFContext = host.contains(vfDomain)?true:false;
        String contextIndexOf = isVFContext==true?vfDomain:'.';
        String instance = host.substring(0,host.indexOf(contextIndexOf));
        if(isVFContext){
            String vfNameSpace = getVisualforceNamespace();
            instance = instance.replace(vfNameSpace+'.','');
        }
        return instance;
    }

    public static String getVisualforceNamespace(){
        String nsPrefix = getNamespacePrefix();
        if(String.isBlank(nsPrefix)){
            nsPrefix = 'c';
        }
        return nsPrefix;
    }

}