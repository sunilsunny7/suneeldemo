global class ExtractandSendPriceAdjvalues implements vlocity_cmt.VlocityOpenInterface{
    
    
    public static String errorMessage = 'Something went Wrong';
    global Boolean invokeMethod(String methodName, map<String,Object> inputMap, map<String,Object> outputMap,map<String,Object> options){
        Boolean result= true;
        try{
            if(methodname.equalsignorecase('extractValues')){
                extractValues(inputMap,outputMap);
            }
           
            else if(methodname.equalsignorecase('sendTransformedJson')){
                    sendTransformedJson(inputMap,outputMap);
                }
            else if(methodname.equalsignorecase('transformedProductJson')){
                    transformedProductJson(inputMap,outputMap);//Modified Json for B2B solution
                }
        }
        catch(exception ex){
            system.debug('errorLineNumber'+ex.getLineNumber());
            system.debug('cause'+ex.getcause());
            system.debug('errorMessage'+ex.getmessage());
            result = false;   
        }     
        
        return result;
        
    }
    
    // Below method is invoked from Integration Procedure of Type=ConnectedOffice, Subtype=C2BAdjustmentPrices
    public static void extractValues(map<String,Object>input, map<String,Object> output){
        
        
        map<String,Object> frstMap = (map<String,Object>)input;
        List<Object> list1 = new List<Object>();
        if(frstMap.containskey('productOfferingCode')){
            list1 = (List<Object>)frstMap.get('productOfferingCode');//Input
        }
        List<Object> list2 = new List<Object>();   //from dataraptor ExtractPriceAdjustmentValues
        if(frstMap.containskey('adjPrices1')){
            list2 = (List<Object>)frstMap.get('adjPrices1');
        }
        List<Object> ol = new List<Object>(); // List will contain the Product Family Code,Price adjustment value,weightFactor,Errorcode
        Set<String> set1= new Set<String>(); 
        Set<String> set2 = new Set<String>();
        if(list1!=null && list1.size()>0 && list2!=null && list2.size()>0){
            for(Object obj1 : list1){
                map<String,Object> ob1 = (map<String,Object>)obj1;
                String pname = (String)ob1.get('productOfferingCode');
                String wf = (String)ob1.get('weightFactor');
                set1.add(wf);//adding weight factors coming from input in a set
                for(Object obj2 : list2){
                    map<String,Object> ob2 = (map<String,Object>)obj2;
                    Decimal value = (Decimal)ob2.get(pname);
                    String wf2 = (String)ob2.get('weightFactor');
                    map<String,Object> keymap =  new map<String,Object>();
                    for(Object ob3 : ob2.keyset()){
                        if(ob3==pname && wf==wf2){ // Comparing weightfactor from input matches with weight factor from Dataraptor
                            set2.add(wf2);// add the matching ones in another set
                            keymap.put('weightFactor',wf2);
                            keymap.put('priceAdjustmentValue',value);
                            keymap.put('productOfferingCode',pname);
                            keymap.put('errorCode','000');
                            ol.add(keymap);
                        }
                    }  
                }             
            }
            if(list1!=null && list1.size()>0){
                if(set1.containsAll(set2)){// check whether the set1 contains set2 values then remove which are there in set2 from set1
                    set1.removeall(set2);
                }
                for(Object obj1 : list1){
                    map<String,Object> ob1 = (map<String,Object>)obj1;
                    String pname = (String)ob1.get('productOfferingCode');
                    String wf = (String)ob1.get('weightFactor');
                    map<String,Object> keymap1 =  new map<String,Object>(); 
                    for(String objset : set1){
                        if(objset==wf){// Here we are comparing that the weight factor coming in input not present in the metdata and we use the set1 to return them in response with errocode 001
                            keymap1.put('weightFactor',objset);
                            keymap1.put('priceAdjustmentValue','');
                            keymap1.put('productOfferingCode',pname);
                            keymap1.put('errorCode','001');
                            ol.add(keymap1);
                        } 
                    }
                } 
            }        
            if(ol!=null && ol.size()>0){
                
                output.put('adjustmentPrices',ol);
                
            }
        }
        else{
            output.put('Error',errorMessage); 
        }
    }
    
    
    // Below method is invoked from Integration Procedure of Type=ConnectedOffice, Subtype=C2BServiceProductMapping
    
    public static void sendTransformedJson(map<String,Object>input, map<String,Object> output){
        
        map<String,Object> frstmap = (map<String,Object>)input;
        map<String,Object> secondmap =  new map<String,Object>();
        
        List<Object> newlist = new List<Object>();// List for BBSTART products
        List<Object> newlist1 = new List<Object>();// List for BBPLUS products
        List<Object> newlist2 = new List<Object>();// List for DATANET products
        List<Object> newlist3 = new List<Object>();// List for BBPRO products
        List<Object> newlist4 = new List<Object>();// List for BBPRO products
        List<Object> objlist = new List<Object>();
        if(frstmap.containskey('productOffering')){
            objlist = (List<Object>)frstmap.get('productOffering');// From DR DR_ExtractPriceAdjsutmentValues
            
        }
        if(objlist!=null && objlist.size()>0){
            for(Object plist: objlist){
                map<String,Object> map1 = (map<String,Object>)plist;    
                if(map1.get('productCode')!=null){
                    if(map1.get('productCode')=='CO-BBSTART'){
                        newlist.add(map1);
                        secondmap.put('bredbandStart',newlist);
                    }
                    else
                        if(map1.get('productCode')=='CO-BBPLUS'){
                            newlist1.add(map1);
                            secondmap.put('bredbandPlus',newlist1);
                        }
                    else
                        if(map1.get('productCode')=='CO-DATANET'){
                            newlist2.add(map1);
                            secondmap.put('datanet',newlist2);
                        }else
                            if(map1.get('productCode')=='CO-BBPRO'){
                                newlist3.add(map1);
                                secondmap.put('bredbandPro',newlist3);
                            }/*else
if(map1.get('productCode')=='CO_InternetAdvance'){
newlist4.add(map1);
secondmap.put('internetAdvanced',newlist4);
}*/
                }
            }
            output.put('productOffering',secondmap);
        }else{
            output.put('Error',errorMessage);
        }
    } 
    //	added to transform json for B2B Solution MCSTO-11639---Teena	
    public static void transformedProductJson(Map<String,Object>input, Map<String,Object> output){
        Map<String,Object> productOfferMap = (Map<String,Object>)input;
        Map<String,List<Object>> pMap = new Map<String,List<Object>>();
        List<Object> itemList = new List<Object>();
        List<Object> offeringList = new List<Object>();
        if(productOfferMap.containskey('productOffering')){
            itemList = (List<Object>)productOfferMap.get('productOffering');// From DR DR_ExtractPriceAdjsutmentValues    
        }
        if(itemList!=null && itemList.size()>0){
            for(Object pList: itemList){
                Map<String,Object> prodMap = (Map<String,Object>)pList;
                prodMap.put('accessCode',String.ValueOf(integer.valueOf(prodMap.get('accessCode'))));
                List<Object> prodList = new List<Object>();          
                String productName= String.valueOf(prodMap.get('productName'));  
                if(pMap.containsKey(productName)){
                    prodList = pMap.get(productName);                   
                }                
                prodList.add(prodMap);
                pMap.put(productName,prodList); 
                
            }
            for(String key: pMap.keyset()){
                Map<String,Object> productOfferingMap = new Map<String,Object>();
                productOfferingMap.put('category',key);
                productOfferingMap.put('productOfferings',pMap.get(key));
                offeringList.add(productOfferingMap);
            }
            output.put('productOffering',offeringList);
        }
    }
}