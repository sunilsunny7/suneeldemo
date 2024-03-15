public class NavigateLEXController{
    
    public PageReference FinishLoginFlowStartUrl(){
        String prefix = URL.getSalesforceBaseURL().toExternalForm().split('\\.')[0];
        prefix = prefix.removeEnd('--c').toLowerCase() +'.lightning.force.com/lightning/page/home';
        return Auth.SessionManagement.finishLoginFlow(prefix);
    }
}