/**
 * Description:
 * Aura component Apex Controller of
 *  - c:LatestVunnenOpportunities
 *  - c:CygateLatestVunnen
 *  - c:CygateLatestVunnenOpportunities
 *  - c:CygateTopTenPipelineOpportunity
 *  - c:FiberLatestVunnen
 *  - c:SMESOHOLatestVunnenOpportunities
 *  - c:SMETop10latestOpty
 * 
 * LatestVunnenOpportunities component implements a list of the Top 10 most valuable recently closed Opportunities, 
 * displayed on the Home page.
 * Component:
 *  - displays the list
 *  - allows Users to like an Opportunity
 *  - allows Users to examine the list of Users that have like an Opportunity
 * 
 * Modifications:
 * 26.06.2023 [Tomass Brazovskis] LTAT-10218 - Refactored methods retrieving Cygate records to use Dynamic SOQL and 
 *            take User-selected filtering criteria values as arguments.
 * 24.03.2023 [Tomass Brazovskis] SALEF-8266 - Adjusted retrieval criteria in getListOfLatestClosedOpportunityFiber().
 * 02.02.2023 [Aivaras Nausutis] SALEF-7995 - 'Like'-button functionality introduced for Fiber report.
 * 02.12.2022 [Tomass Brazovskis] SALEF-7566 - getlistoftopclosedopportunitycygate() modified to retrieve and process
 *              "Like" related information.
 * 28.05.2021 [Yogini Kothekar] SALEF-4710 - getlistoftop10latestclosedSMESOHOopportunity() introduced.
 * 14.04.2021 [Yogini Kothekar] SALEF-4510 - getlistoflatestclosedSMESOHOopportunityNew() modified to return the Top 10 
 *              Opportunities with the highest 'Sales Value', Won in the current week.
 * 25.03.2021 [Pramod Shinde] SALEF-4308 - 'Like'-button functionality introduced.
 * 11.03.2021 [Deividas Kandrotas] SALEF-3833 - New method introduced (for the new Fiber start page).
 * 10.10.2019 [Yogini Kothekar] SALEF-2380 - getlistoflatestclosedSMESOHOopportunityNew() introduced to display The 10 most 
 *              recently Won Opportunities for BA1 and BA2 in LatestVunnenOpportunities Aura component.
 * 17.05.2018 [Shruti Singh] SALEF-1114 - Introduced.
 **/
public without sharing class LatestClosedOpportunities {

    private static Id contextUserProfileId = UserInfo.getProfileId();
    private static List<User> lstContextUser;

    @AuraEnabled
    public static List <Opportunity> getlistoflatestclosedopportunity() {
    //used for Large group and set like status on load
        List <Opportunity> OppList = [select Id, Name, Number_of_Likes__c, Like_Status__c, Like_Details__c, OwnerId, Owner.SmallPhotoUrl, Owner.Name, Account.Owner.Name, Account.Name, Large_New_Sales__c, Large_Continuation_Sales__c, CloseDate, Vunnen_Time_Stamp__c from Opportunity where(Owner.Profile.Name = 'Telia Sales - Large'
            OR Owner.Profile.Name = 'Telia Sales - Service'
            OR Owner.Profile.Name = 'Telia Sales - Solution') and Vunnen_Time_Stamp__c != null Order By Vunnen_Time_Stamp__c Desc Limit 10];
        if (OppList.Size() > 0) {
            for (Opportunity Opp: OppList) {
                if (Opp.Like_Details__c == null && (Opp.Number_of_Likes__c == 0 || Opp.Number_of_Likes__c == null)) {
                    Opp.Like_Status__c = false;
                } else if (String.valueof(Opp.Like_Details__c).contains(UserInfo.getUserId()) && Opp.Number_of_Likes__c > 0) {
                    Opp.Like_Status__c = true;
                } else {
                    Opp.Like_Status__c = false;
                }

            }
        }
        return OppList;
    }
    @AuraEnabled
    public static String numberofLikesonOpty(Id OppId) {
    //Updates Like details and returns number of likes
        String retmsg;
        List <Opportunity> Opp = [Select id, Number_of_Likes__c, Like_Details__c, Like_Status__c from Opportunity where id =: OppId limit 1];
        if (opp[0].Number_of_Likes__c == null || opp[0].Number_of_Likes__c == 0) {
            opp[0].Number_of_Likes__c = 1;
            opp[0].Like_Details__c = UserInfo.getUserId();
        } else if (opp[0].Number_of_Likes__c != null && !opp[0].Like_Details__c.contains(UserInfo.getUserId())) {
            opp[0].Number_of_Likes__c = opp[0].Number_of_Likes__c + 1;
            opp[0].Like_Details__c = opp[0].Like_Details__c + ',' + String.valueof(UserInfo.getUserId());
        } else if (opp[0].Number_of_Likes__c != null && opp[0].Like_Details__c.contains(UserInfo.getUserId())) {
            opp[0].Like_Details__c = opp[0].Like_Details__c.remove(UserInfo.getUserId());
            opp[0].Number_of_Likes__c = opp[0].Number_of_Likes__c - 1;
        }
      try{
        retmsg = String.valueof(opp[0].Number_of_Likes__c);
        update opp[0];
        
        }catch(Exception e){
           retmsg = e.getMessage();
        }
        
        return retmsg;
    }
    @AuraEnabled
    public static List<User> getLikedOppUser(Id OppId) {
        //Retuns list of users who has liked an Opps
        Opportunity Opp = [select id, Like_Details__c from Opportunity where id =: OppId limit 1];
        String likeusers = Opp.Like_Details__c;
        List<Id> UserIds = new List <Id>();
        Set<Id> userIdSet = new Set <Id>();
        if (likeusers != Null && likeusers.length() > 0) {
            UserIds = likeusers.split(',');
        }
        return [select id, name, SmallPhotoUrl, profile.name, userrole.name from user where id in: UserIds];


    }

    /**
     * Description:
     * Retrieve the Top 10 (or fewer) most valuable recently won Cygate-type Opportunities.
     * @param doFilterByRegion - Filter Opportunities by ctxt User Cygate_User_Team
     * @return List of Cygate Opportunities to display in a Lightning Component.
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Refactored to use Dynamic SOQL and take User-selected
     *            filtering criteria values as arguments.
     * 02.12.2022 [TB] SALEF-7566 - Modified. Retrieve and process "Like"-related information.
     **/
    @AuraEnabled
    public static List <Opportunity> getlistoftopclosedopportunitycygate(Boolean doFilterByRegion) {
        List<Opportunity> oppList;
        Map<String, Object> mapOpportunityBinds = new Map<String, Object>();
        String LOGICAL_OPERATOR_SPACED_AND = ' AND ';
        String BIND_VARIABLE_NAME_CONTEXT_USER_REGION = 'curUserRegion';
        try{
            // Set up a Dynamic SOQL query string
            List<String> lstOpportunityRecTypeDevNames = new List<String>{
                SEUtility.OPP_RECTYPE_CYGATE_WEBORDER,
                SEUtility.OPP_RECTYPE_CYGATE_AFFAR,
                SEUtility.OPP_RECTYPE_CYGATE_AFTERREG,
                SEUtility.OPP_RECTYPE_CYGATE_STANDARD,
                SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT
            };
            List<String> lstOpportunityStageNames = new List<String>{
                SEConstants.OPPORTUNITY_STAGE_VUNNEN
            };
            Integer numOfRecords = 10;

            mapOpportunityBinds.put('lstOppRecordTypeDevNames', lstOpportunityRecTypeDevNames);
            mapOpportunityBinds.put('lstOpportunityStageNames', lstOpportunityStageNames);
            mapOpportunityBinds.put('numOfRecords', numOfRecords);

            // LTAT-10218 - Establish Opportunity Cygate_Sales_Team value to filter by
            if(doFilterByRegion){
                if(!setContextUserBindVariable_Region(  mapOpportunityBinds, 
                                                        BIND_VARIABLE_NAME_CONTEXT_USER_REGION)
                ){
                    return new List<Opportunity>();
                }
            }

            String queryOppsString = 'SELECT Id';
            String spaceOrSpacedLogicalOperator = ' ';
            List<String> lstFieldApiNamesToQuery = new List<String>{
                'Name',
                'Account.Name',
                'Owner.Name',
                'Owner.SmallPhotoUrl',
                'CloseDate',
                'Probability',
                'StageName',
                'Total_Amount_Cygate__c',
                'Total_Amount_Produkt__c',
                'Total_Amount_Tj_nst__c',
                'Cygate_Sales_Team__c',
                'Number_of_Likes__c',
                'Like_Status__c',
                'Like_Details__c'
            };
            for(String curOppFieldName : lstFieldApiNamesToQuery){
                queryOppsString += (', ' + curOppFieldName);
            }
            // Query sObject
            queryOppsString += ' FROM Opportunity';
            // Query Criteria
            queryOppsString += ' WHERE';
            queryOppsString += ' CloseDate = THIS_MONTH';
            queryOppsString += ' AND StageName IN :lstOpportunityStageNames';
            queryOppsString += ' AND Recordtype.DeveloperName IN :lstOppRecordTypeDevNames';
            // LTAT-10218 - Optional User-selected filter criterion
            if(doFilterByRegion){
                queryOppsString += (' AND Cygate_Sales_Team__c = :' + BIND_VARIABLE_NAME_CONTEXT_USER_REGION);
            }
            // Record Order
            queryOppsString += ' ORDER BY Total_Amount_Cygate__c DESC';
            // Max # of records to return
            queryOppsString += ' LIMIT :numOfRecords';
            // Execute query
            oppList = Database.queryWithBinds(queryOppsString, mapOpportunityBinds, AccessLevel.SYSTEM_MODE);
            // 'Like' functionality related processing
            if (oppList.Size() > 0) {
                helperSetOpportunityLikeStatus(oppList);
            }
        } catch(Exception curException){
            throw new LatestClosedOppsException(System.Label.LATEST_CLOSED_OPPORTUNITIES_ERROR_MSG);
        }
        return OppList;
    }

    /**
     * Description:
     * Retrieve the Top 10 (or fewer) most valuable open Cygate-type Opportunities.
     * @param doFilterByRegion - Filter Opportunities by ctxt User Cygate_User_Team
     * @return List of Cygate Opportunities to display in a Lightning Component.
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Refactored to use Dynamic SOQL and take User-selected
     *            filtering criteria values as arguments.
     **/
    @AuraEnabled
    public static List <Opportunity> getlistofpipelinedopportunitycygate(Boolean doFilterByRegion){
        List<Opportunity> oppList;
        Map<String, Object> mapOpportunityBinds = new Map<String, Object>();
        String LOGICAL_OPERATOR_SPACED_AND = ' AND ';
        String BIND_VARIABLE_NAME_CONTEXT_USER_REGION = 'curUserRegion';
        try{
            // Set up a Dynamic SOQL query string
            List<String> lstOpportunityRecTypeDevNames = new List<String>{
                SEUtility.OPP_RECTYPE_CYGATE_WEBORDER,
                SEUtility.OPP_RECTYPE_CYGATE_AFFAR,
                SEUtility.OPP_RECTYPE_CYGATE_AFTERREG,
                SEUtility.OPP_RECTYPE_CYGATE_STANDARD,
                SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT
            };
            List<String> lstOpportunityStageNamesToExclude = new List<String>{
                SEConstants.OPPORTUNITY_STAGE_VUNNEN,
                SEConstants.OPPORTUNITY_STAGE_FORLORAD,
                SEConstants.OPPORTUNITY_STAGE_AVBRUTEN,
                SEConstants.OPPORTUNITY_STAGE_AVFARDAT_PROSPECT,
                SEConstants.OPPORTUNITY_STAGE_CLOSED_MF,
                SEConstants.OPPORTUNITY_STAGE_CLOSED_STANGD
            };
            Integer numOfRecords = 10;

            mapOpportunityBinds.put('lstOppRecordTypeDevNames', lstOpportunityRecTypeDevNames);
            mapOpportunityBinds.put('lstOpportunityStageNamesToExclude', lstOpportunityStageNamesToExclude);
            mapOpportunityBinds.put('numOfRecords', numOfRecords);

            // LTAT-10218 - Establish Opportunity Cygate_Sales_Team value to filter by
            if(doFilterByRegion){
                if(!setContextUserBindVariable_Region(  mapOpportunityBinds, 
                                                        BIND_VARIABLE_NAME_CONTEXT_USER_REGION)
                ){
                    return new List<Opportunity>();
                }
            }

            String queryOppsString = 'SELECT Id';
            String spaceOrSpacedLogicalOperator = ' ';
            List<String> lstFieldApiNamesToQuery = new List<String>{
                'Name',
                'Account.Name',
                'Owner.Name',
                'Owner.SmallPhotoUrl',
                'CloseDate',
                'Probability',
                'StageName',
                'Total_Amount_Cygate__c',
                'Total_Amount_Produkt__c',
                'Total_Amount_Tj_nst__c',
                'Cygate_Sales_Team__c'
            };
            for(String curOppFieldName : lstFieldApiNamesToQuery){
                queryOppsString += (', ' + curOppFieldName);
            }
            // Query sObject
            queryOppsString += ' FROM Opportunity';
            // Query Criteria
            queryOppsString += ' WHERE';
            queryOppsString += ' (CloseDate = THIS_MONTH OR CloseDate = THIS_YEAR)';
            queryOppsString += ' AND StageName NOT IN :lstOpportunityStageNamesToExclude';
            queryOppsString += ' AND Recordtype.DeveloperName IN :lstOppRecordTypeDevNames';
            // LTAT-10218 - Optional User-selected filter criterion
            if(doFilterByRegion){
                queryOppsString += (' AND Cygate_Sales_Team__c = :' + BIND_VARIABLE_NAME_CONTEXT_USER_REGION);
            }
            // Record Order
            queryOppsString += ' ORDER BY Total_Amount_Cygate__c DESC';
            // Max # of records to return
            queryOppsString += ' LIMIT :numOfRecords';
            // Execute query
            oppList = Database.queryWithBinds(queryOppsString, mapOpportunityBinds, AccessLevel.SYSTEM_MODE);
        } catch(Exception curException){
            throw new LatestClosedOppsException(System.Label.LATEST_CLOSED_OPPORTUNITIES_ERROR_MSG);
        }
        return OppList;
    }

    /**
     * Description:
     * Retrieve the Top 10 (or fewer) most recently won Cygate-type Opportunities.
     * @param doFilterByRegion - Filter Opportunities by ctxt User Cygate_User_Team
     * @return List of Cygate Opportunities to display in a Lightning Component.
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Refactored to use Dynamic SOQL and take User-selected
     *            filtering criteria values as arguments.
     **/
    @AuraEnabled
    public static List<Opportunity> getlistoflatestclosedopportunitycygate(Boolean doFilterByRegion) {
        List<Opportunity> oppList;
        Map<String, Object> mapOpportunityBinds = new Map<String, Object>();
        String LOGICAL_OPERATOR_SPACED_AND = ' AND ';
        String BIND_VARIABLE_NAME_CONTEXT_USER_REGION = 'curUserRegion';
        try{
            // Set up a Dynamic SOQL query string
            List<String> lstOpportunityRecTypeDevNames = new List<String>{
                SEUtility.OPP_RECTYPE_CYGATE_WEBORDER,
                SEUtility.OPP_RECTYPE_CYGATE_AFFAR,
                SEUtility.OPP_RECTYPE_CYGATE_AFTERREG,
                SEUtility.OPP_RECTYPE_CYGATE_STANDARD,
                SEUtility.OPP_RECTYPE_CYGATE_ENLARGEMENT
            };
            List<String> lstOpportunityStageNames = new List<String>{
                SEConstants.OPPORTUNITY_STAGE_VUNNEN
            };
            Integer numOfRecords = 10;

            mapOpportunityBinds.put('lstOppRecordTypeDevNames', lstOpportunityRecTypeDevNames);
            mapOpportunityBinds.put('lstOpportunityStageNames', lstOpportunityStageNames);
            mapOpportunityBinds.put('numOfRecords', numOfRecords);

            // LTAT-10218 - Establish Opportunity Cygate_Sales_Team value to filter by
            if(doFilterByRegion){
                if(!setContextUserBindVariable_Region(  mapOpportunityBinds, 
                                                        BIND_VARIABLE_NAME_CONTEXT_USER_REGION)
                ){
                    return new List<Opportunity>();
                }
            }

            String queryOppsString = 'SELECT Id';
            String spaceOrSpacedLogicalOperator = ' ';
            List<String> lstFieldApiNamesToQuery = new List<String>{
                'Name',
                'Account.Name',
                'Owner.Name',
                'Owner.SmallPhotoUrl',
                'CloseDate',
                'Probability',
                'StageName',
                'Total_Amount_Cygate__c',
                'Total_Amount_Produkt__c',
                'Total_Amount_Tj_nst__c',
                'Cygate_Sales_Team__c',
                'Vunnen_Time_Stamp__c'
            };
            for(String curOppFieldName : lstFieldApiNamesToQuery){
                queryOppsString += (', ' + curOppFieldName);
            }
            // Query sObject
            queryOppsString += ' FROM Opportunity';
            // Query Criteria
            queryOppsString += ' WHERE';
            queryOppsString += ' CloseDate = THIS_MONTH';
            queryOppsString += ' AND StageName IN :lstOpportunityStageNames';
            queryOppsString += ' AND Recordtype.DeveloperName IN :lstOppRecordTypeDevNames';
            queryOppsString += ' AND Vunnen_Time_Stamp__c != null';
            // LTAT-10218 - Optional User-selected filter criterion
            if(doFilterByRegion){
                queryOppsString += (' AND Cygate_Sales_Team__c = :' + BIND_VARIABLE_NAME_CONTEXT_USER_REGION);
            }
            // Record Order
            queryOppsString += ' ORDER BY Vunnen_Time_Stamp__c DESC';
            // Max # of records to return
            queryOppsString += ' LIMIT :numOfRecords';
            // Execute query
            oppList = Database.queryWithBinds(queryOppsString, mapOpportunityBinds, AccessLevel.SYSTEM_MODE);
        } catch(Exception curException){
            throw new LatestClosedOppsException(System.Label.LATEST_CLOSED_OPPORTUNITIES_ERROR_MSG);
        }
        return OppList;
    }

    /**
     * Description:
     * Retrieve a list of recently won Fiber-owned Opportunities.
     * @return List of Fiber Opportunities to display in a Lightning Component.
     * Modifications:
     * 11.03.2021 [DK] SALEF-3833 - Introduced. New start page for Fiber.
     * 02.02.2023 [AN] SALEF-7995 - Modified. Accommodate for the introduction of 'Like' functionality. 
     * 24.03.2023 [TB] SALEF-8266 - Modified. Retrieval criteria adjusted.  
     **/
    @AuraEnabled
    public static List<Opportunity> getListOfLatestClosedOpportunityFiber() {

        List<Opportunity> oppList;
        Map<String, Object> mapOpportunityBinds = new Map<String, Object>();

        // Retrieve Settings
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsSettingApplied = Latest_Closed_Opportunities_Setting__mdt.getInstance('Fiber');
        if(latestClosedOppsSettingApplied == null){
            latestClosedOppsSettingApplied = Latest_Closed_Opportunities_Setting__mdt.getInstance('DEFAULT');
            if(latestClosedOppsSettingApplied == null){
                throw new LatestClosedOppsException(System.Label.LATEST_CLOSED_OPPORTUNITIES_ERROR_MSG);
            }
        }

        try{
            // Set up bind variable map for the Dynamic SOQL query string
            List<String> lstAccountNamesToExcludeProcessed = helperCommaSeparatedValuesToList(latestClosedOppsSettingApplied.Accounts_to_Exclude__c);
            List<String> lstOpportunityOwnerProfileNames = helperCommaSeparatedValuesToList(latestClosedOppsSettingApplied.Opportunity_Owner_Profiles__c);
            mapOpportunityBinds.put('lstAccountNamesToExclude', lstAccountNamesToExcludeProcessed);
            mapOpportunityBinds.put('lstOppOwnerProfileNames', lstOpportunityOwnerProfileNames);
            mapOpportunityBinds.put('numOfRecords', (Integer)latestClosedOppsSettingApplied.Number_of_Rows__c);

            // Construct a Dynamic SOQL query string
            String queryWonFiberOppsString = 'SELECT Id';
            List<String> lstFieldApiNamesToQuery = new List<String>{
                'CloseDate',
                'Like_Details__c',
                'Like_Status__c', 
                'Name', 
                'Number_of_Likes__c',
                'Number_of_Ports__c',
                'OwnerId',
                'Revenue_CS__c',
                'Revenue_NS__c',
                'Vunnen_Time_Stamp__c',
                'Owner.SmallPhotoUrl', 
                'Owner.Name', 
                'Account.Owner.Name',
                'Account.Name'
            };
            for(String curOppFieldName : lstFieldApiNamesToQuery){
                queryWonFiberOppsString += (', ' + curOppFieldName);
            }
            // Query sObject
            queryWonFiberOppsString += ' FROM Opportunity';
            // Query Criteria
            queryWonFiberOppsString += ' WHERE';
            queryWonFiberOppsString += (' CloseDate = ' + latestClosedOppsSettingApplied.Close_Date_Literal__c);
            queryWonFiberOppsString += ' AND Account.Name NOT IN :lstAccountNamesToExclude';
            queryWonFiberOppsString += ' AND Owner.Profile.Name IN :lstOppOwnerProfileNames';
            queryWonFiberOppsString += ' AND Vunnen_Time_Stamp__c != null';
            // Record Order
            queryWonFiberOppsString += ' ORDER BY Vunnen_Time_Stamp__c DESC';
            // Max # of records to return
            queryWonFiberOppsString += ' LIMIT :numOfRecords';
            // Execute query
            oppList = Database.queryWithBinds(queryWonFiberOppsString, mapOpportunityBinds, AccessLevel.SYSTEM_MODE);
            // 'Like' functionality related processing
            if (oppList.Size() > 0) {
                helperSetOpportunityLikeStatus(oppList);
            }
        } catch(Exception curException){
            throw new LatestClosedOppsException(System.Label.LATEST_CLOSED_OPPORTUNITIES_ERROR_MSG);
        }
        return oppList;
    }

    /**
     * Description:
     * Retrieve a list of the top 10 Won Opportunities ranked by 'Sales_Outcomes',
     * filtered based on the context User Profile.
     * @return List of Opportunities to display in a Lightning Component.
     * Modifications:
     * 11.03.2021 [YK] SALEF-2380 - Introduced. New start page for Fiber.
     * 25.03.2021 [PS] SALEF-4308 - Modified. Accommodate for the 'Like'-button functionality.
     * 14.04.2021 [YK] SALEF-4510 - Modified. Retrieve the Top 10 highest value Opportunities Won this week. 
     * 24.03.2023 [TB] SALEF-8396 - Refactored. Retrieve Opportunities based on context User Profile.  
     **/
    @AuraEnabled
    public static List <Opportunity> getlistoflatestclosedSMESOHOopportunity(){
        return getClosedSmeSohoTelesalesOpportunityRank('salesOutcome');
    }

    /**
     * Description:
     * Retrieve a list of the 10 most recently Won Opportunities filtered 
     * based on the context User Profile.
     * @return List of Opportunities to display in a Lightning Component.
     * Modifications:
     * 28.05.2021 [YK] SALEF-4710 - Introduced. Retrieve the 10 most recently Won Opportunities. 
     * 24.03.2023 [TB] SALEF-8396 - Refactored. Retrieve Opportunities based on context User Profile.  
     **/ 
    @AuraEnabled
    public static List<Opportunity> getlistoftop10latestclosedSMESOHOopportunity(){
        return getClosedSmeSohoTelesalesOpportunityRank('wonTimeStamp');
    }

    /**
     * Description:
     * Retrieve a list of the 10 most recently Won Opportunities filtered 
     * based on the context User Profile.
     * @return List of Opportunities to display in a Lightning Component.
     * Modifications: 
     * 24.03.2023 [TB] SALEF-8396 - Introduced. Retrieve Opportunities based on context User Profile.  
     **/ 
    @AuraEnabled
    public static List <Opportunity> getClosedSmeSohoTelesalesOpportunityRank(String rankBy){
        //used for Large group and set like status on load
        List<Opportunity> oppList;
        Map<String, Object> mapOpportunityBinds = new Map<String, Object>();
        String LOGICAL_OPERATOR_SPACED_AND = ' AND ';

        // Retrieve Settings
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsSettingApplied;
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsTelesalesSetting;
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsSMESohoSetting;
        Latest_Closed_Opportunities_Setting__mdt latestClosedOppsDefaultSetting;
        if(rankBy == 'salesOutcome'){
            latestClosedOppsTelesalesSetting = Latest_Closed_Opportunities_Setting__mdt.getInstance('Telesales_RankBySalesOutcome');
            latestClosedOppsSMESohoSetting = Latest_Closed_Opportunities_Setting__mdt.getInstance('SME_SOHO_RankBySalesOutcome');
        } else{
            latestClosedOppsTelesalesSetting = Latest_Closed_Opportunities_Setting__mdt.getInstance('Telesales_RankByDateWon');
            latestClosedOppsSMESohoSetting = Latest_Closed_Opportunities_Setting__mdt.getInstance('SME_SOHO_RankByDateWon');
        }
        latestClosedOppsDefaultSetting = Latest_Closed_Opportunities_Setting__mdt.getInstance('DEFAULT');

        // Throw an error if the expected metadata records have been removed
        if( latestClosedOppsTelesalesSetting == null 
            || latestClosedOppsSMESohoSetting == null
            || latestClosedOppsDefaultSetting == null
        ){
            throw new LatestClosedOppsException(System.Label.LATEST_CLOSED_OPPORTUNITIES_ERROR_MSG);
        }

        // Determine whether the Telesales Settings should be applied
        // to the User viewing the component based on Profile
        List<String> lstTargetProfileNames = helperCommaSeparatedValuesToList(latestClosedOppsTelesalesSetting.Target_Profiles__c);
        for(String curProfileName : lstTargetProfileNames){
            if(contextUserProfileId == SEUtility.getProfileId(curProfileName)){
                latestClosedOppsSettingApplied = latestClosedOppsTelesalesSetting;
                break; 
            }
        }
        // Users assigned to all other Profiles should default to SOHO/SME settings 
        if(latestClosedOppsSettingApplied == null){
            latestClosedOppsSettingApplied = latestClosedOppsSMESohoSetting;
        }

        try{
            // Set up a Dynamic SOQL query string
            List<String> lstAccountNamesToExcludeProcessed = helperCommaSeparatedValuesToList(latestClosedOppsSettingApplied.Accounts_to_Exclude__c);
            List<String> lstOpportunityOwnerProfileNames = helperCommaSeparatedValuesToList(latestClosedOppsSettingApplied.Opportunity_Owner_Profiles__c);
            List<String> lstOpportunityRecTypeDevNames = helperCommaSeparatedValuesToList(latestClosedOppsSettingApplied.Opportunity_Record_Types__c);
            mapOpportunityBinds.put('lstAccountNamesToExclude', lstAccountNamesToExcludeProcessed);
            mapOpportunityBinds.put('lstOppOwnerProfileNames', lstOpportunityOwnerProfileNames);
            mapOpportunityBinds.put('lstOppRecordTypeDevNames', lstOpportunityRecTypeDevNames);
            if(latestClosedOppsSettingApplied.Number_of_Rows__c != null){
                mapOpportunityBinds.put('numOfRecords', (Integer)latestClosedOppsSettingApplied.Number_of_Rows__c);
            } else{
                mapOpportunityBinds.put('numOfRecords', (Integer)latestClosedOppsDefaultSetting.Number_of_Rows__c);
            }
            if(String.isNotBlank(latestClosedOppsSettingApplied.Seller_Sales_Team_Name__c)){
                mapOpportunityBinds.put('sellerSalesTeamName', latestClosedOppsSettingApplied.Seller_Sales_Team_Name__c);
            }

            String queryWonFiberOppsString = 'SELECT Id';
            String spaceOrSpacedLogicalOperator = ' ';
            List<String> lstFieldApiNamesToQuery = new List<String>{
                'CloseDate',
                'Large_Continuation_Sales__c',
                'Large_New_Sales__c',
                'Like_Details__c',
                'Like_Status__c',
                'Name',
                'Number_of_Likes__c',
                'OwnerId',
                'Sales_Outcome__c',
                'Sales_Team_formula__c',
                'Vunnen_Time_Stamp__c',
                'Account.Name',
                'Account.Owner.Name',
                'Owner.Name',
                'Owner.SmallPhotoUrl'
            };
            for(String curOppFieldName : lstFieldApiNamesToQuery){
                queryWonFiberOppsString += (', ' + curOppFieldName);
            }
            // Query sObject
            queryWonFiberOppsString += ' FROM Opportunity';
            // Query Criteria
            queryWonFiberOppsString += ' WHERE';
            if(String.isNotEmpty(latestClosedOppsSettingApplied.Close_Date_Literal__c)){
                queryWonFiberOppsString += (spaceOrSpacedLogicalOperator 
                                            + 'CloseDate = ' + latestClosedOppsSettingApplied.Close_Date_Literal__c);
                spaceOrSpacedLogicalOperator = LOGICAL_OPERATOR_SPACED_AND;
            }
            if(String.isNotEmpty(latestClosedOppsSettingApplied.Won_Opportunity_Time_Stamp_Literal__c)){
                queryWonFiberOppsString += (spaceOrSpacedLogicalOperator 
                                            + 'Vunnen_Time_Stamp__c = ' + latestClosedOppsSettingApplied.Won_Opportunity_Time_Stamp_Literal__c);
                spaceOrSpacedLogicalOperator = LOGICAL_OPERATOR_SPACED_AND;
            } else{
                queryWonFiberOppsString += (spaceOrSpacedLogicalOperator + 'Vunnen_Time_Stamp__c != null');
                spaceOrSpacedLogicalOperator = LOGICAL_OPERATOR_SPACED_AND;
            }
            if(String.isNotEmpty(latestClosedOppsSettingApplied.Seller_Sales_Team_Name__c)){
                queryWonFiberOppsString += (spaceOrSpacedLogicalOperator 
                                            + 'Sales_Team_formula__c LIKE :sellerSalesTeamName');
                spaceOrSpacedLogicalOperator = LOGICAL_OPERATOR_SPACED_AND;
            }
            if(!lstAccountNamesToExcludeProcessed.isEmpty()){
                queryWonFiberOppsString += (spaceOrSpacedLogicalOperator
                                            + 'Account.Name NOT IN :lstAccountNamesToExclude');
                spaceOrSpacedLogicalOperator = LOGICAL_OPERATOR_SPACED_AND;
            }
            if(!lstOpportunityOwnerProfileNames.isEmpty()){
                queryWonFiberOppsString += (spaceOrSpacedLogicalOperator
                                            + 'Owner.Profile.Name IN :lstOppOwnerProfileNames');
                spaceOrSpacedLogicalOperator = LOGICAL_OPERATOR_SPACED_AND;
            }
            if(!lstOpportunityRecTypeDevNames.isEmpty()){
                queryWonFiberOppsString += (spaceOrSpacedLogicalOperator
                                            + 'Recordtype.DeveloperName IN :lstOppRecordTypeDevNames');
                spaceOrSpacedLogicalOperator = LOGICAL_OPERATOR_SPACED_AND;
            }
            // Record Order
            if(rankBy == 'salesOutcome'){
                queryWonFiberOppsString += ' ORDER BY Sales_Outcome__c DESC';
            }else{
                queryWonFiberOppsString += ' ORDER BY Vunnen_Time_Stamp__c DESC';
            }
            // Max # of records to return
            queryWonFiberOppsString += ' LIMIT :numOfRecords';
            // Execute query
            oppList = Database.queryWithBinds(queryWonFiberOppsString, mapOpportunityBinds, AccessLevel.SYSTEM_MODE);
            // 'Like' functionality related processing
            if (oppList.Size() > 0) {
                helperSetOpportunityLikeStatus(oppList);
            }
        } catch(Exception curException){
            throw new LatestClosedOppsException(System.Label.LATEST_CLOSED_OPPORTUNITIES_ERROR_MSG);
        }
        return OppList;
    }

    /**
     * Description:
     * Set Oppportunity 'Like_Status' helper field, only stored in memory,
     * depending on whether context User has 'Liked' the record.
     * @param lstRetrievedOpportunities Opportunities to be displayed in the report component
     * Modifications:
     * 24.03.2023 [TB] SALEF-8266 - Introduced to remove redundancy. 
     **/
    private static void helperSetOpportunityLikeStatus(List<Opportunity> lstRetrievedOpportunities){
        if(lstRetrievedOpportunities != null){
            for(Opportunity curOpportunity : lstRetrievedOpportunities){
                if( curOpportunity.Like_Details__c != null
                    && String.valueof(curOpportunity.Like_Details__c).contains(UserInfo.getUserId())
                    && curOpportunity.Number_of_Likes__c != null 
                    && curOpportunity.Number_of_Likes__c > 0
                ){
                    curOpportunity.Like_Status__c = true;
                } else{
                    curOpportunity.Like_Status__c = false;
                }
            }
        }
    }

    /**
     * Description:
     * Helper converting a String of 'separatorRegEx' separated values
     * into a List containing the values as its elements.
     * @param strRegExSeparatedValues String of 'separatorRegEx'-separated values
     * @param separatorRegEx Value separator
     * @return List of 'separatorRegEx' separated values, empty list when nothing is passed.
     * Modifications:
     * 24.03.2023 [TB] SALEF-8266 - Introduced.  
     **/
    @TestVisible
    private static List<String> helperRegExSeparatedValuesToList(String strRegExSeparatedValues, String separatorRegEx){
        String DEFAULT_SEPARATOR = ',';
        List<String> lstProcessedStrings = new List<String>();
        if(String.isEmpty(strRegExSeparatedValues)){
            return lstProcessedStrings;
        }
        List<String> lstStrings = strRegExSeparatedValues.split(
            !String.isEmpty(separatorRegEx) ? separatorRegEx : DEFAULT_SEPARATOR
        );
        for(String curString : lstStrings){
            lstProcessedStrings.add(curString.trim());
        }
        return lstProcessedStrings;
    }

    /**
     * Description:
     * Helper converting a String of comma separated values
     * into a List containing the values as its elements.
     * @param strCommaSeparatedValues String of comma-separated values
     * @return List of comma separated values, empty list when nothing is passed.
     * Modifications:
     * 24.03.2023 [TB] SALEF-8266 - Introduced.  
     **/
    @TestVisible
    private static List<String> helperCommaSeparatedValuesToList(String strCommaSeparatedValues){
        return helperRegExSeparatedValuesToList(strCommaSeparatedValues, ',');
    }

    /**
     * Description:
     * Get context User details.
     * @return List containing running User.
     * Modifications:
     * 20.06.2023 [TB] LTAT-10218 - Introduced.  
     **/
    @TestVisible
    private static List<User> getContextUser(){
        if( lstContextUser == null || lstContextUser.isEmpty()){
            lstContextUser = [  SELECT ID, Cygate_User_Team__c
                                FROM User
                                WHERE Id = :UserInfo.getUserId()];
        }
        return lstContextUser;
    }

    /**
     * Description:
     * Put the Context User's Region in the bindMap 
     * @param mapBindVarNamesToBindVars - bindMap to use in a dynamic SOQL query
     * @param variableNameToSet - Bind variable name
     * @return True, if the bindMap key-value pair set, False otherwise.
     * Modifications:
     * 20.06.2023 [TB] LTAT-10218 - Introduced.  
     **/
    @TestVisible
    private static Boolean setContextUserBindVariable_Region(   Map<String, Object> mapBindVarNamesToBindVars,
                                                                String variableNameToSet
    ){
        List<User> lstCurContextUser = getContextUser();
        if( !lstCurContextUser.isEmpty()
            && mapBindVarNamesToBindVars != null
            && String.isNotBlank(variableNameToSet)
            && String.isNotBlank(lstCurContextUser[0].Cygate_User_Team__c)
        ){
            mapBindVarNamesToBindVars.put(variableNameToSet, lstCurContextUser[0].Cygate_User_Team__c);
            return true;
        }
        return false;
    }

    // SALEF-8266 - Introduced
    public class LatestClosedOppsException extends Exception {}
    
}