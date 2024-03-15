trigger MBCM_FM_Trigger on Mobility_Cost_margin__c (before insert, before update) 
{
    List<String> fmname = new List<String>();
    //capture all the Name from MobilityCM
    for( Mobility_Cost_margin__c MCM : Trigger.new )
    {
         fmname.add(String.Valueof(MCM.Name));
    }

//Get all the related Financial_material__c match name
 List<Financial_material__c> financialM= new List<Financial_material__c>([SELECT Id, Name FROM Financial_material__c WHERE Name = :fmname]);
 
    for(Mobility_Cost_margin__c MobilityCM : Trigger.new){
      for(Financial_material__c FM: financialM){
      
        if (financialM.size() == 0)
        {
            MobilityCM .addError(label.FM_Trigger);
        }
        else if(MobilityCM.Name ==  FM.Name )
        {
            MobilityCM.Financial_Material_ID__c = FM.Id;
        } 
      }
    }
}