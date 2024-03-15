/*********
* This is the controller for the mass update app
* @author cchen
* 
* Author & Date Update: Varma Alluri,  21.03.2017
* Description: JIRA Ticket: SAEN-2201
* Restricted fields in Step2 and Added logic in step3 for Owner and Partially Responsible fields to get all
* the active User names in the search based on the field selected in the step2 and adding the names to the list, displaying
* the list of values in the inputText to give flexibility to the user to select the required Name from list of Users.
**********/

public with sharing class MassUpdateSimpleController {
    
    private final ApexPages.StandardSetController cntr;
    private final PageReference fromPage;
    private final List<SObject> objs;
    private Map<String, Schema.SObjectField> fieldMap;
    private transient ApexPages.Message currentMsg;
    private final String newLine ='<br></br>';
    private Schema.SObjectField field;
    private String sType;
    private Object convertedFieldData;
    private List<SelectOption> picklistValues;
    private String currentStep;
    public string recid {get;set;} 
    transient public List<String> listOfString { get; set; }  
    transient public list<opportunity> opplist=new list<opportunity>();
    transient public list<Opportunity> olist = new list<Opportunity>();
    transient public list<user> Ulist = new list<user>(); 
    transient public list<Solution_Verification__c> slist = new list<Solution_Verification__c>();
    public string SearchKey{get;set;}
    public list<sObject> reclist {get;set;}
    public boolean showrecords {get;set;}
    public List<SelectOption> records {get;set;}
    public string selectedObject;
    public list<string> lststrings {get;set;}
    public set<string> requiredObjs = new set<string>{'Area__c','Category__c','Estimated_Points_Req__c','Maximum_Points__c','Other_Partially_Responsibles__c','Partially_Responsible__c','Requirement_Evaluation__c','Risk_Categorisation__c','Status__c','Type_of_Requirement__c','Value_of_Requirement__c','Approved__c'};
    public void Searchacc(){
        lststrings = new list<string>();
        showrecords = false;
        reclist = new list<sObject>();
        records = new List<SelectOption>();

        selectedObject = 'user';
        if(SearchKey!='' && SearchKey!=null){
          string query =  'Select Id,Name,isactive from ' +selectedObject +' where isactive=true and Name LIKE \'%' +SearchKey+'%\' ORDER BY Name'; 
          reclist = database.query(Query);
        }

        if(reclist.size()>0){
            showrecords = true;
            for(sObject o : reclist ){
                lststrings.add(String.valueOf(o.get('Name')));
            }   
   
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, System.Label.MassUpdate_No_Records_Found));
        }    
     }
    public MassUpdateSimpleController(ApexPages.StandardSetController controller) {   
        showrecords = false;
        currentStep = '1';
        controller.setPageSize(1000);
        cntr = (ApexPages.StandardSetController)controller;
        fromPage = cntr.cancel();
        Id  recordId = (Id)ApexPages.CurrentPage().getParameters().get('id');
        if (recordId!=null && cntr.getSelected().size()==0) {
            
            DescribeSObjectResult result = discoverSObjectType(controller.getRecord());

            Map<String, Schema.SObjectField> checkfieldMap = result.fields.getMap();
            
            List<String> keys = sortByFieldLabel(checkfieldMap);
            
            for(String key:keys) {
                Schema.DescribeFieldResult d = checkfieldMap.get(key).getDescribe();
                
                if (Schema.DisplayType.REFERENCE == d.getType()) {
                    if (d.getReferenceTo().get(0) ==  recordId.getSobjectType()){
                     
                        String query = generateQuery(result.getSobjectType(), d.getName(), recordId);
                        List<sObject> sobjList = Database.query(query);
                        cntr.setSelected(sobjList);
                    }
                }
            }  
        }
      
        if (this.objs == null) {
            
            if (cntr.getSelected().size()==0 && recordId==null) {     
            }
            
            this.objs = (List<SObject>)cntr.getSelected();   
        }
        if (getRecordSize()<1) {
            String msg = System.Label.Requirement_Select_Records; 
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, msg);
        } else {
            sType= discoverSObjectType(objs.get(0)).getName(); 
            String msg = 'Number of records selected for update: ' + getRecordSize();  ////
            currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
        }
        ApexPages.addMessage(currentMsg);
    }
    
    public String generateQuery(Schema.SObjectType objType, String parentReference, String parentId){
        
        String query = '';
        if (objType == Opportunity.getSObjectType()){
            
            query = 'SELECT Name,Account.Name,CloseDate, Amount, Owner.Name FROM Opportunity ';
        }
        else if (objType == Contact.getSObjectType()){
            
            query = 'SELECT Name,Email,Account.Name, Title, Owner.Name FROM Contact ';
        }
        else if (objType == Asset.getSObjectType()) {
            
            query = 'SELECT Name,Product2.Name,InstallDate, Status, Quantity FROM Asset ';
        }
        else if (objType == Case.getSObjectType()){
            
            query = 'SELECT Subject,CaseNumber,Account.Name, Status, Owner.Name FROM Case ';
        }
        else if (objType == Campaign.getSObjectType()) {
            
            query = 'SELECT Name,StartDate,Type, Status, Owner.Name FROM Campaign ';
        }
        else if (objType == Lead.getSObjectType()) {
            
            query = 'SELECT Name,Email,Company, LeadSource FROM Lead ';
        }
        else if (objType == Product2.getSObjectType()) {
            
            query = 'SELECT Name,IsActive,Family, ProductCode FROM Product2 ';
        }
        
        query = query + 'where '+ parentReference+'=\''+Id.valueOf(parentId)+'\'';
        return query;
    }
    
    public String getStep() {
        return currentStep;
    }

    public String getsType() {
        return sType;
    }      
    
    public integer getRecordSize() {
        if (objs!=null) {
            return objs.size();
        } else {
            return 0;
        }
    }
    
    public String filterId {
        get;
        set;    
    }
    
    public String getNow(Boolean bShowTime) {
        DateTime now = DateTime.now();
        if (bShowTime)
            return  now.year() + '-' + now.month()+ '-' + now.day()+' '+now.hour()+ ':' +now.minute() + ':' + now.second();
        else
            return  now.year() + '-' + now.month()+ '-' + now.day();
    }
    
    public List<SObject> objsToUpdate {
        get {
            return (List<SObject>) cntr.getSelected();
        }
        set;
    }
    
    public String valueToUpdate {
        get;
        set;    
    }
    
    public String fieldName {
        get;
        set {
            fieldName=value;
            field = fieldMap.get(value);
            if (field!=null){   
                Schema.DescribeFieldResult d = field.getDescribe();
                fieldType = d.getType().name();
                
                if (d.getType()==DisplayType.Picklist){    
                    picklistValues = new List<SelectOption>();      
                    if (d.isNillable()) {
                        picklistValues.add(new SelectOption('System.Label.Requirement_Please_Select', '--None--'));
                    }
                    for (Schema.PicklistEntry p : d.getPickListValues()) {
                        picklistValues.add(new SelectOption(p.getValue(), p.getLabel()));
                    }
                }                   
            }
        }
    }
    
    public String fieldType{
        get;
        set;    
    }
    
    public Boolean displayTexField{
        get{
            
            if (fieldType=='CURRENCY'|| fieldType=='DATE' || fieldType=='DATETIME'
                ||fieldType=='TEXT' ||fieldType=='NUMBER'||fieldType=='COMBOBOX'
                ||fieldType=='DOUBLE'||fieldType=='EMAIL'||fieldType=='ID'
                ||fieldType=='ID'||fieldType=='INTEGER'||fieldType=='PERCENT'||fieldType=='MULTIPICKLIST'
                ||fieldType=='PHONE'||fieldType=='STRING'||fieldType=='REFERENCE'||fieldType=='BASE64') {
                    return true;
                }
            return false;  
        }
        set;
    }
    
    public Boolean displayTextArea{
        get{
            if (fieldType=='TEXTAREA'){
                return true;
            }
            return false;
        }
        set;
    }
    
    public Boolean displayCheckBox{
        get{
            if (fieldType=='BOOLEAN'){
                return true;
            }
            return false;
        }
        set;
    }
    
    public Boolean displayPicklist{
        get{
            if (fieldType=='PICKLIST'){
                return true;
            }
            return false;
        }
        set;
        
    }
    
    public List<String> confirmationMessage{
        
        get;
        set;
    }
    
    public String resultMessage{
        get;
        set;
        
    }
    
    private Object convertUserInputToFieldData(){
        if (field==null) return null;
        DisplayType t = field.getDescribe().getType();
        Object s = null;
        
        try {       
            if (t==DisplayType.Double||t==DisplayType.Currency || t==DisplayType.Integer || t==DisplayType.Percent){
                s = decimal.valueOf((String)valueToupdate);         
            } else if (t==DisplayType.Boolean){                 
                if (valueToUpdate=='true'){
                    s = true;               
                } else if (valueToUpdate=='false'){
                    s = false;              
                } else {
                    s = Boolean.valueOf(valueToUpdate);
                }
            } else if (t==DisplayType.Date) {
                s = Date.valueOf(valueToUpdate);
            } else if (t==DisplayType.DateTime) {
                s = DateTime.valueOf(valueToUpdate);
            } else if ((t==DisplayType.PickList || t==DisplayType.PickList) && valueToUpdate==null) {
                s = '';
            }
            else if (t==DisplayType.Reference) {
                string query =  'select id,Name from ' +selectedObject +' where Name=:valueToUpdate limit 1'; 
                if(valueToUpdate==null || valueToUpdate==''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,System.Label.Requirement_Please_select_the_Value));
                }
                else{
                sobject sobj = database.query(Query);
                string rid = String.valueOf(sobj.get('id') );
                s = rid;
                }   
            }else {
                s = valueToupdate;
            }
        } catch (System.TypeException e){
            currentMsg = new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage());
            return null;
        }  
        
        return s;
    }   
    
    public String getFieldInfoToDisplay() {
        if (field==null) 
            field = fieldMap.get('Name');
        String msg = 'Field type of selected field: ' + fieldType + ' ';
        Schema.DescribeFieldResult d = field.getDescribe();
        if (d.getType()==DisplayType.TextArea || d.getType()==(DisplayType.String)||d.getType()==(DisplayType.URL)) {
            msg += 'Max lengh: ' + d.getLength();
            valueToUpdate='';
        } else if (d.getType()==DisplayType.DateTime ){
            msg += 'Format: yyyy-MM-dd HH:mm:ss';
            valueToUpdate=getNow(true);
        } else if (d.getType()==DisplayType.Date){
            msg += 'Format: yyyy-MM-dd';
            valueToUpdate=getNow(false);
        } else if (d.getType()==DisplayType.Picklist){
            
            picklistValues = new List<SelectOption>();      
            if (d.isNillable()) {
                picklistValues.add(new SelectOption('--None--', '--None--'));   ////
            }
            for (Schema.PicklistEntry p : d.getPickListValues()) {
                    picklistValues.add(new SelectOption(p.getValue(), p.getLabel()));
            }
        } else if (d.getType()==DisplayType.MultiPicklist){
            
            msg += 'Valid Picklist Values: ';  ////
            String combined ='';
            
            for (Schema.PicklistEntry p : d.getPickListValues()) {
                msg += newLine + '&nbsp;&nbsp;&nbsp;&nbsp;<b>' +p.getValue()+'</b>';
                combined += p.getValue()+';';
            }
            msg += newline + 'Use ; to seperate each picklist value you want to select';    ////
            msg += newline + 'For example, to select all the picklist values, enter <b>' + combined + '</b> in the textbox below to select all picklist values';  ////
        } else if (d.getType()==DisplayType.Integer){
            msg += 'Max digits: ' + d.getDigits();
        } else if (d.getType()==DisplayType.String){
            msg += 'Max length: ' + d.getLength();
        } else if (d.getType()==DisplayType.Double || d.getType()==DisplayType.Currency || d.getType()==DisplayType.Percent){
            msg += 'Format: (' + (d.getPrecision()-d.getScale()) + ','+d.getScale() +')';
        } else if (d.getType()==DisplayType.Reference){
            msg += 'Use this to change selected records to reference a different record, or even dereference records if the filed is left blank. ';    ////
            msg += 'Please enter ' + d.getName() + ' that the selected records should reference to';    ////
        }
        
        return msg;
    }
    
    public PageReference cancel() {
        return fromPage;
    }
    
    public PageReference step1() { 
        currentStep='1';  
        return ApexPages.currentPage();
    }
    
    public void lexstep1() { 
        currentStep='1';         
    }
    
    public PageReference step2() {
        if(getRecordSize()<1) return fromPage;      
        currentStep='2';         
        return ApexPages.currentPage();
    }
    
    public void lexstep2() {
        currentStep='2';
    }
    
    public PageReference step3() {
        showrecords = false;
        listOfString = new List<String>();
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
        recid = apexpages.currentpage().getparameters().get('id');
        ApexPages.addMessage(currentMsg);
        currentStep='3';    
        if(fieldname!=null){

            if(fieldName.containsIgnoreCase('Partially_Responsible__c')){
                string query1 = 'Select Id,Name from user';
                Ulist = database.query(query1);
                for(user a: Ulist ){
                    listOfString.add(a.Name); 
                }
            }
          
            if(fieldName.containsIgnoreCase('Owner')){
                string query1 = 'Select Id,Name from user';
                ulist = database.query(query1);
                for(user a: ulist ){
                   listOfString.add(a.Name);
                }
            }
        }

        if(fieldName == '--None--' || fieldName == 'null' ){   ////
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,System.Label.Requirement_Please_select_the_Value));
            return ApexPages.currentPage();
        }
        else    
        return ApexPages.currentPage();
    }
    
    public void lexstep3() {
        if (fieldName!=System.Label.Requirement_Please_Select) {
            currentStep='3';   
        } 
    } 
    
    public PageReference step4() {
        if(fieldType=='REFERENCE' &&( (valueToUpdate==null || valueToUpdate=='') || selectedObject==null)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,System.Label.Requirement_Please_select_the_Value));
            return ApexPages.currentPage();
        }
        else{
        convertedFieldData = convertUserInputToFieldData();
        if(convertedFieldData!=null || convertedFieldData!=''){
        // data type validation
        if (currentMsg!=null) {
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, getFieldInfoToDisplay());
            ApexPages.addMessage(msg);
            ApexPages.addMessage(currentMsg);
            return ApexPages.currentPage();
        }
        
        String msg = 'Please review your selections before confirm: /n';       ////
        msg = msg + '<br><b>Records Selected:</b>    ' + getRecordSize() +'/n';
        msg = msg + '<br><b>Field To Be Updated:</b> ' + fieldName + '</br>';
        msg = msg + '<br><b>New Value:</b>           ' + convertedFieldData + '</br>';
        currentMsg = new ApexPages.Message(ApexPages.severity.INFO, msg);
        ApexPages.addMessage(currentMsg);
        currentStep='4';         
        return ApexPages.currentPage();
        }
        else{
             return ApexPages.currentPage();
        }   
        }     
    } 
    public void lexstep4() {
        convertedFieldData = convertUserInputToFieldData();
        List<String> msgs = new List<String>();
        msgs.add('Records Selected: ' + getRecordSize());
        msgs.add('Field To Be Updated: ' + fieldName);
        msgs.add('New Value: ' + convertedFieldData);
        confirmationMessage = msgs;
        currentStep='4';
    } 
    
    public PageReference step5() {
        currentMsg = (new MassUpdater(objs, field, convertedFieldData)).massUpdate();
        ApexPages.addMessage(currentMsg);
        currentStep='5';         
        return ApexPages.currentPage();
    }
    
    public void lexstep5() {
        currentMsg = (new MassUpdater(objs, field, convertedFieldData)).massUpdate();
        resultMessage = currentMsg.getSummary();
        currentStep='5';         
    }
    
    public DescribeSObjectResult discoverSObjectType(SObject s) {
        Map<String, Schema.SObjectType> des = Schema.getGlobalDescribe();
        for(Schema.SObjectType o:des.values()) {
            if( s.getSObjectType()==o) {
                return o.getDescribe();
            }     
        }
        return null;
    }
    
    public List<SelectOption> getFieldTypeOptions() {
        if (objs.size()<1) return null;
        
        List<SelectOption> options = new List<SelectOption>();      
        options.add(new SelectOption('--None--','--None--'));     ////
        
        Schema.DescribeSObjectResult sObj = discoverSObjectType(objs.get(0));
        
        fieldMap = sObj.fields.getMap();
        
        List<String> keys = sortByFieldLabel(fieldMap);
        
        for(String key:keys) {
            Schema.DescribeFieldResult d = fieldMap.get(key).getDescribe();
            
            if(d.isAccessible() && d.isUpdateable()) {
                if (isSupportedFieldType(d)) {
                    String label = d.getLabel();

                    if(requiredObjs.contains(key)){
                        //if(key == 'Ownerid' )
                          //  label = 'Owner';
                        if(key == 'Approved__c' )
                            label = 'Approved';
                        options.add(new SelectOption(key, label));
                    }     
                }
            }
        }
        return options;
    }
    
    private List<String> sortByFieldLabel(Map<String, Schema.SObjectField> gd) {
        List<String> keys = new List<String>();
        
        Map<String, List<String>> labelMap = new Map<String, List<String>>();
        
        for(Schema.SObjectField s:gd.values()) {
            String label = s.getDescribe().getLabel();
            if(labelMap.get(label) == null) {
                labelMap.put(label, new List<String>());
            }
            
            labelMap.get(label).add(s.getDescribe().getName());        
        }
        
        List<String> labels = new List<String>(labelMap.keySet());
        labels.sort();
        
        for(String label:labels){
            keys.addAll(labelMap.get(label));
        }
        
        return keys;
    }
    
    public List<SelectOption> getPicklistValues() {
        return picklistValues;
    }
    
    private boolean isSupportedFieldType(DescribeFieldResult d) {
        // always return true for now, but in future some fields might not be supported
        return true;
    }
}