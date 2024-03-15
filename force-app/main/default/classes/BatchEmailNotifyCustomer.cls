public class BatchEmailNotifyCustomer implements Database.Batchable<sObject>,Database.Stateful{
    public List<Id> totalErrorIds;
    public BatchEmailNotifyCustomer(){
        totalErrorIds = new List<Id>();
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        date todaysDate = system.today();
        String CUSTOMER_CONTACT_ID = SEUtility.getRecordTypeId(SEUtility.CONTACT_RECTYPE_CUSTOMER);
        String IntegrationIdVal = System.Label.Integration_User_Id;
        String SMEIntegrationIdVal = System.Label.SME_Integration_User_Id;
        
        String query = 'SELECT Id,Email,AccountId,Hard_Bounce__c,Account.Parent.OwnerId,Account.Parent.Owner.Email,Account.Parent.Owner.Phone,Account.Parent.Is_Owner_Changed__c FROM Contact WHERE recordtypeId=: CUSTOMER_CONTACT_ID' +
            ' AND Account.Parent.Is_Owner_Changed__c =: todaysDate ' +
            ' AND Inaktiv__c =False' +
            ' AND Hard_Bounce__c =False' +
            ' AND pi__pardot_hard_bounced__c = False' +
            ' AND Account.Parent.OwnerId !=: IntegrationIdVal' +
            ' AND Account.Parent.OwnerId !=: SMEIntegrationIdVal' +
            ' AND Marketing_Mails_Opt_Out_Contact__c =null';
        system.debug('query-'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        system.debug('Switch Val:'+Label.OwnerChangeNotification.toUpperCase());
        String SELLER_EMAIL_TEMPLATE_NAME = 'SMESaleskundmallNyAM';
        String MANAGER_EMAIL_TEMPLATE_NAME = 'SMESaleskundmallNyAMverB';
        SET<ID>AccountParentIds = new SET<ID>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'noreply-salesforce@teliacompany.com' LIMIT 1];
        
        //Assign Sales Team to Map
        
        //Check if the functionality needs to be executed
        if((Label.OwnerChangeNotification).toUpperCase() == 'TRUE'){
            system.debug('scope:'+scope);
            List<FeedItem> listofFeedItem = new List<FeedItem>();
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            Map<Id,Seller__c> mapofsellerRec = new Map<Id,Seller__c>();
            Map<String,EmailTemplate> mapofTemplate = new Map<String,EmailTemplate>();
            Map<Id,String>mapOfAcchist = new Map<Id,String>();
            
            //Get the Email Template
            for (EmailTemplate eTemplate : [select Id,DeveloperName,htmlvalue,Body from EmailTemplate where DeveloperName IN (:SELLER_EMAIL_TEMPLATE_NAME,:MANAGER_EMAIL_TEMPLATE_NAME)]){
                if(eTemplate.DeveloperName == SELLER_EMAIL_TEMPLATE_NAME){
                    mapofTemplate.put('Seller',eTemplate);
                }else
                    mapofTemplate.put('SellerManager',eTemplate);
            }
            system.debug('EmailList:'+mapofTemplate);
            
            //Get the Parent Account Id from Scope
            for(Sobject conObjRec : scope){
                Contact conrec = (Contact)conObjRec;
                AccountParentIds.add(conrec.Account.ParentId);
            }
            system.debug('Changed KKNR'+AccountParentIds);
            
            //Get the Seller Record
            for (Seller__c rec : [select id,Type__c,User__c,Sales_Team_Name__c,Sales_Unit_Name__c from seller__c where Sales_Team_Name__c !='SME Sales Nykund' AND Sales_Unit_Name__c = 'SME' AND End_Date__c > :system.today() AND Type__c IN ('Seller','Sales Team Manager')]){
                mapofsellerRec.put(rec.User__c,rec);
            }
            system.debug('@@@'+mapofsellerRec);
            
            //Get the Account History in a Map
            for(AccountHistory acchist : [select AccountId, OldValue, Newvalue, Field 
                                          From AccountHistory where Field = 'Owner' AND 
                                          AccountId IN :AccountParentIds AND 
                                          DAY_ONLY(CreatedDate) =:system.today() ORDER BY CreatedDate ASC]){
                                              String newVal = (String)acchist.Newvalue; 
                                              if(!newVal.startswith('005')){
                                                  mapOfAcchist.put(acchist.AccountId,newVal);    
                                              }
                                          }
            system.debug('mapOfAcchist-'+mapOfAcchist);
            
            //Iterate the scope object
            for(Sobject conObj : scope){
                Contact con = (Contact)conObj;
                if(mapofsellerRec.containsKey(con.Account.Parent.OwnerId)){
                    system.debug('###'+con.account.parentId);
                    
                    /*For Test Class generation
List<AccountHistory> tempList = new List<AccountHistory>();
AccountHistory TestRecordAcc = new AccountHistory();
TestRecordAcc.Field ='Owner';
tempList.add(TestRecordAcc); */
                    
                    //Get the history details
                    String newValCapture = Test.isRunningTest() ? 'USERVALUE' :mapOfAcchist.get(con.Account.parentId);
                    system.debug('###'+newValCapture);
                    
                    //Create Single Email Message
                    Messaging.SingleEmailMessage mailMsg = new Messaging.SingleEmailMessage();
                    mailMsg.setTargetObjectId(con.Id);
                    mailMsg.setOrgWideEmailAddressId(owea.get(0).Id);
                    mailMsg.setSaveAsActivity(false);
                    
                    //Create FeedItem
                    FeedItem postItem = new FeedItem();
                    postItem.ParentId = con.Id;
                    
                    //Check if the user is Seller or Sales Team Manager
                    if(mapofsellerRec.get(con.Account.Parent.OwnerId).Type__c =='Seller'){
                        
                        //Set Template Body
                        String updateEmailbdy='';
                        String emailBody = mapofTemplate.get('Seller').HTMLValue;
                        updateEmailbdy = emailBody.replace('{{{Sender.Name}}}',newValCapture).replace('{{{Sender.Phone}}}',con.Account.Parent.Owner.Phone !=null?con.Account.Parent.Owner.Phone:'').replace('{{{Sender.Email}}}',con.Account.Parent.Owner.Email);
                        system.debug('updateEmailbdy-'+updateEmailbdy);
                        
                        //Set Template
                        mailMsg.setHtmlBody(updateEmailbdy);
                        mailMsg.setSubject('Ny kontaktperson på Telia');
                        mailMsg.setTemplateId(mapofTemplate.get('Seller').Id);
                        
                        //Post Feed
                        String plainTextbody = mapofTemplate.get('Seller').Body;
                        String updatedplainText = plainTextbody.replace('{{{Sender.Name}}}',newValCapture).replace('{{{Sender.Phone}}}',con.Account.Parent.Owner.Phone !=null?con.Account.Parent.Owner.Phone:'').replace('{{{Sender.Email}}}',con.Account.Parent.Owner.Email);
                        String feedEmailbody = 'Sent Email at '+system.today()+'\n'+updatedplainText;
                        postItem.body = feedEmailbody;
                        
                    }else if(mapofsellerRec.get(con.Account.Parent.OwnerId).Type__c =='Sales Team Manager'){
                        
                        //Check if the Sales Team existis in the custom setting
                        SMESalesTeam__c TeamCS = SMESalesTeam__c.getValues(mapofsellerRec.get(con.Account.Parent.OwnerId).Sales_Team_Name__c);
                        
                        //If match is found, get the team address Id
                        if(TeamCS !=null){
                            String teamEmail =  TeamCS.Email__c;
                            
                            //Set Template Body
                            String updateMrgEmailbdy='';
                            String emailMgrBody = mapofTemplate.get('SellerManager').HTMLValue;
                            updateMrgEmailbdy = emailMgrBody.replace('xxxxx@teliacompany.com',teamEmail);
                            system.debug('updateMrgEmailbdy-'+updateMrgEmailbdy);
                            system.debug('Team Email-'+teamEmail);
                            
                            //Set Template
                            mailMsg.setHtmlBody(updateMrgEmailbdy);
                            mailMsg.setSubject('Nya kontaktvägar till Telia');
                            mailMsg.setTemplateId(mapofTemplate.get('SellerManager').Id);
                            
                            //Post Feed 
                            String plainTextbodyMgr = mapofTemplate.get('SellerManager').Body;
                            String updatedplainTextMgr = plainTextbodyMgr.replace('xxxxx@teliacompany.com',teamEmail);
                            String feedEmailbodyMgr = 'Sent Email at '+system.today()+'\n'+updatedplainTextMgr;
                            postItem.body = feedEmailbodyMgr;
                            system.debug('^^^'+feedEmailbodyMgr);
                        }
                    }
                    //Add to the list Email Message and FeedItem
                    system.debug('***'+postItem.body);
                    if(postItem.body !=null){
                        mailList.add(mailMsg);
                        listofFeedItem.add(postItem);
                    }
                }
            }
            //Start of Error Log
            List<Messaging.SendEmailResult> emailrslt = Messaging.sendEmail(new Messaging.SingleEmailMessage[mailList]);
            List<Messaging.SendEmailError> errorList = new List<Messaging.SendEmailError>();
            for(Messaging.SendEmailResult rslt : emailrslt){
                if(rslt.isSuccess()){
                    system.debug('Success Email Sent');
                }else{
                    for(Messaging.SendEmailError err : rslt.getErrors()){
                        totalErrorIds.add(err.getTargetObjectId());
                    }
                }
            }
            //End of Error Log
            system.debug('FeedItem:'+mailList.size());
            system.debug('FeedItem:'+listofFeedItem);
            system.debug('FeedItem:'+emailrslt);
            database.SaveResult[] rslt =  database.insert(listofFeedItem);
            system.debug('rslt:'+rslt);
        }
    }
    public void finish(Database.BatchableContext BC){
        system.debug('Total Error Ids-'+totalErrorIds.size());
    }
}