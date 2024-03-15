public class AggregatedBroadbandServiceController {
    public final Account acc;
    public Map<String, AggregatedWrapper> getAggregatedData { get { return aggregatedData; } }
    private Map<String, AggregatedWrapper> aggregatedData;
    public String selectedLevelOneCategory { get; set; }
    public Boolean loaded { get; set; }

    public AggregatedBroadbandServiceController(ApexPages.StandardController stdController) {
        //Get C2B_Org_nr__c field because the StandardController only returns ID
        this.loaded = false;
        Id accId = stdController.getRecord().Id;
        this.acc = [SELECT Id, C2B_Org_nr__c FROM Account WHERE Id = :accId limit 1][0];            
    }

    public void loadData(){
        aggregatedData = getAggregatedData();
        this.loaded = true;
    }

    public Map<String, AggregatedWrapper> getAggregatedData(){
        //Check if C2B_Org_nr__c is set because we need it to query external objects
        if(this.acc.C2B_Org_nr__c == null) return null;
        
        
        List<broadbandsubscriptions__x> listofsubs =[SELECT category__c, offeringname__c
                FROM broadbandsubscriptions__x 
                WHERE customeridentificationnumber__c = :this.acc.C2B_Org_nr__c];   
                
         if(test.isRunningTest()){
         if(listofsubs.size() ==0){
           listofsubs.add(Test_DataFactory.MockRequestDataCreationBS());
         }
         }  

        Map<String, AggregatedWrapper> levelOneMap = new Map<String, AggregatedWrapper>();  
        //Aggretating the functionsubs based on category         
        for(broadbandsubscriptions__x subs : listofsubs){     
            String levelOneHash = String.valueOf(subs.category__c.hashCode());
            String levelTwoHash = String.valueOf(subs.offeringname__c.hashCode());
            //If levelOne already has the category, we aggregate and go levelTwo
            if(levelOneMap.containsKey(levelOneHash)){  
                levelOneMap.get(levelOneHash).Count++;
                //Check if the levelTwo contains the offering name, if so we aggregate
                if(levelOneMap.get(levelOneHash).NextLevelMap.containsKey(levelTwoHash)){
                    //We generate the paging key and aggregate the count
                    levelOneMap.get(levelOneHash).NextLevelMap.get(levelTwoHash).Count++;               
                } else {
                    AggregatedWrapper aggrLevelTwo = new AggregatedWrapper(subs.offeringname__c, 1, null, false);
                    levelOneMap.get(levelOneHash).NextLevelMap.put(levelTwoHash, aggrLevelTwo);                 
                }
            } else {
                //We create the levelOne and levelTwo aggregatedWrapper and connect them
                Map<String, AggregatedWrapper> levelTwoMap = new Map<String, AggregatedWrapper>();  
                AggregatedWrapper aggrLevelTwo = new AggregatedWrapper(subs.offeringname__c, 1, null, false);
                levelTwoMap.put(levelTwoHash, aggrLevelTwo);    

                AggregatedWrapper aggrLevelOne = new AggregatedWrapper(subs.category__c, 1, levelTwoMap, false);
                levelOneMap.put(levelOneHash, aggrLevelOne);
            }   
        }

        return levelOneMap;
    }

    public void ExpandLevelOne(){
        aggregatedData.get(selectedLevelOneCategory).Expanded = !aggregatedData.get(selectedLevelOneCategory).Expanded;     
    }

    //Our Aggregated Broadband Service wrapper
    public class AggregatedWrapper{
        public Map<String, AggregatedWrapper> NextLevelMap { get; set;}
        public String Category { get; set;}
        public Integer Count { get; set;}
        public Integer PagingKey { get; set;}
        public Boolean Expanded { get; set;}

        public AggregatedWrapper(String cat, Integer count, Map<String, AggregatedWrapper> nextLvlMap, Boolean exp){
            this.Category = cat;
            this.Count = count;
            this.NextLevelMap = nextLvlMap;
            this.Expanded = exp;
            this.PagingKey = 0;
        }
    }
 }