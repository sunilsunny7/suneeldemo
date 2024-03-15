trigger SetAnswerOnQuestion on Answer_Sequence_Item__c (after insert, after update) {
    Set<Id> sequenceIds = new Set<Id>();

    for(Answer_Sequence_Item__c item : Trigger.new)
    {
        sequenceIds.add(item.Answer_Sequence__c);
    }

    Map<Id, Answer_Sequence__c> sequenceList = new Map<Id, Answer_Sequence__c>([SELECT Id,
        (SELECT Id, Answer_Text__c, Is_Correct_Answer__c FROM Answer_Sequence_Items__r WHERE Is_Correct_Answer__c = true)
        FROM Answer_Sequence__c WHERE Id IN :sequenceIds ]);

    List<Question__c> questionList = [SELECT Answer__c, Answer_Sequence__c FROM Question__c WHERE Answer_Sequence__c IN :sequenceIds AND Type__c = 'SelectOneQuestion'];

    for(Question__c question : questionList)
    {
        Answer_Sequence__c sequence = sequenceList.get(question.Answer_Sequence__c);
        // If sequence.Answer_Sequence_Items__r is empty (i.e the question yet has no correct answer) set question.Answer__c to null
        // Otherwise set question.Answer__c to the Answer_Text__c of the first item in list 
        // (The list should always have zero or one correct answers since question type is 'SelectOneQuestion')
        if(sequence.Answer_Sequence_Items__r.isEmpty()) question.Answer__c = null;
        else question.Answer__c = sequence.Answer_Sequence_Items__r[0].Answer_Text__c;
        System.debug('question'+question.Answer__c);
    }

    if(!questionList.isEmpty()) update questionList;
}