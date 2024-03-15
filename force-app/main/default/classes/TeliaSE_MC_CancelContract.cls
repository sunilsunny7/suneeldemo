public class TeliaSE_MC_CancelContract 
{
    @InvocableMethod 
    public static void cancelContract(list<Id> contractIds)
    {
            If(contractIds.size()>0)
            {
                List<Contract> contractsActive = [select id, status,Reason_for_Cancellation__c from contract where Account.FA_Contract__c In:contractIds and status = 'Active'];
                List<Contract> contractToUpdate = new List<Contract>();
                If(contractsActive.size() > 0)
                {
                    for(Contract con: contractsActive)
                    {
                        con.TeliaSE_Reason_for_Cancellation__c = 'Revised';
                        con.status = 'Cancelled';
                        contractToUpdate.add(con);
                    }    
                }
                if(contractToUpdate!=null && contractToUpdate.size()>0)
                {
                     update contractToUpdate;
                }
            }
    }
    
}