@isTest
public class CustomResultToXliTest {
 @istest
      static void test(){
          Map<String, Object> jsonResult = new Map<String, Object>();
        
           List<Object> jsonRecords = new  List<Object>();
          Map<String, Object> strmap = new Map<String, Object>();
          jsonRecords.add(strmap);
          jsonResult.put('records', jsonRecords);
          CustomResultToXli.iterateJsonResult(jsonResult);
  }
    
     @istest
      static void test1(){
           List<Object> jsonRecords = new List<Object>();
 jsonRecords.add('records');
 Set<String> fieldsToUpdate = new Set<String>();
 fieldsToUpdate.add('TestStr');
 fieldsToUpdate.add('lineItems');
  fieldsToUpdate.add('productGroups');
 
 Map<String, Object> jsonRecord = new Map<String, Object>();
 Map<String, Object> productGroupsMap = new Map<String, Object>();
 Map<String, Object> productGroupsMap1 = new Map<String, Object>();
 List<Object> objlist = new List<Object>();
          objlist.add(productGroupsMap);
          productGroupsMap1.put('records',objlist);
        jsonRecord.put('productGroups',productGroupsMap1); 
          jsonRecord.put('lineItems',productGroupsMap1);  
 CustomResultToXli.iterateJsonRecord(jsonRecord);
      }
      @istest
      static void test2(){        
          String methodName;
          Map<String, Object> inputMap = new Map<String, Object>();
          Map<String, Object> outputMap = new Map<String, Object>();
          Map<String, Object> options = new Map<String, Object>();
          Map<String, Object> result = new Map<String, Object>();
          List<Object> jsonRecords = new  List<Object>();
          Map<String, Object> strmap = new Map<String, Object>();
          jsonRecords.add(strmap);
          result.put('records', jsonRecords);
          inputMap.put('result',result);
          new CustomResultToXli().invokeMethod('generateXLIFromResult', inputMap, outputMap,options);
      } 
   
      @istest
      static void test3(){
           vlocity_cmt.VOIInvoker invoker = vlocity_cmt.VOIInvoker.getInstance();
     vlocity_cmt.VlocityOpenInterface defaultResultToXli = (vlocity_cmt.VlocityOpenInterface)invoker.invoke('DefaultResultToXLIImplementation', 'debugCreate', null, null, null);
    
     Map<String, Object> inputMap = new  Map<String, Object>();
      Map<String, Object> outputMap = new  Map<String, Object>();
           Map<String, Object> options = new  Map<String, Object>();
     defaultResultToXli.invokeMethod('generateXLIFromResult', inputMap, outputMap, options);
      }
}