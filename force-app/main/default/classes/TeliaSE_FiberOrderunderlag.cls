/*-----------------------------------------------------------------------------------------------------------
**Name        :        TeliaSE_FiberOrderunderlag
**Created By  :        Rahul Kadam
**Date      :          10 Feb 2022
**User Story  :       
**Description :        Contains Apex Migration of OrderunderlagExtract DR
-----------------------------------------------------------------------------------------------------------*/
global class TeliaSE_FiberOrderunderlag implements vlocity_cmt.VlocityOpenInterface
{
    global Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outputMap, Map<String, Object> options)
    {
        try 
        {
            if(methodName.equalsIgnoreCase('generateOrderunderlagExtract'))
            {
                system.debug('Inside Method invoked');
                Map < String, Object > result = new Map < String, Object > ();
                List<Object> arguments = (List<Object>) inputMap.get('arguments');
                Id cid = Id.valueOf((String) arguments[0]);
                generateOrderunderlagExtract(cid,outputMap);
            }
            if(methodName.equalsIgnoreCase('getMRCForHousehold'))
            {
                Map < String, Object > result = new Map < String, Object > ();
                List<Object> arguments = (List<Object>) inputMap.get('arguments');
                
                Id cid = Id.valueOf((String) arguments[0]);//Here cid is your quote id
               getMRCForHousehold(cid,outputMap);
            }
        }
        catch(Exception e)
        {  
            System.debug('exception: '+e);
        } 
        return true;
    }
    public static void generateOrderunderlagExtract(Id cid, Map<String,Object> outputMap)
    {
        //Declare DR variables
        string isHALEBOPBB = '';
        decimal isHALEBOPBBRCT;
        decimal HALEBOPBBQuantity;
        //Declaration MDU_FS_Internet products
        string MDUFSInternet2Name = '', MDUFSInternet10Name = '', MDUFSInternet100Name = '', MDUFSInternet1000Name = '';
        decimal MDUFSInternet2RCT, MDUFSInternet10RCT, MDUFSInternet100RCT, MDUFSInternet1000RCT;
        decimal MDUFSInternet2Quantity, MDUFSInternet10Quantity, MDUFSInternet100Quantity, MDUFSInternet1000Quantity;
        //Declaration MDU_FS_IP_VPN products
        string MDU_FS_IP_VPN2Name = '', MDU_FS_IP_VPN10Name = '', MDU_FS_IP_VPN100Name = '', MDU_FS_IP_VPN1000Name = '';
        decimal MDU_FS_IP_VPN2RCT, MDU_FS_IP_VPN10RCT, MDU_FS_IP_VPN100RCT, MDU_FS_IP_VPN1000RCT;
        decimal MDU_FS_IP_VPN2Quantity, MDU_FS_IP_VPN10Quantity, MDU_FS_IP_VPN100Quantity, MDU_FS_IP_VPN1000Quantity;
        //Declaration MDU_FS_VPN products
        string MDU_FS_VPN2Name = '', MDU_FS_VPN10Name = '', MDU_FS_VPN100Name = '', MDU_FS_VPN1000Name = '';
        decimal MDU_FS_VPN2RCT, MDU_FS_VPN10RCT, MDU_FS_VPN100RCT, MDU_FS_VPN1000RCT;
        decimal MDU_FS_VPN2Quantity, MDU_FS_VPN10Quantity, MDU_FS_VPN100Quantity, MDU_FS_VPN1000Quantity;
        //Declaration FS_Etableringsport products
        string FS_Etableringsport_100Name = '', FS_Etableringsport_1000Name = '', FS_Etableringsport_10000Name = '';
        decimal FS_Etableringsport_100RCT, FS_Etableringsport_1000RCT, FS_Etableringsport_10000RCT;
        decimal FS_Etableringsport_100Quantity, FS_Etableringsport_1000Quantity, FS_Etableringsport_10000Quantity;
        //Declaration FS_Etableringsport_VPN products
        string FS_Etableringsport_VPN100Name = '', FS_Etableringsport_VPN1000Name = '', FS_Etableringsport_VPN10000Name = '';
        decimal FS_Etableringsport_VPN100RCT, FS_Etableringsport_VPN1000RCT, FS_Etableringsport_VPN10000RCT;
        decimal FS_Etableringsport_VPN100Quantity, FS_Etableringsport_VPN1000Quantity, FS_Etableringsport_VPN10000Quantity;
        //Declaration FS_Nationellt_tillagg products
        string FS_Nationellt_tillagg_2019Name = '';
        decimal FS_Nationellt_tillagg_2019RCT;
        decimal FS_Nationellt_tillagg_2019Quantity;
        //Declaration MDU_CollIPTVB2B products
        string MDU_CollIPTVB2B_Name = '';
        decimal MDU_CollIPTVB2B_RCT;
        decimal MDU_CollIPTVB2B_Quantity;
        //Declaration HalebopBB products
        string HalebopBB_Name = '';
        decimal HalebopBB_RCT;
        decimal HalebopBB_Quantity;

        string switchProductCode;
        //End of declaring DR variables
        
        Map<String, Object> resultMap = new Map<String, Object>();
        Boolean istestclass = false;
        if (test.isRunningTest())
        {
            istestclass = true;
        }
        list<vlocity_cmt__ContractLineItem__c> allData = [SELECT Name, TeliaSE_Type__c, vlocity_cmt__ProductCode__c, vlocity_cmt__Quantity__c, vlocity_cmt__RecurringCharge__c, Fiber_Customer_Requested_Price__c, TeliaSE_Fiber_Frame_Agreement__c, TeliaSE_Orderunderlag_Price__c FROM vlocity_cmt__ContractLineItem__c WHERE vlocity_cmt__ContractId__c =: cid];
        //system.debug('All Data --> '+allData.size());
        for(vlocity_cmt__ContractLineItem__c i:allData){
            switchProductCode = i.vlocity_cmt__ProductCode__c ;
            switch on switchProductCode{
                when 'HalebopBB_100'{
                    HalebopBB_Name = i.vlocity_cmt__ProductCode__c;
                    HalebopBB_RCT = i.TeliaSE_Orderunderlag_Price__c;
                    HalebopBB_Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'HalebopBB_250'{
                    HalebopBB_Name = i.vlocity_cmt__ProductCode__c;
                    HalebopBB_RCT = i.TeliaSE_Orderunderlag_Price__c;
                    HalebopBB_Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'HalebopBB_500'{
                    HalebopBB_Name = i.vlocity_cmt__ProductCode__c;
                    HalebopBB_RCT = i.TeliaSE_Orderunderlag_Price__c;
                    HalebopBB_Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'HalebopBB_1000'{
                    HalebopBB_Name = i.vlocity_cmt__ProductCode__c;
                    HalebopBB_RCT = i.TeliaSE_Orderunderlag_Price__c;
                    HalebopBB_Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_Internet_2_2019'{
                    MDUFSInternet2Name = i.vlocity_cmt__ProductCode__c;
                    MDUFSInternet2RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDUFSInternet2Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_Internet_10_2019'{
                    MDUFSInternet10Name = i.vlocity_cmt__ProductCode__c;
                    MDUFSInternet10RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDUFSInternet10Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_Internet_100_2019'{
                    MDUFSInternet100Name = i.vlocity_cmt__ProductCode__c;
                    MDUFSInternet100RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDUFSInternet100Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_Internet_1000_2019'{
                    MDUFSInternet1000Name = i.vlocity_cmt__ProductCode__c;
                    MDUFSInternet1000RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDUFSInternet1000Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_IP-VPN_2_2019'{
                    MDU_FS_IP_VPN2Name = i.vlocity_cmt__ProductCode__c;
                    MDU_FS_IP_VPN2RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_FS_IP_VPN2Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_IP-VPN_10_2019'{
                    MDU_FS_IP_VPN10Name = i.vlocity_cmt__ProductCode__c;
                    MDU_FS_IP_VPN10RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_FS_IP_VPN10Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_IP-VPN_100_2019'{
                    MDU_FS_IP_VPN100Name = i.vlocity_cmt__ProductCode__c;
                    MDU_FS_IP_VPN100RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_FS_IP_VPN100Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_IP-VPN_1000_2019'{
                    MDU_FS_IP_VPN1000Name = i.vlocity_cmt__ProductCode__c;
                    MDU_FS_IP_VPN1000RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_FS_IP_VPN1000Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_VPN_2_2019'{
                    MDU_FS_VPN2Name = i.vlocity_cmt__ProductCode__c;
                    MDU_FS_VPN2RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_FS_VPN2Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_VPN_10_2019'{
                    MDU_FS_VPN10Name = i.vlocity_cmt__ProductCode__c;
                    MDU_FS_VPN10RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_FS_VPN10Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_VPN_100_2019'{
                    MDU_FS_VPN100Name = i.vlocity_cmt__ProductCode__c;
                    MDU_FS_VPN100RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_FS_VPN100Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_FS_VPN_1000_2019'{
                    MDU_FS_VPN1000Name = i.vlocity_cmt__ProductCode__c;
                    MDU_FS_VPN1000RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_FS_VPN1000Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'FS_Etableringsport_100_2019'{
                    FS_Etableringsport_100Name = i.vlocity_cmt__ProductCode__c;
                    FS_Etableringsport_100RCT = i.TeliaSE_Orderunderlag_Price__c;
                    FS_Etableringsport_100Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'FS_Etableringsport_1000_2019'{
                    FS_Etableringsport_1000Name = i.vlocity_cmt__ProductCode__c;
                    FS_Etableringsport_1000RCT = i.TeliaSE_Orderunderlag_Price__c;
                    FS_Etableringsport_1000Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'FS_Etableringsport_10000_2019'{
                    FS_Etableringsport_10000Name = i.vlocity_cmt__ProductCode__c;
                    FS_Etableringsport_10000RCT = i.TeliaSE_Orderunderlag_Price__c;
                    FS_Etableringsport_10000Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'FS_Etableringsport-VPN_100_2019'{
                    FS_Etableringsport_VPN100Name = i.vlocity_cmt__ProductCode__c;
                    FS_Etableringsport_VPN100RCT = i.TeliaSE_Orderunderlag_Price__c;
                    FS_Etableringsport_VPN100Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'FS_Etableringsport-VPN_1000_2019'{
                    FS_Etableringsport_VPN1000Name = i.vlocity_cmt__ProductCode__c;
                    FS_Etableringsport_VPN1000RCT = i.TeliaSE_Orderunderlag_Price__c;
                    FS_Etableringsport_VPN1000Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'FS_Etableringsport-VPN_10000_2019'{
                    FS_Etableringsport_VPN10000Name = i.vlocity_cmt__ProductCode__c;
                    FS_Etableringsport_VPN10000RCT = i.TeliaSE_Orderunderlag_Price__c;
                    FS_Etableringsport_VPN10000Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'FS_Nationellt-tillagg_2019'{
                    FS_Nationellt_tillagg_2019Name = i.vlocity_cmt__ProductCode__c;
                    FS_Nationellt_tillagg_2019RCT = i.TeliaSE_Orderunderlag_Price__c;
                    FS_Nationellt_tillagg_2019Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_CollIPTVB2B_Bas_2143'{
                    MDU_CollIPTVB2B_Name = i.vlocity_cmt__ProductCode__c;
                    MDU_CollIPTVB2B_RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_CollIPTVB2B_Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_CollIPTVB2B_Start_2143'{
                    MDU_CollIPTVB2B_Name = i.vlocity_cmt__ProductCode__c;
                    MDU_CollIPTVB2B_RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_CollIPTVB2B_Quantity = i.vlocity_cmt__Quantity__c;
                }
                when 'MDU_CollIPTVB2B_Lagom_2143'{
                    MDU_CollIPTVB2B_Name = i.vlocity_cmt__ProductCode__c;
                    MDU_CollIPTVB2B_RCT = i.TeliaSE_Orderunderlag_Price__c;
                    MDU_CollIPTVB2B_Quantity = i.vlocity_cmt__Quantity__c;
                }
            }//End of Switch
        }//End of iterator on CLI
        //For HalebopBB products
        resultMap.put('HalebopBB_Name', HalebopBB_Name);
        resultMap.put('HalebopBB_RCT', HalebopBB_RCT);
        resultMap.put('HalebopBB_Quantity',HalebopBB_Quantity);
        
        //For MDU_FS_Internet products
        resultMap.put('MDUFSInternet2Name', MDUFSInternet2Name);
        resultMap.put('MDUFSInternet2RCT', MDUFSInternet2RCT);
        resultMap.put('MDUFSInternet2Quantity',MDUFSInternet2Quantity);
        resultMap.put('MDUFSInternet10Name', MDUFSInternet10Name);
        resultMap.put('MDUFSInternet10RCT', MDUFSInternet10RCT);
        resultMap.put('MDUFSInternet10Quantity',MDUFSInternet10Quantity);
        resultMap.put('MDUFSInternet100Name', MDUFSInternet100Name);
        resultMap.put('MDUFSInternet100RCT', MDUFSInternet100RCT);
        resultMap.put('MDUFSInternet100Quantity',MDUFSInternet100Quantity);
        resultMap.put('MDUFSInternet1000Name', MDUFSInternet1000Name);
        resultMap.put('MDUFSInternet1000RCT', MDUFSInternet1000RCT);
        resultMap.put('MDUFSInternet1000Quantity',MDUFSInternet1000Quantity);
        //For MDU_FS_IP_VPN products
        resultMap.put('MDU_FS_IP_VPN2Name', MDU_FS_IP_VPN2Name);
        resultMap.put('MDU_FS_IP_VPN2RCT', MDU_FS_IP_VPN2RCT);
        resultMap.put('MDU_FS_IP_VPN2Quantity',MDU_FS_IP_VPN2Quantity);
        resultMap.put('MDU_FS_IP_VPN10Name', MDU_FS_IP_VPN10Name);
        resultMap.put('MDU_FS_IP_VPN10RCT', MDU_FS_IP_VPN10RCT);
        resultMap.put('MDU_FS_IP_VPN10Quantity',MDU_FS_IP_VPN10Quantity);
        resultMap.put('MDU_FS_IP_VPN100Name', MDU_FS_IP_VPN100Name);
        resultMap.put('MDU_FS_IP_VPN100RCT', MDU_FS_IP_VPN100RCT);
        resultMap.put('MDU_FS_IP_VPN100Quantity',MDU_FS_IP_VPN100Quantity);
        resultMap.put('MDU_FS_IP_VPN1000Name', MDU_FS_IP_VPN1000Name);
        resultMap.put('MDU_FS_IP_VPN1000RCT', MDU_FS_IP_VPN1000RCT);
        resultMap.put('MDU_FS_IP_VPN1000Quantity',MDU_FS_IP_VPN1000Quantity);
        //For MDU_FS_VPN products
        resultMap.put('MDU_FS_VPN2Name', MDU_FS_VPN2Name);
        resultMap.put('MDU_FS_VPN2RCT', MDU_FS_VPN2RCT);
        resultMap.put('MDU_FS_VPN2Quantity',MDU_FS_VPN2Quantity);
        resultMap.put('MDU_FS_VPN10Name', MDU_FS_VPN10Name);
        resultMap.put('MDU_FS_VPN10RCT', MDU_FS_VPN10RCT);
        resultMap.put('MDU_FS_VPN10Quantity',MDU_FS_VPN10Quantity);
        resultMap.put('MDU_FS_VPN100Name', MDU_FS_VPN100Name);
        resultMap.put('MDU_FS_VPN100RCT', MDU_FS_VPN100RCT);
        resultMap.put('MDU_FS_VPN100Quantity',MDU_FS_VPN100Quantity);
        resultMap.put('MDU_FS_VPN1000Name', MDU_FS_VPN1000Name);
        resultMap.put('MDU_FS_VPN1000RCT', MDU_FS_VPN1000RCT);
        resultMap.put('MDU_FS_VPN1000Quantity',MDU_FS_VPN1000Quantity);
        //For FS_Etableringsport products
        resultMap.put('FS_Etableringsport_100Name', FS_Etableringsport_100Name);
        resultMap.put('FS_Etableringsport_100RCT', FS_Etableringsport_100RCT);
        resultMap.put('FS_Etableringsport_100Quantity',FS_Etableringsport_100Quantity);
        resultMap.put('FS_Etableringsport_1000Name', FS_Etableringsport_1000Name);
        resultMap.put('FS_Etableringsport_1000RCT', FS_Etableringsport_1000RCT);
        resultMap.put('FS_Etableringsport_1000Quantity',FS_Etableringsport_1000Quantity);
        resultMap.put('FS_Etableringsport_10000Name', FS_Etableringsport_10000Name);
        resultMap.put('FS_Etableringsport_10000RCT', FS_Etableringsport_10000RCT);
        resultMap.put('FS_Etableringsport_10000Quantity',FS_Etableringsport_10000Quantity);
        //For FS_Etableringsport_VPN products
        resultMap.put('FS_Etableringsport_VPN100Name', FS_Etableringsport_VPN100Name);
        resultMap.put('FS_Etableringsport_VPN100RCT', FS_Etableringsport_VPN100RCT);
        resultMap.put('FS_Etableringsport_VPN100Quantity',FS_Etableringsport_VPN100Quantity);
        resultMap.put('FS_Etableringsport_VPN1000Name', FS_Etableringsport_VPN1000Name);
        resultMap.put('FS_Etableringsport_VPN1000RCT', FS_Etableringsport_VPN1000RCT);
        resultMap.put('FS_Etableringsport_VPN1000Quantity',FS_Etableringsport_VPN1000Quantity);
        resultMap.put('FS_Etableringsport_VPN10000Name', FS_Etableringsport_VPN10000Name);
        resultMap.put('FS_Etableringsport_VPN10000RCT', FS_Etableringsport_VPN10000RCT);
        resultMap.put('FS_Etableringsport_VPN10000Quantity',FS_Etableringsport_VPN10000Quantity);
        //For FS_Nationellt_tillagg products
        resultMap.put('FS_Nationellt_tillagg_2019Name', FS_Nationellt_tillagg_2019Name);
        resultMap.put('FS_Nationellt_tillagg_2019RCT', FS_Nationellt_tillagg_2019RCT);
        resultMap.put('FS_Nationellt_tillagg_2019Quantity',FS_Nationellt_tillagg_2019Quantity);
        //For MDU_CollIPTVB2B products
        resultMap.put('MDU_CollIPTVB2B_Name', MDU_CollIPTVB2B_Name);
        resultMap.put('MDU_CollIPTVB2B_RCT', MDU_CollIPTVB2B_RCT);
        resultMap.put('MDU_CollIPTVB2B_Quantity',MDU_CollIPTVB2B_Quantity);
        
        //End of mapping to result map
        
        outputMap.put('result', resultMap);
    }//End of method generateOrderunderlagExtract
    public static void getMRCForHousehold(Id cid, Map<String,Object> outputMap){
        list<QuoteLineItem > allData = [SELECT vlocity_cmt__Product2Id__r.ProductCode, Fiber_Customer_Requested_Price__c, vlocity_cmt__RecurringCharge__c FROM QuoteLineItem  WHERE QuoteId =: cid];
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<string, double> mapOfProducts = new Map<string, double>();//This map captures all the product codes of household products 
        double defaultHouseHoldPrice = 0;
        double totalMRC = 0, tempMRC = 0;
        quote quoteToUpdate = new quote( id = cid);
        
        List <TeliaSE_HouseHold_Products__mdt> houseHoldmdt = new list<TeliaSE_HouseHold_Products__mdt>();
        houseHoldmdt = [SELECT Product_Code__c FROM TeliaSE_HouseHold_Products__mdt];
         for(TeliaSE_HouseHold_Products__mdt i: houseHoldmdt){
            mapOfProducts.put(i.Product_Code__c,defaultHouseHoldPrice);
         }
        for( QuoteLineItem qItem: allData){
            if( mapOfProducts.get( qItem.vlocity_cmt__Product2Id__r.ProductCode) != null){//This if checks whether given qLI product is household or not
                if( totalMRC == 0 ){
                    if( qItem.Fiber_Customer_Requested_Price__c == null ){
                        totalMRC = qItem.vlocity_cmt__RecurringCharge__c;
                    }//End of if( qItem.Fiber_Customer_Requested_Price__c == null )
                    else{
                        totalMRC = qItem.Fiber_Customer_Requested_Price__c;
                    }//End of else
                }//End of if( totalMRC == 0 )
                else{//This else adds up all the MRC only for household products
                    if( qItem.Fiber_Customer_Requested_Price__c == null ){
                        totalMRC = totalMRC + qItem.vlocity_cmt__RecurringCharge__c;
                    }//End of if( qItem.Fiber_Customer_Requested_Price__c == null )
                    else{
                        totalMRC = totalMRC + qItem.Fiber_Customer_Requested_Price__c;
                    }//End of else
                }//End of else
            } 
        }//End of for( QuoteLineItem qItem: allData)
        //Following  code update MRC field on Quote level
        quoteToUpdate.Fiber_Total_MRC_HouseHold__c = totalMRC;
        update quoteToUpdate;
        
        resultMap.put('totalMRCOfHousehold',totalMRC);
        outputMap.put('result', resultMap);
    }
}