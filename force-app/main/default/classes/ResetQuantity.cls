global class ResetQuantity implements vlocity_cmt.VlocityOpenInterface {
    
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options)
    {
        Boolean result = false;
        try {
            // check methodName
            if(methodName == 'resetQuoteQty') {
                resetQuoteQty(outMap);
                result = true;
            }
        } catch(Exception e) {
            system.debug('The error is ' + e.getMessage());
        }
        return result;
    }
    
    private void resetQuoteQty(Map<String,Object> outMap) {
        //List<Account> accountList = [SELECT Id, Name, Website, Phone FROM Account LIMIT 10];
        //outMap.put('account', accountList);
 }
    
}