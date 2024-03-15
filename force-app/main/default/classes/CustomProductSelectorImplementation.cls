// To enable this class: Create an Interface Implementation record that references this class and set it
// as the Active implementation for the ProductSelectorInterface
global with sharing class CustomProductSelectorImplementation implements vlocity_cmt.VlocityOpenInterface 
{
    global Boolean invokeMethod(String methodName, Map<String, Object> input, Map<String, Object> output,
                                Map<String, Object> options)
    {
        if (methodName == 'getAllProducts')
        {

            System.debug(input);

            input.put('sortString', 'ORDER BY Product2.MC_Product_Sequence__c NULLS LAST');

 			System.debug('sortString '+input.get('sortString'));            
        }
        Type t = Type.forName('vlocity_cmt.DefaultProductSelectorImplementation');

        System.debug(t);
        if (t != null)
        {
            vlocity_cmt.VlocityOpenInterface productSelector = (vlocity_cmt.VlocityOpenInterface)t.newInstance();
            //System.debug('*** CustomProductSelectorImplementation input: ' + json.serialize(input));
            Boolean result = productSelector.invokeMethod(methodName, input, output, options);
            //System.debug('*** CustomProductSelectorImplementation output: ' + json.serialize(output));

            return result;
        }
        return false;
    }
}