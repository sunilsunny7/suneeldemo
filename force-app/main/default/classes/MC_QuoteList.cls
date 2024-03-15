public class MC_QuoteList {
@AuraEnabled
    public static List<Quote> getQuote(String oppId){
    
        List<Quote> response2 = new List<Quote>();
        try{
            String rectype = 'Contract Quote';
            String quotelist = 'select id,QuoteNumber, Name, CreatedBy.Name,CreatedById,Status from Quote where OpportunityId =: oppId and RecordType.Name =: rectype';
            response2 =  Database.query(quotelist);            
            
        }catch(Exception exp){         
            System.debug(exp.getStackTraceString());
            System.debug(exp.getLineNumber());
            System.debug(exp.getMessage());
        }
        
        return response2;
    }
}