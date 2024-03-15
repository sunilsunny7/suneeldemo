global without sharing class TeliaSE_Renegotiation implements vlocity_cmt.VlocityOpenInterface{
    public class ValidationException extends Exception{}
    public class TeliSE_RenegotiationWrapper{
        public String approval ='N';
        public Integer agreementTerm {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public String agreementId {get;set;}
        public String level {get;set;}
        public String status {get;set;}
        public String agreementType {get;set;}
        public String name {get;set;}
        public String paymentTerms {get;set;}
        public String renegotiation='Y';
        public String owner {get;set;}
        public String zeropricePlan ='N';
        public String subagreementExist='N';
        public Integer utilizerCount =0;
        public String switchingSolution='N';
        public String validswitchingSolution='N';
        public String sfAgreement='N';
        public String inOfferCode='N';
        public String inOffersCode='N';
        public String underInOffersCode='N';
        public String subsidisedVoice = 'N';
        
        //MINIDEB Function Variables - START
        //MCSTO-3036, MCSTO-2085
        public String miniDebTP='N';
        public String miniDebMobile='N';
        public String miniDebMobileWarningPercentage='';
        public String miniDebMobileWarningActive='N';
        public String miniDebMobileAgreedPercentage='';
        public String miniDebMobileFunctionActive='N';
        public String miniDebTPWarningPercentage='';
        public String miniDebTPWarningActive='N';
        public String miniDebTPAgreedPercentage='';
        public String miniDebTPFunctionActive='N';
        //MINIDEB Function Variables - END
        
        public String sfAgreementNumber {get;set;}
        public String quoteforClone {get;set;}
        public List<String> reasons= new List<String>();
        public String guidingTexts='';
    }
    public class TeliSE_RenegotiationMobileWrapper
    {
        public List<String> reasons= new List<String>();
        public String guidingTexts {get;set;}
        public String approval {get;set;}
    }
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        try
        {
            if (methodName.equals('renegotiateValidation'))
            {
                renegotiateValidation(inputMap,outMap);
            }
            else if (methodName.equals('hardwareRenegotiateValidation'))
            {
                hardwareRenegotiateValidation(inputMap,outMap);
            }
            else if (methodName.equals('nonMobileProductsCheck'))
            {
                nonMobileProductsCheck(inputMap,outMap);
            }
            
            /*
else if (methodName.equals('getMockup'))
{
getMockup(inputMap,outMap);
}
*/
            
            else 
            {
                result = false;
            }   
        } 
        catch(Exception e)
        {
            System.debug('exception: '+e);
            result = false;
            outMap.put('ErrorAgreement','Error');
            outMap.put('ErrorMessage',e.getMessage());
        }
        return result;
    }
    
    /* public static void getMockup(Map<String,Object> inputMap, Map<String,Object> outMap){
string jsonInput = '{"resultDesc":"Request with no errors","result":"OK","frameAgreements":[{"inOffers":[],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":null,"frameAgreementStartDate":"2000-01-01","inAgreement":null,"frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"UNDER","frameAgreementId":"00000012","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[{"status":"E","description":"DIRIGENT KONTROLL","version":0,"code":"DKOF¤"},{"status":"E","description":"DIRIGENT KONTROLL","version":0,"code":"DKOF4"},{"status":"E","description":"TEST","version":0,"code":"DKON"},{"status":"V","description":"OE4","version":0,"code":"OE4"},{"status":"E","description":"TMOE","version":0,"code":"TMOE"}],"minimiDebitFunctions":[{"productId":"MOBILE","agreedAmount":"100","agreedPercentage":"50","functionStartDate":"2020-06-22","functionActive":"Y","commitmentPeriod":"24","commitmentStartDate":"2020-03-22","commitmentStopDate":"2022-03-22","minimiDebitLastExecution":null,"minimiDebitTriggered":"N","minimiDebitLastCountAmount":null,"warningPercentage":"90","warningActive":"Y","warningLastExecution":null,"warningTriggered":"N","warningLastCountAmount":null},{"productId":"TOUCHPOINT","agreedAmount":"40","agreedPercentage":"50","functionStartDate":"2020-06-22","functionActive":"Y","commitmentPeriod":"12","commitmentStartDate":"2020-03-22","commitmentStopDate":"2021-03-22","minimiDebitLastExecution":null,"minimiDebitTriggered":"N","minimiDebitLastCountAmount":null,"warningPercentage":"90","warningActive":"Y","warningLastExecution":null,"warningTriggered":"N","warningLastCountAmount":null}],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":"2002-05-05","frameAgreementStartDate":"2000-09-25","inAgreement":"50505050","frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"00000024","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":null,"frameAgreementStartDate":"2002-02-25","inAgreement":null,"frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"00000026","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":"2000-05-05","frameAgreementStartDate":"2000-01-01","inAgreement":null,"frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"00000123","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[{"status":"E","description":"DIRIGENT KONTROLL","version":0,"code":"DKOF¤"},{"status":"E","description":"DIRIGENT KONTROLL","version":0,"code":"DKOF4"},{"status":"E","description":"TEST","version":0,"code":"DKON"},{"status":"V","description":"OE4","version":0,"code":"OE4"},{"status":"E","description":"TMOE","version":0,"code":"TMOE"}],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":"2001-05-25","frameAgreementStartDate":"2000-01-01","inAgreement":"50505050","frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"00000303","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":null,"frameAgreementStartDate":"2000-01-01","inAgreement":"1717","frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"00000317","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[{"status":"V","description":"KONTROLL ANYA","version":0,"code":"ANY"},{"status":"V","description":"ANY2","version":0,"code":"ANY2"},{"status":"V","description":"ANY3","version":0,"code":"ANY3"},{"status":"V","description":"ANY4-A","version":0,"code":"ANY4"},{"status":"V","description":"JAN JONSSON HA","version":0,"code":"JAN"},{"status":"V","description":"JANWO-NAMN","version":0,"code":"JANWO"},{"status":"V","description":"ANYA","version":0,"code":"LIS"},{"status":"V","description":"STEFAN LARSSON A","version":0,"code":"SLA"}],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":null,"frameAgreementStartDate":"2000-01-01","inAgreement":"00006301","frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"00000403","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":null,"frameAgreementStartDate":"2001-04-19","inAgreement":"00050311","frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"00000419","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[],"numberOfUtilizers":7,"zeroPriceExist":false,"frameAgreementEndDate":"2013-12-31","frameAgreementStartDate":"2004-12-01","inAgreement":null,"frameAgreementSuperior":null,"frameAgreementStatus":"E","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"00000555","customerRoleStatus":"V","customerRole":"U","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":null,"frameAgreementStartDate":"2001-01-01","inAgreement":null,"frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"00000607","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":null,"frameAgreementStartDate":"1999-08-07","inAgreement":null,"frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"00000608","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":"2002-02-23","frameAgreementStartDate":"2000-05-25","inAgreement":null,"frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"99999631","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"},{"inOffers":[],"minimiDebitFunctions":[{"productId":"MOBILE","agreedAmount":"100","agreedPercentage":"50","functionStartDate":"2020-06-22","functionActive":"Y","commitmentPeriod":"24","commitmentStartDate":"2020-03-22","commitmentStopDate":"2022-03-22","minimiDebitLastExecution":null,"minimiDebitTriggered":"N","minimiDebitLastCountAmount":null,"warningPercentage":"90","warningActive":"Y","warningLastExecution":null,"warningTriggered":"N","warningLastCountAmount":null},{"productId":"TOUCHPOINT","agreedAmount":"40","agreedPercentage":"50","functionStartDate":"2020-06-22","functionActive":"Y","commitmentPeriod":"12","commitmentStartDate":"2020-03-22","commitmentStopDate":"2021-03-22","minimiDebitLastExecution":null,"minimiDebitTriggered":"N","minimiDebitLastCountAmount":null,"warningPercentage":"90","warningActive":"Y","warningLastExecution":null,"warningTriggered":"N","warningLastCountAmount":null}],"numberOfUtilizers":0,"zeroPriceExist":false,"frameAgreementEndDate":"2002-05-05","frameAgreementStartDate":"2000-06-18","inAgreement":null,"frameAgreementSuperior":null,"frameAgreementStatus":"N","frameAgreementType":"STO","frameAgreementLevel":"RAM","frameAgreementId":"99999634","customerRoleStatus":"N","customerRole":"O","customerName":"AVTALSKUND AB","legalId":"6801057826"}]}';
Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(jsonInput);
outMap.put('CustomerAgreementSummary', jsonObj);
}
*/
    
    global static void renegotiateValidation(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
        try{
            //US-926
            //Integer touchPointAgreementsCount=0;
            String sfAgreementExist='N';
            String renegotiatable='N';
            TeliaSE_RenegotiationSettings__mdt metaData=[select TeliaSE_frameAgreementLevel__c,TeliaSE_frameAgreementType__c,TeliaSE_Status__c,TeliaSE_tourchpointCode__c from TeliaSE_RenegotiationSettings__mdt where DeveloperName='RenegotiationData'];
            Map<String,List<Object>> parentAgreementMap=new Map<String,List<Object>>();
            Map<String,Integer> agreementIdMap=new Map<String,Integer>();
            List<TeliSE_RenegotiationWrapper> frameAgreements= new List<TeliSE_RenegotiationWrapper>();
            
            String level=metaData.TeliaSE_frameAgreementLevel__c;
            String type=metaData.TeliaSE_frameAgreementType__c;
            String touchpointCode=metaData.TeliaSE_tourchpointCode__c;
            String status=metaData.TeliaSE_Status__c;
            String role='O';
            String zeroPriceList='false';
            
            TeliSE_RenegotiationWrapper wrapper;
            Map<String,Object> data=(Map<String,Object>)inputMap.get('CustomerAgreementSummary');
            String resultstatus=(String)data.get('result');
            if(resultstatus !='OK')
            {
                String errorMesage=System.Label.TeliaSE_Madam_Error;
                if((String)data.get('resultMessage') != null)
                {
                    errorMesage=errorMesage+'\n\n'+' Error Message(MADAM) : '+(String)data.get('resultMessage');
                    throw new ValidationException(errorMesage);    
                }
                else if((String)data.get('message') != null)
                {
                    errorMesage=errorMesage+'\n\n'+' Error Message(MADAM) : '+(String)data.get('error');
                    throw new ValidationException(errorMesage);    
                }
                else
                    throw new ValidationException(errorMesage);
                
            }
            List<Object> madamAgreements=(List<Object>)data.get('frameAgreements');
            if(madamAgreements.size() == 0)
            {
                outMap.put('MadamAgreements','N');
            }
            else
            {    
                for(Object obj:(List<Object>)data.get('frameAgreements'))
                {
                    Map<String,Object> objData=(Map<String,object>)obj;
                    if(String.valueOf(objData.get('frameAgreementLevel')).equals('UNDER'))
                    {
                        parentAgreementMap.put((String)objData.get('frameAgreementSuperior'),(List<Object>)objData.get('inOffers'));
                    }
                    agreementIdMap.put((String)objData.get('frameAgreementId'),null);
                }
                
                Map<String,Contract> contractMap=new Map<String,Contract>();
                Map<String,String> sfmadamIds=new Map<String,String>();
                for(Contract con:[select id,Agreement_Nr__c,vlocity_cmt__QuoteId__c,ContractNumber from Contract where status='Active' and Agreement_Nr__c =:agreementIdMap.keyset() and recordType.Name = 'Ramavtal'])
                {
                    sfmadamIds.put(con.Agreement_Nr__c,con.id);
                    contractMap.put(con.Agreement_Nr__c,con);
                }
                Map<String,Integer> utilizerCountMap=new Map<String,Integer>();
                for(Account acc:[select id,FA_Contract__c from Account where FA_Contract__c in (select id from Contract where Agreement_Nr__c =:agreementIdMap.keyset() and status='Active') and TeliaSE_Utilzer_Role__c='Utilizer'])
                {
                    if(utilizerCountMap.get(acc.FA_Contract__c) !=null)
                    {
                        utilizerCountMap.put(acc.FA_Contract__c,utilizerCountMap.get(acc.FA_Contract__c)+1);
                    }
                    else
                    {
                        utilizerCountMap.put(acc.FA_Contract__c,1);
                    }
                }
                
                for(String id:agreementIdMap.keyset())
                {
                    String utilizerCount=sfmadamIds.get(String.valueOf(utilizerCountMap.get(sfmadamIds.get(id))));
                    Integer count=utilizerCount!=null?Integer.valueOf(utilizerCount):0;
                    agreementIdMap.put(id,count);
                }
                
                for(Object obj:(List<Object>)data.get('frameAgreements'))
                {
                    wrapper=new TeliSE_RenegotiationWrapper();
                    wrapper.reasons.add(System.Label.TeliaSE_Agreement_Custom);
                    Map<String,Object> objData=(Map<String,object>)obj;
                    
                    //MCSTO-3036, MCSTO-2085 - START
                    List<Object> minimiDebitFunctionList1 = (List<Object>)objData.get('minimiDebitFunctions') != null ? (List<Object>)objData.get('minimiDebitFunctions') : null;
                    if(minimiDebitFunctionList1 != null && minimiDebitFunctionList1.size() > 0){
                        for(Object minimiDebitFunctionCurrObj : minimiDebitFunctionList1){
                            
                            Map<String,Object> minimiDebitFunctionObj = (Map<String,object>)minimiDebitFunctionCurrObj;
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('productId') != null && String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('MOBILE')){
                                wrapper.miniDebMobile = 'Y';
                            }
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('productId') != null && String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('TOUCHPOINT')){
                                wrapper.miniDebTP = 'Y';
                            }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('warningActive') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('warningActive')).equalsIgnoreCase('Y') && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('TOUCHPOINT')
                              ){
                                  wrapper.miniDebTPWarningActive = 'Y';
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('warningActive') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('warningActive')).equalsIgnoreCase('Y') && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('MOBILE')
                              ){
                                  wrapper.miniDebMobileWarningActive = 'Y';
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('warningPercentage') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('TOUCHPOINT')
                              ){
                                  wrapper.miniDebTPWarningPercentage = String.ValueOf(minimiDebitFunctionObj.get('warningPercentage'));
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('warningPercentage') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('MOBILE')
                              ){
                                  wrapper.miniDebMobileWarningPercentage = String.ValueOf(minimiDebitFunctionObj.get('warningPercentage'));
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('agreedPercentage') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('TOUCHPOINT')
                              ){
                                  wrapper.miniDebTPAgreedPercentage = String.ValueOf(minimiDebitFunctionObj.get('agreedPercentage'));
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('agreedPercentage') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('MOBILE')
                              ){
                                  wrapper.miniDebMobileAgreedPercentage = String.ValueOf(minimiDebitFunctionObj.get('agreedPercentage'));
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('functionActive') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('TOUCHPOINT')
                              ){
                                  wrapper.miniDebTPFunctionActive = String.ValueOf(minimiDebitFunctionObj.get('functionActive'));
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('functionActive') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('MOBILE')
                              ){
                                  wrapper.miniDebMobileFunctionActive = String.ValueOf(minimiDebitFunctionObj.get('functionActive'));
                              }
                        }
                    }
                    //MCSTO-3036, MCSTO-2085 - END
                    
                    if(!level.contains((String)objData.get('frameAgreementLevel')))
                    {
                        String message=System.Label.TeliaSE_Agreement_Level+' '+level;
                        wrapper.renegotiation='N';
                        wrapper.reasons.add(message);
                    }   
                    if(!type.contains((String)objData.get('frameAgreementType')))
                    {
                        String message=System.Label.TeliaSE_Agreement_Type+' '+type;
                        wrapper.renegotiation='N';
                        wrapper.reasons.add(message);
                    }
                    if(!status.contains((String)objData.get('frameAgreementStatus')))
                    {
                        String message=System.Label.TeliaSE_Agreement_Status;
                        wrapper.renegotiation='N';
                        wrapper.reasons.add(message);
                    }
                    if(!role.equals((String)objData.get('customerRole')))
                    {
                        String message=System.Label.TeliaSE_Agreement_Owner;
                        wrapper.renegotiation='N';
                        wrapper.reasons.add(message);
                    }
                    if((Boolean)objData.get('zeroPriceExist'))
                    {
                        String message=System.Label.TeliaSE_Zero_PriceList;
                        wrapper.renegotiation='N';
                        wrapper.zeropricePlan='Y';
                        wrapper.reasons.add(message);
                    }
                    /*if(parentAgreementMap.containsKey((String)objData.get('frameAgreementId')))
{
String message=System.Label.TeliaSE_Sub_Agreements;
wrapper.renegotiation='N';
wrapper.subagreementExist='Y';
wrapper.reasons.add(message);
}
*/
                    if(agreementIdMap.get((String)objData.get('frameAgreementId')) != null && agreementIdMap.get((String)objData.get('frameAgreementId')) != Integer.valueOf(objData.get('numberOfUtilizers')))
                    {
                        String temp=System.Label.TeliaSE_Guiding_Text1;
                        String temp1=temp.replace('XXX',String.valueOf(Integer.valueOf(objData.get('numberOfUtilizers'))));
                        String message=temp1.replace('YYY',String.valueOf(agreementIdMap.get((String)objData.get('frameAgreementId'))));
                        wrapper.guidingTexts=wrapper.guidingTexts+ '\n\n'+message;
                    }
                    if(sfmadamIds.get((String)objData.get('frameAgreementId')) != null)
                    {
                        Contract con=contractMap.get((String)objData.get('frameAgreementId'));
                        wrapper.sfAgreement='Y';
                        wrapper.sfAgreementNumber=con.ContractNumber;
                        wrapper.quoteforClone=con.vlocity_cmt__QuoteId__c;
                        if(role.equals((String)objData.get('customerRole')))
                        {
                            sfAgreementExist='Y';
                        }
                    }
                    wrapper.owner=(String)objData.get('customerRole')=='O'?System.Label.TeliaSE_OwnerAccount:System.Label.TeliaSE_UtilizerAccount;
                    wrapper.level=(String)objData.get('frameAgreementLevel');
                    wrapper.status=(String)objData.get('frameAgreementStatus')=='V'?System.Label.TeliaSE_Valid:System.Label.TeliaSE_Exist;
                    wrapper.agreementType=(String)objData.get('frameAgreementType');
                    wrapper.paymentTerms=(String)objData.get('paymentTerms');
                    wrapper.agreementId=(String)objData.get('frameAgreementId');
                    wrapper.utilizerCount=objData.get('numberOfUtilizers') != null?Integer.valueOf(objData.get('numberOfUtilizers')):0;
                    List<Object> inOffers=(List<Object>)objData.get('inOffers');
                    if(inOffers.size()>0 && wrapper.renegotiation!='N')
                    {
                        //US-926
                        //touchPointAgreementsCount++;
                        for(Object tpObj:(List<Object>)objData.get('inOffers'))
                        {
                            wrapper.switchingSolution='Y';
                            wrapper.validswitchingSolution='Y';
                            wrapper.inOffersCode='Y';
                            wrapper.renegotiation='Y';
                            wrapper.guidingTexts=wrapper.guidingTexts +'\n\n'+System.Label.TeliaSE_Guiding_Text3;
                            Map<String,Object> tpData=(Map<String,object>)tpObj;
                            if(!touchpointCode.contains((String)tpData.get('code')))
                            {
                                String message=System.Label.TeliaSE_Touchpoint_Code+' '+touchpointCode;
                                wrapper.renegotiation='N';
                                wrapper.validswitchingSolution='N';
                                wrapper.inOffersCode='N';
                                wrapper.reasons.add(message);
                                //US-926
                                //touchPointAgreementsCount--;
                                
                            }
                        }
                        
                    }
                    if(parentAgreementMap.containsKey((String)objData.get('frameAgreementId')))
                    {
                        List<Object> underInoffers = parentAgreementMap.get((String)objData.get('frameAgreementId'));
                        if(underInoffers.size()>0)
                        {
                            for(Object undertpObj : underInoffers)
                            {
                                wrapper.underInOffersCode='Y';
                                Map<String,Object> UndertpData=(Map<String,object>)undertpObj;
                                System.debug('UndertpData---->'+UndertpData);
                                if(!touchpointCode.contains((String)UndertpData.get('code')))
                                {
                                    wrapper.underInOffersCode='N';
                                }
                            }
                        }
                    }
                    
                    if(parentAgreementMap.containsKey((String)objData.get('frameAgreementId')) && (wrapper.inOffersCode == 'N') && (wrapper.underInOffersCode == 'N'))
                    {
                        String message=System.Label.TeliaSE_Sub_Agreements;
                        wrapper.renegotiation='N';
                        wrapper.subagreementExist='Y';
                        wrapper.reasons.add(message);                }
                    if(objData.get('frameAgreementStartDate') != null  && objData.get('frameAgreementEndDate') != null  
                       && wrapper.renegotiation !='N')
                    {
                        Date today=Date.today();
                        Date startDate=Date.valueOf((String)objData.get('frameAgreementStartDate'));
                        Date endDate=Date.valueOf((String)objData.get('frameAgreementEndDate'));
                        wrapper.startDate=startDate;
                        wrapper.endDate=endDate;
                        wrapper.agreementTerm=startDate.monthsBetween(endDate);
                        if(startDate.monthsBetween(endDate) >=12 && startDate.monthsBetween(endDate) < 24)
                        {
                            if(today.monthsBetween(endDate) <= 3)
                            {
                                wrapper.approval='N';
                            }
                            else
                            {
                                String temp=System.Label.TeliaSE_Guiding_Text2;
                                String temp1=temp.replace('XXX', String.valueOf(startDate.monthsBetween(endDate)));
                                String message=temp1.replace('YYY',String.valueOf(endDate));
                                wrapper.guidingTexts=wrapper.guidingTexts+'\n\n'+message;
                                wrapper.approval='Y';
                            }
                        }
                        else if(startDate.monthsBetween(endDate) >=24 && startDate.monthsBetween(endDate) < 36)
                        {
                            if(today.monthsBetween(endDate) <= 6)
                            {
                                wrapper.approval='N';
                            }
                            else
                            {   
                                String temp=System.Label.TeliaSE_Guiding_Text2;
                                String temp1=temp.replace('XXX', String.valueOf(startDate.monthsBetween(endDate)));
                                String message=temp1.replace('YYY',String.valueOf(endDate));
                                wrapper.guidingTexts=wrapper.guidingTexts+'\n\n' +message;
                                wrapper.approval='Y';
                            }
                        }
                        else if(startDate.monthsBetween(endDate) >=36)
                        {
                            if(today.monthsBetween(endDate) <= 6)
                            {
                                wrapper.approval='N';
                            }
                            else
                            {
                                String temp=System.Label.TeliaSE_Guiding_Text2;
                                String temp1=temp.replace('XXX', String.valueOf(startDate.monthsBetween(endDate)));
                                String message=temp1.replace('YYY',String.valueOf(endDate));
                                wrapper.guidingTexts=wrapper.guidingTexts+'\n\n'+message;
                                wrapper.approval='Y';
                            }
                        }
                    }
                    
                    frameAgreements.add(wrapper); 
                    if(wrapper.renegotiation == 'Y')
                    {
                        renegotiatable='Y';
                    }
                    
                    
                }
                outMap.put('MadamAgreements','Y');
            }
            Integer agreementIndex=0;
            //US-926
            //Integer agreementIndexTouchPoint=0;
            List<TeliSE_RenegotiationWrapper> tempList=new List<TeliSE_RenegotiationWrapper>();
            for(TeliSE_RenegotiationWrapper wrapp:frameAgreements)
            {
                if(wrapp.sfAgreement == 'Y')
                {
                    agreementIndex=frameAgreements.indexOf(wrapp);
                    //US-926
                    /*   agreementIndexTouchPoint=0;
tempList.clear();
tempList.add(wrapp);
}
else if(wrapp.switchingSolution == 'Y' && wrapp.validswitchingSolution == 'Y' && touchPointAgreementsCount == 1)
{
agreementIndexTouchPoint=frameAgreements.indexOf(wrapp);*/
                    tempList.add(wrapp);
                }
            }
            if(agreementIndex !=0 && agreementIndex != -1)
            {
                frameAgreements.remove(agreementIndex);
                tempList.addAll(frameAgreements);
                frameAgreements=tempList;
            }
            //US-926
            /*else if(agreementIndexTouchPoint !=0 && agreementIndexTouchPoint!=-1)
{
frameAgreements.remove(agreementIndexTouchPoint);
tempList.addAll(frameAgreements);
frameAgreements=tempList;
}
*/
            //Added by Praveena SALEF-3838
            List<TeliSE_RenegotiationWrapper> frameAgreement = new List<TeliSE_RenegotiationWrapper>();
            for(Integer i = 0; i<frameAgreements.size();i++){
                if(frameAgreements[i].renegotiation=='Y'){
                    frameAgreement.add(frameAgreements.get(i));
                }                 
            }
            for(Integer i = 0; i<frameAgreements.size();i++){
                if(frameAgreements[i].renegotiation=='N'){
                    frameAgreement.add(frameAgreements.get(i));
                }                 
            }
            outMap.put('frameAgreements',frameAgreement);
            outMap.put('renegotiatable',renegotiatable); 
            
            outMap.put('sfAgreementExist',sfAgreementExist);
            //outMap.put('touchPointCount',touchPointAgreementsCount);
        }catch(Exception e){
            outMap.put('Exception', e.getStackTraceString());
            system.debug('Exception on TeliaSE_Renegotiation : '+e.getStackTraceString());
        }
    }
    
    global static void hardwareRenegotiateValidation(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
        try{
            //US-926
            //Integer touchPointAgreementsCount=0;
            String sfAgreementExist='N';
            String renegotiatable='N';
            TeliaSE_RenegotiationSettings__mdt metaData=[select TeliaSE_frameAgreementLevel__c,TeliaSE_frameAgreementType__c,TeliaSE_Status__c,TeliaSE_tourchpointCode__c from TeliaSE_RenegotiationSettings__mdt where DeveloperName='HardwareRenegotiationData'];
            Map<String,String> parentAgreementMap=new Map<String,String>();
            Map<String,Integer> agreementIdMap=new Map<String,Integer>();
            List<TeliSE_RenegotiationWrapper> frameAgreements= new List<TeliSE_RenegotiationWrapper>();
            
            String level=metaData.TeliaSE_frameAgreementLevel__c;
            String type=metaData.TeliaSE_frameAgreementType__c;
            String touchpointCode=metaData.TeliaSE_tourchpointCode__c;
            String status=metaData.TeliaSE_Status__c;
            String role='O';
            String zeroPriceList='false';
            
            TeliSE_RenegotiationWrapper wrapper;
            Map<String,Object> data=(Map<String,Object>)inputMap.get('CustomerAgreementSummary');
            String resultstatus=(String)data.get('result');
            if(resultstatus !='OK')
            {
                String errorMesage=System.Label.TeliaSE_Madam_Error;
                if((String)data.get('resultMessage') != null)
                {
                    errorMesage=errorMesage+'\n\n'+' Error Message(MADAM) : '+(String)data.get('resultMessage');
                    throw new ValidationException(errorMesage);    
                }
                else if((String)data.get('message') != null)
                {
                    errorMesage=errorMesage+'\n\n'+' Error Message(MADAM) : '+(String)data.get('error');
                    throw new ValidationException(errorMesage);    
                }
                else
                    throw new ValidationException(errorMesage);
                
            }
            List<Object> madamAgreements=(List<Object>)data.get('frameAgreements');
            if(madamAgreements.size() == 0)
            {
                outMap.put('MadamAgreements','N');
            }
            else
            {    
                for(Object obj:(List<Object>)data.get('frameAgreements'))
                {
                    Map<String,Object> objData=(Map<String,object>)obj;
                    if(String.valueOf(objData.get('frameAgreementLevel')).equals('UNDER'))
                    {
                        parentAgreementMap.put((String)objData.get('frameAgreementSuperior'),null);
                    }
                    agreementIdMap.put((String)objData.get('frameAgreementId'),null);
                }
                
                Map<String,Contract> contractMap=new Map<String,Contract>();
                Map<String,String> sfmadamIds=new Map<String,String>();
                for(Contract con:[select id,Agreement_Nr__c,vlocity_cmt__QuoteId__c,ContractNumber from Contract where status='Active' and Agreement_Nr__c =:agreementIdMap.keyset()])
                {
                    sfmadamIds.put(con.Agreement_Nr__c,con.id);
                    contractMap.put(con.Agreement_Nr__c,con);
                }
                Map<String,Integer> utilizerCountMap=new Map<String,Integer>();
                for(Account acc:[select id,FA_Contract__c from Account where FA_Contract__c in (select id from Contract where Agreement_Nr__c =:agreementIdMap.keyset() and status='Active') and TeliaSE_Utilzer_Role__c='Utilizer'])
                {
                    if(utilizerCountMap.get(acc.FA_Contract__c) !=null)
                    {
                        utilizerCountMap.put(acc.FA_Contract__c,utilizerCountMap.get(acc.FA_Contract__c)+1);
                    }
                    else
                    {
                        utilizerCountMap.put(acc.FA_Contract__c,1);
                    }
                }
                
                for(String id:agreementIdMap.keyset())
                {
                    String utilizerCount=sfmadamIds.get(String.valueOf(utilizerCountMap.get(sfmadamIds.get(id))));
                    Integer count=utilizerCount!=null?Integer.valueOf(utilizerCount):0;
                    agreementIdMap.put(id,count);
                }
                for(Object obj:(List<Object>)data.get('frameAgreements'))
                {
                    wrapper=new TeliSE_RenegotiationWrapper();
                    wrapper.reasons.add(System.Label.TeliaSE_Agreement_Custom);
                    Map<String,Object> objData=(Map<String,object>)obj;
                    List<Object> inOfferList = (List<Object>)objData.get('inOffers') != null ? (List<Object>)objData.get('inOffers') : null;
                    if(inOfferList != null && inOfferList.size() > 0){
                        
                        for(Object inOffer : inOfferList){
                            
                            Map<String,Object> inOfferObj = (Map<String,object>)inOffer;
                            List<String> allCodes = System.Label.TeliaSE_MC_SubAgreementCodes.split(',');
                            
                            if(inOfferObj != null && inOfferObj.get('code') != null && allCodes.contains(String.valueOf(inOfferObj.get('code'))) ){
                                wrapper.inOfferCode = 'Y';
                            }
                        }
                    }else{
                        wrapper.inOfferCode = 'Y';
                    }
                    
                    
                    List<Object> minimiDebitFunctionList1 = (List<Object>)objData.get('minimiDebitFunctions') != null ? (List<Object>)objData.get('minimiDebitFunctions') : null;
                    if(minimiDebitFunctionList1 != null && minimiDebitFunctionList1.size() > 0){
                        for(Object minimiDebitFunctionCurrObj : minimiDebitFunctionList1){
                            
                            Map<String,Object> minimiDebitFunctionObj = (Map<String,object>)minimiDebitFunctionCurrObj;
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('productId') != null && String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('MOBILE')){
                                wrapper.miniDebMobile = 'Y';
                            }
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('productId') != null && String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('TOUCHPOINT')){
                                wrapper.miniDebTP = 'Y';
                            }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('warningActive') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('warningActive')).equalsIgnoreCase('Y') && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('TOUCHPOINT')
                              ){
                                  wrapper.miniDebTPWarningActive = 'Y';
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('warningActive') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('warningActive')).equalsIgnoreCase('Y') && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('MOBILE')
                              ){
                                  wrapper.miniDebMobileWarningActive = 'Y';
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('warningPercentage') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('TOUCHPOINT')
                              ){
                                  wrapper.miniDebTPWarningPercentage = String.ValueOf(minimiDebitFunctionObj.get('warningPercentage'));
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('warningPercentage') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('MOBILE')
                              ){
                                  wrapper.miniDebMobileWarningPercentage = String.ValueOf(minimiDebitFunctionObj.get('warningPercentage'));
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('agreedPercentage') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('TOUCHPOINT')
                              ){
                                  wrapper.miniDebTPAgreedPercentage = String.ValueOf(minimiDebitFunctionObj.get('agreedPercentage'));
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('agreedPercentage') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('MOBILE')
                              ){
                                  wrapper.miniDebMobileAgreedPercentage = String.ValueOf(minimiDebitFunctionObj.get('agreedPercentage'));
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('functionActive') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('TOUCHPOINT')
                              ){
                                  wrapper.miniDebTPFunctionActive = String.ValueOf(minimiDebitFunctionObj.get('functionActive'));
                              }
                            
                            if(minimiDebitFunctionObj != null && minimiDebitFunctionObj.get('functionActive') != null && 
                               String.ValueOf(minimiDebitFunctionObj.get('productId')).equalsIgnoreCase('MOBILE')
                              ){
                                  wrapper.miniDebMobileFunctionActive = String.ValueOf(minimiDebitFunctionObj.get('functionActive'));
                              }
                        }
                    }
                    
                    if(!level.contains((String)objData.get('frameAgreementLevel')))
                    {
                        String message=System.Label.TeliaSE_Agreement_Level+' '+level;
                        wrapper.renegotiation='N';
                        wrapper.reasons.add(message);
                    }   
                    if(!type.contains((String)objData.get('frameAgreementType')))
                    {
                        String message=System.Label.TeliaSE_Agreement_Type+' '+type;
                        wrapper.renegotiation='N';
                        wrapper.reasons.add(message);
                    }
                    if(!status.contains((String)objData.get('frameAgreementStatus')))
                    {
                        String message=System.Label.TeliaSE_Agreement_Status;
                        wrapper.renegotiation='N';
                        wrapper.reasons.add(message);
                    }
                    if(!role.equals((String)objData.get('customerRole')))
                    {
                        String message=System.Label.TeliaSE_Agreement_Owner;
                        wrapper.renegotiation='N';
                        wrapper.reasons.add(message);
                    }
                    if((Boolean)objData.get('zeroPriceExist'))
                    {
                        String message=System.Label.TeliaSE_Zero_PriceList;
                        wrapper.renegotiation='N';
                        wrapper.zeropricePlan='Y';
                        wrapper.reasons.add(message);
                    }
                    if(parentAgreementMap.containsKey((String)objData.get('frameAgreementId')))
                    {
                        String message=System.Label.TeliaSE_Sub_Agreements;
                        wrapper.renegotiation='N';
                        wrapper.subagreementExist='Y';
                        wrapper.reasons.add(message);
                    }
                    if(agreementIdMap.get((String)objData.get('frameAgreementId')) != null && agreementIdMap.get((String)objData.get('frameAgreementId')) != Integer.valueOf(objData.get('numberOfUtilizers')))
                    {
                        String temp=System.Label.TeliaSE_Guiding_Text1;
                        String temp1=temp.replace('XXX',String.valueOf(Integer.valueOf(objData.get('numberOfUtilizers'))));
                        String message=temp1.replace('YYY',String.valueOf(agreementIdMap.get((String)objData.get('frameAgreementId'))));
                        wrapper.guidingTexts=wrapper.guidingTexts+ '\n\n'+message;
                    }
                    if(sfmadamIds.get((String)objData.get('frameAgreementId')) != null)
                    {
                        Contract con=contractMap.get((String)objData.get('frameAgreementId'));
                        wrapper.sfAgreement='Y';
                        wrapper.sfAgreementNumber=con.ContractNumber;
                        wrapper.quoteforClone=con.vlocity_cmt__QuoteId__c;
                        sfAgreementExist='Y';
                    }
                    wrapper.owner=(String)objData.get('customerRole')=='O'?System.Label.TeliaSE_OwnerAccount:System.Label.TeliaSE_UtilizerAccount;
                    wrapper.level=(String)objData.get('frameAgreementLevel');
                    wrapper.status=(String)objData.get('frameAgreementStatus')=='V'?System.Label.TeliaSE_Valid:System.Label.TeliaSE_Exist;
                    wrapper.agreementType=(String)objData.get('frameAgreementType');
                    wrapper.subsidisedVoice = (String)objData.get('subsidisedVoice');
                    wrapper.agreementId=(String)objData.get('frameAgreementId');
                    wrapper.utilizerCount=objData.get('numberOfUtilizers') != null?Integer.valueOf(objData.get('numberOfUtilizers')):0;
                    List<Object> inOffers=(List<Object>)objData.get('inOffers');
                    if(inOffers.size()>0)
                    {
                        //US-926
                        //touchPointAgreementsCount++;
                        for(Object tpObj:(List<Object>)objData.get('inOffers'))
                        {
                            wrapper.switchingSolution='Y';
                            wrapper.validswitchingSolution='Y';
                            wrapper.guidingTexts=wrapper.guidingTexts +'\n\n'+System.Label.TeliaSE_Guiding_Text3;
                            Map<String,Object> tpData=(Map<String,object>)tpObj;
                            if(!touchpointCode.contains((String)tpData.get('code')))
                            {
                                String message=System.Label.TeliaSE_Touchpoint_Code+' '+touchpointCode;
                                wrapper.renegotiation='N';
                                wrapper.validswitchingSolution='N';
                                wrapper.reasons.add(message);
                                //US-926
                                //touchPointAgreementsCount--;
                                break;
                            }
                        }
                        
                    }
                    if(objData.get('frameAgreementStartDate') != null  && objData.get('frameAgreementEndDate') != null  
                       && wrapper.renegotiation !='N')
                    {
                        Date today=Date.today();
                        Date startDate=Date.valueOf((String)objData.get('frameAgreementStartDate'));
                        Date endDate=Date.valueOf((String)objData.get('frameAgreementEndDate'));
                        wrapper.startDate=startDate;
                        wrapper.endDate=endDate;
                        wrapper.agreementTerm=startDate.monthsBetween(endDate);
                        if(startDate.monthsBetween(endDate) >=12 && startDate.monthsBetween(endDate) < 24)
                        {
                            if(today.monthsBetween(endDate) <= 3)
                            {
                                wrapper.approval='N';
                            }
                            else
                            {
                                String temp=System.Label.TeliaSE_Guiding_Text2;
                                String temp1=temp.replace('XXX', String.valueOf(startDate.monthsBetween(endDate)));
                                String message=temp1.replace('YYY',String.valueOf(endDate));
                                wrapper.guidingTexts=wrapper.guidingTexts+'\n\n'+message;
                                wrapper.approval='Y';
                            }
                        }
                        else if(startDate.monthsBetween(endDate) >=24 && startDate.monthsBetween(endDate) < 36)
                        {
                            if(today.monthsBetween(endDate) <= 6)
                            {
                                wrapper.approval='N';
                            }
                            else
                            {   
                                String temp=System.Label.TeliaSE_Guiding_Text2;
                                String temp1=temp.replace('XXX', String.valueOf(startDate.monthsBetween(endDate)));
                                String message=temp1.replace('YYY',String.valueOf(endDate));
                                wrapper.guidingTexts=wrapper.guidingTexts+'\n\n' +message;
                                wrapper.approval='Y';
                            }
                        }
                        else if(startDate.monthsBetween(endDate) >=36)
                        {
                            if(today.monthsBetween(endDate) <= 6)
                            {
                                wrapper.approval='N';
                            }
                            else
                            {
                                String temp=System.Label.TeliaSE_Guiding_Text2;
                                String temp1=temp.replace('XXX', String.valueOf(startDate.monthsBetween(endDate)));
                                String message=temp1.replace('YYY',String.valueOf(endDate));
                                wrapper.guidingTexts=wrapper.guidingTexts+'\n\n'+message;
                                wrapper.approval='Y';
                            }
                        }
                    }
                    
                    frameAgreements.add(wrapper); 
                    if(wrapper.renegotiation == 'Y')
                    {
                        renegotiatable='Y';
                    }
                    
                    
                }
                outMap.put('MadamAgreements','Y');
            }
            Integer agreementIndex=0;
            //US-926
            //Integer agreementIndexTouchPoint=0;
            List<TeliSE_RenegotiationWrapper> tempList=new List<TeliSE_RenegotiationWrapper>();
            for(TeliSE_RenegotiationWrapper wrapp:frameAgreements)
            {
                if(wrapp.sfAgreement == 'Y')
                {
                    agreementIndex=frameAgreements.indexOf(wrapp);
                    //US-926
                    /*   agreementIndexTouchPoint=0;
tempList.clear();
tempList.add(wrapp);
}
else if(wrapp.switchingSolution == 'Y' && wrapp.validswitchingSolution == 'Y' && touchPointAgreementsCount == 1)
{
agreementIndexTouchPoint=frameAgreements.indexOf(wrapp);*/
                    tempList.add(wrapp);
                }
            }
            if(agreementIndex !=0 && agreementIndex != -1)
            {
                frameAgreements.remove(agreementIndex);
                tempList.addAll(frameAgreements);
                frameAgreements=tempList;
            }
            //US-926
            /*else if(agreementIndexTouchPoint !=0 && agreementIndexTouchPoint!=-1)
{
frameAgreements.remove(agreementIndexTouchPoint);
tempList.addAll(frameAgreements);
frameAgreements=tempList;
}
*/
            outMap.put('frameAgreements',frameAgreements);
            outMap.put('renegotiatable',renegotiatable);
            outMap.put('sfAgreementExist',sfAgreementExist);
            //outMap.put('touchPointCount',touchPointAgreementsCount);
        }catch(Exception e){
            outMap.put('Exception', e.getStackTraceString());
            system.debug('Exception on TeliaSE_Renegotiation : '+e.getStackTraceString());
        }
    }
    
    
    private static void nonMobileProductsCheck(Map<String,Object> inputMap, Map<String,Object> outMap)
    {
        Map<String,Object> contractDetails = (Map<String,Object>) inputMap.get('ContractDetails');
        Boolean contractExist = (Boolean) contractDetails.get('ContractExist');
        Boolean isNonMobile=false;
        if(contractExist)
        {
            isNonMobile = true;
            TeliSE_RenegotiationMobileWrapper wrapper =new TeliSE_RenegotiationMobileWrapper();
            //Contract con=[select startDate,endDate from Contract where id=:agreementId];
            Date startDate=date.valueOf((String)contractDetails.get('ContractStartDate'));
            Date endDate=date.valueOf((String)contractDetails.get('ContractEndDate'));
            Date today=Date.today();
            if(startDate.monthsBetween(endDate) >=12 && startDate.monthsBetween(endDate) < 24)
            {
                if(today.monthsBetween(endDate) <= 3)
                {
                    wrapper.approval='N';
                }
                else 
                {
                    String temp=System.Label.TeliaSE_Guiding_Text2;
                    String temp1=temp.replace('XXX', String.valueOf(startDate.monthsBetween(endDate)));
                    String message=temp1.replace('YYY',String.valueOf(endDate));
                    wrapper.guidingTexts=wrapper.guidingTexts+'\n\n'+message;
                    wrapper.approval='Y';
                }
            }
            else if(startDate.monthsBetween(endDate) >=24 && startDate.monthsBetween(endDate) < 36)
            {
                if(today.monthsBetween(endDate) <= 6)
                {
                    wrapper.approval='N';
                }
                else 
                {
                    String temp=System.Label.TeliaSE_Guiding_Text2;
                    String temp1=temp.replace('XXX', String.valueOf(startDate.monthsBetween(endDate)));
                    String message=temp1.replace('YYY',String.valueOf(endDate));
                    wrapper.guidingTexts=wrapper.guidingTexts+'\n\n'+message;
                    wrapper.approval='Y';
                }
            }
            else if(startDate.monthsBetween(endDate) >=36)
            {
                if(today.monthsBetween(endDate) <= 6)
                {
                    wrapper.approval='N';
                }
                else 
                {
                    String temp=System.Label.TeliaSE_Guiding_Text2;
                    String temp1=temp.replace('XXX', String.valueOf(startDate.monthsBetween(endDate)));
                    String message=temp1.replace('YYY',String.valueOf(endDate));
                    wrapper.guidingTexts=wrapper.guidingTexts+'\n\n'+message;
                    wrapper.approval='Y';
                }
            }           
            outMap.put('NonMobileAgreement',wrapper);
        }
        outMap.put('isNonMobile',isNonMobile);
    }
}