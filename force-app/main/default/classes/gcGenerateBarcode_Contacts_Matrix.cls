public with sharing class gcGenerateBarcode_Contacts_Matrix {
    public List<List<Contact>> groupedContacts {get;set;}

    public static final Integer COLUMNS_AMOUNT = 3;
    private Contact[] records;
    public gcGenerateBarcode_Contacts_Matrix(ApexPages.StandardSetController ctrl) {
    
        set<Id> setIdContact = new set<Id>();
        for(Contact c : (List<Contact>)ctrl.getSelected())
        {
            setIdContact.add(c.Id);
        }
        
        records = new list<Contact>();
        
        for(Contact c : 
        [SELECT Id, Name, Email, Account.Name, Barcode_ID__c
         FROM Contact
         WHERE Id IN :setIdContact])
         {
          records.add(c);
         }
        //ctrl.addFields(new List<String> {'Name', 'Email', 'Id', 'AccountId','Barcode_ID__c'});
        //records = (List<Contact>)ctrl.getSelected();

        groupedContacts = new List<List<Contact>>();

        Integer ind = 0;
        for (Integer i = 0; i < (records.size() / COLUMNS_AMOUNT) + 1; i++) {
            List<Contact> row = new List<Contact>();

            for (Integer i2 = 0; i2 < COLUMNS_AMOUNT; i2++) {

                if (ind >= records.size()) {
                    break;
                }

                row.add(records[ind]);

                ind += 1;
            }

            for (Integer i3 = row.size(); i3 < COLUMNS_AMOUNT; i3++) {
                row.add(null);
            }

            groupedContacts.add(row);
            if (ind >= records.size()) {
                break;
            }

        }
    }


}