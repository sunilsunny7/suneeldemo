trigger QuestionTrigger on Question__c (before insert) {
    Set<Id> sequenceIds = new Set<Id>();

    for(Question__c question : Trigger.new)
    {
        sequenceIds.add(question.Answer_Sequence__c);
    }

    Map<Id, String> sequenceAnswerMap = new Map<Id, String>();
    for(Answer_Sequence__c sequence : [SELECT Id,
        (SELECT Id, Answer_Text__c, Is_Correct_Answer__c FROM Answer_Sequence_Items__r WHERE Is_Correct_Answer__c = true)
        FROM Answer_Sequence__c WHERE Id IN :sequenceIds ]){

    	String answer = null;
        if(!sequence.Answer_Sequence_Items__r.isEmpty()) answer = sequence.Answer_Sequence_Items__r[0].Answer_Text__c;
        sequenceAnswerMap.put(sequence.Id, answer);
    }

    List<Question__c> questionUpdateList = new List<Question__c>();

    for(Question__c question : Trigger.new)
    {
        if(sequenceAnswerMap.containsKey(question.Answer_Sequence__c))
        	question.Answer__c = sequenceAnswerMap.get(question.Answer_Sequence__c);
    }
}