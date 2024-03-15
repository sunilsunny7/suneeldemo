public class ConExcelDownloadctr {
    
    
     public List<List<Contact>> groupedContacts {get;set;}
   private Contact[] records;
   public ConExcelDownloadctr(ApexPages.StandardSetController ctrl) {
    
        set<Id> setIdContact = new set<Id>();
        for(Contact c : (List<Contact>)ctrl.getSelected())
        {
            setIdContact.add(c.Id);
        }
        
        records = new list<Contact>();
        
        for(Contact c : [SELECT Id, Name, Email, Account.Name, Barcode_ID__c FROM Contact WHERE Id IN :setIdContact])
         {
          records.add(c);
         }
       
         groupedContacts = new List<List<Contact>>();
         groupedContacts.add(records);
   }
}