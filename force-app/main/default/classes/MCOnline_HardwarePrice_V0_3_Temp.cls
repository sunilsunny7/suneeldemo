global class MCOnline_HardwarePrice_V0_3_Temp implements vlocity_cmt.VlocityOpenInterface2 {
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        Decimal startTime = dateTime.now().getTime();
        Decimal endTime = dateTime.now().getTime();
        Decimal timeDiff;
        try { 
            if(methodName.equalsIgnoreCase('getHardwarePrice')) {
                startTime = dateTime.now().getTime();
                MCOnline_HardwarePrice_V0_3_Temp.getHardwarePrice(inputMap, outMap);
                endTime = dateTime.now().getTime();
        		timeDiff=(endTime-startTime)/1000;
            }else {
                result = false;
            }
        }catch(Exception e){
            result = false;
            String error_message= e.getMessage() +' '+e.getLineNumber();
            outMap.put('statusCode', 500);
            outMap.put('Exception', e.getStackTraceString());
            outMap.put('ErrorResponse', generateError('UNKNOWN_ERROR', inputMap));
            MCOnline_Utility.logError(error_message,'500','MCONLINE_HardwarePriceMatrixV0.2,MCOnline_HardwarePrice_V0_3.invokeMethod','Apex Class', 'Exception',JSON.serialize(inputMap),'','');
            }
        return result;
    }
	// Method to Generate Error 
    public static Map<String,Object> generateError(string errorCode, Map<String,Object> inputMap){
    	String agreementNumber= String.valueOf(inputMap.get('AgreementNumber'));
        String offerBundleCode = String.valueOf(inputMap.get('offerBundleCode'));
        String commitmentDuration = String.valueOf(inputMap.get('CommitmentDuration'));
        String catalog = String.valueOf(inputMap.get('Catalog'));
        String offerCode = String.valueOf(inputMap.get('offerCode'));
        Map<String,Object> ipInputMap = new Map<String,Object>(); 
        string urlDetails = '{"agreementNumber": "'+agreementNumber+'", "offerBundleCode":"'+offerBundleCode+'", "commitmentDuration":"'+commitmentDuration+'", "catalog":"'+catalog+'", "offerCode":"'+offerCode+'"}';
        ipInputMap.put('functionality', 'GetMobileDevicePriceMatrix');
        ipInputMap.put('errorType', 'custom');
        ipInputMap.put('success', false);
        ipInputMap.put('errorCode', errorCode);
        Map<String,Object> errorResponse = MCOnline_Utility.getError(ipInputMap);
        MCOnline_Utility.logError(JSON.serialize(errorResponse), errorCode,'MCONLINE_HardwarePriceMatrixV0.2,MCOnline_HardwarePrice_V0_3.generateError','Integration Procedure, Apex Class', 'Custom Error',JSON.serialize(inputMap),'','',urlDetails);
        return MCOnline_Utility.getError(ipInputMap);
    }
    //Method to get hardware price from matrix
  	public static void getHardwarePrice(Map<String,Object> inputMap, Map<String,Object> outMap){
        Decimal startTime = dateTime.now().getTime();
        Decimal endTime = dateTime.now().getTime();
        Decimal timeDiff;
        system.debug('time log'+dateTime.now().getTime());
    	string agreementNumber = inputMap.get('AgreementNumber')+'';
    	string offerBundleCode  = inputMap.get('offerBundleCode')+'';
    	string commitmentDuration = inputMap.get('CommitmentDuration')+'';
    	string catalog = inputMap.get('Catalog')+'';
   		string offerCode = inputMap.get('offerCode')+'';
        string errorCode;
 		//errorHandling start
 		startTime = dateTime.now().getTime();
        system.debug('time log'+dateTime.now().getTime());
    	List<Product2> offerCodeList = [SELECT ProductCode FROM Product2 WHERE ProductCode =:offerCode limit 1];
        endTime = dateTime.now().getTime();
        timeDiff=(endTime-startTime)/1000;
        
    	if((!(commitmentDuration == '24' || commitmentDuration == '36' || commitmentDuration == '0')) || catalog != 'MOBILEDEVICE' || (offerCodeList.size()==0 || offerCodeList==null)){
     		if(!(commitmentDuration == '24' || commitmentDuration == '36' || commitmentDuration == '0')){  
                errorCode = 'InvalidCommitmentDuration1';
       		}else if(catalog != 'MOBILEDEVICE'){
                errorCode = 'InvalidOrBlankCatalog';
         	}else if(offerCodeList.size()==0 || offerCodeList==null){
                errorCode = 'InvalidOrBlankOfferCode';
        	}
            outMap.put('ErrorResponse', generateError(errorCode, inputMap));
       		outMap.put('StatusCode', 400);
    	}else if(String.isBlank(agreementNumber) || String.isBlank(offerBundleCode) || String.isBlank(offerCode)){
        	if(String.isBlank(agreementNumber)){
                errorCode = 'InvalidOrBlankAgreementNumber';
            }else if(String.isBlank(offerBundleCode)){
                errorCode = 'InvalidOrBlankOfferBundleCode';
            }else if(String.isBlank(offerCode)){
                errorCode = 'InvalidOrBlankOfferCode';
            }
            outMap.put('ErrorResponse', generateError(errorCode, inputMap));
            outMap.put('StatusCode', 400);
        // errorHandling stop
        }else{
            startTime = dateTime.now().getTime();
        	List<vlocity_cmt__ProductChildItem__c> childProdList = [SELECT id,vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.Name,vlocity_cmt__ChildProductId__r.vlocity_cmt__JSONAttribute__c FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode =:offerBundleCode];
            Map<String,Map<String,String>> prodSapIdMap = getSAPIdMap(offerBundleCode,childProdList);
            endTime = dateTime.now().getTime();
            timeDiff=(endTime-startTime)/1000;
        	system.debug('time log'+dateTime.now().getTime());
         
        	
        	// error handling start
        	if(childProdList.size()==0 || childProdList==null){
               outMap.put('ErrorResponse', generateError('InvalidOfferBundleCode', inputMap));
               outMap.put('StatusCode', 400); // error handling stop
        	}else{
          		List<Product2> productObj = new List<Product2>();
        		for( vlocity_cmt__ProductChildItem__c child : childProdList){
        			productObj.add(child.vlocity_cmt__ChildProductId__r);
       			}
        		
        		//List<Product2> productObj = [SELECT id,name,productcode FROM Product2 WHERE Name IN:childList ];

        		if(Test.isRunningTest()){
                    startTime = dateTime.now().getTime();
        			agreementNumber = [select id, contractNumber from Contract limit 1].contractNumber;
                    endTime = dateTime.now().getTime();
                    timeDiff=(endTime-startTime)/1000;
                    system.debug('time log'+dateTime.now().getTime());
       			}
        		List<vlocity_cmt__ContractLineItem__c> cliList = [SELECT id,vlocity_cmt__RecurringTotal__c,TeliaSE_MC_Customer_Requested_Price__c,vlocity_cmt__RecurringCharge__c,vlocity_cmt__contractid__r.contractnumber,name,vlocity_cmt__contractid__r.status,vlocity_cmt__productcode__c FROM vlocity_cmt__ContractLineItem__c WHERE (vlocity_cmt__ContractId__r.ContractNumber = :agreementNumber AND vlocity_cmt__ContractId__r.Status = 'Active' AND vlocity_cmt__Product2Id__r.C2BC_Category__c='mobilevoicesubscription' AND vlocity_cmt__Product2Id__r.C2BC_Subcategory__c='voice')];
        		// error handling start
        		if(cliList.size()==0 || cliList==null){
                    startTime = dateTime.now().getTime();
            		List<Contract> agreementNum = [select Id from Contract where ContractNumber=:agreementNumber limit 1];
                    endTime = dateTime.now().getTime();
                    timeDiff=(endTime-startTime)/1000;
            		system.debug('time log'+dateTime.now().getTime());
                    if(agreementNum.size()==0 || agreementNum==null){
                        outMap.put('ErrorResponse', generateError('InvalidAgreementNumber', inputMap));
             			outMap.put('StatusCode', 400); 
            		}// error handling stop
        		}else{       
        			startTime = dateTime.now().getTime();
        			List<PricematrixRanges__c> ranges = new List<PricematrixRanges__c>([select   High__c,Low__c,Name from PricematrixRanges__c]);
        			endTime = dateTime.now().getTime();
                    timeDiff=(endTime-startTime)/1000;
                    system.debug('time log'+dateTime.now().getTime());
                    List<Map<String, Object>> dataMap = new  List<Map<String, Object>>();
        			Object[] inputdata = new List < Object > ();
       				Map<string, string> agreementLines = new Map<string, string>();
        			Map<string, string> agreementMap = new Map<string, string>();
       				String prodSapId1;
        			List<Map < String, Object >> dataMapChildren = new List<Map < String, Object >> ();
        			//system.debug('cliList size'+cliList.size());
        			//system.debug('time log'+dateTime.now().getTime());
                    startTime = dateTime.now().getTime();
        			for(vlocity_cmt__ContractLineItem__c cli : cliList){
          				//if(prodListStr.contains(cli.Name)){
                			String priceRange;
                			Decimal efsprice;
                			// Decimal efsprice= cli.vlocity_cmt__RecurringTotal__c;
                			if(cli.TeliaSE_MC_Customer_Requested_Price__c!=null){
                    			efsprice = cli.TeliaSE_MC_Customer_Requested_Price__c;
                			}else if(cli.vlocity_cmt__RecurringCharge__c!=null){
                    			efsprice = cli.vlocity_cmt__RecurringCharge__c;
                			}
                			if(efsprice != null){
                    			for(PricematrixRanges__c range : ranges){
                       				if (efsprice >= range.Low__c && efsprice <= range.High__c){
                            			priceRange = range.Name;
                        			}
                    			}
                    			agreementLines.put(cli.vlocity_cmt__productcode__c,String.valueOf(efsprice));
                    			
                    			for(Product2 childProd : productObj){
                        			if(childProd!=null){
                        			Map < String, Object > dataMap2 = new Map < String, Object > ();
                        			dataMap2.put('Source Product Name', childProd.name);
                        			dataMap2.put('Source Product Code', childProd.ProductCode);
                        			dataMap2.put('Quantity', priceRange);
                        			dataMap2.put('Characteristic Name', 'HWSAPID');
                        			prodSapId1 = ((Map<String,String>)prodSapIdMap.get(childProd.ProductCode)).get('sAPID');    
                        			dataMap2.put('Characteristic Value', prodSapId1);
                        			dataMap2.put('listPrice',((Map<String,String>)prodSapIdMap.get(childProd.ProductCode)).get('listPrice'));
                        			dataMap2.put('SubscriptionProductCode',cli.vlocity_cmt__productcode__c);
                        			dataMap2.put('SubscriptionMRC',String.valueOf(efsprice));
                        			dataMapChildren.add(dataMap2);
                        			agreementMap.put(prodSapId1+''+priceRange,cli.vlocity_cmt__productcode__c);
                                    }
                                }
               	 			}
            			//}
        }
                    endTime = dateTime.now().getTime();
                    timeDiff=(endTime-startTime)/1000;
                    system.debug('time log'+dateTime.now().getTime());
    				if(commitmentDuration != null){
                        startTime = dateTime.now().getTime();
        				invokeProcedure(dataMapChildren, outMap, agreementLines, agreementMap, commitmentDuration,prodSapIdMap);  
                        endTime = dateTime.now().getTime();
                        timeDiff=(endTime-startTime)/1000;
   			 		}
				}
  			}   
        }
	}
    //method to get SAP ID of HW
    public static Map<String,Map<String,String>> getSAPIdMap(String offerBundleCode,List<vlocity_cmt__ProductChildItem__c> childProdList){
    	
        //List<vlocity_cmt__ProductChildItem__c> childProdList = [SELECT id,vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.ProductCode,vlocity_cmt__ChildProductId__r.vlocity_cmt__JSONAttribute__c FROM vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.ProductCode =:offerBundleCode];
    	List<String> childList = new List<String>();
    	for( vlocity_cmt__ProductChildItem__c child : childProdList){
       childList.add(child.vlocity_cmt__ChildProductId__r.ProductCode);
    }
        
    	List<vlocity_cmt__PriceListEntry__c> productObj1 = [select vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c,vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c, vlocity_cmt__ProductId__c,vlocity_cmt__ProductId__r.ProductCode from vlocity_cmt__PriceListEntry__c   where vlocity_cmt__ProductId__r.ProductCode  IN :childList ];
    	
        Map<String,Map<String,String>> mapSAPId = new Map<String,Map<String,String>>();
    	String prodSapId;
    	Map<String,object> map1 = new Map<String,object>();
   		List<object> attrList = new List<object>();
    	for(vlocity_cmt__PriceListEntry__c prod : productObj1){
    	String prodid = prod.vlocity_cmt__ProductId__c;
        Map<String,String> SAPListPrice = new Map<String,String>(); 
           
        if(prod.vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c!=null){
        	String attr = prod.vlocity_cmt__ProductId__r.vlocity_cmt__JSONAttribute__c;
            map1 = (Map<String,object>) JSON.deserializeUntyped(attr);
            attrList = (List<object>)map1.get('ATT_CODE_TELIAMOBAGGR');
            for(object o : attrList){
            	Map<String,object> map3 = new Map<String,object>();
                map3 = (Map<String,object>) o;
                if(map3.get('attributeuniquecode__c') == 'ATT_HW_SAP_ID'){
                	prodSapId = (String)map3.get('value__c');
                    SAPListPrice.put('sAPID',prodSapId);
                    SAPListPrice.put('listPrice',String.ValueOf(prod.vlocity_cmt__PricingElementId__r.vlocity_cmt__Amount__c));
                    mapSAPId.put(prod.vlocity_cmt__ProductId__r.ProductCode,SAPListPrice);
                }
            }
        }
           
    }
    	return mapSAPId; 
    }
    //method to invoke calculation procedure
    public static void invokeProcedure(List<Object> dataMap, 
                                        Map<String,Object> outMap, 
                                        Map<String,String> agreementLinesCodeList, 
                                        Map<string, string> agreementMap, string commitmentDuration,Map<string,Map<String,String>> prodSapIdMap){
      
      Decimal startTime = dateTime.now().getTime();
      Decimal endTime = dateTime.now().getTime();
      Decimal timeDiff;
      Map < String, Object > inputMap = new Map < String, Object > ();
      Map < String, Object > options = new Map < String, Object > ();
      Map<string,HW_Cal_Procedure__c> calProc = HW_Cal_Procedure__c.getall();
      String configurationName;
      string outputRespose;
      string outforCompare;                                      
      List<CalculationResult> finalList = new List<CalculationResult>();
      List<String> noPriceProd = new List<String>();
      List<Map < String, Object >> noPriceDataMap = new List<Map < String, Object >> ();
      //system.debug('dataMap ==>'+dataMap);
      //system.debug('agreementMap'+agreementMap);                                    
      if(commitmentDuration != null && commitmentDuration.equalsIgnoreCase('24')){
        //configurationName = (String)(calProc.get('Hardware_24M').get('configurationName__c'));
        configurationName = 'MCOnline_Hardware_24M_Price_Procedure';
        options.put('configurationName', configurationName);
      }else if(commitmentDuration != null && commitmentDuration.equalsIgnoreCase('36')){
        configurationName = (String)(calProc.get('Hardware_36M').get('configurationName__c'));
        options.put('configurationName', configurationName);
      }else if(commitmentDuration == '0'){
        configurationName = 'No_Calculation_Procedure';
      }
      if(configurationName == 'No_Calculation_Procedure'){
         startTime = dateTime.now().getTime();
         outputRespose = getListPriceResponse(dataMap);
         endTime = dateTime.now().getTime();
         timeDiff=(endTime-startTime)/1000;
      }else{
        startTime = dateTime.now().getTime();
        options.put('includeInputs', true);
        Object[] inputdata = new List < Object > ();
        Map < String, Object > c = new Map < String, Object > ();
        List < Object > productList = new List < Object > ();
        Map < String, Object > prod1 = new Map < String, Object > ();
       	inputMap.put('UserInputList', dataMap);
        options.put('verbose', false);
        options.put('mergeInListName', 'UserInputList');
        Map < String, Object > output = new Map < String, Object > ();
        Type t = Type.forName('vlocity_cmt','PricingMatrixCalculationService');
        vlocity_cmt.VlocityOpenInterface vpsi = (vlocity_cmt.VlocityOpenInterface) t.newInstance();
        if(!Test.isRunningTest()){
            startTime = dateTime.now().getTime();
            vpsi.invokeMethod('calculate', inputMap, output, options);
            system.debug('output==>'+output);
            endTime = dateTime.now().getTime();
            timeDiff=(endTime-startTime)/1000;
            //system.debug('output ==>'+output);
            outputRespose = JSON.serialize(output);
           
            system.debug('outputRespose ==>'+outputRespose);
        }else{
            outputRespose='[{"Source Product Code":"", "Source Product Name":"", "Characteristic Value":"", "Characteristic Name":"", "PriceMatrix_36M_Hardware__MRC":"", "PriceMatrix_36M_Hardware__NRC":""}]';
        }
        outputRespose = outputRespose.replace('Source Product Code', 'SourceProductCode');
        outputRespose = outputRespose.replace('Source Product Name', 'SourceProductName');
        outputRespose = outputRespose.replace('Characteristic Value', 'CharacteristicValue');
        outputRespose = outputRespose.replace('Characteristic Name', 'CharacteristicName');
        if(commitmentDuration != null && commitmentDuration.equalsIgnoreCase('36')){
        	outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__MRC', 'MRC');
           	outputRespose = outputRespose.replace('PriceMatrix_36M_Hardware__NRC', 'NRC');
        }else if(commitmentDuration != null && commitmentDuration.equalsIgnoreCase('24')){
         	outputRespose = outputRespose.replace('PriceMatrix_24M_Hardware__MRC', 'MRC');
           	outputRespose = outputRespose.replace('PriceMatrix_24M_Hardware__NRC', 'NRC');
       	}
      }
      startTime = dateTime.now().getTime();
      MCOnline_HardwarePrice_V0_3_Temp hwWrapperObj = MCOnline_HardwarePrice_V0_3_Temp.parse(outputRespose);
      endTime = dateTime.now().getTime();
      timeDiff=(endTime-startTime)/1000;
      //system.debug('hwWrapperObj.output ==>'+(hwWrapperObj.output).size());
      List<cls_calculationResults> resultList = new List<cls_calculationResults>();                                           
      List<CalculationResult> resultNewList = new List<CalculationResult>();
      if(hwWrapperObj.output != null && (hwWrapperObj.output).size() > 0){
        startTime = dateTime.now().getTime();  
      	resultNewList = formatResponse(hwWrapperObj,agreementMap,agreementLinesCodeList,prodSapIdMap);
        endTime = dateTime.now().getTime();
     	timeDiff=(endTime-startTime)/1000; 
        //system.debug('resultNewList==>'+resultNewList.size());
        //system.debug('dataMap==>'+dataMap.size());
        if(resultNewList.size() != dataMap.size()){
           startTime = dateTime.now().getTime(); 
           outforCompare = getListPriceResponse(dataMap);
           endTime = dateTime.now().getTime();
     	   timeDiff=(endTime-startTime)/1000;  
            startTime = dateTime.now().getTime();
           MCOnline_HardwarePrice_V0_3_Temp hwWrapperObj2 = MCOnline_HardwarePrice_V0_3_Temp.parse(outforCompare);
           endTime = dateTime.now().getTime();
     	   timeDiff=(endTime-startTime)/1000;  
            //system.debug('hwWrapperObj2.output ==>'+(hwWrapperObj2.output).size());
           List<cls_calculationResults> resultList2 = new List<cls_calculationResults>();                                           
           List<CalculationResult> resultNewList2 = new List<CalculationResult>();
           if(hwWrapperObj2.output != null && (hwWrapperObj2.output).size() > 0){
             startTime = dateTime.now().getTime();  
             resultNewList2 = formatResponse(hwWrapperObj2,agreementMap,agreementLinesCodeList,prodSapIdMap);
             endTime = dateTime.now().getTime();
     	     timeDiff=(endTime-startTime)/1000;  
               //finalList = getNoPriceHardWare(resultNewList,resultNewList2,agreementMap,agreementLinesCodeList,prodSapIdMap );
               startTime = dateTime.now().getTime();  
               getNoPriceHardWare(resultNewList,resultNewList2,agreementMap,agreementLinesCodeList,prodSapIdMap );
               endTime = dateTime.now().getTime();
     	       timeDiff=(endTime-startTime)/1000;  
               outMap.put('statusCode', 200);
        	 outMap.put('outputRespose', JSON.serialize(resultNewList));
           }
        }else{
           outMap.put('statusCode', 200);
           outMap.put('outputRespose', JSON.serialize(resultNewList));
        }
        }else{
            String outResponse;
            startTime = dateTime.now().getTime();
          	outResponse = getListPriceResponse(dataMap);
            endTime = dateTime.now().getTime();
     	    timeDiff=(endTime-startTime)/1000;  
          	List<CalculationResult> resultNewList1 = new List<CalculationResult>();
          	MCOnline_HardwarePrice_V0_3_Temp hwWrapperObj1 = MCOnline_HardwarePrice_V0_3_Temp.parse(outResponse);
        	//system.debug('hwWrapperObj1.output ==>'+(hwWrapperObj1.output).size());
        	startTime = dateTime.now().getTime();
         	resultNewList1 = formatResponse(hwWrapperObj1,agreementMap,agreementLinesCodeList,prodSapIdMap);
          	endTime = dateTime.now().getTime();
     	    timeDiff=(endTime-startTime)/1000;  
            outMap.put('statusCode', 200);
         	outMap.put('outputRespose', JSON.serialize(resultNewList1));
      	}                                     
   	}
    public cls_output[] output;
    //wrapper class for output
    class cls_output {
        public cls_aggregationResults aggregationResults;
        public cls_calculationResults[] calculationResults;
        
    }
    class cls_aggregationResults {
    }
    class cls_calculationResults {
        public String MRC;
        public String NRC;
        public String SourceProductName;
        public String SourceProductCode;
        public String Quantity;
        public String CharacteristicName;
        public String CharacteristicValue;
        
        
    }
    class CalculationResult {
        public String increasedMRC;
        public String increasedNRC;
        public String subscriptionProductCode;
        public String mobileDeviceSAPId;
        public String mobileDeviceProductCode;
        public String subscriptionMRC;
        public String mobileDeviceNRC;
        
    }
    //method to parse JSON string
    public static MCOnline_HardwarePrice_V0_3_Temp parse(String json){
        return (MCOnline_HardwarePrice_V0_3_Temp) System.JSON.deserialize(json, MCOnline_HardwarePrice_V0_3_Temp.class);
    }
    //Get list price of HW
    public static string getListPriceResponse(List<Object> dataMap){
          Map<String,Object> output1 = new Map<String,Object>();
          List<Map<String,Object>> CalculationResults  = new List<Map<String,Object>>();
          Map<String,List<Object>> CalculationResults1 = new Map<String,List<Object>>();
          List<Object> output = new List<Object>();
          string outputRespose;
          for(Object data : dataMap){
              Map<String,Object> res = (Map<String,Object>)data;
              res.put('MRC','0');
              res.put('NRC','0');
              CalculationResults.add(res);
          }
          CalculationResults1.put('CalculationResults',CalculationResults);
          CalculationResults1.put('aggregationResults',null);
          output.add(CalculationResults1);
          output1.put('output',output);
          outputRespose = JSON.serialize(output1);
          //system.debug('CalculationResults'+CalculationResults);
          //system.debug('output ==>'+output);
          outputRespose = outputRespose.replace('Source Product Code', 'SourceProductCode');
          outputRespose = outputRespose.replace('Source Product Name', 'SourceProductName');
          outputRespose = outputRespose.replace('Characteristic Value', 'CharacteristicValue');
          outputRespose = outputRespose.replace('Characteristic Name', 'CharacteristicName');
          return outputRespose;
	}
    //Method to format the response
    public static List<CalculationResult> formatResponse(MCOnline_HardwarePrice_V0_3_Temp hwWrapperObj,Map<string, string> agreementMap,Map<String,String> agreementLinesCodeList,Map<string,Map<String,String>> prodSapIdMap){
 		List<cls_calculationResults>  calResult = new List<cls_calculationResults>();
        calResult = hwWrapperObj.output[0].calculationResults;
        List<CalculationResult> resultNewList = new List<CalculationResult>();
        //startTime = dateTime.now().getTime();
        for(cls_calculationResults calculationResultObj : calResult){
             CalculationResult calculationResultNewObj = new CalculationResult();
             String subProdCode = calculationResultObj.CharacteristicValue+calculationResultObj.Quantity;
             calculationResultNewObj.subscriptionProductCode = String.valueOf(agreementMap.get(subProdCode));
             calculationResultNewObj.subscriptionMRC = agreementLinesCodeList.get(calculationResultNewObj.SubscriptionProductCode);
             calculationResultNewObj.increasedMRC = calculationResultObj.MRC;
             calculationResultNewObj.increasedNRC = calculationResultObj.NRC;
             calculationResultNewObj.mobileDeviceProductCode = calculationResultObj.SourceProductCode;
             calculationResultNewObj.mobileDeviceSAPId = calculationResultObj.CharacteristicValue;
             String price = ((Map<String,String>) prodSapIdMap.get(calculationResultNewObj.mobileDeviceProductCode)).get('listPrice');
             calculationResultNewObj.mobileDeviceNRC = price;
             resultNewList.add(calculationResultNewObj);
			 
         }
       // endTime = dateTime.now().getTime();
		 return resultNewList;
    }
    // Method to add HW nodes for which no price is defined in the matrix
    public static void getNoPriceHardWare(List<CalculationResult> resultNewList1,List<CalculationResult> resultNewList2,Map<string, string> agreementMap,Map<String,String> agreementLinesCodeList,Map<string,Map<String,String>> prodSapIdMap ){

        List<String> cal1 = new List<String>();
        List<String> cal2 = new List<String>();
        for(CalculationResult calRes1 :resultNewList1){
            cal1.add(calRes1.mobileDeviceProductCode+calRes1.subscriptionProductCode);
        }
        for(CalculationResult calRes2 :resultNewList2){
            cal2.add(calRes2.mobileDeviceProductCode+calRes2.subscriptionProductCode);
        }
        for (String val : cal2) {
            if (!cal1.contains(val)) {
                resultNewList1.add(resultNewList2.get(cal2.indexOf(val)));
            }
        }
   }
   
}