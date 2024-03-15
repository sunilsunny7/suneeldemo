trigger MCONLINE_RemovePricelistEntries on vlocity_cmt__PriceListEntry__c (after insert) 
{
  PriceListEntryHandler.handleEvents(Trigger.old,Trigger.new,Trigger.oldMap,Trigger.newMap,Trigger.operationType);
}