public class homepagecontroller {
    public string UniqueReqId {get;set;}
    public boolean isSuccess {get;set;}
    public boolean isValidUser {get;set;}
    //Constructor
    public homepagecontroller(){ 
        UniqueReqId = '';
        isSuccess = false;
        isValidUser = true;
        String requestKey = ApexPages.currentPage().getParameters().get('uniqueId');
        System.debug('RequestKey:-'+requestKey);
        //Decode the key using own private key
        try{
            If(string.isNotBlank(requestKey)){
                String getSecurityKey = Label.AESSecurityKey;
                Blob CryptoKey = EncodingUtil.base64Decode(getSecurityKey);
                System.debug('Key Data:-'+CryptoKey.size());
                Blob decodedData=EncodingUtil.base64Decode(requestKey);
                Blob decryptedData = Crypto.decryptWithManagedIV('AES256', CryptoKey, decodedData);
                System.debug('Decrypted Data:-'+decryptedData.toString());
                UniqueReqId = decryptedData.toString();
            }
        }catch(Exception ex){
            system.debug('Exception:-'+ex.getMessage());
        }
    }
    
    public void updaterecordreq(){
        system.debug('Event clicked'+UniqueReqId);
        Database.SaveResult saverslt;
        Database.SaveResult usrreqObj;
        Userdeactive__c[] usrreq = new Userdeactive__c[3];
        try{
            User[] UsrObj = [select Id,username,Name,Profile.name,Lastlogindate,Email from USER where username =:UniqueReqId AND isActive=true AND IsDeactivationRequested__c = false LIMIT 1];
            if(UsrObj.size() >0){
                isValidUser = true;
                usrreq = [select Id from Userdeactive__c where User__c =:UsrObj[0].Id AND Status__c = 'Open'];
                Userdeactive__c usrDA = new Userdeactive__c();
                usrDA.Name = 'De-Activation Request for '+UsrObj[0].name;
                usrDA.User__c = UsrObj[0].Id;
                usrDA.UserName__c = UsrObj[0].username;
                usrDA.Status__c = 'Open';
                usrDA.UserProfile__c = UsrObj[0].Profile.name;
                usrDA.SalesforceLastLogin__c = UsrObj[0].Lastlogindate;
                usrDA.DeactiveRequestTime__c = system.now();
                if(usrreq.size() > 0){
                    usrDA.Id = usrreq[0].Id;
                    saverslt = Database.update(usrDA);
                }else{
                    usrreqObj = Database.insert(usrDA);
                }
                system.debug('usrreqObj:-'+usrreqObj+'saverslt:-'+saverslt);
                if((saverslt != null && saverslt.isSuccess()) || (usrreqObj!=null && usrreqObj.isSuccess())){
                    UsrObj[0].IsDeactivationRequested__c = true;
                    isSuccess = true;
                    database.update(UsrObj);
                }
            }else{
                isValidUser = false;
            }
        }catch(Exception Ex){
            system.debug(ex.getMessage()+'Line Number'+ex.getLineNumber());
        } 
    }
}