global class MCONLINE_GetMobileDevPriceMatrix_Payment implements vlocity_cmt.VlocityOpenInterface2 {

    public cls_output[] output;
    global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outMap, Map < String, Object > options) {

        Boolean result = true;
        try {
            if (methodName.equalsIgnoreCase('getHardwarePrice')) {
                MCONLINE_GetMobileDevPriceMatrix_Payment.getHardwarePrice(inputMap, outMap);
            } else {
                result = false;
            }
        } catch (Exception e) {
            result = false;
            String error_message = e.getMessage() + ' ' + e.getLineNumber();
            outMap.put('statusCode', 500);
            outMap.put('Exception', e.getStackTraceString());
            outMap.put('ErrorResponse', generateError('UNKNOWN_ERROR', inputMap));
            MCOnline_Utility.logError(error_message, '500', 'MCONLINE_GetMobileDevPriceMatrix_Payment,MCONLINE_GetMobileDevPriceMatrix_Payment.invokeMethod', 'Apex Class', 'Exception', JSON.serialize(inputMap), '', '');
        }
        return result;
    }

    // Method to Generate Error 
    public static Map < String, Object > generateError(string errorCode, Map < String, Object > inputMap) {

        String agreementNumber = String.valueOf(inputMap.get('AgreementNumber'));
        String offerBundleCode = String.valueOf(inputMap.get('offerBundleCode'));
        String commitmentDuration = String.valueOf(inputMap.get('CommitmentDuration'));
        String catalog = String.valueOf(inputMap.get('Catalog'));
        String offerCode = String.valueOf(inputMap.get('offerCode'));
        Map < String, Object > ipInputMap = new Map < String, Object > ();
        string urlDetails = '{"agreementNumber": "' + agreementNumber + '", "offerBundleCode":"' + offerBundleCode + '", "commitmentDuration":"' + commitmentDuration + '", "catalog":"' + catalog + '", "offerCode":"' + offerCode + '"}';
        ipInputMap.put('functionality', 'GetMobileDevicePriceMatrix');
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('success', false);
        ipInputMap.put('errorCode', errorCode);
        Map < String, Object > errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode, 'MCONLINE_GetMobileDevPriceMatrix_Payment,MCONLINE_GetMobileDevPriceMatrix_Payment.generateError', 'Integration Procedure, Apex Class', 'Custom Error', JSON.serialize(inputMap), '', '', urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }

    //Method to get hardware price from matrix
    public static void getHardwarePrice(Map < String, Object > inputMap, Map < String, Object > outMap) {

        string agreementNumber = inputMap.get('AgreementNumber') + '';
        string offerBundleCode = inputMap.get('offerBundleCode') + '';
        string commitmentDuration = inputMap.get('CommitmentDuration') + '';
        string catalog = inputMap.get('Catalog') + '';
        string offerCode = inputMap.get('offerCode') + '';
        Boolean validParams = commitmentDuration != '24' && commitmentDuration != '36' && commitmentDuration != '0';
        string errorCode;
        List < String > prodName = new List < String > ();
        Map<ID,vlocity_cmt__ProductChildItem__c> insuranceProdMap = new Map<ID,vlocity_cmt__ProductChildItem__c>();
        Set<String> parentProd = new Set<String>();
        prodName.add(offerCode);
        prodName.add(offerBundleCode);
        prodName.add('INSURANCE_OFFER');
        //validate OfferCode , Catalog and commitment duration. 
        Map < ID, vlocity_cmt__ProductChildItem__c > childProdList = new Map < ID, vlocity_cmt__ProductChildItem__c > ([SELECT id, vlocity_cmt__ChildProductId__c, vlocity_cmt__ChildProductId__r.ProductCode, vlocity_cmt__ChildProductId__r.Name, vlocity_cmt__ChildProductId__r.vlocity_cmt__JSONAttribute__c,vlocity_cmt__ParentProductId__r.ProductCode FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode IN: prodName AND (vlocity_cmt__ParentProductId__r.ProductCode =: offerBundleCode OR vlocity_cmt__ChildProductId__r.ProductCode =:offerBundleCode OR vlocity_cmt__ChildProductId__r.C2BC_Category__c='insurance')]);
        Map < ID, vlocity_cmt__ProductChildItem__c > tempChildProdList = childProdList;
        if(!childProdList?.isEmpty()){
           for (ID idKey: tempChildProdList.keyset()) {
           	vlocity_cmt__ProductChildItem__c child = tempChildProdList.get(idKey);
            parentProd.add(child.vlocity_cmt__ParentProductId__r.ProductCode);
            	if(child.vlocity_cmt__ParentProductId__r.ProductCode == offerCode){
                	childProdList.remove(idKey);
                }else if(child.vlocity_cmt__ParentProductId__r.ProductCode == 'INSURANCE_OFFER'){
                    insuranceProdMap.put(idKey,child);
                    childProdList.remove(idKey);
                }
			} 
        }
        if (validParams || catalog != 'MOBILEDEVICE' || !(parentProd?.contains(offerCode)) || childProdList?.isEmpty()) {
            errorCode =	validParams ? 'InvalidCommitmentDuration1' : (catalog != 'MOBILEDEVICE') ? 'InvalidOrBlankCatalog' : (childProdList?.isEmpty()) ? 'InvalidOrBlankOfferBundleCode': !(parentProd?.contains(offerCode)) ? 'InvalidOrBlankOfferCode' : null;
            outMap.put('ErrorResponse', generateError(errorCode, inputMap));
            outMap.put('StatusCode', 400);
        } else if (String.isBlank(agreementNumber) || String.isBlank(offerBundleCode) || String.isBlank(offerCode)) {
            //check if blank value passed for agreementNumber , offerBundleCode and offerCode.
            if (String.isBlank(agreementNumber)) {
                errorCode = 'InvalidOrBlankAgreementNumber';
            } else if (String.isBlank(offerBundleCode)) {
                errorCode = 'InvalidOrBlankOfferBundleCode';
            } else if (String.isBlank(offerCode)) {
                errorCode = 'InvalidOrBlankOfferCode';
            }
            outMap.put('ErrorResponse', generateError(errorCode, inputMap));
            outMap.put('StatusCode', 400);
        } else {
            Map < String, Map < String, String >> prodSapIdMap = getSAPIdMap(offerBundleCode, childProdList,insuranceProdMap);
            for(String HW:prodSapIdMap.keyset()){
                
                System.debug('sAPID===>'+HW+ +prodSapIdMap.get(HW).get('sAPID'));
            }
            if (Test.isRunningTest()) {
                agreementNumber = [select id, contractNumber from Contract where Status = 'Active'
                    limit 1
                ]?.contractNumber;
            }
            List < vlocity_cmt__ContractLineItem__c > cliList = [SELECT id, vlocity_cmt__RecurringTotal__c, TeliaSE_MC_Customer_Requested_Price__c, vlocity_cmt__RecurringCharge__c, vlocity_cmt__contractid__r.contractnumber, name, vlocity_cmt__contractid__r.status, vlocity_cmt__productcode__c FROM vlocity_cmt__ContractLineItem__c WHERE(vlocity_cmt__ContractId__r.ContractNumber =: agreementNumber AND vlocity_cmt__ContractId__r.Status = 'Active'
                AND vlocity_cmt__Product2Id__r.C2BC_Category__c = 'mobilevoicesubscription'
                AND vlocity_cmt__Product2Id__r.C2BC_Subcategory__c = 'voice')];
            // check if agreement is active and has contract line items
            if (cliList?.size() == 0) {
                outMap.put('ErrorResponse', generateError('InvalidAgreementNumber', inputMap));
                outMap.put('StatusCode', 400);
            } else {
                //fetch available price ranges
                List < PricematrixRanges__c > ranges = PricematrixRanges__c.getall().values();
                List < Map < String, Object >> dataMap = new List < Map < String, Object >> ();
                Object[] inputdata = new List < Object > ();
                Map < string, string > agreementLines = new Map < string, string > ();
                Map < string, string > agreementMap = new Map < string, string > ();
                String prodSapId1;
                String relatedProduct;
                String offer;
                String offerCatalog;
                List < Map < String, Object >> dataMapChildren = new List < Map < String, Object >> ();
                //for each contract Line item check find out the price range.customer requested price is considered
                //if it is not null else Recurring price is considered.
                for (vlocity_cmt__ContractLineItem__c cli: cliList) {
                    String priceRange;
                    Decimal efsprice;
                    if (cli.TeliaSE_MC_Customer_Requested_Price__c != null) {
                        efsprice = cli.TeliaSE_MC_Customer_Requested_Price__c;
                    } else if (cli.vlocity_cmt__RecurringCharge__c != null) {
                        efsprice = cli.vlocity_cmt__RecurringCharge__c;
                    }
                    //assign the price range depending on the price of the subscription.                      
                    if (efsprice != null) {

                        for (PricematrixRanges__c range: ranges) {
                            if (efsprice >= range.Low__c && efsprice <= range.High__c) {
                                priceRange = range.Name;
                                break;
                            }
                        }
                        agreementLines.put(cli.vlocity_cmt__productcode__c, String.valueOf(efsprice));
                        for (ID idKey: childProdList.keyset()) {
                            vlocity_cmt__ProductChildItem__c child = childProdList.get(idKey);
                            Product2 childProd = child.vlocity_cmt__ChildProductId__r;
                            if (childProd != null) {
                                system.debug(childProd.ProductCode);
                                Map < String, Object > dataMap2 = new Map < String, Object > ();
                                dataMap2.put('Source Product Name', childProd.name);
                                system.debug(childProd.name);
                                dataMap2.put('Source Product Code', childProd.ProductCode);
                                dataMap2.put('Quantity', priceRange);
                                dataMap2.put('Characteristic Name', 'HWSAPID');
                                prodSapId1 = ((Map < String, String > ) prodSapIdMap.get(childProd.ProductCode)).get('sAPID');
                                dataMap2.put('Characteristic Value', prodSapId1);
                                relatedProduct = ((Map < String, String > ) prodSapIdMap.get(childProd.ProductCode)).get('insuranceProduct');
                                dataMap2.put('insuranceProduct', relatedProduct);
                                offer = ((Map < String, String > ) prodSapIdMap.get(childProd.ProductCode)).get('insuranceOffer');
                                dataMap2.put('insuranceOffer', offer);
                                offerCatalog = ((Map < String, String > ) prodSapIdMap.get(childProd.ProductCode)).get('insuranceCatalog');
                                dataMap2.put('insuranceCatalog', offerCatalog);
                                dataMap2.put('listPrice', ((Map < String, String > ) prodSapIdMap.get(childProd.ProductCode)).get('listPrice'));
                                dataMap2.put('SubscriptionProductCode', cli.vlocity_cmt__productcode__c);
                                dataMap2.put('SubscriptionMRC', String.valueOf(efsprice));
                                dataMapChildren.add(dataMap2);
                                agreementMap.put(prodSapId1 + '' + priceRange, cli.vlocity_cmt__productcode__c);
                            }
                        }
                    }
                }
                if (commitmentDuration != null) {
                    invokeProcedure(dataMapChildren, outMap, agreementLines, agreementMap, commitmentDuration, prodSapIdMap);
                }
            }

        }
    }

    //method to get SAP ID of HW
    public static Map < String, Map < String, String >> getSAPIdMap(String offerBundleCode, Map < ID, vlocity_cmt__ProductChildItem__c > childProdList,Map<ID,vlocity_cmt__ProductChildItem__c> insuranceProdMap) {

        List < String > childList = new List < String > ();
        Map < String, Map < String, String >> mapSAPId = new Map < String, Map < String, String >> ();
        String prodSapId;
        Map < String, object > map1 = new Map < String, object > ();
        List < vlocity_cmt__PriceListEntry__c > productInsurance = new List < vlocity_cmt__PriceListEntry__c >();
        List < object > attrList = new List < object > ();
        for (ID idKey: childProdList.keyset()) {
            vlocity_cmt__ProductChildItem__c child = childProdList.get(idKey);
            childList.add(child.vlocity_cmt__ChildProductId__r.ProductCode);
        }
        for (ID idKey: insuranceProdMap.keyset()) {
    		vlocity_cmt__ProductChildItem__c child = insuranceProdMap.get(idKey);
            if(child.vlocity_cmt__ChildProductId__r.Id!=null){
                childList.add(child.vlocity_cmt__ChildProductId__r.ProductCode);
            }
		}
        //Fetch list price of the HW under the input offerBundleCode and price of insurance products
        /*List < vlocity_cmt__PriceListEntry__c > productObj1 = [select vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c,vlocity_cmt__ProductId__r.C2BC_Category__c, vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProductId__c, vlocity_cmt__ProductId__r.ProductCode from vlocity_cmt__PriceListEntry__c where vlocity_cmt__ProductId__r.ProductCode IN: childList AND vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c = 'One-time'
            AND vlocity_cmt__PriceListName__c = 'Online Pricelist'
            AND vlocity_cmt__IsActive__c = true
        ];*/
        List < vlocity_cmt__PriceListEntry__c > productObj1 = [select  vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c,vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c,vlocity_cmt__ProductId__r.C2BC_Category__c, vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProductId__c, vlocity_cmt__ProductId__r.ProductCode,vlocity_cmt__ProductId__r.C2BC_Subcategory__c	 from vlocity_cmt__PriceListEntry__c where vlocity_cmt__ProductId__r.ProductCode IN: childList
            AND vlocity_cmt__PriceListName__c = 'Online Pricelist'
            AND vlocity_cmt__IsActive__c = true
        ];
        //seperate the insurance products
        List < vlocity_cmt__PriceListEntry__c > dupList = new List < vlocity_cmt__PriceListEntry__c >(productObj1);
        for(vlocity_cmt__PriceListEntry__c priceEntry :dupList ){
            if(priceEntry.vlocity_cmt__ProductId__r.C2BC_Category__c == 'insurance' && priceEntry.vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c=='Recurring'){
                productInsurance.add(priceEntry);
                integer place = productObj1.indexOf(priceEntry);
                productObj1.remove(place);
            }else if(!(priceEntry.vlocity_cmt__PricingElementId__r.vlocity_cmt__PricingVariableId__r.vlocity_cmt__ChargeType__c=='One-time' && priceEntry.vlocity_cmt__ProductId__r.C2BC_Category__c == 'goods' && priceEntry.vlocity_cmt__ProductId__r.C2BC_Subcategory__c=='mobiledevice')){
                integer place = productObj1.indexOf(priceEntry);
                productObj1.remove(place);
            }
        }
        for (vlocity_cmt__PriceListEntry__c prod: productObj1) {
            String prodid = prod.vlocity_cmt__ProductId__c;
            Map < String, String > SAPListPrice = new Map < String, String > ();
            //get the SAPID of the HW.
            if (prod.vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c != null) {
                String attr = prod.vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c;
                map1 = (Map < String, object > ) JSON.deserializeUntyped(attr);
                attrList = (List < object > ) map1.get('ATT_CODE_TELIAMOBAGGR');
                for (object o: attrList) {
                    Map < String, object > map3 = new Map < String, object > ();
                    map3 = (Map < String, object > ) o;
                    if (map3.get('attributeuniquecode__c') == 'ATT_HW_SAP_ID') {
                        prodSapId = (String) map3.get('value__c');
                        SAPListPrice.put('sAPID', prodSapId);
                        SAPListPrice.put('listPrice', String.ValueOf(prod.vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c));
                        mapSAPId.put(prod.vlocity_cmt__ProductId__r.ProductCode, SAPListPrice);
                        break;
                    }
                }
            }

        }
        //get insurance products
        Map < String, Map < String, String >> prodSapIdMap = getInsurenceProducts(mapSAPId,insuranceProdMap,productInsurance);
        return prodSapIdMap;
    }

    //method to get insurence products
    public static Map < String, Map < String, String >> getInsurenceProducts(Map < String, Map < String, String >> prodSapIdMap,Map<ID,vlocity_cmt__ProductChildItem__c> insuranceProdMap,List < vlocity_cmt__PriceListEntry__c > productInsurance) {
        
        Map < String, Map < String, String >> cloneMap = new Map < String, Map < String, String >>(prodSapIdMap);
        Map<String,Object> prodMap = new Map<String,Object>();
        Map<String,String> catalogOfferMap = new Map<String,String>();
		List<String> insuranceProd = new List<String>();
        Map<String, Map<String,String>> insuranceMap = new Map<String, Map<String,String>>();
        List<String> insuranceParent = new List<String>();
        Map < String, Map < String, String >> mapInsurence = new Map < String, Map < String, String >> ();
        String low;
		String high;
        String deductable;
        String campaignFreeMonths;
        Map < String, object > map1 = new Map < String, object > ();
        List < object > attrList = new List < object > ();
        for (ID idKey: insuranceProdMap.keyset()) {
    		vlocity_cmt__ProductChildItem__c child = insuranceProdMap.get(idKey);
            if(child.vlocity_cmt__ChildProductId__r.Id!=null){
                insuranceProd.add(child.vlocity_cmt__ChildProductId__r.ProductCode);
                insuranceParent.add(child.vlocity_cmt__ParentProductId__r.ProductCode);
                
            }
		}
        //fetch the Catalog/offer for insurance product.
        List<vlocity_cmt__CatalogProductRelationship__c> catalogRelation = [select id,vlocity_cmt__Product2Id__r.ProductCode,vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c from vlocity_cmt__CatalogProductRelationship__c where vlocity_cmt__Product2Id__r.ProductCode IN : insuranceParent];
        for (ID idKey: insuranceProdMap.keyset()) {
            vlocity_cmt__ProductChildItem__c child = insuranceProdMap.get(idKey);
            if(child.Id!=null){
                for(vlocity_cmt__CatalogProductRelationship__c catg : catalogRelation){
                	if(child.vlocity_cmt__ParentProductId__r.ProductCode == catg.vlocity_cmt__Product2Id__r.ProductCode){
                    	Map<String,String> insuranceInfo = new Map<String,String>();
        				insuranceInfo.put('offer',child.vlocity_cmt__ParentProductId__r.ProductCode);
            			insuranceInfo.put('catalog',catg.vlocity_cmt__CatalogId__r.vlocity_cmt__CatalogCode__c);
            			insuranceMap.put(child.vlocity_cmt__ChildProductId__r.ProductCode,insuranceInfo);
                	}
            	}
            }
            
        }
        //find out range of each insurance product
        for (vlocity_cmt__PriceListEntry__c prod: productInsurance) {
            String prodid = prod.vlocity_cmt__ProductId__c;
            Map < String, String > insurenceAttribute = new Map < String, String > ();
            if (prod.vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c != null) {
                String attr = prod.vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c;
                map1 = (Map < String, object > ) JSON.deserializeUntyped(attr);
                attrList = (List < object > ) map1.get('ATT_CODE_TELIAMOBAGGR');
                for (object o: attrList) {
                    Map < String, object > map3 = new Map < String, object > ();
                    map3 = (Map < String, object > ) o;
                    if (map3.get('attributeuniquecode__c') == 'VALUE_FROM_EXCL_VAT') {
                        low = (String) map3.get('value__c');
                        insurenceAttribute.put('VALUE_FROM_EXCL_VAT', low);
                    }else if(map3.get('attributeuniquecode__c') == 'Value_to_excl.VAT') {
                        high = (String) map3.get('value__c');
                        insurenceAttribute.put('Value_to_excl.VAT', high);
                    }
                }
        	}
            mapInsurence.put(prod.vlocity_cmt__ProductId__r.ProductCode,insurenceAttribute);

        }
        // Check if HW price falls in any of the ranges of insurance
       	for(String hw:cloneMap.keySet()){
          Decimal mobileListPrice = Decimal.valueOf(((Map < String, String >)cloneMap.get(HW)).get('listPrice'));  
          for(String insurenceProd:mapInsurence.keySet()){
                Decimal rangeStart = Decimal.valueOf(((Map<String,String>)mapInsurence.get(insurenceProd)).get('VALUE_FROM_EXCL_VAT'));
                Decimal rangeEnd = Decimal.valueOf(((Map<String,String>)mapInsurence.get(insurenceProd)).get('Value_to_excl.VAT'));
                if (mobileListPrice >= rangeStart && mobileListPrice <= rangeEnd) {
                    Map<String,String> hwInfo = (Map < String, String >)cloneMap.get(HW);
                    Map < String, String > insurenceInfo = (Map < String, String >)mapInsurence.get(insurenceProd);
                    hwInfo.put('insuranceProduct',insurenceProd);
                    if(insuranceMap.containsKey(insurenceProd)){
                      Map<String,String> offerCatalog = (Map<String,String>)insuranceMap.get(insurenceProd);  
                      hwInfo.put('insuranceOffer',offerCatalog.get('offer'));  
                      hwInfo.put('insuranceCatalog',offerCatalog.get('catalog'));  
                    }
                    prodSapIdMap.put(hw,hwInfo); 
               }
            }
        }
        // return HW with SAP ID and appropriate insurance info
		return prodSapIdMap;
    }
    //method to invoke calculation procedure
    public static void invokeProcedure(List < Object > dataMap, Map < String, Object > outMap, Map < String, String > agreementLinesCodeList, Map < string, string > agreementMap, string commitmentDuration, Map < string, Map < String, String >> prodSapIdMap) {

        Map < String, Object > inputMap = new Map < String, Object > ();
        Map < String, Object > options = new Map < String, Object > ();
        Map < string, HW_Cal_Procedure__c > calProc = HW_Cal_Procedure__c.getall();
        String configurationName;
        string outputRespose;
        string outforCompare;
        List < CalculationResult > finalList = new List < CalculationResult > ();
        List < String > noPriceProd = new List < String > ();
        List < Map < String, Object >> noPriceDataMap = new List < Map < String, Object >> ();
        if (commitmentDuration?.equalsIgnoreCase('24')) {
            configurationName = (String)(calProc.get('Hardware_24M').get('configurationName__c'));
            options.put('configurationName', configurationName);
        } else if (commitmentDuration?.equalsIgnoreCase('36')) {
            configurationName = (String)(calProc.get('Hardware_36M').get('configurationName__c'));
            options.put('configurationName', configurationName);
        } else if (commitmentDuration == '0') {
            configurationName = 'No_Calculation_Procedure';
        }
        if (configurationName == 'No_Calculation_Procedure') {
            outputRespose = getListPriceResponse(dataMap);
        } else {
            options.put('includeInputs', true);
            Object[] inputdata = new List < Object > ();
            Map < String, Object > c = new Map < String, Object > ();
            List < Object > productList = new List < Object > ();
            Map < String, Object > prod1 = new Map < String, Object > ();
            inputMap.put('UserInputList', dataMap);
            options.put('verbose', false);
            options.put('mergeInListName', 'UserInputList');
            Map < String, Object > output = new Map < String, Object > ();
            Type t = Type.forName('vlocity_cmt', 'PricingMatrixCalculationService');
            vlocity_cmt.VlocityOpenInterface vpsi = (vlocity_cmt.VlocityOpenInterface) t.newInstance();
            if (!Test.isRunningTest()) {
                vpsi.invokeMethod('calculate', inputMap, output, options);
                outputRespose = JSON.serialize(output);
            } else {
                outputRespose = '[{"Source Product Code":"", "Source Product Name":"", "Characteristic Value":"", "Characteristic Name":"", "PriceMatrix_36M_Hardware__MRC":"", "PriceMatrix_36M_Hardware__NRC":""}]';
            }
            outputRespose = outputRespose.replace('Source Product Code', 'SourceProductCode');
            outputRespose = outputRespose.replace('Source Product Name', 'SourceProductName');
            outputRespose = outputRespose.replace('Characteristic Value', 'CharacteristicValue');
            outputRespose = outputRespose.replace('Characteristic Name', 'CharacteristicName');
            if (commitmentDuration != null && commitmentDuration.equalsIgnoreCase('36')) {
                outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__MRC', 'MRC');
                outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__NRC', 'NRC');
            } else if (commitmentDuration != null && commitmentDuration.equalsIgnoreCase('24')) {
                outputRespose = outputRespose.replace('PriceMatrix_24M_Hardware__MRC', 'MRC');
                outputRespose = outputRespose.replace('PriceMatrix_24M_Hardware__NRC', 'NRC');
            }
        }
        MCONLINE_GetMobileDevPriceMatrix_Payment hwWrapperObj = MCONLINE_GetMobileDevPriceMatrix_Payment.parse(outputRespose);
        List < cls_calculationResults > resultList = new List < cls_calculationResults > ();
        List < CalculationResult > resultNewList = new List < CalculationResult > ();
        //if price matrix response contains data then process.                                      
        if ((hwWrapperObj.output)?.size() > 0) {
            //format the response  
            resultNewList = formatResponse(hwWrapperObj, agreementMap, agreementLinesCodeList, prodSapIdMap,commitmentDuration);
            //check if number of combinations in the input is same as output combinations. 
            //if there is difference then there is no availability of price in price matrix for some hw.
            //Hence list price need to be added for those missing combinations.
            if (resultNewList.size() != dataMap.size()) {
                //get list price 
                outforCompare = getListPriceResponse(dataMap);
                MCONLINE_GetMobileDevPriceMatrix_Payment hwWrapperObj2 = MCONLINE_GetMobileDevPriceMatrix_Payment.parse(outforCompare);
                List < cls_calculationResults > resultList2 = new List < cls_calculationResults > ();
                List < CalculationResult > resultNewList2 = new List < CalculationResult > ();
                if ((hwWrapperObj2.output)?.size() > 0) {
                    //format list price. 
                    resultNewList2 = formatResponse(hwWrapperObj2, agreementMap, agreementLinesCodeList, prodSapIdMap,commitmentDuration);
                    //Add list price combinations to the combinations of matrix response.
                    getNoPriceHardWare(resultNewList, resultNewList2, agreementMap, agreementLinesCodeList, prodSapIdMap);
                    //send final response.
                    outMap.put('statusCode', 200);
                    outMap.put('outputRespose', JSON.serialize(resultNewList));
                }
            } else {
                outMap.put('statusCode', 200);
                outMap.put('outputRespose', JSON.serialize(resultNewList));
            }
        } else {
            //if no data in price matrix response then send list price to response.  
            String outResponse;
            //get list price.  
            outResponse = getListPriceResponse(dataMap);
            List < CalculationResult > resultNewList1 = new List < CalculationResult > ();
            MCONLINE_GetMobileDevPriceMatrix_Payment hwWrapperObj1 = MCONLINE_GetMobileDevPriceMatrix_Payment.parse(outResponse);
            //format the response.
            resultNewList1 = formatResponse(hwWrapperObj1, agreementMap, agreementLinesCodeList, prodSapIdMap,commitmentDuration);
            outMap.put('statusCode', 200);
            outMap.put('outputRespose', JSON.serialize(resultNewList1));
        }
    }

    //wrapper class for output
    class cls_output {

        public cls_aggregationResults aggregationResults;
        public cls_calculationResults[] calculationResults;
    }

    class cls_aggregationResults {}

    class cls_calculationResults {

        public String MRC;
        public String NRC;
        public String SourceProductName;
        public String SourceProductCode;
        public String Quantity;
        public String CharacteristicName;
        public String CharacteristicValue;
        //added SubscriptionProductCode,subscriptionMRC to retain value when parsed( MCONL-8516)
        public String SubscriptionProductCode;
        public String subscriptionMRC;
		public String insuranceProduct;
		public String insuranceOffer;
        public String insuranceCatalog;
        public String upfrontPaymentNRC;
    }
    class CalculationResult {

        public String increasedMRC;
        public String increasedNRC;
        public String subscriptionProductCode;
        public String mobileDeviceSAPId;
        public String mobileDeviceProductCode;
        public String subscriptionMRC;
        public String mobileDeviceNRC;
        public String insuranceProduct;
        public String insuranceOffer;
        public String insuranceCatalog;
        public String upfrontPaymentNRC;

    }

    //method to parse JSON string
    public static MCONLINE_GetMobileDevPriceMatrix_Payment parse(String json) {

        return (MCONLINE_GetMobileDevPriceMatrix_Payment) System.JSON.deserialize(json, MCONLINE_GetMobileDevPriceMatrix_Payment.class);
    }

    //Get list price of HW
    public static string getListPriceResponse(List < Object > dataMap) {

        Map < String, Object > output1 = new Map < String, Object > ();
        List < Map < String, Object >> CalculationResults = new List < Map < String, Object >> ();
        Map < String, List < Object >> CalculationResults1 = new Map < String, List < Object >> ();
        List < Object > output = new List < Object > ();
        string outputRespose;
        for (Object data: dataMap) {
            Map < String, Object > res = (Map < String, Object > ) data;
            res.put('MRC', '0');
            res.put('NRC', '0');
            CalculationResults.add(res);
        }
        CalculationResults1.put('CalculationResults', CalculationResults);
        CalculationResults1.put('aggregationResults', null);
        output.add(CalculationResults1);
        output1.put('output', output);
        outputRespose = JSON.serialize(output1);
        outputRespose = outputRespose.replace('Source Product Code', 'SourceProductCode');
        outputRespose = outputRespose.replace('Source Product Name', 'SourceProductName');
        outputRespose = outputRespose.replace('Characteristic Value', 'CharacteristicValue');
        outputRespose = outputRespose.replace('Characteristic Name', 'CharacteristicName');
        return outputRespose;
    }

    //Method to format the response
    public static List < CalculationResult > formatResponse(MCONLINE_GetMobileDevPriceMatrix_Payment hwWrapperObj, Map < string, string > agreementMap, Map < String, String > agreementLinesCodeList, Map < string, Map < String, String >> prodSapIdMap,string commitmentDuration) {

        List < cls_calculationResults > calResult = new List < cls_calculationResults > ();
        calResult = hwWrapperObj.output[0].calculationResults;
        List < CalculationResult > resultNewList = new List < CalculationResult > ();
        for (cls_calculationResults calculationResultObj: calResult) {
            CalculationResult calculationResultNewObj = new CalculationResult();
            calculationResultNewObj.subscriptionProductCode = calculationResultObj.SubscriptionProductCode;
            calculationResultNewObj.subscriptionMRC = calculationResultObj.subscriptionMRC;
            calculationResultNewObj.increasedMRC = calculationResultObj.MRC;
            calculationResultNewObj.increasedNRC = calculationResultObj.NRC;
            calculationResultNewObj.mobileDeviceProductCode = calculationResultObj.SourceProductCode;
            calculationResultNewObj.mobileDeviceSAPId = calculationResultObj.CharacteristicValue;
            String price = ((Map < String, String > ) prodSapIdMap.get(calculationResultNewObj.mobileDeviceProductCode)).get('listPrice');
            calculationResultNewObj.mobileDeviceNRC = price;
            calculationResultNewObj.insuranceProduct = calculationResultObj.insuranceProduct;
            calculationResultNewObj.insuranceOffer = calculationResultObj.insuranceOffer;
            calculationResultNewObj.insuranceCatalog = calculationResultObj.insuranceCatalog;
            // upfront amount is calculated and assigned
            // Calculation is based on matrix = Matrix MRC* commitment duration + matrix NRC
            calculationResultNewObj.upfrontPaymentNRC = String.valueOf(integer.valueof(commitmentDuration)*(integer.valueof(calculationResultObj.MRC))+integer.valueof(calculationResultObj.NRC));
            resultNewList.add(calculationResultNewObj);

        }
        return resultNewList;
    }

    // Method to add HW nodes for which no price is defined in the matrix
    public static void getNoPriceHardWare(List < CalculationResult > resultNewList1, List < CalculationResult > resultNewList2, Map < string, string > agreementMap, Map < String, String > agreementLinesCodeList, Map < string, Map < String, String >> prodSapIdMap) {

        List < String > cal1 = new List < String > ();
        List < String > cal2 = new List < String > ();
        for (CalculationResult calRes1: resultNewList1) {
            cal1.add(calRes1.mobileDeviceProductCode + calRes1.subscriptionProductCode);
        }
        for (CalculationResult calRes2: resultNewList2) {
            String cal2Key = calRes2.mobileDeviceProductCode + calRes2.subscriptionProductCode;
            if (!cal1.contains(cal2Key)) {
                resultNewList1.add(calRes2);
            }
        }
    }
}