public class JsonUpdateMigration 
{
    public static QuoteLineItem updateJsonAttributes(QuoteLineItem qli)
    {       
        Map<String,Object> rawObj = (Map<String,Object>) JSON.deserializeUntyped(qli.vlocity_cmt__JSONAttribute__c);
        List<Object> o1 = (List<Object>)rawObj.get('ATT_CODE_TELIAMOBAGGR');
        Map<String,Object> jsonNode = new Map<String,Object>();
        List<Object> newJson = new List<Object>();
        string attributeName;
		string attributedisplayName;
        Boolean flag = false;  
        for(Object o2: o1)
        {		
            jsonNode = (Map<String,Object>)o2;
            attributeName = (String) jsonNode.get('attributeuniquecode__c');
            attributedisplayName = (String) jsonNode.get('attributedisplayname__c');
			//Removing Abroad call discount and Invoice fee
			If((qli.TeliaSE_Product_Code__c =='MOB_MULTI_ALL_IN_PLUS' || qli.TeliaSE_Product_Code__c =='MOB_MULTI_TOTAL') ||  (attributeName!='ATT_ABR_CALL_DISC' && attributeName!='ATTR_INVOICE'))
			{
                //Name change subsdized
				If(attributeName == 'ATT_RT_SUB')
				{
					If(attributedisplayName != 'Subventionerat')
					{
						system.debug('subsidized loop');
						jsonNode.put('attributedisplayname__c','Subventionerat');
						flag = true;
					}
				}
                //Name Change No of users
				else if(attributeName == 'ATT_RT_NoU')
				{
					If(attributedisplayName != 'Antal för basnivå')
					{
						jsonNode.put('attributedisplayname__c','Antal för basnivå');
						flag = true;
					}
				}  
                //Name Change commitment period
				else if(attributeName == 'ATT_RT_CMTP')
				{
					If(attributedisplayName != 'Avtalstid')
					{
						system.debug('Commitment Period');
						jsonNode.put('attributedisplayname__c','Avtalstid');
						flag = true;
					}	
				}
                //Name change Minimum Commit
				else if(attributeName == 'ATT_RT_MINC')
				{
					If(attributedisplayName != 'Basnivå (%)')
					{
						system.debug('Minimum Commit');
						jsonNode.put('attributedisplayname__c','Basnivå (%)');
						flag = true;
					}					
				}
                //name change quarantine period
				else if(attributeName =='ATT_QUARANTINE_PERIOD')
				{
					If(attributedisplayName != 'Tid för att uppfylla basnivå')
					{
						system.debug('Quarantine Period');
						jsonNode.put('attributedisplayname__c','Tid för att uppfylla basnivå');
						flag = true;
					}
				}
                //name change data paket bas
                else if(attributeName =='ATT_BAS_PRICEPLAN_CAT' || attributeName =='ATTR_PR_TYPE_CAT')
				{
					If(attributedisplayName != 'Datapaket för Bas')
					{
						system.debug('Data Paket Bas');
						jsonNode.put('attributedisplayname__c','Datapaket för Bas');
						flag = true;
					}
				}
				newJson.add(jsonNode);
			}
        }
        if(flag == true)
        {
            //System.debug('Object 3 :' + o3);
            Map<String,Object> newMap = new Map<String,Object>();
            newMap.put('ATT_CODE_TELIAMOBAGGR',newJson);
            //System.debug(newMap);
            String jsonMap=JSON.serialize(newMap);
            //System.debug(jsonMap);
            qli.vlocity_cmt__JSONAttribute__c = jsonMap;
            return qli;
        }
        else
        {
            return null;
        }
        
    }

}