trigger versioncontentSF on ContentVersion (after update, after insert) {
    ContentVersionHandler handler = new ContentVersionHandler ();
    if(Trigger.isInsert && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
    if(Trigger.isUpdate && Trigger.isAfter){
        handler.OnAfterInsert(Trigger.new);
    }
}