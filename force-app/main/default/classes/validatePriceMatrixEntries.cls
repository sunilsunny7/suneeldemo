global class validatePriceMatrixEntries Implements Schedulable{ 
    
    global void execute(SchedulableContext sc) 
    {
        validate();
    }
    
    @future(callout=true)
    public static void validate(){
        Map<String,Object> inputData24 = new Map<String,Object>();
        Map<String,Object> inputData36 = new Map<String,Object>();
        List<vlocity_cmt__ProductChildItem__c> activeHardware = [select id,vlocity_cmt__ParentProductId__r.ProductCode ,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.Name from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.C2BC_Category__c ='HW Bundle' and vlocity_cmt__ChildProductId__r.C2BC_Subcategory__c ='mobiledevice' and vlocity_cmt__ChildProductId__r.IsActive =true and vlocity_cmt__ChildProductId__r.vlocity_cmt__Status__c ='Active' and vlocity_cmt__ParentProductId__r.Family ='Online Order'];
        List < PricematrixRanges__c > ranges = PricematrixRanges__c.getall().values();
        Integer rangeCount = ranges.size();
        system.debug('rangeCount - '+rangeCount);
        String version24 = [select id,Name,vlocity_cmt__CalculationMatrixId__r.Name,vlocity_cmt__VersionNumber__c from vlocity_cmt__CalculationMatrixVersion__c where vlocity_cmt__CalculationMatrixId__r.Name = 'PriceMatrix_24M_Hardware' order by vlocity_cmt__VersionNumber__c desc limit 1].Name;
        String version36 = [select id,Name,vlocity_cmt__CalculationMatrixId__r.Name,vlocity_cmt__VersionNumber__c from vlocity_cmt__CalculationMatrixVersion__c where vlocity_cmt__CalculationMatrixId__r.Name = 'PriceMatrix_36M_Hardware' order by vlocity_cmt__VersionNumber__c desc limit 1].Name;
        List<vlocity_cmt__CalculationMatrixRow__c> matrixData24 = [select id,vlocity_cmt__CalculationMatrixVersionId__r.Name,vlocity_cmt__OutputData__c,vlocity_cmt__InputData__c from vlocity_cmt__CalculationMatrixRow__c where vlocity_cmt__CalculationMatrixVersionId__r.Name =: version24];
        List<vlocity_cmt__CalculationMatrixRow__c> matrixData36 = [select id,vlocity_cmt__CalculationMatrixVersionId__r.Name,vlocity_cmt__OutputData__c,vlocity_cmt__InputData__c from vlocity_cmt__CalculationMatrixRow__c where vlocity_cmt__CalculationMatrixVersionId__r.Name =: version36];      
        Map<String,Integer> productCount24 = new Map<String,Integer>();
        Map<String,Integer> productCount36 = new Map<String,Integer>();
        Set<String> productCode = new Set<String>();
        Set<String> mismatch24 = new Set<String>();
        Set<String> mismatch36 = new Set<String>();
        Set<String> value24 = new Set<String>();
        Set<String> value36 = new Set<String>();
        
        if(activeHardware != null){
            for(vlocity_cmt__ProductChildItem__c items: activeHardware){
                productCode.add(items.vlocity_cmt__ChildProductId__r.ProductCode);
            }
        }
                if(productCode != null)
                {
                        for(vlocity_cmt__CalculationMatrixRow__c row1: matrixData24)
                        {
                            inputData24 = (Map<String,Object>)JSON.deserializeUntyped(row1.vlocity_cmt__InputData__c);
                            String prcode = String.valueOf(inputData24.get('Source Product Code'));
                            if(prcode != null && productCode.contains(prcode)){
                                if(productCount24.get(prcode) != null){
                                    Integer pcount = Integer.valueOf(productCount24.get(prcode));
                                    pcount++;
                                   productCount24.put(prcode,pcount); 
                                }
                                else{
                                    Integer count = 0;
                                    count++;
                                    productCount24.put(prcode,count);
                                }
                            }
                        }
                        for(vlocity_cmt__CalculationMatrixRow__c row1: matrixData36)
                        {
                            inputData36 = (Map<String,Object>)JSON.deserializeUntyped(row1.vlocity_cmt__InputData__c);
                            String prcode = String.valueOf(inputData36.get('Source Product Code'));
                            if(prcode != null && productCode.contains(prcode)){
                                if(productCount36.get(prcode) != null){
                                    Integer pcount = Integer.valueOf(productCount36.get(prcode));
                                    pcount++;
                                   productCount36.put(prcode,pcount); 
                                }
                                else{
                                    Integer count = 0;
                                    count++;
                                    productCount36.put(prcode,count);
                                }
                            }
                        }
                    
                }
        for(String s:productCount24.keySet()){
            value24.add(s);
            if(productCount24.get(s) != rangeCount){
                mismatch24.add(s);
            }
        }
        for(String s:productCount36.keySet()){
            value36.add(s);
            if(productCount36.get(s) != rangeCount){
                mismatch36.add(s);
            }
        }
        system.debug('mismatch - '+mismatch24);
        system.debug(JSON.serialize(productCount24));
        sendEmail(mismatch24,mismatch36,value24,value36,productCode);        
    }
    public static void sendEmail(Set<String> mismatch24, Set<String> mismatch36,Set<String> value24,Set<String> value36,Set<String> productCode){
        Set<String> products = new Set<String>();
        products = productCode;
        productCode.removeAll(value24);
        products.removeAll(value36);
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        String[] toAddresses = new String[] {'simran.gupta@capgemini.com','itishree.a.dash@capgemini.com','neelam.kungwani@capgemini.com','pancham.verma@capgemini.com','vamsi.doddapani@capgemini.com'}; 
        String[] ccAddresses = new String[] {'shaik.ershad@capgemini.com','anchal.sahu@capgemini.com'};

        // Assign the addresses for the To and CC lists to the mail object.
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        // Specify the subject line for your email address.
        mail.setSubject('Price Matrix Entries Update');
        // Specify the text content of the email.

        mail.setPlainTextBody('Products with range mismatch in 24M Price Matrix : '+mismatch24+'\n'+'Products with range mismatch in 36M Price Matrix :  '+mismatch36+'\n'+'Product without Entries in 24M Price Matrix : '+JSON.serialize(productCode)+'\n'+'Product without Entries in 36M Price Matrix : '+JSON.serialize(products));

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });        
    }
}