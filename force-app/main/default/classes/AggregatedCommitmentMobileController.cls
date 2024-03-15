public class AggregatedCommitmentMobileController {
	public final Account acc;
	public Map<String, AggregatedWrapper> GetAggregatedData { get { return aggregatedData; } }
	public String SelectedLevelOneCategory { get; set; }
	private Map<String, AggregatedWrapper> aggregatedData;
	public Boolean loaded { get; set; }

    public AggregatedCommitmentMobileController(ApexPages.StandardController stdController) {
		//Get C2B_Org_nr__c field because the StandardController only returns ID
		this.loaded = false;
		Id accId = stdController.getRecord().Id;
		this.acc = [SELECT Id,C2B_Org_nr__c FROM Account WHERE Id = :accId limit 1][0];		   	
    }

	public void loadData(){    
		aggregatedData = getAggregatedData();
		this.loaded = true;
	}

	public Map<String, AggregatedWrapper> getAggregatedData(){
		//Check if C2B_Org_nr__c is set because we need it to query external objects
		if(this.acc.C2B_Org_nr__c == null) return null;

		Map<String, AggregatedWrapper> levelOneMap = new Map<String, AggregatedWrapper>();
		
		//Aggretating the functionsubs based on category 
		for(mobilesubscriptions__x subs : [SELECT category__c, offeringname__c, commitmentenddate__c
                FROM mobilesubscriptions__x WHERE customeridentificationnumber__c = :this.acc.C2B_Org_nr__c]){		
			String levelOneHash = String.valueOf(subs.category__c.hashCode());
			String levelTwoHash = String.valueOf(subs.offeringname__c.hashCode());
			Datetime commitEndTime = null;

			//We set the time interval here
			if(subs.commitmentenddate__c != null){
				Integer year = Integer.valueOf(subs.commitmentenddate__c.substring(0,4));
				Integer month = Integer.valueOf(subs.commitmentenddate__c.substring(4,6));
				Integer day = Integer.valueOf(subs.commitmentenddate__c.substring(6,8));
				commitEndTime = Datetime.newInstance(year,month,day);
			}
				
			Datetime shortTime = Datetime.now().addMonths(4);
			Datetime medTime = Datetime.now().addMonths(6);
			//If levelOne already has the category, we aggregate and go levelTwo
			if(levelOneMap.containsKey(levelOneHash)){	
				levelOneMap.get(levelOneHash).Count++;
				//Aggregate Date
				AggregateCommitmentDate(shortTime, medTime, commitEndTime, levelOneMap.get(levelOneHash));	
				//Check if the levelTwo contains the offering name, if so we aggregate
				if(levelOneMap.get(levelOneHash).NextLevelMap.containsKey(levelTwoHash)){			
					levelOneMap.get(levelOneHash).NextLevelMap.get(levelTwoHash).Count++;
					AggregateCommitmentDate(shortTime, medTime, commitEndTime, levelOneMap.get(levelOneHash).NextLevelMap.get(levelTwoHash));								
				} else {		
					AggregatedWrapper aggrLevelTwo = new AggregatedWrapper(subs.offeringname__c, 1, null, false);
					AggregateCommitmentDate(shortTime, medTime, commitEndTime, aggrLevelTwo);
					levelOneMap.get(levelOneHash).NextLevelMap.put(levelTwoHash, aggrLevelTwo);					
				}
			} else {		
				Map<String, AggregatedWrapper> levelTwoMap = new Map<String, AggregatedWrapper>();	

				AggregatedWrapper aggrLevelTwo = new AggregatedWrapper(subs.offeringname__c, 1, null, false);
				AggregateCommitmentDate(shortTime, medTime, commitEndTime, aggrLevelTwo);
				levelTwoMap.put(levelTwoHash, aggrLevelTwo);	
		
				AggregatedWrapper aggrLevelOne = new AggregatedWrapper(subs.category__c, 1, levelTwoMap, false);
				AggregateCommitmentDate(shortTime, medTime, commitEndTime, aggrLevelOne);
				levelOneMap.put(levelOneHash, aggrLevelOne);
			}	
		}
		return levelOneMap;
	}

	public void AggregateCommitmentDate(Datetime shortTime, Datetime medTime, Datetime commitEndTime, AggregatedWrapper aw){
		if(commitEndTime == null || commitEndTime <= shortTime ){
			aw.ShortTimeLeft++;
		}else if(commitEndTime > shortTime  && commitEndTime <= medTime){
			aw.MediumTimeLeft++;
		}
	}

	public void ExpandLevelOne(){
		aggregatedData.get(selectedLevelOneCategory).Expanded = !aggregatedData.get(selectedLevelOneCategory).Expanded;		
	}

	//Our Aggregated Broadband Service wrapper
	public class AggregatedWrapper{
		public Map<String, AggregatedWrapper> NextLevelMap { get; set;}
		public String Category { get; set;}
		public Integer Count { get; set;}
		public Integer ShortTimeLeft { get; set;}
		public Integer MediumTimeLeft { get; set;}
		public Integer PagingKey { get; set;}
		public Boolean Expanded { get; set;}

		public AggregatedWrapper(String cat, Integer count, Map<String, AggregatedWrapper> nextLvlMap, Boolean exp){
			this.Category = cat;
			this.Count = count;
			this.NextLevelMap = nextLvlMap;
			this.Expanded = exp;
			this.PagingKey = 0;
			this.ShortTimeLeft = 0;
			this.MediumTimeLeft = 0;
		}
	}
 }