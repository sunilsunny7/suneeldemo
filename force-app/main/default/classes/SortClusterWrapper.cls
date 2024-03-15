/**
* @Author:      Aditi Goyal
* @Company:     Capgemini
* @Date:        28-Feb-2022
* @Description: This wrapper class is used to sort Smart Connect QLIs based on the clusters
* ----------------------------------------------------------------------------------------------------------------------------------------------
*/

public class SortClusterWrapper implements Comparable{
    public String clusterCode,name;
    public Double price;
    
    public SortClusterWrapper(QuoteLineItem qli){
        this.name = qli.vlocity_cmt__Product2Id__r.Name;
        this.clusterCode = qli.TeliaSE_ParentClusterCode__c !=null && qli.TeliaSE_ParentClusterCode__c.contains('SC_KLU')?qli.TeliaSE_ParentClusterCode__c.remove('SC_KLU_'):qli.TeliaSE_ParentClusterCode__c;
		this.price = qli.TeliaSE_MC_Customer_Requested_Price__c != null ?qli.TeliaSE_MC_Customer_Requested_Price__c:qli.TeliaSE_Target_Price__c;       
    }
    
    public Integer compareTo(Object compareTo){
        //List<String> orderedClusters = new List<String>{'BAS','SMALL','MEDIUM','LARGE','XLARGE','PLUS','LEGACY'};//default cluster order
        List<String> orderedClusters = new List<String>{'PLUS','XLARGE','LARGE','MEDIUM','SMALL','BAS'};//descending cluster order (MCSTO-10724(23.3))
        
        SortClusterWrapper sortWrapper = (SortClusterWrapper)compareTo;
        String compareClusterCode = sortWrapper.clusterCode;
        if (orderedClusters.contains(clusterCode) && orderedClusters.contains(compareClusterCode)){
            // Both objects are in our ordered list. Compare them by their position in the list
            return orderedClusters.indexOf(clusterCode) - orderedClusters.indexOf(compareClusterCode);
        }
        /*if (orderedClusters.contains(clusterCode)){
            // o1 is in the ordered list, but o2 isn't. o1 is smaller (i.e. first)
            return -1;
        }
        if (orderedClusters.contains(compareClusterCode)){
            // o2 is in the ordered list, but o1 isn't. o2 is smaller (i.e. first)
            return 1;
        }*/  
        return 0;
    }
}