trigger BBCM_FM_Trigger on Broadband_Cost_Magin__c (before insert, before update) 
{
    List<String> fmname = new List<String>();
    //capture all the Name
    for( Broadband_Cost_Magin__c BCM : Trigger.new )
    {
         fmname.add(String.Valueof(BCM.Name));
    }

//Get all the related Financial_material__c match name

 List<Financial_material__c> financialM= new List<Financial_material__c>([SELECT Id, Name  FROM Financial_material__c WHERE Name = :fmname]);
 
    for(Broadband_Cost_Magin__c BroadbandCM : Trigger.new){
      for(Financial_material__c FM: financialM){
      
        if (financialM.size() == 0)
        {
            BroadbandCM .addError(label.FM_Trigger);
        }
        else if(BroadbandCM.Name ==  FM.Name )
        {
            BroadbandCM.Financial_Material_ID__c = FM.Id;
        } 
      

      }
    }

}