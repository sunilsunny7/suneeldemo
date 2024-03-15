public class LeadAgentFormHandlerController {

    public string firstname{get;set;}
    public string lastname{get;set;}
    public string email{get;set;}
    public string phone{get;set;}
    public string company{get;set;}
    public string orgnr{get;set;}
    public string description{get;set;}
    public string AFnum{get;set;}
    public string tholboxid{get;set;}
    public string senderfname{get;set;}
    public string senderlname{get;set;}
    public string senderphone{get;set;}
    public String selectedproductarea{get;set;}
    public boolean display{get;set;}
    public String TeliaId {get;set;}
    public String LeadAgentUrl{get;set;}
    public String SalesReptUrl{get;set;}
    public String LeadAgenttabUrl{get;set;}
    public String SalesRepttabUrl{get;set;}
    public String HomePageURL{get;set;}
    public String LeadAgentSuccessURL{get;set;}
    public String LeadAgentErrorURL{get;set;}
    public String SalesRepSuccessURL{get;set;}
    public String SalesRepErrorURL{get;set;}
    public String currentpageurl;
    public Boolean isLightning;
    public Boolean isCellPhoneValid= false;
    public Boolean isSenderPhoneValid= false;

    
    public LeadAgentFormHandlerController(){
        display = true;
        User u = [SELECT Telia_Id__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        TeliaId = u.Telia_Id__c;
        General_Lead_Settings__c settings = General_Lead_Settings__c.getValues('General Settings');
        LeadAgentUrl = settings.AF_Lead_URL__c;
        SalesReptUrl = settings.SalesRep_Lead_URL__c;
        LeadAgenttabUrl = settings.Lead_Agent_Form_Tab_URL__c;
        SalesRepttabUrl = settings.Sales_Rep_Form_Tab_URL__c;
        HomePageURL = settings.Home_Page_URL__c;
        LeadAgentSuccessURL = settings.Lead_Agent_Success_URL__c;
        LeadAgentErrorURL = settings.Lead_Agent_Error_URL__c;
        SalesRepSuccessURL = settings.Sales_Rep_Success_URL__c;
        SalesRepErrorURL = settings.Sales_Rep_Error_URL__c;
        currentpageurl = ApexPages.currentPage().getURL();
        isLightning = UserInfo.getUiThemeDisplayed() == 'Theme4d';
        senderfname = UserInfo.getFirstName();
        senderlname = UserInfo.getLastName();
        senderphone =  [SELECT MobilePhone FROM User WHERE Id =: UserInfo.getUserId()].MobilePhone;
        String profileName = [SELECT Name FROM profile WHERE Id = :UserInfo.getProfileId()].name;
        if( profileName=='Fiber Base Profile' || profileName=='Fiber Sales restricted' ) {
            selectedproductarea = 'Fastighetsnät (NEXT)';
        }
    }
    public void getAccountName()
    {
        try
        {
            company = [SELECT name FROM Account WHERE Org_Nr__c = :orgnr LIMIT 1].name;
        }
        catch(exception ex)
        {
        }

    }
    public List<SelectOption> getproductAreaOptions(){
        List<SelectOption> productarealist = new List<SelectOption>();       
        for(PardotLeadAgentProductArea__c setting : PardotLeadAgentProductArea__c.getAll().values())
        {
            productarealist.add(new selectOption(setting.Name,setting.Name)); 
        }     
        return productarealist;
    }

    public PageReference Submitlead()
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        if(phone != ' ' || senderphone != ' ')
        {
            string regExp = '^[+][ ]?[4]{1}[6]{1}?[ ]?([1-9]{1})([0-9]{4,20})||^[+][ ]?[1-9]{2}?[ ]?([1-9]{1})([0-9]{4,20})$';
            isCellPhoneValid = Pattern.matches(regExp,phone);
            isSenderPhoneValid = Pattern.matches(regExp,senderphone);
        }
        if(firstname == '' || lastname == '' || email == '' || phone == '' || company == '' || orgnr == '' || AFnum == '' || tholboxid == '' || senderfname == '' || senderlname == '' || senderphone == '' || selectedproductarea == '' || description == '')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,+system.Label.Lead_Sales_Rep_Form_Mandatory_Error_Message));   
        }
        else if(email != ' ' || phone != ' ' || senderphone != ' ')
        {
            if((email.contains('teliacompany') || email.contains('teliasonera') || email.contains('Teliacompany') || email.contains('Teliasonera')))
            {   
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,+system.Label.Lead_Sales_Rep_Form_Email_Error_Message1)); 
            }
            else if(!email.contains('@'))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,+system.Label.Lead_Sales_Rep_Form_Email_Error_Message2));   
            }
            else if(!isCellPhoneValid || !isSenderPhoneValid)
            {
              system.debug('--gaya****');
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,+system.Label.Contact_PhoneValidation));   
            }  
            else
            {  
                try 
                {
                    if(LeadAgentUrl != null)
                    {
                        req.setEndPoint(+LeadAgentUrl);    
                        req.setBody('first_name=' +firstname + '&last_name='+lastname + '&email=' +email +'&phone=' +phone +'&company=' +company +'&orgnr=' +orgnr +'&description=' +description +'&AFnum=' +AFnum +'&tholboxid=' +TeliaId +'&senderfname=' +senderfname +'&senderlname=' +senderlname +'&senderphone=' +senderphone +'&selectedproductarea=' +selectedproductarea);              
                        if(!Test.isRunningTest())
                        {
                            req.setMethod('POST');                              
                            HttpResponse res = h.send(req);
                            if(res.getStatusCode() == 200 && res.getStatus() == 'OK' && res.getBody().contains('success')) 
                            { 
                                PageReference ReturnPage = new PageReference(+LeadAgentSuccessURL);  
                                ReturnPage.setRedirect(true);   
                                return ReturnPage;               
                            }
                            else 
                            {
                                PageReference ReturnPage = new PageReference(+LeadAgentErrorURL);  
                                ReturnPage.setRedirect(true);   
                                return ReturnPage;
                            }                       
                        }
                    } 
                }
                catch(System.CalloutException e) {
                        System.debug('ERROR: '+e);
                }                               
            }
        }
        return null;
    }
    
    public Pagereference cancel()
    {     
        if(!isLightning)
        {
            PageReference ReturnPage = new PageReference('/home/home.jsp');
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        }
        else
        {
            PageReference ReturnPage = new PageReference(+HomePageURL);
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        } 
    }
   
    public PageReference pardotLeadAgentSuccessPageBack(){
        
        if(!isLightning)
        {
            PageReference ReturnPage = new PageReference('/apex/AF_Lead_form');
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        }
        else
        {
            PageReference ReturnPage = new PageReference(+LeadAgenttabUrl);
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        } 
    }
      
    public PageReference pardotLeadAgentErrorPageBack(){
        if(!isLightning)
        {
            PageReference ReturnPage = new PageReference('/apex/AF_Lead_form');
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        }
        else
        {
            PageReference ReturnPage = new PageReference(+LeadAgenttabUrl);
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        } 
    }
      
    public PageReference doneHomePage(){
        if(!isLightning)
        {
            PageReference ReturnPage = new PageReference('/home/home.jsp');
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        }
        else
        {
            PageReference ReturnPage = new PageReference(+HomePageURL);
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        } 
    }
      
    public Pagereference SubmitSalesRepForm()
    {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        if(phone != ' ' || senderphone != ' ')
        {
            string regExp = '^[+][ ]?[4]{1}[6]{1}?[ ]?([1-9]{1})([0-9]{4,20})||^[+][ ]?[1-9]{2}?[ ]?([1-9]{1})([0-9]{4,20})$';
            isCellPhoneValid = Pattern.matches(regExp,phone);
            isSenderPhoneValid = Pattern.matches(regExp,senderphone);
        }
        if(firstname == '' || lastname == '' || email == '' || phone == '' || company == '' || senderfname == '' || senderlname == '' || senderphone == '' || selectedproductarea == '' || description == '')
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,+system.Label.Lead_Sales_Rep_Form_Mandatory_Error_Message));   
        }
        else if(email != ' ' || phone != ' ' || senderphone != ' ')
        {
            if(email.contains('teliacompany') || email.contains('teliasonera') || email.contains('Teliacompany') || email.contains('Teliasonera'))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,+system.Label.Lead_Sales_Rep_Form_Email_Error_Message1));   
            }
            else if(!email.contains('@'))
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,+system.Label.Lead_Sales_Rep_Form_Email_Error_Message2));   
            }
            else if(!isCellPhoneValid || !isSenderPhoneValid)
            {
              ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,+system.Label.Contact_PhoneValidation));   
            }           
            else
            {                               
                try 
                {
                    req.setEndPoint(+SalesReptUrl);    
                    req.setBody('first_name=' +firstname + '&last_name='+lastname + '&email=' +email +'&phone=' +phone +'&company=' +company +'&orgnr=' +orgnr +'&description=' +description +'&teliaid=' +TeliaId +'&senderfname=' +senderfname +'&senderlname=' +senderlname +'&senderphone=' +senderphone +'&selectedproductarea=' +selectedproductarea);              
                    if(!Test.isRunningTest())
                    {
                        req.setMethod('POST'); 
                        HttpResponse res = h.send(req);
                        if(res.getStatusCode() == 200 && res.getStatus() == 'OK' && res.getBody().contains('success')) 
                        { 
                                PageReference ReturnPage = new PageReference(+SalesRepSuccessURL);  
                                ReturnPage.setRedirect(true);   
                                return ReturnPage;               
                        }
                        else 
                        {
                                PageReference ReturnPage = new PageReference(+SalesRepErrorURL);  
                                ReturnPage.setRedirect(true);   
                                return ReturnPage;
                        }
                    }
                } 
                catch(System.CalloutException e) {
                        System.debug('------ERROR: '+ e);
                }
            }
        }
        return null;
      
        }
    public PageReference pardotSalesRepErrorPageBack(){
        if(!isLightning)
        {
            PageReference ReturnPage = new PageReference('/apex/PardotSalesRepForm');
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        }
        else
        {
            PageReference ReturnPage = new PageReference(+SalesRepttabUrl);
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        } 
    }
      
    public PageReference pardotSalesRepSuccessPageBack(){
        if(!isLightning)
        {
            PageReference ReturnPage = new PageReference('/apex/PardotSalesRepForm');
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        }
        else
        {
            PageReference ReturnPage = new PageReference(+SalesRepttabUrl);
            ReturnPage.setRedirect(true);   
            return ReturnPage;
        } 
    }
}