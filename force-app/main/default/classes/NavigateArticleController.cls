public class NavigateArticleController {
    @AuraEnabled
    public static string GettargetObjectId (String recordId){
        system.debug('Id:-'+recordId);
        if(string.isNotBlank(recordId)){
            ProcessInstanceWorkitem workItem =[SELECT Actor.name,OriginalActor.name,ProcessInstanceId FROM ProcessInstanceWorkitem 
                                               WHERE Id =: recordId];
            ProcessInstance instancerec = [SELECT TargetObjectId FROM ProcessInstance WHERE Id =: workItem.ProcessInstanceId];
            return instancerec.TargetObjectId; 
        }
        return null;
    }
}