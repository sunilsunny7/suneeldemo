/****************************************************************************************************************************
* @author                 Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @maintainedBy           Suneel Shivanna
* @version                1.0
* @description            REST API to  upsert products and pricing 
* @modified               
******************************************************************************************************************************/
@RestResource(urlMapping='/loadProducts')
global without sharing class LoadProduct {
    public static String parentProduct;
    public static String parentPhimId;   
    public static Integer productsCount=0;
    @HttpPost
    global static void importProducts()
    {
        RestResponse res=RestContext.response;
        Map<String,String> outMap=new Map<String,String>();
        outMap.put('Status','Success');
        outMap.put('StatusCode','200');
        try{
            List<Load_Product__c> prods=new List<Load_Product__c>();
            Load_Product__c prod;
            Map<String,Object> attributes;
            RestRequest req=RestContext.request;
            
            String updatedData=req.requestBody.toString().replaceAll('&quot;','"');
            Map<String,Object> data=(Map<String,Object>)JSON.deserializeUnTyped(updatedData);
            
            parentPhimId=String.valueOf(data.get('PhimId'));
            
            genericGetter((List<Object>)data.get('Fields'),prod);
            Integer productsCount=((List<Object>)data.get('Variants')).size();
            for(Object variant:(List<Object>)data.get('Variants'))
            {
                prod =new Load_Product__c();
                prod.ParentProductCode__c='HW_'+parentPhimId;
                prod.MCOnline_BundleName__c=parentProduct;
                prod.ParentPhimId__c=parentPhimId;
                

                Map<String,Object> temp=(Map<String,Object>)variant;
                prod.PhimId__c=String.valueOf(temp.get('PhimId'));
                genericGetter((List<Object>)temp.get('Fields'),prod);

                prods.add(prod);
            }
            if(prods.size()>0)
            {
                insert prods;
            }
        }catch(Exception e)
        {
            outMap.put('Status','failure');
            outMap.put('StatusCode','500');
            outMap.put('ErrorMessage',e.getMessage()+' at Linenumber: '+e.getLineNumber());
        }   
        res.responseBody=Blob.valueOf(JSON.serialize(outMap));
        res.addHeader('Content-Type', 'application/json');
        
    }

    private static void genericGetter(List<Object> data,Load_Product__c prod)
    {
        
        for(Object obj:data)
        {
            Map<String,Object> field=(Map<String,Object>)obj;

            switch on (String)field.get('Id')
            {
                when 'HWProductName'
                {
                    parentProduct=field.get('Data')!=null?getDataFromMap(field.get('Data')):null;
                    break;                    
                }
                when 'HWItemName'
                {
                    prod.ProductNameEng__c=field.get('Data')!=null?getDataFromMap(field.get('Data')):null;
                    prod.ProductNameSwe__c=field.get('Data')!=null?getDataFromMapSwe(field.get('Data')):null;
                    prod.productCode__c=field.get('Data')!=null?getProductCode(getDataFromMap(field.get('Data'))):null; 
                }
                when 'HWItemSapMaterialIdSe'
                {
                    prod.TeliaSE_Product_Service_Code__c=field.get('Data')==null?null:field.get('Data') instanceof String ? field.get('Data')+'':getData(field.get('Data'));
                }
                when  'HWItemRecommendedSalesPriceExcl'
                {
                    prod.NRC__c=Decimal.valueOf(String.valueOf(field.get('Data')));
                }
                when  'HWItemManufacturerName'
                {
                    prod.Brand__c=field.get('Data')==null?null:field.get('Data') instanceof String ? field.get('Data')+'':getData(field.get('Data'));
                }
                when  'HWItemCnetMemory'
                {
                    prod.Memory__c =field.get('Data')==null?null:field.get('Data') instanceof String ? field.get('Data')+'':getData(field.get('Data'));
                }
                when  'HWItemStatus'
                {
                    prod.Status__c=field.get('Data')!=null?getDataFromKeyMapSwe(field.get('Data')):null;
                }
                when 'HWItemSaleStart'
                {
                    prod.SalesStart__c=field.get('Data')==null?null:field.get('Data') instanceof String ? field.get('Data')+'':getData(field.get('Data'));
                }
                when 'HWItemBrandColorCvl'
                {
                    prod.color__c=field.get('Data')!=null?getDataFromKeyMapSwe(field.get('Data')):null;
                }
                when 'HWItemAssortment'
                {
                    prod.PhimProductGroup__c=field.get('Data')!=null?getDataFromKeyMapSwe(field.get('Data')):null;
                    prod.OfferName__c =field.get('Data')!=null?(getDataFromKeyMapSwe(field.get('Data'))=='Mobiltelefoner'?'Mobiltelefoner':'Tilbehör'):null;
                    prod.MCSales_OfferName__c =field.get('Data')!=null?(getDataFromKeyMapSwe(field.get('Data'))=='Mobiltelefoner'?'Mobiltelefoner':'Tilbehör'):null;
                    prod.offerCode__c=prod.OfferName__c=='Mobiltelefoner'?getOfferCode(parentPhimId):getOfferCode(null);
                    prod.C2BC_Category__c=field.get('Data')!=null?getDataFromKeyMapSwe(field.get('Data')):null;
                    prod.MCSales_Offer_Code__c=prod.OfferName__c=='Mobiltelefoner'?'MOB_HARDWARE_OFFER':'MOB_ACCESSORY_OFFER';
                }
            }
        }
    }

    private static String getData(Object temp)
    {
        Map<String,Object> tempMap=(Map<String,Object>)temp;
        return (String)tempMap.get('Value');
    }
    
    
    private static String getDataFromKeyMapSwe(Object temp)
    {
        Map<String,Object> tempMap=(Map<String,Object>)temp;
        tempMap=(Map<String,Object>)tempMap.get('Value');
        tempMap=(Map<String,Object>)tempMap.get('stringMap');
        return (String)tempMap.get('sv');
    }

    private static String getDataFromMap(Object temp)
    {
        Map<String,Object> tempMap=(Map<String,Object>)temp;
        tempMap=(Map<String,Object>)tempMap.get('stringMap');
        return (String)tempMap.get('en');
    }
     
    private static String getDataFromMapSwe(Object temp)
    {
        Map<String,Object> tempMap=(Map<String,Object>)temp;
        tempMap=(Map<String,Object>)tempMap.get('stringMap');
        return (String)tempMap.get('sv');
    }

    private static String getProductCode(String code)
    {
        String productCode='';
        for(String prodCode:code.split(' '))
        {
				productCode+=prodCode.toUpperCase()+'_';
        }
        return productCode.removeEnd('_');
    }
    
    private static String getOfferCode(String bundlePhimId)
    {
        List<Id> bundleIds=new List<Id>();
        String offerCode=[select id,ProductCode from Product2 where ProductCode like 'HW_MOBILEDEVICES%' and vlocity_cmt__ObjectTypeId__r.Name ='Offer' order by ProductCode desc limit 1]?.productCode;
        List<vlocity_cmt__ProductChildItem__c> bundles=[select vlocity_cmt__ChildProductId__c,vlocity_cmt__ChildProductId__r.productCode from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.productCode=:offerCode];
        for(vlocity_cmt__ProductChildItem__c item:bundles)
        {
            bundleIds.add(item.vlocity_cmt__ChildProductId__c);
        }
        List<vlocity_cmt__ProductChildItem__c> products=[select vlocity_cmt__ChildProductId__c from vlocity_cmt__ProductChildItem__c where vlocity_cmt__ParentProductId__r.productCode IN :bundleIds];

        if(products.size()+productsCount > 20)
        {
            return createNewOffer(offerCode);
        }
        return offerCode;
    }

    private static String createNewOffer(String offerCode)
    {
        offerCode='HW_MOBILEDEVICES'+Integer.valueOf(offerCode.subStringAfter('HW_MOBILEDEVICES'));
        Product2 offerProduct=new Product2();
        offerProduct.Name='Mobiltelefoner';
        offerProduct.productCode=offerCode;
        offerProduct.vlocity_cmt__Status__c='Active';
        offerProduct.vlocity_cmt__SpecificationType__c='Offer';
        offerProduct.vlocity_cmt__IsOrderable__c=true;
        offerProduct.C2BC_Category__c='offerbundle';
        offerProduct.vlocity_cmt__ObjectTypeId__c=[SELECT id,name FROM vlocity_cmt__ObjectClass__c WHERE Name ='Offer']?.Id;
        return offerCode;
    }
}