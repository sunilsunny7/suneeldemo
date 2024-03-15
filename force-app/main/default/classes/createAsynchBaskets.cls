public class createAsynchBaskets implements Queueable {

    private Map<String, Object> input = new Map<String, Object>();
    private Map<String, Object> output = new Map<String, Object>();
    private Map<String, Object> option = new Map<String, Object>();
    private Map<String, Object> checkoutInput = new Map<String, Object>();
    private Map<String, Object> updateAsynchBskts = new Map<String, Object>();
    private id BasketId;
    private integer productConfigListSize;
    private integer count;
    private string AgreementId;
    private string TSCID;
    private string User;
    private list<Id> BasketIdsOfAsynch = new List<Id>();
    
    public createAsynchBaskets(Map<String, Object> input,Map<String, Object> output,Map<String, Object> option, id BasketId, integer productConfigListSize, integer count,string AgreementId,string TSCID,string User, Map<String, Object>checkoutInput,Map<String, Object> updateAsynchBskts,List<id> BasketIds) {
        this.input = input;
        this.output = output;
        this.option = option;
        this.basketId = BasketId;
        this.productConfigListSize = productConfigListSize;
        this.count = count;
        this.checkoutInput = checkoutInput;
        this.AgreementId = AgreementId;
        this.TSCID = TSCID;
        this.User = User;
        this.updateAsynchBskts=updateAsynchBskts;
        this.BasketIdsOfAsynch = BasketIds;
       }
    
    public void execute(System.QueueableContext qc) {
        system.debug(input);
        
        vlocity_cmt.CpqAppHandler appHandler = new vlocity_cmt.CpqAppHandler();
        appHandler.invokeMethod('addAfterConfig', input, output, option);
         system.debug('output after MTS quueable-> '+output);
        if(output.containskey('nexttransaction'))
        {
            Map<String, Object> next = (Map<String, Object>)output.get('nexttransaction');
            Map<String,Object> rest = (Map<String, Object>)next.get('rest');
            Map<String,Object> params = (Map<String, Object>)rest.get('params');
            String multiTransactionKey = (String)params.get('multiTransactionKey');
            input.put('multiTransactionKey',multiTransactionKey);
            if(!Test.isRunningTest())
            {
                appHandler.invokeMethod('addAfterConfig', input, output, option);
                
            }
        }
        
        updateAsynchBskts.put(BasketId,output);
        //BasketIdsOfAsynch.add(BasketId);
        MCOnline_MultiAddToBasketAndCheckOut_V3.UpdateBasket(output,BasketId,productConfigListSize,count,AgreementId,TSCID,User,checkoutInput,updateAsynchBskts,BasketIdsOfAsynch);
    }
    
  
}