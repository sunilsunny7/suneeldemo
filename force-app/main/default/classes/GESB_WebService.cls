/**
    About
    -----
    Description: GESB_WebService
    Create date: November 2016

    Update History
    --------------
    Created Oct 2016 - A.N - Created. New method getLeadStatus. This is called by Tholbox via GESB to get the status of leads. SAEN-1881
	Updated January 2017 - V.M - Updated the logic so it applies to Buy Interest instead of Leads.
            
    Issues / TODOs
    --------------     
*/

global class GESB_WebService {

	@testvisible private static final String ERR_INVALID_ID = 'No or invalid retailerID provided.';
	@testvisible private static final String ERR_NO_LEADS = 'No leads found in Salesforce for the input request parameters.';

	webservice static LeadStatusResponse getLeadStatus(LeadStatusRequest request){
		System.debug('GESB_WebService.getLeadStatus running. request: ' + request);
		LeadStatusResponse response = new LeadStatusResponse();

		if(request.startDate != null) System.debug('request.startDate is ' +  request.startDate + 'and formatGMT date is: ' + request.startDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
		if(request.endDate != null) System.debug('request.endDate is ' +  request.endDate + 'and formatGMT date is: ' + request.endDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
		
		/* Build up the query string */
		String query = 'SELECT Id, Status__c, Opportunity__r.StageName, Opportunity__r.IsClosed, Opportunity__r.IsWon, Owner.Name, CreatedDate, Buy_Interest_Submitter__r.Reseller_Tholbox_ID__c, Buy_Interest_Submitter__r.Account.Telia_Reseller_Id__c, Lead__r.Lead_No__c, Lead__r.Time_to_first_contact__c, Lead__r.Org_nr__c, Lead__r.Company FROM Buy_Interest__c WHERE';
		// Check if required parameter retailerID is provided
		if(String.isEmpty(request.retailerID)) return getLeadStatusErrorResponse(ERR_INVALID_ID);
		else query += ' Buy_Interest_Submitter__r.Account.Telia_Reseller_Id__c = \'' + String.escapeSingleQuotes(request.retailerID) + '\'';
		// Add optional parameters to query string if provided
		if(!String.isEmpty(request.retailerUserId)) query += ' AND Buy_Interest_Submitter__r.Reseller_Tholbox_ID__c = \'' + String.escapeSingleQuotes(request.retailerUserId) + '\'';
		if(request.startDate != null) query += ' AND CreatedDate >= ' + request.startDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
		if(request.endDate != null)	query += ' AND CreatedDate <= ' + request.endDate.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'');
		// Sort by created date with newest on top
		query += ' ORDER BY CreatedDate DESC LIMIT ';
		if(request.maxRows != null && request.maxRows > 0) query += String.escapeSingleQuotes(String.valueOf(request.maxRows));
		else query += '500';
		System.debug('GESB_WebService.getLeadStatus query string is : ' + query);

		try{
			Map<Id, Buy_Interest__c> biMap = new Map<Id, Buy_Interest__c>();
            for(Buy_Interest__c bi : Database.query(query)){
                biMap.put(bi.Id, bi);
            }
			System.debug('biMap: ');
            System.debug(biMap);
			if(biMap.isEmpty()) return getLeadStatusErrorResponse('No leads found in Salesforce for the input request parameters.');
			else{
				//Buy Interest Id
                Map<Id, List<OpportunityLineItem>> oliMap = new Map<Id, List<OpportunityLineItem>>();
                
                    for(OpportunityLineItem oli : [SELECT Buy_Interest__c FROM OpportunityLineItem WHERE Buy_Interest__c IN :biMap.keySet()]){
                        if(oliMap.get(oli.Buy_Interest__c) != null){
                              oliMap.get(oli.Buy_Interest__c).add(oli);    
                        }else{
                            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                            oliList.add(oli);
                            oliMap.put(oli.Buy_Interest__c, oliList);
                        }
                  
                    }
                
                response.success = true;
                response.numberOfRows = biMap.size();
                response.leadStatusList = new List<LeadStatus>();
                for(Buy_Interest__c bi : biMap.values()) {
                    response.leadStatusList.add(new LeadStatus(bi, oliMap.get(bi.Id)));
                }
			}
		} catch (Exception e){
            	System.debug('------exception: ');
            System.debug(e);
			return getLeadStatusErrorResponse(e.getMessage());
		}

		return response;
	}

	private static LeadStatusResponse getLeadStatusErrorResponse(String errorMessage){
		LeadStatusResponse response = new LeadStatusResponse();
		response.success = false;
		response.errorMsg = errorMessage;
		response.numberOfRows = 0;
		return response;		
	}

	global class LeadStatusRequest{
		webservice String retailerID; // ÅF Number
		webservice String retailerUserId; // TholboxId
		webservice DateTime startDate; // Search for leads created >= this date. System default is 180 days back in time. 
		webservice DateTime endDate; // Search for leads created <= this date.
		webservice Integer maxRows; // Max number of rows in the replay. System default is to be 500 rows.
	}

	global class LeadStatusResponse{
		webservice List<LeadStatus> leadStatusList;
		webservice Integer numberOfRows;
		webservice Boolean success;
		webservice String errorMsg;
	}

	global class LeadStatus{
		webservice String retailerID; // ÅF Number
		webservice String retailerUserId; // Tholbox id
		webservice String leadId; // The unique lead id, i.e. SF id
		webservice DateTime leadCreationDate; // The date the lead was created
		webservice DateTime leadInitialActivityDate; // The data when some one at Telia picks up the lead and starts working on it. 
		webservice String customerOrgNr; // 10 digits orgnr
		webservice String customerName; // Customer name/SF account.name
		webservice String leadStatus; // Status of the lead/oportunity
		webservice String leadOwnerName; // The current owner of the lead
		
		public LeadStatus(Buy_Interest__c bi, List<OpportunityLineItem> oliList ) {
            this.retailerID = bi.Buy_Interest_Submitter__r.Account.Telia_Reseller_Id__c;
            this.retailerUserId = bi.Buy_Interest_Submitter__r.Reseller_Tholbox_ID__c;
          	this.leadId = bi.Id; //bi.Lead__r.Lead_No__c;
            this.leadCreationDate = bi.CreatedDate;
          	this.leadInitialActivityDate = bi.Lead__r.Time_to_first_contact__c;
          	this.customerOrgNr = bi.Lead__r.Org_nr__c;
         	this.customerName = bi.Lead__r.Company;
            this.leadOwnerName = bi.Owner.Name;

            //If there is no product generated, we use the Buy Interest Status, else Opp Stage.
            if(oliList == null && bi.Opportunity__r.IsClosed){
                this.leadStatus = System.Label.GESB_Closed;
            }else if(oliList != null ){
                this.leadStatus = bi.Opportunity__r.StageName;
            }else{
                 this.leadStatus = bi.Status__c;
            }

        }
	}
}