public class ArticleController {
    @InvocableMethod(label='Auto Publish Article' description='Returns void')
    public static void setpublishArticle(List<ID> articleId) {
        if(articleId !=null){
            Knowledge__kav articleObj = [SELECT Id,Title,KnowledgeArticleId FROM Knowledge__kav WHERE id =:articleId.get(0)];
            KbManagement.PublishingService.publishArticle(articleObj.KnowledgeArticleId, true);
        }
    }
}