public class HardwareServices{    
    public static List<Mobilabonnemang__c> invokeGetSubscriptionsIntegrationProcedure(string accId,Map<String,Object> ResponseMapTest){
        string ProcedureName = 'Hardware_GetSubscriptions';
        Boolean BindingTimeCalc = false;
        String trimBindingTime = '',StringBindingTime = '',startDate = '',endDate = '';
        Integer bindTimecalc;
        String stringBindTimeCalc = '';
        Map<String, Object> inputMap = new Map<String, Object>();
        Map<String, Object> optionsMap = new Map<String, Object>();
        inputMap.put('AccountId',accId);
        Map<String, Object> ResponseMap = new Map<String, Object>();
        if(Test.isRunningTest()){
            ResponseMap = ResponseMapTest;
        }
        if(!Test.isRunningTest()){
            ResponseMap = invokeIntegrationProcedure(ProcedureName,inputMap,optionsMap,optionsMap,null);
        }
        Map<String, Object> Response2Map = (Map<String,Object>)ResponseMap.get('Response2');  
        system.debug('response2:'+ Response2Map);
        Map<String, Object> dataMap = (Map<String,Object>)Response2Map.get('data');        
        Map<String, Object> SubscriptionMap = (Map<String,Object>)dataMap.get('Subscriptions');
        List<Mobilabonnemang__c> mobList = new List<Mobilabonnemang__c>();
        for(Object hrdObj1:(List<Object>)SubscriptionMap.get('select')){
            Mobilabonnemang__c mbObj = new Mobilabonnemang__c();
            Map<String,Object> hrdObj = (Map<String,Object>)hrdObj1;
            String headerCmtmntDate  = String.ValueOf(hrdObj.get('commitmentenddate'));
            if(headerCmtmntDate == null || headerCmtmntDate == ''){
                mbObj.Allowed_To_Bind__c = 'NEJ';
            }
            else{
                Integer yr2 = Integer.valueOf(headerCmtmntDate.substring(0,4)),month2 = Integer.valueOf(headerCmtmntDate.substring(4,6)),day2 = Integer.valueOf(headerCmtmntDate.substring(6,8));
                Date headerValDate = Date.newInstance(yr2,month2,day2);
                bindTimecalc = headerValDate.daysBetween(Date.today());
                stringBindTimeCalc = String.Valueof(bindTimecalc);
                if(stringBindTimeCalc.contains('-')){
                    bindTimecalc = Integer.Valueof(stringBindTimeCalc.replace('-',''));
                }
                if(bindTimecalc > 90){
                    mbObj.Allowed_To_Bind__c = 'NEJ';
                } else mbObj.Allowed_To_Bind__c = 'JA';
            }
            List<Object> mobileServiceList = (List<Object>)hrdObj.get('mobileservices')!= null ? (List<Object>)hrdObj.get('mobileservices') : null;
            Map<String,TeliaSE_MC_Roaming_Addons__c> mcs = TeliaSE_MC_Roaming_Addons__c.getall();
            String romingDetails ='';
            if(mobileServiceList != null && mobileServiceList.size()>0){
                for(Object mobileService : mobileServiceList){
                    Map<String,Object> mobileServiceObj = (Map<String,object>)mobileService;
                    if(mobileServiceObj != null && mobileServiceObj.get('servicecode') != null){ 
                        if(String.ValueOf(mobileServiceObj.get('servicecode')).equalsIgnoreCase('BND') && String.ValueOf(mobileServiceObj.get('servicevalue'))!= '0'){
                            mbObj.Subsidized_Subscription__c = 'JA';
                        } else if(mbObj.Subsidized_Subscription__c != 'JA'){
                            mbObj.Subsidized_Subscription__c = 'NEJ';
                        }
                        if(mbObj.Allowed_To_Bind__c == 'NEJ' && mbObj.Subsidized_Subscription__c == 'NEJ'){
                            mbObj.Subsidized_Subscription__c = 'NEJ';
                        } else mbObj.Subsidized_Subscription__c = 'JA';                      
                        String roaming = (String)mobileServiceObj.get('servicecode');                        
                        if(TeliaSE_MC_Roaming_Addons__c.getValues(roaming) != null){
                            romingDetails= romingDetails!=''?romingDetails+','+TeliaSE_MC_Roaming_Addons__c.getValues(roaming).AddOn_Description__c:TeliaSE_MC_Roaming_Addons__c.getValues(roaming).AddOn_Description__c; 
                        }
                    }
                    List<Object> mobileAttrList = (List<Object>)mobileServiceObj.get('attributes')!= null ? (List<Object>)mobileServiceObj.get('attributes') : null; 
                    if(mobileAttrList != null && mobileAttrList.size()>0){
                        for(Object mobileAttr : mobileAttrList){
                            Map<String,Object> mobileAttrObj = (Map<String,object>)mobileAttr;
                            if(bindTimecalc < 90 && mobileAttrObj != null){
                                if(String.ValueOf(mobileAttrObj.get('attributename')) == 'NextCommitmentEndDate' && mbObj.Allowed_To_Bind__c != 'No'){
                                    mbObj.Allowed_To_Bind__c = 'NEJ'; 
                                }
                                else if(String.ValueOf(mobileAttrObj.get('attributename')) !='NextCommitmentEndDate'){
                                    mbObj.Allowed_To_Bind__c = 'JA';  
                                }
                            }
                            if(mobileAttrObj != null && mobileServiceObj.get('servicecode') != null && String.ValueOf(mobileServiceObj.get('servicecode')).equalsIgnoreCase('BND') && String.ValueOf(mobileAttrObj.get('attributename')).equalsIgnoreCase('NextCommitmentEndDate') && mobileAttrObj.get('attributevalue') != null){    
                                String nextCommitmentEndDate = String.ValueOf(mobileAttrObj.get('attributevalue'));
                                Integer yr = Integer.valueOf(nextCommitmentEndDate.substring(0,4)),month = Integer.valueOf(nextCommitmentEndDate.substring(4,6)),day = Integer.valueOf(nextCommitmentEndDate.substring(6,8));
                                Date attValDate = Date.newInstance(yr,month,day);

                                Integer bindingTime = attValDate.daysBetween(Date.today());
                                StringBindingTime = String.Valueof(bindingTime);    
                                if(StringBindingTime.contains('-')){
                                    trimBindingTime = StringBindingTime.replace('-','');
                                    mbObj.Binding_Time_Left__c = String.Valueof(trimBindingTime) +' dagar';
                                }
                                else{
                                    mbObj.Binding_Time_Left__c = String.Valueof(StringBindingTime) +' dagar';
                                }
                            }                            
                            else{
                                String cmtmntEnddate = String.ValueOf(hrdObj.get('commitmentenddate'));
                                if(cmtmntEnddate != null){
                                    Integer yr1 = Integer.valueOf(cmtmntEnddate.substring(0,4)),month1 = Integer.valueOf(cmtmntEnddate.substring(4,6)),day1 = Integer.valueOf(cmtmntEnddate.substring(6,8)); 
                                    Date attValDate1 = Date.newInstance(yr1,month1,day1);
                                    Integer bindingTime1 = attValDate1.daysBetween(Date.today());
                                    StringBindingTime = String.Valueof(bindingTime1);                                  
                                    if(StringBindingTime.contains('-')){
                                        trimBindingTime = StringBindingTime.replace('-','');
                                        mbObj.Binding_Time_Left__c = String.Valueof(trimBindingTime) +' dagar';
                                    }
                                    else{
                                        mbObj.Binding_Time_Left__c = String.Valueof(StringBindingTime) +' dagar';
                                    }
                                }                                
                            }
                        }
                    }
                }              
            }
            mbObj.Agreement__c = 'NEJ';
            mbObj.Category__c = String.ValueOf(hrdObj.get('categoryname'));
            mbObj.GPRS_Service_Allowance__c = '';
            mbObj.MSISDN__c = String.ValueOf(hrdObj.get('last_used_imeisv_number'));
            mbObj.Account__c = String.ValueOf(accId);
            mbObj.Subscription_Id__c = String.ValueOf(hrdObj.get('subscriptionid'));
            mbObj.Offering_Name__c = String.ValueOf(hrdObj.get('offeringnameofferingcode'));
            endDate = String.ValueOf(hrdObj.get('commitmentenddate'));
            if(endDate != null){
                String yy = endDate.substring(0,4),mm = endDate.substring(4,6),dd = endDate.substring(6,8);
                endDate = yy+'-'+mm+'-'+dd;
                mbObj.CommitmentEndDate__c = endDate;
            }
            mbObj.CommitmentStartDate__c = String.ValueOf(hrdObj.get('commitmentstartdate'));
            mbObj.CommitmentLength__c = String.ValueOf(hrdObj.get('commitmentlength'));
            mbObj.Start_Date__c = String.ValueOf(hrdObj.get('startdate'));
            mbObj.Subscription_Type__c = String.ValueOf(hrdObj.get('subscriptiontypecategory'));
            mbObj.TeliaSE_Subscription_Name__c = String.ValueOf(hrdObj.get('offeringname'));
            mbObj.TeliaSE_User_Name__c = String.ValueOf(hrdObj.get('customername'));
            mbObj.Last_Used_Model__c= String.ValueOf(hrdObj.get('last_used_model_by_imei'));
            mbObj.MSISDN__c = String.ValueOf(hrdObj.get('last_used_imeisv_number'));
            if(romingDetails != null){
                mbObj.Roaming_Service_Descr__c = romingDetails;
            }
            mobList.add(mbObj);
        }
        if(mobList.size() > 0){
            insert mobList;
        }
        return mobList;
    }
/*
 * Description: calling Integration Procedure and sending the response to "invokeGetSubscriptionsIntegrationProcedure" method
 */    
    public static Map<String,Object> invokeIntegrationProcedure(string ProcedureName,Map<String,Object> input,Map<String,Object> output,Map<String,Object> options,Map<String,Object> ResponseMapTest){
        try{
            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> optionsMap = new Map<String,Object>();
            Object result;
            if(Test.isRunningTest()){
                result = ResponseMapTest;
            }
            if(!Test.isRunningTest()){
                result = vlocity_cmt.IntegrationProcedureService.runIntegrationService(ProcedureName,input,optionsMap);
            }
            output.put('Result',result);
            String str = String.valueOf(result);
            string jsonstr = JSON.serialize(result);
            Map<String, Object> m = (Map<String,Object>)JSON.deserializeUntyped(jsonstr);
            return m;
        }
        catch(Exception e){
            System.debug('EXCEPTION>>>>>>>');
            system.debug(e);
            system.debug(e.getStackTraceString());
            return null;
        }
    }
}