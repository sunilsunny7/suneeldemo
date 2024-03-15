global class ContactController {
    public ID recordID;
    
    public ContactController(ApexPages.StandardController controller) {
        recordID = controller.getID();
        system.debug('recordId-'+recordID);
    }
     @RemoteAction 
    global static String logrecord (String ObjId){
        system.debug('RecordId:-'+ObjId);
        try{
            String navUrl = '';
            Contact conObj =  [SELECT Id,
                               Email,
                               FirstName,
                               LastName,
                               MobilePhone,
                               Phone
                               FROM CONTACT 
                               WHERE Id = :ObjId LIMIT 1];
            if(conObj !=null){
                conObj.FirstName = conObj.FirstName !=null ? conObj.FirstName : '';
                conObj.LastName = conObj.LastName !=null ? conObj.LastName : '';
                conObj.Email = conObj.Email !=null ? conObj.Email : '';
                conObj.Phone = conObj.Phone !=null ? conObj.Phone : '';
                conObj.MobilePhone = conObj.MobilePhone !=null ? conObj.MobilePhone : '';
                if(conObj.MobilePhone !=''){
                   conObj.MobilePhone = conObj.MobilePhone.replaceAll('[^0-9]','').trim(); 
                }
                navUrl = Label.MyBusinessCotsUrl +'&firstname='+conObj.FirstName+'&lastname='+conObj.LastName+'&mobile='+conObj.MobilePhone+'&email='+ conObj.Email;
                Contact conUpdate = new Contact();
                conUpdate.Id = conObj.Id;
                conUpdate.Last_Timestamp_My_Business__c = System.now();
                conUpdate.My_Business_Created_By__c= userinfo.getName();
                database.update(conUpdate);           
            }
            system.debug('NavUrl-'+navUrl);
            return navUrl;
        }catch(Exception Ex){
            system.debug('Exception-'+Ex.getMessage());
            return null;
        }
    }
}