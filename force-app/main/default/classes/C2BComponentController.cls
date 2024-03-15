public class C2BComponentController {
    
    public static Account Record {get; set;}

    public class C2BGenericWrapper{    
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String Amount {get; set;}
    }
    
    public C2BComponentController(){
        String parameter = ApexPages.currentPage().getParameters().get('accId');
        if(parameter != null){
            Record = [SELECT Id, Name, RecordType.Name FROM Account WHERE Id = :parameter LIMIT 1];
        }
    }
    
    @AuraEnabled
    public static String getOrgNumber(String accountId){
        Account acc = [SELECT Org_nr__c FROM Account WHERE ID = :accountId LIMIT 1];
        return String.ValueOf(acc.Org_nr__c);
    }
    
    @AuraEnabled
    public static List<C2BGenericWrapper> getMobSubCategory(String orgnumber){
        List<C2BGenericWrapper> gwList = new List<C2BGenericWrapper>();
        for(mobilesubscriptions_aggregation__x xObj :[SELECT customeridentificationnumber__c, category__c, category_count__c FROM mobilesubscriptions_aggregation__x WHERE customeridentificationnumber__c = :orgnumber]){
            C2BGenericWrapper gw = new C2BGenericWrapper();
            gw.Name = xObj.category__c;
            gw.Amount = xObj.category_count__c;
            gwList.add(gw); 
        }     
        
        return gwList;
    }
    
    @AuraEnabled
    public static List<C2BGenericWrapper> getMobSubOffering(String orgnumber, String category){
        List<C2BGenericWrapper> gwList = new List<C2BGenericWrapper>();
        
            System.debug(orgnumber);
          System.debug(category);
        for(mobilesubscriptions_aggregation__x xObj :[SELECT category__c,  category_count__c, offeringname__c, offeringname_count__c FROM mobilesubscriptions_aggregation__x WHERE customeridentificationnumber__c = :orgnumber]){
            if(xObj.category__c == category){
                C2BGenericWrapper gw = new C2BGenericWrapper();
                gw.Name = xObj.offeringname__c;
                gw.Amount = xObj.offeringname_count__c;
                gwList.add(gw);
                
            }
        }    
        System.debug(gwList);
        return gwList;
    }
    
    @AuraEnabled
    public static List<C2BGenericWrapper> getBroadbandCategory(String orgnumber){
        List<C2BGenericWrapper> gwList = new List<C2BGenericWrapper>();
        for(broadbandsubscriptions_aggregation__x xObj :[SELECT customeridentificationnumber__c, category__c, category_count__c FROM broadbandsubscriptions_aggregation__x WHERE customeridentificationnumber__c = :orgnumber]){
            C2BGenericWrapper gw = new C2BGenericWrapper();
            gw.Name = xObj.category__c;
            gw.Amount = xObj.category_count__c;
            gwList.add(gw);
        }
        System.debug(gwList);
        return gwList;
    }
    
    @AuraEnabled
    public static List<C2BGenericWrapper> getBroadbandOffering(String orgnumber, String category){
        List<C2BGenericWrapper> gwList = new List<C2BGenericWrapper>();       
        for(broadbandsubscriptions_aggregation__x xObj :[SELECT category__c,  category_count__c, offeringname__c, offeringname_count__c FROM broadbandsubscriptions_aggregation__x WHERE customeridentificationnumber__c = :orgnumber]){
            if(xObj.category__c == category){
                C2BGenericWrapper gw = new C2BGenericWrapper();
                gw.Name = xObj.offeringname__c;
                gw.Amount = xObj.offeringname_count__c;
                gwList.add(gw);
            }
        }    
        
        return gwList;
    }
    
    
    @AuraEnabled
    public static List<C2BGenericWrapper> getFunctionCategory(String orgnumber){       
        List<C2BGenericWrapper> gwList = new List<C2BGenericWrapper>();
        for(functionsubscriptions_aggregation__x xObj :[SELECT customeridentificationnumber__c, category__c, category_count__c FROM functionsubscriptions_aggregation__x WHERE customeridentificationnumber__c = :orgnumber]){
            C2BGenericWrapper gw = new C2BGenericWrapper();
            gw.Name = xObj.category__c;
            gw.Amount = xObj.category_count__c;
            gwList.add(gw); 
        }      
        return gwList;
    }
    
    @AuraEnabled
    public static List<C2BGenericWrapper> getFunctionOffering(String orgnumber, String category){        
        List<C2BGenericWrapper> gwList = new List<C2BGenericWrapper>();
        for(functionsubscriptions_aggregation__x xObj :[SELECT category__c,  category_count__c, offeringname__c, offeringname_count__c FROM functionsubscriptions_aggregation__x WHERE customeridentificationnumber__c = :orgnumber]){
            if(xObj.category__c == category){
                C2BGenericWrapper gw = new C2BGenericWrapper();
                gw.Name = xObj.offeringname__c;
                gw.Amount = xObj.offeringname_count__c;
                gwList.add(gw);
                
            }
        }        
        return gwList;
    }
    
}