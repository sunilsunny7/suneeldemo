/**
About
-----
Description: LeadTriggerHandler on Lead
Create date: 26.10-2016

Update History 
--------------
Created Oct 2016 - V.M - Created. Added method setOrgLookup SAEN-1898
Updated Oct 2016 - A.N - New method setContactTeliaResellerId SAEN 1909/1923
Updated Oct 2016 - A.N - New method createBuyInterestOnPardotSync SAEN 1909/1926. (Replaces Process Builder from SAEN-1836)
Updated Oct 2016 - A.N - New method updateBuyInterestsOnLeadConvertion SAEN 1909/1926. (Replaces Process Builder from SAEN-1836)
Updated Oct 2016 - N.G - New method populateAccLookup created SAEN-1898 :- To auto populate account lookup on Lead based on orgnr. and company name on/of Lead
Updated Nov 2016 - A.N - New functionality for updating Buy Interest Status on Lead Status change. As both this functionality and existing
method updateBuyInterestsOnLeadConvertion will potentially update the same records, the functionality for this has
been merged into a single method updateBuyInterestsOnLeadStatusChange. SAEN-1982
Updated Nov 2016 - A.N - SAEN-2031 Updated updateBuyInterestsOnLeadConvertion with functionality for copying Lead Owner on Buy Interest
Updated Nov 2016 - A.N - SAEN-1985 Functionality added that resets the Description_Pardot on each update. When Pardot forms are submitted
however the submitted Pardot Description value (from the newMap) should be stored on Buy Interest
Updated Nov 2016 - A.N - SAEN-1957 new method updateLeadStatusOnPardotSync
Updated Dec 2016 - A.N - SAEN-2103 new method setResellerAccountName
Updated Dec 2016 - A.N - Added recursion handling in the methods that creates BuyInterest On PardotSync (SAEN-2103/1840)
Updated Dec 2016 - N.G - SAEN-1861 , New methods reminderPostDispatcher and chatterPostForVolumeSalesCLM to send reminder notification on volume sales CLM queue group. 
Updated Jan 2016 - A.N - Case-2398 Refactored populateAccLookup-method. Added Limit to SOQL query and try/catch to handle exceptions.
Updated Feb 2017 - V.M - SEAN-2178 Updated validateBuyInterestTholbox method in LeadTriggerHandler so it validates LeadsAgents aswell. 
Updated Mar 2017 - D.C - Case # 2720 Add new picklist value to Köpintresse Product_Area value is Servicetjänster (Personal services).
Updated Jun 2017 - V.A - SAEN-2404 Added new ConvertToCygateLead Method for change in field value of 'Cygate Sync' then Convert that record into Cygate Lead record type.
Updated Jun 2017 - V.M - SAEN-2409 CygateLeads: Enable automatic routing for leads
Updated Sep 2017 - D.C - SALEF-238 - Update Partner__c field on Buy intrest from the Lead when Cygate)Sync is incremented.
Updated Sep 2017 - D.C - SALEF-212 - Update Lead source "Telia PIX" for the new Form Handler.
Updated Mar 2018 - D.C - SALEF-951 - Update Lead Product_Area with new value "Cygate Event Signup".
Updated Apr 2018 - D.C - SALEF-1057 - Update Lead Product_Area with new value "Mobil Integration".
Updated Apr 2018 - D.C - SALEF-1185 - Add new field 'Additional_comments__c' which will behave same as Description_Pardot__c and also add new Telia Product area 'Konfiguratorn.
Updated Oct 2018 - D.C - SALEF-1589 - Update Lead Product_Area with new value "Healthcare".
Updated Apr 2019 - D.C - SALEF-2052 - Leads without Buy Interest were not showing comments.
Updated Apr 2019 - D.C - SALEF-2028 - Update Lead Product_Area with new value "Cygate Digital Arbetsplats" for Cygate record Type.
Updated Sept 2019 - P.S - SALEF-2375 - Commented the methods chatterPostForVolumeSalesCLM() and  reminderPostDispatcher() as part of Valume Sales cleanup.
Created Nov 2019 -S.K - SALEF-2429 - Created Method addCampaignMemberLead() to add leads to Campaign Pardot Kalla Leads 
Created Apr 2022- L.k - SALEF-6483:- Logic to create task note on Buy Interest object from Lead object
28.02.2023 [Tomass Brazovskis] SALEF-8276 - Optimizations to avoid unnecessary SOQL queries.
12.04.2023 [Tomass Brazovskis] SALEF-8573 - SALEF-6483-introduced Task Status should be set to 'Stängd'.
LTAT-7483: Change Lead product area value API names
Issues / TODOs
--------------     
*/
public class LeadTriggerHandler {
    /* * * * * * * * * * * * * * * * * * * * */
    /* * LeadTriggerHandler Trigger Calls  * */
    /* * * * * * * * * * * * * * * * * * * * */
    
    @TestVisible
    private static Boolean pardotLeadsBuyInterestCreated = false;
    @TestVisible
    private static Boolean feedPostisExecuting = false;
    private static Boolean m_isExecuting = false;
    private static Boolean acc_isExecuting = false;
    public static Boolean IsExecuted = true;

    private integer BatchSize = 0;

    private static Map < Id, String > pardotDescriptionMap;
    private static Map < Id, String > pardotAddCommentMap; //D.C.
    public static Map < Id, Integer > pardotfacilitiesMap;
    public static Map < Id, String > pardotfacilitycheckMap;
    // SALEF-8276: Map to keep track of a set of Leads, for which the Validation Rule has been
    // applied already, and, hence, should not be revalidated in case of a trigger recursion
    private static Map <String, Set<Id>> mapValidRuleNamesToSetOfValidatedLeadIds = new Map<String, Set<Id>>();

    public static List < Lead > deletedLead;
    public static List < Buy_Interest__c > deleteBuyIntds;
    
    public LeadTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(List < Lead > newList, Map < ID, Lead > newMap) {
        System.debug(
            'LeadTriggerHandler.OnBeforeInsert starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize
        );
        convertToCygateLead(newList); // V.A
        // Note: This should be the (one of the) first method to run on before insert, since other
        // methods depend on the Telia_Employee_Telia_Id__c/Reseller_Tholbox_ID__c being set.
        setContactTeliaResellerId(newList, null);
        setResellerAccountName(newList, null);
        if (!newList.isEmpty()) {
            populateAccLookup(newList);
        }
        setCygateManager(newList); //P.P
    }
    
    public void OnBeforeUpdate(List < Lead > newList, Map < ID, Lead > newMap, List < Lead > oldList, Map < ID, Lead > oldMap) {
        System.debug(
            'LeadTriggerHandler.OnBeforeUpdate starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize
        );
        resetPardotDescriptionField(newList, oldMap);
        updateLeadStatusOnPardotSync(newList, oldMap);
        setContactTeliaResellerId(newList, oldMap);
        setResellerAccountName(newList, oldMap);
        validateBuyInterestTholbox(newMap);
        updateLeadStatusOnCygateSync(newList, oldMap); //V.A
        routeOnAccountChange(newMap, oldMap);
        //  createTaskInBuyInt(newList, oldMap);
    }
    
    public void OnAfterInsert(List < Lead > newList, Map < ID, Lead > newMap) {
        System.debug(
            'LeadTriggerHandler.OnAfterInsert starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize
        );
        createBuyInterestOnPardotSync(newMap, null);
        createBuyInterestOnCygateSync(newMap, null); // V.A
        addCampaignMemberLead(newList, null);
        
        /* if(feedPostisExecuting == false){
chatterPostForVolumeSalesCLM(newList,'immidiate msg');
}*/
    }
    
    public void OnAfterUpdate(List < Lead > newList, Map < ID, Lead > newMap, List < Lead > oldList, Map < ID, Lead > oldMap) {
        System.debug(
            'LeadTriggerHandler.OnAfterUpdate starts. Number of SOQLs used so far ' + Limits.getQueries() + ' queries. Number of records = ' + BatchSize
        );
        
        createBuyInterestOnPardotSync(newMap, oldMap);
        createBuyInterestOnCygateSync(newMap, oldMap); //V.A
        updateBuyInterestsOnLeadChange(newList, oldMap);
        updateBuyInterestsOnLeadChangeCygate(newList, oldMap); //V.A
        addCampaignMemberLead(newList, oldMap);
        if (IsExecuted) {
            createTaskInBuyInt(newList, oldMap);
        }
        /*if(feedPostisExecuting == false){
reminderPostDispatcher(newList);
}*/
    }
    
    public void OnAfterDelete(List < Lead > oldList, Map < ID, Lead > oldMap) {
        //Added to delete the buyinterest when lead is deleted from system
        deleteLeadBuyInterest(oldList, oldMap);
    }
    
    public void OnBeforedelete(Map < ID, Lead > oldMap, List < Lead > oldList) {
        getbuyinttdeleteRecords(oldList, oldMap);
    }
    
    /* * * * * * * * * * * * * * * * * * * * * * */
    /* * LeadTriggerHandler Trigger Methods * */
    /* * * * * * * * * * * * * * * * * * * * * * */
    
    // Lead Source Picklist Definitions
    public static final String LEAD_SOURCE_RESELLER = 'ÅF';
    public static final String LEAD_SOURCE_TELIA_SE = 'Telia.se';
    public static final String LEAD_SOURCE_TELIA_INTRANET = 'Telia Intranet';
    public static final String LEAD_SOURCE_OTHER = 'Övrig Telia';
    public static final String LEAD_SOURCE_LEADAGENT = 'Lead Agent';
    public static final String LEAD_SOURCE_SALESREP = 'Sales Rep';
    public static final String LEAD_SOURCE_PERSONAL_TECHNICIAN = 'Personlig Tekniker';
    public static final String LEAD_SOURCE_TELIA_ADMIN = 'Telia Admin';
    public static final String LEAD_SOURCE_TELIA_PIX = 'Telia PIX';
    // Lead Status Picklist Definitions
    public static final String LEAD_STATUS_NEW = 'Nytt';
    public static final String LEAD_STATUS_PREQUALIFY = 'Förkvalificera';
    public static final String LEAD_STATUS_QUALIFY = 'Kvalificera';
    public static final String LEAD_STATUS_RETURNED = 'Returnerad';
    public static final String LEAD_STATUS_CONVERTED = 'Konverterat';
    public static final String LEAD_STATUS_DISMISSED = 'Avfärdat';
    public static final String LEAD_STATUS_ROUTE = 'Routing';
    
    // Lead Close Reason Picklist Definitions
    public static final String LEAD_CLOSE_REASON_DUPLICATE = 'Dubblett';
    
    // Lead Converts to Cygate opportunity type Picklist Definitions
    public static final String CYGATE_BUSINESS_OPPORTUNITY = 'Cygate affär';
    
    // Lead Product Area Picklist Definitions
    // LTAT-7483: Changed the API names Övrigt to Other, Växlar to PBX, Bredband to Broadband 
    public static final String LEAD_PRODAREA_BB = 'Broadband';
    public static final String LEAD_PRODAREA_CS = 'Molntjänster';
    public static final String LEAD_PRODAREA_CN = 'Företagsnätverk';
    public static final String LEAD_PRODAREA_CC = 'Kontaktcenter';
    public static final String LEAD_PRODAREA_ESD = 'Expert och servicetjänster';
    public static final String LEAD_PRODAREA_IOT = 'IOT';
    public static final String LEAD_PRODAREA_MS = 'Mötestjänster';
    public static final String LEAD_PRODAREA_OTHER = 'Other';
    public static final String LEAD_PRODAREA_SS = 'Supporttjänster';
    public static final String LEAD_PRODAREA_SWITCH = 'PBX';
    public static final String LEAD_PRODAREA_TELEPHONY = 'Telefoni';
    public static final String LEAD_PRODAREA_PS = 'Servicetjänster';
    public static final String LEAD_PRODAREA_SECURITY = 'Security';
    public static final String LEAD_PRODAREA_CLOUD = 'Cloud';
    public static final String LEAD_PRODAREA_SER_STO = 'Server/Storage';
    public static final String LEAD_PRODAREA_CITYNET = 'Citynet';
    public static final String LEAD_PRODAREA_NETWORK = 'Network';
    public static final String LEAD_PRODAREA_DMD = 'DMD';
    public static final String LEAD_PRODAREA_UC = 'UC';
    public static final String LEAD_PRODAREA_CES = 'Cygate Event Signup';
    public static final String LEAD_PRODAREA_MI = 'Mobil Integration';
    public static final String LEAD_PRODAREA_HC = 'Healthcare';
    public static final String LEAD_PRODAREA_CG = 'Konfiguratorn'; //D.C.
    public static final String LEAD_PRODAREA_WORKPLACE = 'Cygate Digital Arbetsplats'; //D.C.
    
    // SALEF-8276: Procedures to only perform once in case of trigger recursions
    public static final String BUY_INTEREST_THOLBOX = 'BuyInterestTholbox';
    
    // Author A.N
    // Copy the value from Lead_Submitter__c (Set by Pardot for incoming leads from Pardot)
    // into either Telia_Employee_Telia_Id__c or Reseller_Tholbox_ID__c field (based on Lead Source)
    private void setContactTeliaResellerId(List < Lead > newList, Map < Id, Lead > oldMap) {
        for (Lead l: newList) {
            if (oldMap == null || (oldMap != null && l.Lead_Submitter_ID__c != oldMap.get(l.Id).Lead_Submitter_ID__c)) {
                if (l.Lead_Submitter_ID__c != null && l.Lead_Submitter_ID__c != '') {
                    if (l.LeadSource == LEAD_SOURCE_RESELLER || l.LeadSource == LEAD_SOURCE_LEADAGENT || l.LeadSource == LEAD_SOURCE_TELIA_ADMIN) {
                        System.debug('The lead submitter is a reseller contact');
                        l.Telia_Employee_Telia_Id__c = null;
                        l.Reseller_Tholbox_ID__c = l.Lead_Submitter_ID__c;
                    } else if (
                        l.LeadSource == LEAD_SOURCE_TELIA_SE ||
                        l.LeadSource == LEAD_SOURCE_TELIA_INTRANET ||
                        l.LeadSource == LEAD_SOURCE_SALESREP ||
                        l.LeadSource == LEAD_SOURCE_PERSONAL_TECHNICIAN ||
                        l.LeadSource == LEAD_SOURCE_TELIA_PIX
                    ) {
                        System.debug('The lead submitter is a Telia employee');
                        l.Telia_Employee_Telia_Id__c = l.Lead_Submitter_ID__c;
                        l.Reseller_Tholbox_ID__c = null;
                    }
                } else {
                    l.Telia_Employee_Telia_Id__c = null;
                    l.Reseller_Tholbox_ID__c = null;
                }
            }
        }
    }
    
    // Author A.N
    // Set Reseller Account based on Lead Submitter No for all "ÅF"-leads (Reseller)
    private void setResellerAccountName(List < Lead > newList, Map < Id, Lead > oldMap) {
        List < Lead > resellerLeads = new List < Lead > ();
        List < String > accountResellerIds = new List < String > ();
        
        // Filter leads where Lead Submitter no not null and where Lead Submitter has been set/updated
        for (Lead l: newList) {
            if (l.LeadSource == LEAD_SOURCE_RESELLER || l.LeadSource == LEAD_SOURCE_LEADAGENT) {
                if (l.Lead_Submitter_No__c != null && (oldMap == null || l.Lead_Submitter_No__c != oldMap.get(l.Id).Lead_Submitter_No__c)) {
                    resellerLeads.add(l);
                    accountResellerIds.add(l.Lead_Submitter_No__c);
                }
            }
        }
        
        if (resellerLeads.isEmpty())
            return;
        
        // Query accounts
        Map < String, String > resellerIdNameMap = new Map < String, String > ();
        for (Account acc : [SELECT Id, Name, Telia_Reseller_Id__c FROM Account WHERE Telia_Reseller_Id__c IN :accountResellerIds]) {
            resellerIdNameMap.put(acc.Telia_Reseller_Id__c, acc.Name);
        }
        
        // Set Reseller Account Name field on Leads
        for (Lead l: resellerLeads) {
            l.Reseller_Account_Name__c = resellerIdNameMap.get(l.Lead_Submitter_No__c);
        }
    }
    
    // Author A.N
    // When a new Lead is updated reset the field Description_Pardot__c and Additional_comments__c to "-". We will store the submitted value
    // in a Map as this should be set on the Buy Interest if they are created by the after trigger.
    private void resetPardotDescriptionField(List < Lead > newList, Map < Id, Lead > oldMap) {
        pardotDescriptionMap = new Map < Id, String > ();
        pardotAddCommentMap = new Map < Id, String > (); //D.C.
        pardotfacilitiesMap = new Map < Id, Integer > ();
        pardotfacilitycheckMap = new Map < Id, String > ();
        for (Lead newLead: newList) {
            pardotDescriptionMap.put(newLead.Id, newLead.Description_Pardot__c);
            pardotAddCommentMap.put(newLead.Id, newLead.Additional_comments__c); //D.C.
            newLead.Description_Pardot__c = '-';
            if (newLead.Number_of_Facilities__c != null)
                pardotfacilitiesMap.put(newLead.Id, newLead.Number_of_Facilities__c.intValue());
            pardotfacilitycheckMap.put(newLead.id, newLead.New_facility__c);
            //if(newLead.Pardot_Sync__c != null && newLead.Pardot_Sync__c != oldMap.get(newLead.Id).Pardot_Sync__c){
            if (newLead.Pardot_Sync__c != null && (oldMap == null || newLead.Pardot_Sync__c != oldMap.get(newLead.Id).Pardot_Sync__c)) {
                System.debug(
                    '####newLead.Pardot_Sync__c: ' + newLead.Pardot_Sync__c + 'oldMap.get(newLead.Id).Pardot_Sync__c : ' + oldMap.get(newLead.Id).Pardot_Sync__c
                );
                // Reset Number_of_Facilities__c to 'null' on all updates
                newLead.Number_of_Facilities__c = 0;
                // Reset New_facility__c to '-' on all updates
                newLead.New_facility__c = '-';
                // Reset Additional_comments__c to '-' on all updates
                newLead.Additional_comments__c = '-';
            }
        }
    }
    
    // Author A.N
    // If Lead status = "Avfärdat" and Pardot Sync, set Lead status to "Nytt" (SAEN-1957)
    private void updateLeadStatusOnPardotSync(List < Lead > newList, Map < Id, Lead > oldMap) {
        for (Lead l: newList) {
            if (l.Status == LEAD_STATUS_DISMISSED) {
                if (l.Pardot_Sync__c != null && l.Pardot_Sync__c != oldMap.get(l.Id).Pardot_Sync__c) {
                    l.Status = LEAD_STATUS_NEW;
                    l.Lead_Close_Reason__c = null;
                }
            }
        }
    }
    
    // Author A.N
    // When a new Lead is submitted or updated from Pardot (counter field Pardot_Sync__c has changed)
    // The different steps are as follows:
    // 1. Create a new Buy Interest record. Copy fields from Lead to the Buy interest record.
    // 2. If any of the submitted Lead forms have Telia_Employee_Telia_Id__c/Reseller_Tholbox_ID__c != null,
    //    we also try to find the related contact.
    //   2.1 For Leads with Telia_Employee_Telia_Id__c != null
    //      - If no contact is found, this is a Internal Telia user and we will create a new contact record.
    //      - We will then relate the bu interest to the correct Telia contact (Internal user or SF user)
    //      - For Telia Internal contacts, we will also update field values Name, Email, Phone if necessary based on the new form.
    //   2.2 For Leads with Reseller_Tholbox_ID__c != null
    //      - We will try to set the correct Reseller contact on the Buy interest
    //      - If no contact is found, no contact will be created or set on the Buy Interest
    //      (Note: The reseller contacts should always exist in SF before they submit any lead forms)
    // 3. Insert the new Buy Interest records
    private void createBuyInterestOnPardotSync(Map < Id, Lead > newMap, Map < Id, Lead > oldMap) {
        // Recursion handling: Only run this code once
        if (pardotLeadsBuyInterestCreated)
            return;
        else
            pardotLeadsBuyInterestCreated = true;
        
        List < Buy_Interest__c > biList = new List < Buy_Interest__c > ();
        Set < String > teliaAndResellerIds = new Set < String > ();
        List<Lead> leadNeedsBuyInterestSubmiter = new List<Lead>();
        for (Lead l: newMap.values()) {
            // For all Leads from Pardot (Pardot_Sync__c != null) which are new or Pardot_Sync__c is updated, create Buy Interest
            if (l.Pardot_Sync__c != null && (oldMap == null || l.Pardot_Sync__c != oldMap.get(l.Id).Pardot_Sync__c)) {
                // Create Buy Interests. Set status new and copy fields from Lead
                Buy_Interest__c bi = createBuyInterestFromLead(l);
                biList.add(bi);
                if (l.Telia_Employee_Telia_Id__c != null)
                    teliaAndResellerIds.add(l.Telia_Employee_Telia_Id__c.toLowerCase());
                else if (l.Reseller_Tholbox_ID__c != null)
                    teliaAndResellerIds.add(l.Reseller_Tholbox_ID__c.toLowerCase());
            }
        }
        
        if (biList.isEmpty())
            return;
        
        // For all new Buy Interests we also need to set the Submitter Contact Lookup (only if Lead Telia/Reseller Id is populated)
        if (!teliaAndResellerIds.isEmpty()) {
            // First we create a map of the existing contacts where the Telia/Reseller Id is the Key
            Map < String, Contact > teliaUserResellerContactsMap = new Map < String, Contact > ();
            for (Contact con : [
                SELECT Id, FirstName, LastName, Email, Phone, Telia_Id__c, Reseller_Tholbox_ID__c, Is_Telia_User_Contact__c, Is_Cygate_User_Contact__c
                FROM Contact
                WHERE Telia_Id__c IN :teliaAndResellerIds OR Reseller_Tholbox_ID__c IN :teliaAndResellerIds
                              ]) {
                if (con.Telia_Id__c != null)
                    teliaUserResellerContactsMap.put(con.Telia_Id__c.toLowerCase(), con);
                else if (con.Reseller_Tholbox_ID__c != null)
                    teliaUserResellerContactsMap.put(con.Reseller_Tholbox_ID__c.toLowerCase(), con);
                              }
            
            // For all Leads where Telia Id is not null we first must create new contacts if they don't exist
            List < Contact > newContacts = new List < Contact > ();
            for (Buy_Interest__c bi: biList) {
                Lead lead = newMap.get(bi.Lead__c);
                if (lead.Telia_Employee_Telia_Id__c != null && !teliaUserResellerContactsMap.containsKey(lead.Telia_Employee_Telia_Id__c.toLowerCase())) {
                    Contact newCon = new Contact(
                        FirstName = lead.Lead_Submitter_first_name__c,
                        Email = lead.Lead_Submitter_email__c,
                        Phone = lead.Lead_Submitter_phone__c,
                        Telia_Id__c = lead.Telia_Employee_Telia_Id__c.toLowerCase()
                    );
                    
                    // Insert of new contact will fail if LastName is null, so must set "Last Name Missing" if not profided from Pardot.
                    newCon.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_TELIA_INTERNAL);
                    newCon.LastName = (lead.Lead_Submitter_Last_name__c == null ? '[Efternamn saknas]' : lead.Lead_Submitter_Last_name__c);
                    newCon.AccountId = UserTriggerHandler.getTeliaAccountId(); // This Method should be
                    System.debug(newCon);
                    newContacts.add(newCon);
                }
            }
            // Insert the new Contacts and add them to the Map teliaUserResellerContactsMap
            if (!newContacts.isEmpty()) {
                Database.insert(newContacts, false);
                for (Contact con: newContacts) {
                    if (con.Id != null)
                        teliaUserResellerContactsMap.put(con.Telia_Id__c.toLowerCase(), con);
                }
            }
            
            // If the lead submitter already exist as a contact in the system we might need to update the contact record
            List < Contact > updatedContacts = new List < Contact > ();
            // Set the Lead Submitter field on the Buy Interest records

            for (Buy_Interest__c bi: biList) {
                Lead lead = newMap.get(bi.Lead__c);
                Contact con;
                if (lead.Telia_Employee_Telia_Id__c != null && teliaUserResellerContactsMap.containsKey(lead.Telia_Employee_Telia_Id__c.toLowerCase())) {
                    con = teliaUserResellerContactsMap.get(lead.Telia_Employee_Telia_Id__c.toLowerCase());
                    bi.Buy_Interest_Submitter__c = con.Id;
                    // Added lead.Buy_Interest_Submitter to start move functionality from Bi to lead it will be moved to before when we remove BI
                    Lead leadNeedUpdate = new Lead(id = lead.id, Buy_Interest_Submitter__c = con.Id);
                    leadNeedsBuyInterestSubmiter.add(leadNeedUpdate);
                } else if (lead.Reseller_Tholbox_ID__c != null && teliaUserResellerContactsMap.containsKey(lead.Reseller_Tholbox_ID__c.toLowerCase())) {
                    con = teliaUserResellerContactsMap.get(lead.Reseller_Tholbox_ID__c.toLowerCase());
                    bi.Buy_Interest_Submitter__c = con.Id;
                    // Added l.Buy_Interest_Submitter to start move functionality from Bi to lead it will be moved to before when we remove BI
                    Lead leadNeedUpdate = new Lead(id = lead.id, Buy_Interest_Submitter__c = con.Id);
                    leadNeedsBuyInterestSubmiter.add(leadNeedUpdate);
                }
                // The isContactUpdateNeeded-method returns null if no changes between lead and contact, otherwise it returns the updated contact record
                Contact updatedCon = isContactUpdateNeeded(con, lead);
                if (updatedCon != null)
                    updatedContacts.add(updatedCon);
            }
            if (!updatedContacts.isEmpty())
                Database.update(updatedContacts, false);
        }
        
        // Insert new Buy Interest records
        if (!biList.isEmpty()) {
        insert biList;
    }
    
        if (!leadNeedsBuyInterestSubmiter.isEmpty()) {
            update leadNeedsBuyInterestSubmiter;
        }
    }

    // Author A.N
    // Create a new Buy Interest record. Copy fields from Lead
    private static Buy_Interest__c createBuyInterestFromLead(Lead l) {
        Buy_Interest__c bi = new Buy_Interest__c();
        bi.OwnerId = l.OwnerId;
        bi.Lead__c = l.Id;
        bi.Status__c = LEAD_STATUS_NEW;
        bi.Date_Set_to_New__c = System.now();
        bi.Number_of_Premises__c = l.Number_of_Premises__c;
        bi.Number_of_Households__c = l.Number_of_Households__c;
        bi.MunicipalityBuyInterest__c = l.Municipality__c;
        bi.Prel_construction_start_date__c = l.Prel_construction_start_date__c;
        // The Pardot Description on Lead is reset to "-" every time a new Pardot Lead is updated.
        // On update we need to go to pardotDescriptionMap and fetch the originally submitted value for pardotDescription
        // On update we need to go to pardotAddCommentMap and fetch the originally submitted value for pardotAddComment
        if (pardotDescriptionMap != null) {
            // Is Update,
            String pardotDescription = pardotDescriptionMap.get(l.Id);
            bi.Description__c = (pardotDescription != null ? pardotDescription : l.Description_Pardot__c);
        } else {
            // Is insert
            bi.Description__c = l.Description_Pardot__c;
        }
        if (pardotAddCommentMap != null) {
            //D.C.
            String pardotAddComment = pardotAddCommentMap.get(l.Id); //D.C
            bi.Additional_comments__c = (pardotAddComment != null ? pardotAddComment : l.Additional_comments__c); //D.C.
        } else {
            bi.Additional_comments__c = l.Additional_comments__c; //D.C.
        }
        bi.Form_Source__c = l.Form_Source__c;
        bi.Form_Source_URL__c = l.Form_Source_URL__c;
        bi.Lead_Source__c = l.LeadSource;
        // Extra field from Fiber Form
        if (pardotfacilitiesMap != null) {
            // Is Update
            Integer pardotfacilities = pardotfacilitiesMap.get(l.Id);
            bi.Number_of_Facilities__c = (pardotfacilities != null ? pardotfacilities : l.Number_of_Facilities__c);
        } else {
            // Is insert
            bi.Number_of_Facilities__c = l.Number_of_Facilities__c;
        }
        // Extra field from Fiber Form
        if (pardotfacilitycheckMap != null) {
            // Is Update
            String pardotcheckfacilities = pardotfacilitycheckMap.get(l.Id);
            system.debug('22222' + pardotcheckfacilities);
            bi.New_facility__c = (pardotcheckfacilities != null ? pardotcheckfacilities : l.New_facility__c);
        } else {
            // Is insert
            bi.New_facility__c = l.New_facility__c;
        }
        bi.Name = l.Product_Area__c;
        bi.Contact__c = l.Contact__c;
        bi.Submitted_Product_Area__c = l.Product_Area__c;
        bi.Submitted_Org_nr__c = l.Org_nr__c;
        // Set checkboxes based on Product Area on the Lead
        bi.Interest_Broadband__c = (l.Product_Area__c == LEAD_PRODAREA_BB ? true : false);
        bi.Interest_Cloud_Services__c = (l.Product_Area__c == LEAD_PRODAREA_CS ? true : false);
        bi.Interest_Company_Network__c = (l.Product_Area__c == LEAD_PRODAREA_CN ? true : false);
        bi.Interest_Contact_Center__c = (l.Product_Area__c == LEAD_PRODAREA_CC ? true : false);
        bi.Interest_Expert_and_Service_Duties__c = (l.Product_Area__c == LEAD_PRODAREA_ESD ? true : false);
        bi.Interest_IOT__c = (l.Product_Area__c == LEAD_PRODAREA_IOT ? true : false);
        bi.Interest_Meeting_Services__c = (l.Product_Area__c == LEAD_PRODAREA_MS ? true : false);
        bi.Interest_Other__c = (l.Product_Area__c == LEAD_PRODAREA_OTHER ? true : false);
        bi.Interest_Support_Services__c = (l.Product_Area__c == LEAD_PRODAREA_SS ? true : false);
        bi.Interest_Switches__c = (l.Product_Area__c == LEAD_PRODAREA_SWITCH ? true : false);
        bi.Interest_Telephony__c = (l.Product_Area__c == LEAD_PRODAREA_TELEPHONY ? true : false);
        bi.Interest_Personal_Services__c = (l.Product_Area__c == LEAD_PRODAREA_PS ? true : false);
        bi.Interest_Personal_Services__c = (l.Product_Area__c == LEAD_PRODAREA_MI ? true : false);
        bi.Interest_Personal_Services__c = (l.Product_Area__c == LEAD_PRODAREA_HC ? true : false);
        bi.Interest_Personal_Services__c = (l.Product_Area__c == LEAD_PRODAREA_CG ? true : false);
        system.debug('333333' + bi);
        return bi;
    }
    
    // Author A.N
    // Check if any of the Name, Email, Phone fields from the newly submitted webform (Lead)
    // has different values than the existing contact.
    // If yes, update the fields on the contact record and return the updated contact
    // If no, return null
    private static Contact isContactUpdateNeeded(Contact con, Lead lead) {
        // We don't want to update contact info for existing salesforce users automatically from webforms, these contacts should be updated from the user records only.
        if (con == null || lead == null || con.Is_Telia_User_Contact__c || con.Is_Cygate_User_Contact__c)
            return null;
        
        Integer count = 0;
        if (lead.Lead_Submitter_first_name__c != null && con.FirstName != lead.Lead_Submitter_first_name__c) {
            con.FirstName = lead.Lead_Submitter_first_name__c;
            count += 1;
        }
        if (lead.Lead_Submitter_email__c != null && con.Email != lead.Lead_Submitter_email__c) {
            con.Email = lead.Lead_Submitter_email__c;
            count += 1;
        }
        if (lead.Lead_Submitter_phone__c != null && con.Phone != lead.Lead_Submitter_phone__c) {
            con.Phone = lead.Lead_Submitter_phone__c;
            count += 1;
        }
        if (lead.Lead_Submitter_Last_name__c != null && con.LastName != lead.Lead_Submitter_Last_name__c) {
            con.LastName = lead.Lead_Submitter_Last_name__c;
            count += 1;
        }
        
        if (count == 0)
            return null;
        return con;
    }
    
    // Author A.N
    // For all leads where status have been changed, update the status
    // For all converted leads, update related Buy Interest records with the Converted Contact and/or Opportunity Id
    private void updateBuyInterestsOnLeadChange(List < Lead > newList, Map < Id, Lead > oldMap) {
        Set < Id > updatedLeadIds = new Set < Id > ();
        Set < Id > convertedLeadIds = new Set < Id > ();
        Set < Id > updatedStatusLeadIds = new Set < Id > ();
        Set < Id > changedOwnerLeadIds = new Set < Id > ();
        Set < Id > changedQueueOwnerLeadIds = new Set < Id > ();
        
        for (Lead l: newList) {
            // This functionality should only apply to Telia Leads
            if (l.RecordTypeId != SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_TELIA))
                continue;
            
            // Add all Leads which have been converted to convertedLeadIds
            if (l.IsConverted && !oldMap.get(l.Id).IsConverted && Lead.Product_Area__c != null) {
                convertedLeadIds.add(l.Id);
                updatedLeadIds.add(l.Id);
            }
            // Add all Leads with updated status to updatedStatusLeadIds
            if (l.Status != oldMap.get(l.Id).Status || l.Lead_Close_Reason__c != oldMap.get(l.Id).Lead_Close_Reason__c) {
                updatedStatusLeadIds.add(l.Id);
                updatedLeadIds.add(l.Id);
            }
            // Add all Leads which are new or with updated owner
            if (oldMap == null || l.OwnerId != oldMap.get(l.Id).OwnerId) {
                changedOwnerLeadIds.add(l.Id);
                updatedLeadIds.add(l.Id);
            }
            // Add all Leads with updated owner to changedOwnerLeadIds. If new Owner is queue and not Leadcentralen add to changedQueueOwnerLeadIds
            if (l.OwnerId != oldMap.get(l.Id).OwnerId) {
                changedOwnerLeadIds.add(l.Id);
                updatedLeadIds.add(l.Id);
                if (String.valueOf(l.OwnerId).substring(0, 3) == '00G' && l.OwnerId != getLeadCentralenId()) {
                    changedQueueOwnerLeadIds.add(l.Id);
                }
            }
        }
        
        if (updatedLeadIds.isEmpty())
            return;
        
        // Update Buy Interest for converted lists
        List < Buy_Interest__c > biList = new List < Buy_Interest__c > ();
        List<Lead> updatedLeadsList = [
            SELECT
                Id,
                ConvertedContactId,
                ConvertedOpportunityId,
                Status,
                OwnerId,
                Owner.Name,
                Lead_Close_Reason__c,
                CA_Buy_Interest__c,
                (
                    SELECT
                        Id,
                        Date_Set_to_New__c,
                        Date_Set_to_Prequalify__c,
                        Date_Set_to_Qualify__c,
                        Date_Set_to_Converted__c,
                        Date_Set_to_Dismissed__c,
                        Date_Set_to_Returned__c,
                        Lead_Queue__c,
                        Status__c,
                        Lead_Close_Reason__c,
                        Contact__c,
                        Opportunity__c,
                        OwnerId,
                        Lead_Source__c
                    FROM Buy_Interests__r
                )
            FROM Lead
            WHERE Id IN :updatedLeadIds
                                         ];
        
        for (Lead l: updatedLeadsList) {
            for (Buy_Interest__c bi: l.Buy_Interests__r) {
                Boolean isUpdated = false;
                if (!updatedStatusLeadIds.isEmpty() && updatedStatusLeadIds.contains(l.Id)) {
                    if (bi.Status__c != LEAD_STATUS_CONVERTED && bi.Status__c != LEAD_STATUS_DISMISSED) {
                        bi.Status__c = l.Status;
                        bi.Lead_Close_Reason__c = l.Lead_Close_Reason__c;
                        //updateBuyInterestStatusDates(bi);
                        isUpdated = true;
                    }
                }
                
                if (!convertedLeadIds.isEmpty() && convertedLeadIds.contains(l.Id) && l.CA_Buy_Interest__c == bi.Id) {
                    System.debug('l.ConvertedContactId: ' + l.ConvertedContactId);
                    bi.Contact__c = l.ConvertedContactId;
                    bi.Opportunity__c = l.ConvertedOpportunityId;
                    isUpdated = true;
                } else if (!convertedLeadIds.isEmpty() && convertedLeadIds.contains(l.Id) && bi.Lead_Source__c == LeadTriggerHandler.LEAD_SOURCE_RESELLER) {
                    bi.Status__c = 'Avfärdat';
                    isUpdated = true;
                } else if (!convertedLeadIds.isEmpty() && convertedLeadIds.contains(l.Id)) {
                    bi.Contact__c = l.ConvertedContactId;
                    bi.Opportunity__c = l.ConvertedOpportunityId;
                    isUpdated = true;
                }
                if (!changedOwnerLeadIds.isEmpty() && changedOwnerLeadIds.contains(l.Id)) {
                    bi.OwnerId = l.OwnerId;
                    isUpdated = true;
                }
                if (!changedQueueOwnerLeadIds.isEmpty() && changedQueueOwnerLeadIds.contains(l.Id)) {
                    if (bi.Lead_Queue__c == null) {
                        bi.Lead_Queue__c = l.Owner.Name;
                        isUpdated = true;
                    }
                }
                
                if (isUpdated)
                    biList.add(bi);
            }
        }
        
        if (!biList.isEmpty()) {
            System.debug('Updating ' + biList.size() + ' Buy Interest records from Leads with status update: ' + biList);
            update biList;
        }
    }
    
    private static Id leadCentralenId;
    private static Id getLeadCentralenId() {
        if (leadCentralenId == null) {
            Group gr = [
                SELECT Id
                FROM Group
                WHERE DeveloperName = 'Leadcentralen' AND Type = 'Queue'
                        LIMIT 1
                       ];
            if (gr != null)
                leadCentralenId = gr.Id;
        }
        return leadCentralenId;
    }
    
    private static void updateBuyInterestStatusDates(Buy_Interest__c bi) {
        if (bi.Status__c == LEAD_STATUS_NEW) {
            bi.Date_Set_to_New__c = System.now();
        } else if (bi.Status__c == LEAD_STATUS_PREQUALIFY) {
            bi.Date_Set_to_Prequalify__c = System.now();
        } else if (bi.Status__c == LEAD_STATUS_QUALIFY) {
            bi.Date_Set_to_Qualify__c = System.now();
        } else if (bi.Status__c == LEAD_STATUS_CONVERTED) {
            bi.Date_Set_to_Converted__c = System.now();
        } else if (bi.Status__c == LEAD_STATUS_DISMISSED) {
            bi.Date_Set_to_Dismissed__c = System.now();
        } else if (bi.Status__c == LEAD_STATUS_RETURNED) {
            bi.Date_Set_to_Returned__c = System.now();
        }
    }
    
    //Author: N.G
    // This method will populate Account lookup on Lead when a new lead is created(not on updation)
    // Refactored AN January 2017: Added Limit to SOQL to avoid System.QueryException, and added try/catch statement
    private static void populateAccLookup(List < Lead > newList) {
        Set < String > orgNumbers = new Set < String > ();
        Set < String > compName = new Set < String > ();
        Set < String > leadEmailDomain = new Set < String > ();
        
        for (Lead l: newList) {
            if (
                l.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_TELIA)) ||
                l.RecordTypeId.equals(SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_CYGATE))
            ) {
                if (!String.isBlank(l.Org_nr__c)) {
                    l.Org_nr__c = l.Org_nr__c.replaceAll('-', '');
                    orgNumbers.add(l.Org_nr__c);
                }
                if (l.Company != null && l.Company.length() > 2) {
                    compName.add(l.Company);
                }
                if (String.isNotBlank(l.EmailDomain__c)) {
                    leadEmailDomain.add(l.EmailDomain__c);
                }
            }
        }
        if (!orgNumbers.isEmpty() || !compName.isEmpty() || !leadEmailDomain.isEmpty()) {
            Map < String, Id > orgNoAccMap = new Map < String, Id > ();
            Map < String, Id > nameAccMap = new Map < String, Id > ();
            Map < String, Id > domainAccMap = new Map < String, Id > ();
            Set < String > largeSMEaccRecTypeNames = new Set < String > {
                SEUtility.ACC_RECTYPE_SME,
                    SEUtility.ACC_RECTYPE_LARGE,
                    SEUtility.ACC_RECTYPE_LARGE_SEC1,
                    SEUtility.ACC_RECTYPE_LARGE_SEC2
                    };
                        List < Account > accList = new List < Account >();
            try {
                accList = [
                    SELECT Id, Org_nr__c, AccountDomain__c, Name
                    FROM Account
                    WHERE
                        (Name IN :compName
                        OR Org_Nr__c IN :orgNumbers
                        OR AccountDomain__c IN :leadEmailDomain)
                        AND RecordType.developerName IN :largeSMEaccRecTypeNames
                ];
            } catch (Exception e) {
                System.debug(
                    'Exception thrown, no Account will be set for any of the Leads. Exception Message:' + e.getMessage() + 'Line Number:-' + e.getLineNumber()
                );
                return;
            }
            if (accList.size() != 0) {
                for (Account acc: accList) {
                    if(acc.Org_nr__c != null) {
                        orgNoAccMap.put(acc.Org_nr__c, acc.id);
                    }
                    if(acc.Name != null) {
                        nameAccMap.put(acc.Name.toLowerCase(), acc.Id);
                    }
                    if(acc.AccountDomain__c != null) {
                        domainAccMap.put(acc.AccountDomain__c.toLowerCase(), acc.Id);
                    }
                }
                for (Lead l: newList) {
                    if (orgNoAccMap != null && orgNoAccMap.containsKey(l.Org_nr__c) && l.Org_nr__c != null) {
                        l.Account__c = orgNoAccMap.get(l.Org_nr__c);
                    } else if (nameAccMap != null && nameAccMap.containsKey(l.Company.toLowerCase()) && l.Company.length() > 2 && l.Company != null) {
                        l.Account__c = nameAccMap.get(l.Company.toLowerCase());
                    } else if (
                        domainAccMap != null &&
                        domainAccMap.containsKey(l.EmailDomain__c.toLowerCase()) &&
                        l.EmailDomain__c != null &&
                        l.recordtypeId == SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_CYGATE)
                    ) {
                        l.Account__c = domainAccMap.get(l.EmailDomain__c.toLowerCase());
                    }
                }
            }
        }
    }
    
    /**@Description:
     * Validates the Submitter field on Leads Buy Interests, if they are from Reseller(ÅF)
     * and Submitter field is empty, fire validation error.
     * @param newMap - A map of IDs to the new versions of the Lead records.
     * Modifications:
     *  02.2017 [VM] SAEN-2178 - Updated. Apply to records with 'Lead Agents' Lead Source as well.
     *  28.02.2023 [TB] SALEF-8276 - Optimized to prevent a repeated Lead validation in a transaction.
     **/
    private static void validateBuyInterestTholbox(Map < Id, Lead > newMap) {
        if(mapValidRuleNamesToSetOfValidatedLeadIds.get(BUY_INTEREST_THOLBOX) == null){
            mapValidRuleNamesToSetOfValidatedLeadIds.put(BUY_INTEREST_THOLBOX, new Set<Id>());
        }
        Set<Id> setOfValidatedLeadIds = mapValidRuleNamesToSetOfValidatedLeadIds.get(BUY_INTEREST_THOLBOX);
        Set < Id > filteredLeadIds = new Set < Id > ();
        
        //Filter Leads so they match criteria
        for (Lead l : newMap.values()) {
            if (
                l.Status != LeadTriggerHandler.LEAD_STATUS_NEW &&
                l.Status != LeadTriggerHandler.LEAD_STATUS_PREQUALIFY &&
                SEUtility.getRecordTypeDevName(l.RecordTypeId) == SEUtility.LEAD_RECTYPE_TELIA
            ){
                filteredLeadIds.add(l.Id);
            }
        }
        // Avoid validating the same Lead more than once per transaction 
        filteredLeadIds.removeAll(setOfValidatedLeadIds);
        setOfValidatedLeadIds.addAll(filteredLeadIds);
        
        if (filteredLeadIds.isEmpty())
            return;
        
        //Get all related Buy Interests that is from Reseller(ÅF) with no Submitter fields.
        for (Buy_Interest__c bi : [
            SELECT Id, Name, Lead__c
                                    FROM Buy_Interest__c
            WHERE
                Lead__c IN :filteredLeadIds
                AND (Lead_Source__c = :LeadTriggerHandler.LEAD_SOURCE_RESELLER
                OR Lead_Source__c = :LeadTriggerHandler.LEAD_SOURCE_LEADAGENT)
                                    AND Buy_Interest_Submitter__c = NULL
        ]){
            newMap.get(bi.Lead__c).addError(System.Label.No_Submitter_Validation_Error + ' [Köpintresse: ' + bi.Name + ']');
        }        
    }
    
    //N.G : SAEN-1861 , This method sends the reminder notification if Lead is not assigned to Volume Sales CLM queue member till 6 or 8 hours.
    /* Commenting this method as part of SALEF-2375 - Volume Sales clean up
public static void reminderPostDispatcher(List<Lead> newList){
List<Lead> newFourHrRecList = new List<Lead>();
List<Lead> newSixHrRecList = new List<Lead>();
for(lead L : newList){
if(L.Reminder_Post_After_4_hrs__c == true &&  L.Priority_CLM__c == 'CLM 1' && SEUtility.getRecordTypeDevName(l.RecordTypeId) == SEUtility.LEAD_RECTYPE_TELIA){
newFourHrRecList.add(L);
}
else if(L.Reminder_Post_After_6_hrs__c == true && L.Priority_CLM__c == 'CLM 2'&& SEUtility.getRecordTypeDevName(l.RecordTypeId) == SEUtility.LEAD_RECTYPE_TELIA){
newSixHrRecList.add(L);
}
}
if(!newFourHrRecList.isEmpty())
chatterPostForVolumeSalesCLM(newFourHrRecList, 'Priority 1 Lead reminder');
if(!newSixHrRecList.isEmpty())
chatterPostForVolumeSalesCLM(newSixHrRecList, 'Priority 2 Lead reminder');

}
private static void chatterPostForVolumeSalesCLM(List<Lead> newList,string msg) {

feedPostisExecuting = true;
list<lead> finalupdateLead = new list<lead>();
list<Group> queueID = [select Id from Group where Name = 'Volume Sales CLM' and Type = 'Queue'];
list<CollaborationGroup> chatterGroupID = [SELECT Id From CollaborationGroup WHERE CollaborationType='Public' AND name = 'Volume Sales CLM Group'];
list<FeedItem> postList = new list<FeedItem>();
for(lead l : newList){

if(l.ownerID ==queueID[0].id  && SEUtility.getRecordTypeDevName(l.RecordTypeId) == SEUtility.LEAD_RECTYPE_TELIA){
FeedItem post = new FeedItem();
post.ParentId = chatterGroupID[0].id; //ID of chatter group
post.Body = msg + ' ' +'of priority' + ' ' + l.Priority_CLM__c;
post.Title = l.firstName + ' ' +l.lastName;
post.LinkUrl = '/'+l.id;
postList.add(post);
lead newLead = new lead(id = l.id,Reminder_Post_After_4_hrs__c = l.Reminder_Post_After_4_hrs__c,Reminder_Post_After_6_hrs__c = l.Reminder_Post_After_6_hrs__c);
if(newLead.Reminder_Post_After_4_hrs__c == true)
newLead.Reminder_Post_After_4_hrs__c = false;
if(newLead.Reminder_Post_After_6_hrs__c == true)
newLead.Reminder_Post_After_6_hrs__c = false;
finalupdateLead.add(newLead);
}
}
try{
if(!postList.isEmpty())
insert postList;
if(!finalupdateLead.isEmpty())
update finalupdateLead;
}
catch(exception ex){
}
}*/
    
    //Vahraz Mostajir
    //SAEN-2409 CygateLeads: Enable automatic routing for leads
    //SAEN-2499 CygateLeads: Stages Auto update
    private static void routeOnAccountChange(Map < Id, Lead > newMap, Map < Id, Lead > oldMap) {
        Map < Id, Lead > cygateLeads = new Map < Id, Lead > ();
        //AccId, List LeadId
        Map < Id, List < Id >> accLeadIdMap = new Map < Id, List < Id >> ();
        for (Lead l: newMap.values()) {
            if (l.RecordTypeId == SEUtility.getRecordTypeId('Cygate_Lead') && l.Account__c != null && l.Account__c != oldMap.get(l.Id).Account__c) {
                cygateLeads.put(l.Id, l);
                if (accLeadIdMap.get(l.Account__c) == null) {
                    //List that holds the leadIds, mapped to one Account
                    List < Id > leadIds = new List < Id > ();
                    leadIds.add(l.Id);
                    accLeadIdMap.put(l.Account__c, leadIds);
                } else {
                    accLeadIdMap.get(l.Account__c).add(l.Id);
                }
            }
        }
        
        if (!cygateLeads.isEmpty()) {
            //LeadId, UserId
            Map < Id, Id > leadUserIdMap = new Map < Id, Id > ();
            
            //Try to match by checking Account
            if (!accLeadIdMap.isEmpty()) {
                for (Account acc : [
                    SELECT Id, Cygate_Account_Manager__c, TotalEmployees_reported__c, Business_Unit__c
                    FROM Account
                    WHERE Id = :accLeadIdMap.keySet()
                                  ]) {
                                      if (acc.Cygate_Account_Manager__c != null) {
                                          //Go through the leads matched to the Account and map them to a user
                                          for (Id leadId: accLeadIdMap.get(acc.Id)) {
                                              leadUserIdMap.put(leadId, acc.Cygate_Account_Manager__c);
                                              
                                              //Set status to Qualify since there is a match on Cygate Account Manager
                                              cygateLeads.get(leadId).Status = LEAD_STATUS_QUALIFY;
                                          }
                                      }
                                  }
            }
            
            //Set the OwnerId
            for (Lead l: cygateLeads.values()) {
                if (leadUserIdMap.get(l.Id) != null) {
                    l.OwnerId = leadUserIdMap.get(l.Id);
                }
            }
        }
    }
    
    //Vahraz Mostajir
    //SAEN-2409 CygateLeads: Enable automatic routing for leads
    private static void setCygateManager(List < Lead > newList) {
        //Get all the cygate leads
        //HashCode as ID since it's before trigger, the object does not have an ID
        Id queueId = [SELECT Id FROM Group WHERE  Type = 'Queue' AND NAME = 'Cygate Auto Rules'].Id;
        Map < Integer, Lead > cygateLeads = new Map < Integer, Lead > ();
        for (Lead l: newList) {
            if (l.RecordTypeId == SEUtility.getRecordTypeId('Cygate_Lead') && l.OwnerId == queueId) {
                cygateLeads.put(System.hashCode(l), l);
                //Set status to New since it's directly from Pardot
                l.Status = LEAD_STATUS_NEW;
            }
        }
        if (!cygateLeads.isEmpty()) {
            //AccId, LeadList Hashcode
            Map < Id, List < Integer >> accLeadHashMap = new Map < Id, List < Integer >> ();
            
            //Get Cygate Sales Support Queue Id and assign it to LeadOwner if there is no Account Match
            General_Lead_Settings__c gls = General_Lead_Settings__c.getInstance('General Settings');
            
            //Loop through the keys and pair leads to one account
            for (Integer key: cygateLeads.keySet()) {
                if (cygateLeads.get(key).Account__c != null) {
                    //If it's the first account we need to create a new Lead List as value
                    if (accLeadHashMap.get(cygateLeads.get(key).Account__c) == null) {
                        //List that holds the leadHashKeys, mapped to one Account
                        List < Integer > leadHashKeys = new List < Integer > ();
                        leadHashKeys.add(key);
                        accLeadHashMap.put(cygateLeads.get(key).Account__c, leadHashKeys);
                    } else {
                        //Lead hashkey List is already created so we can just add it to the List
                        accLeadHashMap.get(cygateLeads.get(key).Account__c).add(key);
                    }
                } else {
                    if (gls != null) {
                        cygateLeads.get(key).OwnerId = gls.Retur_LC_OwnerId__c;
                        
                        //Set Status to Route since it's on Cygate Sales Support
                        cygateLeads.get(key).Status = LEAD_STATUS_ROUTE;
                    }
                }
            }
            //LeadHash, Lead
            Map < Integer, Id > leadHashUserIdMap = new Map < Integer, Id > ();
            
            //Try to match by checking Account
            if (!accLeadHashMap.isEmpty()) {
                for (Account acc : [
                    SELECT Id, Cygate_Account_Manager__c, TotalEmployees_reported__c, Business_Unit__c
                                   FROM Account
                                   WHERE Id =: accLeadHashMap.keySet()
                                  ]) {
                                      if (acc.Cygate_Account_Manager__c != null) {
                                          //Go through the leads matched to the Account and map them to a user
                                          for (Integer hashKey: accLeadHashMap.get(acc.Id)) {
                                              leadHashUserIdMap.put(hashKey, acc.Cygate_Account_Manager__c);
                                              //Set status to Qualify since there is a match on Cygate Account Manager
                                              cygateLeads.get(hashKey).Status = LEAD_STATUS_QUALIFY;
                                          }
                                      }
                                  }
            }
            
            //Set the OwnerId
            for (Integer hashKey: cygateLeads.keySet()) {
                if (leadHashUserIdMap.get(hashKey) != null) {
                    cygateLeads.get(hashKey).OwnerId = leadHashUserIdMap.get(hashKey);
                } else {
                    if (gls != null) {
                        cygateLeads.get(hashKey).OwnerId = gls.Retur_LC_OwnerId__c;
                        cygateLeads.get(hashKey).Status = LEAD_STATUS_ROUTE;
                    }
                }
            }
        }
    }
    
    // Author: Varma Alluri on 31.05.2017, SAEN-2404; When Cygate Sync value changes from null then convert record type into Cygate Lead
    public static void convertToCygateLead(List < Lead > newList) {
        for (Lead l: newlist) {
            if (l.Cygate_Sync__c != null && l.RecordTypeId != SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_CYGATE)) {
                l.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_CYGATE);
                l.Converts_to_opportunity_type_Cygate__c = CYGATE_BUSINESS_OPPORTUNITY;
                l.Business_Dialogue_Start_Date__c = System.Today();
            }
        }
    }
    
    // Author: Varma Alluri on 05.06.2017, SAEN-2401; If the lead is closed, when Cygate Sync Value changes then Lead has to "re-open"
    private void updateLeadStatusOnCygateSync(List < Lead > newList, Map < Id, Lead > oldMap) {
        for (Lead l: newList) {
            if (l.Status == LEAD_STATUS_DISMISSED) {
                if (
                    l.RecordTypeId == SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_CYGATE) &&
                    l.Cygate_Sync__c != null &&
                    l.Cygate_Sync__c != oldMap.get(l.Id).Cygate_Sync__c
                ) {
                    l.Status = LEAD_STATUS_NEW;
                    l.Lead_Close_Reason__c = null;
                }
            }
        }
    }
    
    // Author: Varma Alluri on 02.06.2017, SAEN-2401; When Cygate Sync field value changes then create new record in Buy Interest
    // Updated by Vahraz Mostajir on 22.06.2017, SAEN-2428. Updated so that if there is a Cygate SF Contact with the same email as the Lead Submitter, 
    // we set it the Lead Submitter on the BI with that Contact, else we create a new Cygate SF Contact.
    public static void createBuyInterestOnCygateSync(Map < Id, Lead > newMap, Map < Id, Lead > oldMap) {
        //LeadId, Lead
        Map < Id, Lead > cygateLeads = new Map < Id, Lead > ();
        //Email, LeadId
        Map < String, Id > emailMap = new Map < String, Id > ();
        List<Lead> leadNeedsBuyInterestSubmiter = new List<Lead>();
        try {
            for (Lead l: newMap.Values()) {
                // For all Leads from Pardot (Cygate_Sync__c != null) which are new or Cygate_Sync__c is updated, add it to the cygateLeads List
                if (l.Cygate_Sync__c != null && (oldMap == null || l.Cygate_Sync__c != oldMap.get(l.Id).Cygate_Sync__c)) {
                    //Map the emails to a lead
                    if (l.Lead_Submitter_email__c != null && !String.isEmpty(l.Lead_Submitter_email__c)) {
                        emailMap.put(l.Lead_Submitter_email__c, l.Id);
                    }
                    cygateLeads.put(l.Id, l);
                }
            }
            
            if (!cygateLeads.isEmpty()) {
                //Get the contacts with the matching mail
                Map < String, Contact > contactMap = new Map < String, Contact > ();
                for (Contact c : [
                    SELECT Id, Email
                                 FROM Contact
                    WHERE
                        Email IN :emailMap.keySet()
                        AND (RecordTypeId = :SEUtility.getRecordTypeId('Cygate_SF_User')
                        OR RecordTypeId = :SEUtility.getRecordTypeId('Cygate_Contact'))
                                ]) {
                                    contactMap.put(c.Email, c);
                                }
                List < Buy_Interest__c > biList = new List < Buy_Interest__c > ();
                
                for (Lead l: cygateLeads.Values()) {
                    // Create Buy Interests. Set status new and copy fields from Lead
                    Buy_Interest__c newBuyInterest = createBuyInterestFromLeadCygate(l);
                    //Map the contact to lead submitter
                    // Added l.Buy_Interest_Submitter to start move functionality from Bi to lead it will be moved to before when we remove BI
                    if (contactMap.get(l.Lead_Submitter_email__c) != null) {
                        newBuyInterest.Buy_Interest_Submitter__c = contactMap.get(l.Lead_Submitter_email__c).Id;
                        Lead leadNeedUpdate = new Lead(id = l.id, Buy_Interest_Submitter__c = contactMap.get(l.Lead_Submitter_email__c).Id);
                        leadNeedsBuyInterestSubmiter.add(leadNeedUpdate);
                    }
                    biList.Add(newBuyInterest);
                }
                
                if (!biList.isEmpty()) {
                    insert biList;
                }
                if (!leadNeedsBuyInterestSubmiter.isEmpty()) {
                    update leadNeedsBuyInterestSubmiter;
                }
            }
        } catch (Exception e) {
        }
    }
    
    // Author: Varma Alluri on 02.06.2017, SAEN-2401; When Cygate Sync field value changes then create new record in Buy Interest object & copy fields from Lead
    private static Buy_Interest__c createBuyInterestFromLeadCygate(Lead l) {
        Buy_Interest__c newBuyInterest = new Buy_Interest__c();
        newBuyInterest.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.BUY_INTEREST_RECTYPE_CYGATE);
        newBuyInterest.OwnerId = l.OwnerId;
        newBuyInterest.Lead__c = l.Id;
        newBuyInterest.Name = l.Product_Area__c;
        newBuyInterest.Contact__c = l.Contact__c;
        newBuyInterest.Status__c = LEAD_STATUS_NEW;
        newBuyInterest.Status__c = l.Status;
        newBuyInterest.Date_Set_to_New__c = System.now();
        //Update the Partner__c field.
        newBuyInterest.Partner__c = l.Partner__c;
        // The Pardot Description on Lead is reset to "-" every time a new Pardot Lead is updated.
        // On update we need to go to pardotDescriptionMap and fetch the originally submitted value for pardotDescription
        if (pardotDescriptionMap != null) {
            // Is Update
            String pardotDescription = pardotDescriptionMap.get(l.Id);
            newBuyInterest.Description__c = (pardotDescription != null ? pardotDescription : l.Description_Pardot__c);
        } else {
            // Is insert
            newBuyInterest.Description__c = l.Description_Pardot__c;
        }
        if (pardotAddCommentMap != null) {
            //  Is update, D.C.
            String pardotAddComment = pardotAddCommentMap.get(l.Id); //D.C
            newBuyInterest.Additional_comments__c = (pardotAddComment != null ? pardotAddComment : l.Additional_comments__c); //D.C.
        } else {
            newBuyInterest.Additional_comments__c = l.Additional_comments__c; //D.C.
        }
        
        // Extra field from Fiber Form
        newBuyInterest.Number_of_Facilities__c = l.Number_of_Facilities__c;
        newBuyInterest.New_facility__c = l.New_facility__c;
        newBuyInterest.Lead_Source__c = l.LeadSource;
        newBuyInterest.Form_Source__c = l.Form_Source__c;
        newBuyInterest.Form_Source_URL__c = l.Form_Source_URL__c;
        newBuyInterest.Submitted_Product_Area__c = l.Product_Area__c;
        // Set checkboxes based on Product Area on the Lead
        newBuyInterest.Security__c = (l.Product_Area__c == LEAD_PRODAREA_SECURITY ? true : false);
        newBuyInterest.Cloud__c = (l.Product_Area__c == LEAD_PRODAREA_CLOUD ? true : false);
        newBuyInterest.Server_Storage__c = (l.Product_Area__c == LEAD_PRODAREA_SER_STO ? true : false);
        newBuyInterest.Citynet__c = (l.Product_Area__c == LEAD_PRODAREA_CITYNET ? true : false);
        newBuyInterest.Network__c = (l.Product_Area__c == LEAD_PRODAREA_NETWORK ? true : false);
        newBuyInterest.DMD__c = (l.Product_Area__c == LEAD_PRODAREA_DMD ? true : false);
        newBuyInterest.UC__c = (l.Product_Area__c == LEAD_PRODAREA_UC ? true : false);
        newBuyInterest.UC__c = (l.Product_Area__c == LEAD_PRODAREA_CES ? true : false);
        newBuyInterest.Cloud__c = (l.Product_Area__c == LEAD_PRODAREA_WORKPLACE ? true : false);
        system.debug('Line1013:-' + newBuyInterest);
        return newBuyInterest;
    }
    
    /*  Author: Varma Alluri on 15.06.2017; SAEN-2421, For all leads where status have been changed, update the status
For all converted leads, update related Buy Interest records with the Converted Contact and/or Opportunity Id    */
    private void updateBuyInterestsOnLeadChangeCygate(List < Lead > newList, Map < Id, Lead > oldMap) {
        Set < Id > updatedLeadIds = new Set < Id > ();
        Set < Id > convertedLeadIds = new Set < Id > ();
        Set < Id > updatedStatusLeadIds = new Set < Id > ();
        Set < Id > changedOwnerLeadIds = new Set < Id > ();
        Set < Id > changedQueueOwnerLeadIds = new Set < Id > ();
        
        for (Lead cygateLead: newList) {
            // This functionality apply only to Cygate Leads
            if (cygateLead.RecordTypeId != SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_CYGATE))
                continue;
            // Add all Leads which have been converted to convertedLeadIds
            if (cygateLead.IsConverted && !oldMap.get(cygateLead.Id).IsConverted && Lead.Product_Area__c != null) {
                convertedLeadIds.add(cygateLead.Id);
                updatedLeadIds.add(cygateLead.Id);
            }
            // Add all Leads with updated status to updatedStatusLeadIds
            if (cygateLead.Status != oldMap.get(cygateLead.Id).Status || cygateLead.Lead_Close_Reason__c != oldMap.get(cygateLead.Id).Lead_Close_Reason__c) {
                updatedStatusLeadIds.add(cygateLead.Id);
                updatedLeadIds.add(cygateLead.Id);
            }
            // Add all Leads which are new or with updated owner
            if (oldMap == null || cygateLead.OwnerId != oldMap.get(cygateLead.Id).OwnerId) {
                changedOwnerLeadIds.add(cygateLead.Id);
                updatedLeadIds.add(cygateLead.Id);
            }
            // Add all Leads with updated owner to changedOwnerLeadIds. If new Owner is queue and not Leadcentralen add to changedQueueOwnerLeadIds
            if (cygateLead.OwnerId != oldMap.get(cygateLead.Id).OwnerId) {
                changedOwnerLeadIds.add(cygateLead.Id);
                updatedLeadIds.add(cygateLead.Id);
                if (String.valueOf(cygateLead.OwnerId).substring(0, 3) == '00G' && cygateLead.OwnerId != getLeadCentralenId()) {
                    changedQueueOwnerLeadIds.add(cygateLead.Id);
                }
            }
        }
        
        if (updatedLeadIds.isEmpty())
            return;
        
        // Update Buy Interest for converted lists
        List < Buy_Interest__c > biList = new List < Buy_Interest__c > ();
        List<Lead> updatedLeadsList = [
            SELECT
                Id,
                ConvertedContactId,
                IsConverted,
                ConvertedOpportunityId,
                Status,
                OwnerId,
                Owner.Name,
                Lead_Close_Reason__c,
                CA_Buy_Interest__c,
                (
                    SELECT
                        Id,
                        Date_Set_to_New__c,
                        Date_Set_to_Prequalify__c,
                        Date_Set_to_Qualify__c,
                        Date_Set_to_Converted__c,
                        Date_Set_to_Dismissed__c,
                        Date_Set_to_Returned__c,
                        Lead_Queue__c,
                        Status__c,
                        Lead_Close_Reason__c,
                        Contact__c,
                        Opportunity__c,
                        OwnerId,
                        Lead_Source__c
                    FROM Buy_Interests__r
                )
            FROM Lead
            WHERE Id IN :updatedLeadIds
                                         ];
        
        for (Lead cygateLead: updatedLeadsList) {
            for (Buy_Interest__c bi: cygateLead.Buy_Interests__r) {
                Boolean isUpdated = false;
                
                if (cygateLead.IsConverted == true) {
                    if (bi.Status__c != LEAD_STATUS_CONVERTED && bi.Status__c != LEAD_STATUS_DISMISSED) {
                        bi.Opportunity__c = cygateLead.ConvertedOpportunityId;
                        bi.Status__c = cygateLead.Status;
                    }
                }
                
                if (!updatedStatusLeadIds.isEmpty() && updatedStatusLeadIds.contains(cygateLead.Id)) {
                    if (bi.Status__c != LEAD_STATUS_CONVERTED && bi.Status__c != LEAD_STATUS_DISMISSED) {
                        bi.Status__c = cygateLead.Status;
                        bi.Lead_Close_Reason__c = cygateLead.Lead_Close_Reason__c;
                        updateBuyInterestStatusDates(bi);
                        isUpdated = true;
                    }
                }
                
                if (!convertedLeadIds.isEmpty() && convertedLeadIds.contains(cygateLead.Id) && cygateLead.CA_Buy_Interest__c == bi.Id) {
                    bi.Contact__c = cygateLead.ConvertedContactId;
                    bi.Opportunity__c = cygateLead.ConvertedOpportunityId;
                    isUpdated = true;
                } else if (
                    !convertedLeadIds.isEmpty() &&
                    convertedLeadIds.contains(cygateLead.Id) &&
                    bi.Lead_Source__c == LeadTriggerHandler.LEAD_SOURCE_RESELLER
                ) {
                    bi.Status__c = LEAD_STATUS_DISMISSED;
                    isUpdated = true;
                } else if (!convertedLeadIds.isEmpty() && convertedLeadIds.contains(cygateLead.Id)) {
                    bi.Contact__c = cygateLead.ConvertedContactId;
                    isUpdated = true;
                }
                if (!changedOwnerLeadIds.isEmpty() && changedOwnerLeadIds.contains(cygateLead.Id)) {
                    bi.OwnerId = cygateLead.OwnerId;
                    isUpdated = true;
                }
                if (!changedQueueOwnerLeadIds.isEmpty() && changedQueueOwnerLeadIds.contains(cygateLead.Id)) {
                    if (bi.Lead_Queue__c == null) {
                        bi.Lead_Queue__c = cygateLead.Owner.Name;
                        isUpdated = true;
                    }
                }
                
                if (bi.Status__c == LEAD_STATUS_DISMISSED || bi.Status__c == LEAD_STATUS_CONVERTED) {
                    if (bi.Opportunity__c == null) {
                        bi.Opportunity__c = null;
                        isUpdated = true;
                    }
                }
                
                if (isUpdated)
                    biList.add(bi);
            }
        }
        system.debug('Line1117:-' + biList);
        if (!biList.isEmpty()) {
            update biList;
        }
    }
    public static void getbuyinttdeleteRecords(List < Lead > oldList, Map < Id, Lead > oldMap) {
        deletedLead = new List < Lead > ();
        Set < Id > deletedLeadIds = new Set < Id > ();
        deleteBuyIntds = new List < Buy_Interest__c > ();
        try {
            for (Lead l: oldList) {
                deletedLeadIds.add(l.id);
            }
            deletedLead = [SELECT Id, (SELECT Id, Name FROM Buy_Interests__r) FROM Lead WHERE Id IN :deletedLeadIds];
            for (Lead obj: deletedLead) {
                deleteBuyIntds.addAll(obj.Buy_Interests__r);
            }
        } catch (Exception ex) {
            system.debug('Exception Thrown 1259:' + ex.getMessage() + 'Number:-' + ex.getLineNumber() + 'Cause:-' + ex.getCause());
        }
    }
    public static void deleteLeadBuyInterest(List < Lead > oldList, Map < Id, Lead > oldMap) {
        system.debug('####' + deleteBuyIntds);
        if (deleteBuyIntds.size() > 0)
            database.delete(deleteBuyIntds);
    }
    /*created this method to add Lead to campaign Pardot-kalla leads when the Pardotbearbetning behövs is checked  and remove when it is unchecked*/
    public static void addCampaignMemberLead(List < Lead > newList, Map < Id, Lead > oldMap) {
        Set < Id > LeadId = new Set < Id > ();
        Set < Lead > deleteCM = new Set < Lead > ();
        List < CampaignMember > CMInsert = new List < CampaignMember > ();
        List < CampaignMember > CMDelete = new List < CampaignMember > ();
        for (Lead newLead: newList) {
            if (newLead.recordTypeId == SEUtility.getRecordTypeId(SEUtility.LEAD_RECTYPE_TELIA)) {
                if (oldMap == null && newLead.Pardot_bearbetning_beh_vs__c == true) {
                    CampaignMember cmIN = new CampaignMember();
                    cmIN.Status = 'Anmäld';
                    cmIN.CampaignId = Label.CampaignIdtoInsertLead;
                    cmIN.LeadId = newLead.Id;
                    cmInsert.add(cmIN);
                } else if (
                    oldMap != null &&
                    newLead.Pardot_bearbetning_beh_vs__c != oldMap.get(newLead.Id).Pardot_bearbetning_beh_vs__c &&
                    newLead.Pardot_bearbetning_beh_vs__c == true
                ) {
                    CampaignMember cmIN = new CampaignMember();
                    cmIN.Status = 'Anmäld';
                    cmIN.CampaignId = Label.CampaignIdtoInsertLead;
                    cmIN.LeadId = newLead.Id;
                    cmInsert.add(cmIN);
                } else if (
                    oldMap != null &&
                    newLead.Pardot_bearbetning_beh_vs__c != oldMap.get(newLead.Id).Pardot_bearbetning_beh_vs__c &&
                    oldMap.get(newLead.Id).Pardot_bearbetning_beh_vs__c == true
                ) {
                    deleteCM.add(newLead);
                }
            }
        }
        
        if (cmInsert.size() > 0) {
            Database.insert(cmInsert, false);
        }
        if (!deleteCM.isEmpty()) {
            CMDelete = [SELECT id, status FROM CampaignMember WHERE LeadId = :deleteCM AND campaignId = :Label.CampaignIdtoInsertLead];
        }
        if (CMdelete.size() > 0) {
            database.delete(CMDelete, false);
        }
    }

    /**@Description:
     * Logic to create task note on Buy Interest object from Lead object.
     * @param newList - List of the new versions of the Lead records.
     * @param oldMap - A map of IDs to the old versions of the Lead records.
     * Modifications:
     *  04.2022 [LS] SALEF-6483 - Introduced. 
     *  28.02.2023 [TB] SALEF-8276 - Optimized to avoid unnecessary queries.
     *  12.04.2023 [TB] SALEF-8573 - Task Status should be set to 'Stängd'.
     **/ 
    public static void createTaskInBuyInt(List < Lead > newList, Map < Id, Lead > oldMap) {
        Set<Id> LeadIDSet = new Set<Id>();
        List<Task> lsttsk = new List<Task>();
        for(Lead led : newList){
            if (led.Lead_Close_Reason__c != null && led.Lead_Close_Reason__c != '' && led.Lead_Close_Reason__c != oldMap.get(led.id).Lead_Close_Reason__c) {
                LeadIDSet.add(led.id);
            }
        }
        if(!LeadIDSet.isEmpty()){
            for (Buy_Interest__c buyInt : [
                SELECT Id, Name, lead__r.Status, lead__r.Lead_Close_Reason__c, lead__r.Other_reason__c
                                            FROM Buy_Interest__c
                                            WHERE Lead__c IN :LeadIDSet
            ]){
                Task objtask = new Task();
                objtask.WhatId = buyInt.id;
                objtask.Type = SEConstants.TASK_TYPE_TELEPHONE;
                objtask.Status = SEConstants.TASK_STATUS_CLOSED;
                objtask.Subject = System.Label.Return_LC;
                objtask.TaskSubtype = SEConstants.TASK_SUBTYPE_CALL;

                objtask.Description =
                    'lead status:' +
                    buyInt.lead__r.Status +
                    '\n Lead Close Reason: ' +
                    buyInt.lead__r.Lead_Close_Reason__c +
                    '\n Other Reason: ' +
                    buyInt.lead__r.Other_reason__c;

                lsttsk.add(objtask); 
            }
            if(lsttsk.size() > 0){
                IsExecuted = false;
                insert lsttsk;   
            }
        }
    }
}