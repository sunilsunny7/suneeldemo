@isTest
public class UpdateOrderQueuable_V3_Test {
@isTest
    static void test(){
        Map<String, Object> inputMap = new Map<String, Object>();
      inputMap.put('orderId', 'value');
        new UpdateOrderQueuable_V3(inputMap).execute(null);
            
        
    }
}