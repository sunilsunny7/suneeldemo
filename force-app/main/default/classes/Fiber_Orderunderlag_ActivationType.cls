/****************************************************************************************************************************

* @author                 Sunita Tudu   <sunita.tudu@capgemini.com>
* @modifiedBy             Sunita Tudu   <sunita.tudu@capgemini.com>
* @maintainedBy           Sunita Tudu
* @version                1.0
* @description            Sets the activation type for Line Items in Produkter Tab for Orderunderlag as part of LTAT-8316 and LTAT-8591

* @modified               05-22-2023

******************************************************************************************************************************/
global without Sharing class Fiber_Orderunderlag_ActivationType implements vlocity_cmt.VlocityOpenInterface2 {

  String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

  global Boolean invokeMethod(String methodName, Map < String, Object > inputMap, Map < String, Object > outputMap, Map < String, Object > options) {
    Boolean result;
    try{
      if (methodName.equalsIgnoreCase('getActivationType')) {
        getActivationType(inputMap, outputMap,options);
      }
    }
    catch(Exception e)
    {
      system.debug('Exception e --> '+e);
    }
    return result;
  }

  private static void getActivationType(Map < String, Object > inputMap, Map < String, Object > outputMap,Map<String,Object> options){
    try{


            Map<String,String> codeMap = new Map<String,String>();
            String activationlabel = System.Label.Fiber_installation_Product_Name;
            List<Fiber_Activation_Type__c> actType = Fiber_Activation_Type__c.getAll().values();           
            String allmantData = JSON.serialize(inputMap.get('allmant'));
            Map<String,Object>  allmantObj =  (Map<String,Object>) JSON.deserializeUntyped(allmantData);
            String Strom = (String)allmantObj.get('Strom');
            String data = JSON.serialize(inputMap.get('Produkter'));
            Map<String,Object>  obj =  (Map<String,Object>) JSON.deserializeUntyped(data);  
            String cliName = JSON.serialize(obj.get('CLIName'));
            List<Object>  obj1 =  (List<Object>) JSON.deserializeUntyped(cliName);            
            for(Object nameObj :obj1){
                for(Fiber_Activation_Type__c actTypeRec : actType){
                    
                    String name = JSON.serialize(nameObj);
                    Map<String,Object>  nameObj1 = (Map<String,Object>) JSON.deserializeUntyped(name); 
                    String nameobj2 = JSON.serialize(nameObj1.get('Name'));
                    List<Object>  nameobj3 =  (List<Object>) JSON.deserializeUntyped(nameobj2);
                    String nameobj4 = JSON.serialize(nameobj3[0]);
                    Map<String,Object>  nameobj5 =  (Map<String,Object>) JSON.deserializeUntyped(nameobj4);
                    if(actTypeRec.ProductCode__c == (String)nameobj5.get('ProductCode') && Strom == actTypeRec.Strom__c ){
                        codeMap.put((String)nameobj5.get('ProductCode'),actTypeRec.ActivationType__c); 
                    }
                    else if(actTypeRec.ProductCode__c == (String)nameobj5.get('ProductCode') && actTypeRec.oldActivationLogic__c == true){
                        codeMap.put((String)nameobj5.get('ProductCode'),actTypeRec.ActivationType__c); 
                    }
                }
               codeMap.put('activationlabel',activationlabel);
            }
            system.debug('codeMap '+codeMap);
            outputMap.put('activationtypemapinprodukter',codeMap);


    }
    catch(Exception e){
      outputMap.put('Error',e.getStackTraceString());
    }      
  }



}