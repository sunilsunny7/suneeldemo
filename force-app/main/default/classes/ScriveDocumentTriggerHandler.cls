/**
About
-----
Description: TransactionID from Scrive Document to Opportunity
Create by: Srikanya - SALEF-6778 - created new method scriveDocumentadd,scrive__externalId__c should update in TransactionID__c field seperator by semicolon in Opportunity.
Created date :  07 June 2022
*/
public class ScriveDocumentTriggerHandler {
 public static Boolean toStopRec= true;
     public void scriveDocumentadd(List<scrive__ScriveDocument__c> newRecord){
     Set<Id> oppIds = new Set<Id>();
   // Map<ID, Opportunity> parentOppy = new Map<ID, Opportunity>();
    for(scrive__ScriveDocument__c sd: newRecord) {
       oppIds.add(sd.scrive__opportunity__c);
   }

    List <Opportunity> parentOppys = [SELECT id,TransactionID__c,(select id,scrive__externalId__c  from scrive__ScriveDocuments__r WHERE scrive__externalId__c != null and scrive__status__c ='Signed') FROM Opportunity WHERE id IN :oppIds];
   Boolean firstLoop = True;
    For (Opportunity oppy : parentOppys){
        For(scrive__ScriveDocument__c scriveServDocument : oppy.scrive__ScriveDocuments__r){
            If(firstLoop){
            oppy.TransactionID__c = scriveServDocument.scrive__externalId__c;
            firstLoop = False;
            }
            Else{
            oppy.TransactionID__c = oppy.TransactionID__c +';'+scriveServDocument.scrive__externalId__c;
            }
        }
        firstLoop = True;
    }
     update parentOppys;
     toStopRec = false;
}
}