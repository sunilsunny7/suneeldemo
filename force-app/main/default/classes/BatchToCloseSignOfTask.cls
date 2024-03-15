/**
About
-----
Description: BatchToCloseSignOfTask contains methods to close and delete open signof task under closed opportunity
Create date: 14.07.2022*/
public class BatchToCloseSignOfTask implements Database.Batchable<Sobject>{    
    public Database.QueryLocator start(Database.BatchableContext BC){       
        return Database.getQueryLocator([select id, StageName from opportunity where StageName='Vunnen' OR StageName ='Förlorad' OR StageName ='Avbruten']);
    }
    public void execute(Database.BatchableContext BC, List<Opportunity> lstOpp){ 
        set<ID> OpportunitySetWinLost= new set<ID>();
        list<task> openTskToCloselst = new list<task>();
        for(Opportunity Opp:lstOpp){
            if(opp.stagename=='Vunnen' || opp.stagename =='Förlorad' || opp.stagename =='Avbruten'){
                OpportunitySetWinLost.add(opp.id);                                
            }
        }
        for(Task tsk :[select type from task where whatid in: OpportunitySetWinLost and type ='Signoff' and status='Öppen' ]){
            tsk.status =system.label.SignUpTaskToClosed;
            tsk.Bypass_validation_rule__c = true;
            openTskToCloselst.add(tsk);
        }
        if(!openTskToCloselst.isEmpty()){            
            update openTskToCloselst;
        }
           
    }
    public void finish(Database.BatchableContext BC){
    }
}