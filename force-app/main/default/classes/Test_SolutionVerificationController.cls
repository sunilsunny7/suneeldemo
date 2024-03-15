@isTest
public class Test_SolutionVerificationController{
/*
    
        @isTest static void testSolutionVerificationController() 
        {
           
                Account acc = Test_DataFactory.createOneAccount();
                acc.RecordTypeId = SEUtility.getRecordTypeId(SEUtility.ACC_RECTYPE_LARGE);
                insert acc;
                
                Opportunity opp = Test_DataFactory.createOpportunity();   
                opp.RecordTypeId = SEUtility.getRecordTypeId('Merforsaljningsmojlighet');
                opp.AccountId = acc.id;
                opp.Name = 'MF Opp';
                opp.Send_to_Volume_Sales__c = true;
                insert opp;
                
                Opportunity opp2 = Test_DataFactory.createOpportunity();   
                opp2.RecordTypeId = SEUtility.getRecordTypeId('Merforsaljningsmojlighet');
                opp2.AccountId = acc.id;
                opp2.Name = 'MF Opp';
                opp2.Send_to_Volume_Sales__c = true;
                insert opp2;
                
                Solution_Verification__c sv = new Solution_Verification__c();
                sv.SV_Opportunity__c = opp.id;
                insert sv;
                
                Solution_Verification__c sv2 = new Solution_Verification__c();
                sv2.SV_Opportunity__c = opp.id;
                insert sv2;
                
                SolutionVerificationController.getSolutionVerification(sv.id);
                
                List<Requirement__c> reqlist = new List<Requirement__c>();
                Requirement__c req = new Requirement__c();
                req.Opportunity__c = opp.id; 
                req.Related_Solution__c = sv.id;
                req.Reference_Solution__c = true;             
                reqlist.add(req);
                
                Requirement__c req1 = new Requirement__c();
                req1.Opportunity__c = opp.id; 
                reqlist.add(req1);
                
                Requirement__c req2 = new Requirement__c();
                req2.Opportunity__c = opp2.id;
                req2.Related_Solution__c = sv2.id; 
                req.Reference_Solution__c = false;             
                reqlist.add(req2);
                                
                insert reqlist;
                
                List<Id> listofreIds = new List<Id>();
                for(Requirement__c re : reqlist){
                    listofreIds.add(re.id);
                }
                List<Knowledge__kav> listofknarticles = new List<Knowledge__kav>();
                Knowledge__kav kn = new Knowledge__kav();
                kn.Language = 'sv';
                kn.Related_Solution__c = sv.id;
                kn.Reference_Solution_Approver__c = UserInfo.getUserId();
                kn.Title = 'test';
                kn.Reference_Solution__c = true;
                kn.UrlName= 'test';
                listofknarticles.add(kn);                
                Knowledge__kav kn2 = new Knowledge__kav();
                kn2.Language = 'sv';
                kn2.Related_Solution__c = sv2.id;
                kn2.Title = 'test1';
                kn2.UrlName= 'test1';
                listofknarticles.add(kn2);
                insert listofknarticles;
                Set<knowledge__kav> knIds = new Set<knowledge__kav>();
                for(knowledge__kav knlist : listofknarticles){ knIds.add(knlist);}
                List<knowledge__kav> obj1 = [SELECT Id,Title,KnowledgeArticleId FROM knowledge__kav WHERE id =: knIds];


                
                KbManagement.PublishingService.publishArticle(obj1[0].KnowledgeArticleId, true);
                KbManagement.PublishingService.publishArticle(obj1[1].KnowledgeArticleId, true);

        
                SolutionVerificationController.getAccounts(sv.id);
                SolutionVerificationController.getOpportunities(sv.id);
                SolutionVerificationController.getRequirements(sv.id);
                SolutionVerificationController.getOppRequirements(opp.id,sv.id);
                String myJSON = JSON.serialize(listofreIds);
                SolutionVerificationController.connect(myJSON,sv.id);
                SolutionVerificationController.connect(myJSON,sv2.id);

            
    }
    */
}