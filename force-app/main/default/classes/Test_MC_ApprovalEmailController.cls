@isTest
public class Test_MC_ApprovalEmailController {
    
    @isTest
    public static void test1()
    {
        MC_Sales_ApprovalEmailQLI_Controller mc = new MC_Sales_ApprovalEmailQLI_Controller();
        mc.cartId = '12436';
        Map<String,Object> map1 = mc.callIntegrationprocedure('1234');
        Map<String,Object> map2 = mc.callIntegrationprocedure('');
        Map<String,Object> map3 = mc.ProductInfo;
           
    }

}