@isTest
public class DCAPIParamsImplementation_Test {
    @isTest
    static void test(){
         Map < String, Object > inputs = new Map < String, Object >();
             Map < String, Object > outputs = new  Map < String, Object >();
             Map < String, Object > options = new  Map < String, Object >();
        DCAPIParamsImplementation.invokeMethod('fetchAPIParamsOverride', inputs, outputs, options);
    }
}