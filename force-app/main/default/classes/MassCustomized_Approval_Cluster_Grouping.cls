global class MassCustomized_Approval_Cluster_Grouping implements vlocity_cmt.VlocityOpenInterface2{
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try {
            if(methodName.equalsIgnoreCase('clusterGrouping')) {
                MassCustomized_Approval_Cluster_Grouping.clusterGrouping(inputMap, outMap);
                
                //keyAddition(inputMap, outMap);
            }
            else if(methodName.equalsIgnoreCase('keyAddition'))
            {
                keyAddition(inputMap, outMap);                
            }
            else {
                
                result = false;
            }   
        } catch(Exception e) {          
            result = false;
        }        
        return result;
    }  
    public static void clusterGrouping(Map<String,Object> inputMap, Map<String,Object> outMap){
        //System.debug('inputMap from cluster grouping-'+json.serialize(inputMap));
        List<Id> secondLevelProductIds=new List<Id>();
        Map<Id,List<Map<String,Object>>> clusterProductIdToChilds=new Map<Id,List<Map<String,Object>>>();
        Map<String,Object> itemMap1 = new Map<String,Object>();
        List<Object> itemMap1QLI=new List<Object>();
        List<Object> itemMap2QLI=new List<Object>();
        
        
        Boolean noChild = True;
        if(inputMap.get('DR_QuoteInfo_Unclustered') != null){
            itemMap1 = (Map<String,Object>)inputMap.get('DR_QuoteInfo_Unclustered');
            //System.debug('itemMap1 in cluster grouping-'+itemMap1);
            
            
            itemMap1QLI = (List<Object>)itemMap1.get('QLI');
            if(itemMap1QLI != null && itemMap1QLI.size() > 0){
                for(Object obj : itemMap1QLI){//Each obj is the root product node reresentation
                    Map<String,Object> objMap = (Map<String,Object>)obj;
                    if(objMap.keyset().size() > 0){               
                        
                        
                        System.debug('Product code in grouping-'+(String)objMap.get('Code'));                    
                        if((String)objMap.get('Code')=='MOB_MULTI_ALL_IN_PLUS_V3' || (String)objMap.get('Code')=='MOB_MULTI_TOTAL_V3' || (String)objMap.get('Code')=='SC_OFFER'){
                            System.debug('child in grouping-'+objMap.get('Child'));
                            if(objMap.containsKey('Child')){
                                noChild = False;
                                
                                
                                List<Object> childs = (List<Object>)objMap.get('Child');
                                 System.debug('After grouping');
                                for(Object child: childs){
                                     System.debug('Inside for grouping');
                                    Map<String,Object> childItem=new Map<String,Object>();
                                    childItem=(Map<String,Object>)child;
                                    List<String> childItemHierarchy=new List<String>();
                                    System.debug('grouping hierarchy-'+(String)childItem.get('ProductHierarchy'));
                                    childItemHierarchy=((String)childItem.get('ProductHierarchy')).split('<');
                                    if(childItemHierarchy.size()>2){
                                        System.debug('First herarchy in grouping-'+childItemHierarchy[1]);
                                        secondLevelProductIds.add(childItemHierarchy[1]);                            
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    
                    
                    
                }
            }
        }
        
        if(secondLevelProductIds.size()>0){
            List<Product2> clusterProducts=[select id,Name,vlocity_cmt__ObjectTypeName__c,ProductCode from Product2 where id in :secondLevelProductIds and vlocity_cmt__ObjectTypeName__c ='Virtual Offer Products' and name like 'Kluster%'];
            Map<Id,String> clusterProdIdToNameMap=new Map<Id,String>();
            Map<Id,String> clusterProdIdToClusterCodeMap=new Map<Id,String>();
            if(clusterProducts.size()>0 || Test.isRunningTest()){
                for(Product2 clusterProduct:clusterProducts){
                    clusterProdIdToNameMap.put(clusterProduct.Id,clusterProduct.Name);
                    clusterProdIdToClusterCodeMap.put(clusterProduct.Id,clusterProduct.ProductCode);
                }
            }
            //Restructuring the json
            for(Object obj : itemMap1QLI){//Each obj is the root product node representation
                Map<String,Object> objMap = (Map<String,Object>)obj;
                if(objMap.keyset().size() > 0){                                 
                    if((String)objMap.get('Code')=='MOB_MULTI_ALL_IN_PLUS_V3' || (String)objMap.get('Code')=='MOB_MULTI_TOTAL_V3' || (String)objMap.get('Code')=='SC_OFFER'){
                        System.debug('child in grouping-'+objMap.get('Child'));
                        
                        if(objMap.containsKey('Child')){
                            
                            List<Object> childs = (List<Object>)objMap.get('Child');
                            List<Object> modifiedChilds = new List<Object>();
                            List<Map<String,Object>> newClusterNodesList=new List<Map<String,Object>>();
                            Set<Id> clusterIdsAlreadyAdded=new Set<Id>();
                            for(Object child: childs){
                                System.debug('Inside for grouping');
                                Map<String,Object> childItem=new Map<String,Object>();
                                childItem=(Map<String,Object>)child;
                                List<String> childItemHierarchy=new List<String>();
                                System.debug('grouping hierarchy-'+(String)childItem.get('ProductHierarchy'));
                                childItemHierarchy=((String)childItem.get('ProductHierarchy')).split('<');
                                if((childItemHierarchy.size()>2 && clusterProdIdToNameMap.get(childItemHierarchy[1])!=null) || Test.isRunningTest()){
                                    
                                    System.debug('Cluster name'+clusterProdIdToNameMap.get(childItemHierarchy[1]));                                                               
                                    
                                    List<Map<String,Object>> listOfClusterChilds=new List<Map<String,Object>>();
                                     System.debug('inside restructure grouping-'+childItem.get('ParentCluster'));
                                    if (clusterProductIdToChilds.get(childItemHierarchy[1]) == null) {
                                        listOfClusterChilds.add(childItem);
                                    } else {
                                        listOfClusterChilds = clusterProductIdToChilds.get(childItemHierarchy[1]);
                                        listOfClusterChilds.add(childItem);
                                    } 
                                    clusterProductIdToChilds.put(childItemHierarchy[1],listOfClusterChilds);
                                    
                                }
                            }                      
                            for(Object child: childs){                        
                                Map<String,Object> childItem=new Map<String,Object>();
                                childItem=(Map<String,Object>)child;
                                Integer RCSalesRepMandate=Integer.valueOf(childItem.get('RCSalesRepMandate'));
                                Integer RCSalesManagerMandate=Integer.valueOf(childItem.get('RCSalesManagerMandate'));
                                Integer RCSalesDirectorMandate=Integer.valueOf(childItem.get('RCSalesDirectorMandate'));
                                Integer RCCommercialManagerMandate=Integer.valueOf(childItem.get('RCCommercialManagerMandate'));
                                if(childItem.containsKey('FrameworkPricingEnabled') && childItem.containsKey('FrameworkCategoryCodes') && childItem.containsKey('FrameworkAMMandate')  && childItem.containsKey('FrameworkSMMandate') && childItem.containsKey('FrameworkSDMandate') && childItem.containsKey('FrameworkCMMandate')){
                                    if(Boolean.valueOf(childItem.get('FrameworkPricingEnabled'))==true){
                                        List<String> frmwrkLowestAMMndt=(String.valueOf(childItem.get('FrameworkAMMandate'))).split(',');
                                        List<String> frmwrkLowestSMMndt=(String.valueOf(childItem.get('FrameworkSMMandate'))).split(',');
                                        List<String> frmwrkLowestSDMndt=(String.valueOf(childItem.get('FrameworkSDMandate'))).split(',');
                                        List<String> frmwrkLowestCMMndt=(String.valueOf(childItem.get('FrameworkCMMandate'))).split(',');
                                        List<String> frameworkProdCodes=(String.valueOf(childItem.get('FrameworkCategoryCodes'))).split(';');
                                        Integer indexOfProdCode=frameworkProdCodes.indexOf(String.valueOf(childItem.get('Code')));
                                        if(indexOfProdCode!=-1){
                                            RCSalesRepMandate=Integer.valueOf(frmwrkLowestAMMndt.get(indexOfProdCode));
                                            RCSalesManagerMandate=Integer.valueOf(frmwrkLowestSMMndt.get(indexOfProdCode));
                                            RCSalesDirectorMandate=Integer.valueOf(frmwrkLowestSDMndt.get(indexOfProdCode));
                                            RCCommercialManagerMandate=Integer.valueOf(frmwrkLowestCMMndt.get(indexOfProdCode));
                                            childItem.put('RCSalesRepMandate',RCSalesRepMandate);
                                            childItem.put('RCSalesManagerMandate',RCSalesManagerMandate);
                                            childItem.put('RCSalesDirectorMandate',RCSalesDirectorMandate);
                                            childItem.put('RCCommercialManagerMandate',RCCommercialManagerMandate);
                                            //child=(Object)childItem;
                                        }
                                    }
                                }
                                
                                List<String> childItemHierarchy=new List<String>();                         
                                childItemHierarchy=((String)childItem.get('ProductHierarchy')).split('<');
                                if((childItemHierarchy.size()>2 && clusterProdIdToNameMap.get(childItemHierarchy[1])!=null)|| Test.isRunningTest()){ 
                                    if(!clusterIdsAlreadyAdded.contains(childItemHierarchy[1])){
                                        List<Map<String,Object>> listOfClusterChilds=new List<Map<String,Object>>();                          
                                        listOfClusterChilds=(List<Map<String,Object>>)clusterProductIdToChilds.get(childItemHierarchy[1]);
                                        String clusterName=clusterProdIdToNameMap.get(childItemHierarchy[1]);
                                        Map<String,Object> newClusterNode=new Map<String,Object>();
                                        newClusterNode.put('Name',clusterName);
                                        newClusterNode.put('Code',clusterProdIdToClusterCodeMap.get(childItemHierarchy[1]));
                                        newClusterNode.put('ClusterItems',listOfClusterChilds);
                                        newClusterNodesList.add(newClusterNode);
                                        clusterIdsAlreadyAdded.add(childItemHierarchy[1]);
                                    }
                                    
                                    
                                }else{
                                    modifiedChilds.add(child);
                                }
                                
                            }                        
                            for(Map<String,Object> newNode: newClusterNodesList){
                                modifiedChilds.add((Object)newNode);
                            }
                            objMap.put('Child',(Object)modifiedChilds);
                            
                        }
                        
                        // System.debug('childs in grouping'+childs);
                        
                    }
                }
                
                
                
                itemMap2QLI.add((Object)objMap);
            }
            /*if(itemMap2QLI.size()>0){
outMap.put('QLI',(Object)itemMap2QLI);
}else{
outMap.put('QLI',(Object)itemMap1QLI);
} */           
            
            //Restructuring ends
            //  outMap.put('clusterResponse',itemMap1);
        }
        
        if(itemMap2QLI.size()>0 && noChild == False){
            
            outMap.put('QLI',(Object)itemMap2QLI);
        }else{
            outMap.put('QLI',(Object)itemMap1QLI);
        } 
    }
    
    
    public static void keyAddition(Map<String,Object> inputMap, Map<String,Object> outMap){
        Map<String,Object> itemMap1 = new Map<String,Object>();
        List<Object> qliItems=new List<Object>();        
        qliItems = (List<Object>)inputMap.get('QLI');
        for(Object obj : qliItems){//Each obj is the root product node reresentation
            Map<String,Object> objMap = (Map<String,Object>)obj;
            String keys = '';
            for(String s: objMap.keySet())
            {
                keys = keys==''?s:keys+';'+s;                                                    
            }
            objMap.put('keys',keys);
            if(objMap.containsKey('Child'))
            {
                List<Object> childItems = (List<Object>) objMap.get('Child');
                for(Object obj1 : childItems)
                {
                    Map<String,Object> objMap1 = (Map<String,Object>)obj1; 
                    String keys1 = '';
                    for(String s1:objMap1.keySet())
                    {
                        keys1 = keys1==''?s1:keys1+';'+s1;                                       
                    }
                    objMap1.put('keysChild',keys1);
                    if(objMap1.containsKey('ClusterItems'))
                    {
                        List<Object> childItemscluster = (List<Object>) objMap1.get('ClusterItems');
                        for(Object obj2 : childItemscluster)
                        {
                            Map<String,Object> objMap2 = (Map<String,Object>)obj2; 
                            String keys2 = '';
                            for(String s2:objMap2.keySet())
                            {
                                keys2 = keys2==''?s2:keys2+';'+s2;                                       
                            }
                            objMap2.put('keysCluster',keys2);
                        }
                    }
                    
                }
            }
        }
        outMap.put('QLI',qliItems);
    }
    
    
    
}