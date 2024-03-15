/**
 * Created by kwn687 on 2023-01-30.
 */
trigger RelatedDocumentsTrigger on Related_Documents__c(before update, before insert, after insert, after update) {
    new RelatedDocumentsTriggerHandler().run();
}