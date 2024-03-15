trigger MBCP_FM_Trigger on Mobility_Cost_price__c (before insert, before update) 
{
    List<String> fmname = new List<String>();
    //capture all the Name from MobilityCP
    for( Mobility_Cost_price__c MCP : Trigger.new )
    {
         fmname.add(String.Valueof(MCP.Name));
    }

//Get all the related Financial_material__c match name
 List<Financial_material__c> financialM= new List<Financial_material__c>([SELECT Id, Name FROM Financial_material__c WHERE Name = :fmname]);
 
    for(Mobility_Cost_price__c MobilityCP : Trigger.new){
      for(Financial_material__c FM: financialM){
      
        if (financialM.size() == 0)
        {
            MobilityCP.addError(label.FM_Trigger);
        }
        else if(MobilityCP.Name ==  FM.Name )
        {
            MobilityCP.Financial_Material_ID__c = FM.Id;
        } 
      }
    }
}