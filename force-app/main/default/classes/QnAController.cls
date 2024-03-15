public class QnAController {    
    
    @AuraEnabled
    public static List<QuestionDataCategorySelection> getQuestionCatalogue(){
        return [SELECT CreatedById,CreatedDate,DataCategoryGroupName,DataCategoryName,Id,ParentId,Parent.Title,Parent.createddate,Parent.createdBy.Name FROM QuestionDataCategorySelection where Parent.NumReplies = 0 ORDER BY CreatedDate DESC];
        // return [select Id,title,NumReplies,createddate,createdbyId from QUESTION where NumReplies =0 ];  where Parent.NumReplies = 0
    }
    @AuraEnabled
    public static String getProfiledata(){
        Integer total = 0;
        for (Question qusObj : [SELECT id,BestReplyId,BestReply.createdBy.name,BestReply.createdById, title FROM Question WHERE BestReplyId != '' ORDER BY CreatedDate ASC]){
            if(qusObj.BestReply.createdById == userinfo.getUserId()){
                total = total +1;
            }
        }
        WrapperProfile wrapperObj = new WrapperProfile();
        wrapperObj.BestAnsCount = total;
        wrapperObj.TotalQusCount = [select count() from Question where createdById =: UserInfo.getUserId()];
        system.debug('%%%'+wrapperObj);
        return JSON.serialize(wrapperObj);
    }
    public class WrapperProfile {
        public integer TotalQusCount {get;set;}
        public integer BestAnsCount  {get;set;}   
    }
}