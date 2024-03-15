public class OppTeamTriggerHandler {

    public void OnAfterInsert(List<OpportunityTeamMember> newList){
        list<OpportunityTeamMember> newOtmList = new list<OpportunityTeamMember>();
        list<OpportunityTeamMember> filteredOtmList = new list<OpportunityTeamMember>();
        newOtmList = [select id, UserId,OpportunityId,Opportunity.name,Opportunity.ownerID from OpportunityTeamMember where id in :newList];
        for(OpportunityTeamMember otm : newOtmList){
            if(otm.UserId != otm.Opportunity.ownerID){
                filteredOtmList.add(otm);
            }       
        }
        PostToUserChatter(filteredOtmList);     
    }   
    public void OnAfterUpdate(List<OpportunityTeamMember> newList){
        list<OpportunityTeamMember> newOtmList = new list<OpportunityTeamMember>();
        list<OpportunityTeamMember> filteredOtmList = new list<OpportunityTeamMember>();
        newOtmList = [select id, UserId,OpportunityId,Opportunity.name,Opportunity.ownerID from OpportunityTeamMember where id in :newList];
        for(OpportunityTeamMember otm : newOtmList){
            if(otm.UserId != otm.Opportunity.ownerID){
                filteredOtmList.add(otm);
            }       
        }
        PostToUserChatter(filteredOtmList);     
    }       
    public static void PostToUserChatter(list<OpportunityTeamMember>newRecList) { 
        List<ConnectApi.BatchInput> chatterPosts = new List<ConnectApi.BatchInput>();
        for(OpportunityTeamMember otm: newRecList){
             ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
             ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
             ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
             ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
             ConnectApi.FeedElementCapabilitiesInput capability = new ConnectApi.FeedElementCapabilitiesInput();
             ConnectApi.LinkCapabilityInput link = new ConnectApi.LinkCapabilityInput();

             messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
             //Mention user here
             mentionSegmentInput.id = otm.UserId;
             messageBodyInput.messageSegments.add(mentionSegmentInput);
             textSegmentInput.text = ' added to Opportunity Team:';
             messageBodyInput.messageSegments.add(textSegmentInput);
             link.url = '/'+otm.OpportunityId;
             link.urlName = otm.Opportunity.name;
             capability.link = link;
             feedItemInput.capabilities = capability;            
             feedItemInput.body = messageBodyInput;
             feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
             //feedItemInput.subjectId = otm.Id;
             feedItemInput.subjectId = otm.OpportunityId;
             ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
             chatterPosts.add(batchInput);
        }
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), chatterPosts);
    } 
  }