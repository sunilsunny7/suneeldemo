public class CreateLeadController {     
    public Boolean LoadScript { get; set; }
    public String TypeId { get; set; }
    
    public CreateLeadController(ApexPages.StandardController controller){
        
    }
    
    //Redirects to pardot form
    public PageReference redirect(){
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String recordTypeId = params.get('RecordType');
        String retUrl = params.get('retURL') != null ? params.get('retURL') : '/00Q';
        String saveNewUrl =   params.get('save_new_url');
        
        Boolean isLightning = UserInfo.getUiThemeDisplayed() == 'Theme4d';
        Boolean isMobile = UserInfo.getUiThemeDisplayed() == 'Theme4t';
        
        String recordTypeName = SEUtility.getRecordTypeDevName(recordTypeId);
        String profileId = UserInfo.getProfileId();
        
        
        //Direct to Cygate Lead Creation
        If(SEUtility.isCygateUser(profileId) || recordTypeName == 'Cygate_Lead'){
            if(isLightning || isMobile){
                TypeId = SEUtility.getRecordTypeId('Cygate_Lead');
                LoadScript = true;
                return null;
            }else{
                return createPageReference('/00Q/e', retUrl, recordTypeId);
            }
        
        //Direct to Standard Telia Lead Creation
        }else if((SEUtility.isSystemAdmin(profileId) || SEUtility.isEnterpriseBusinessAdminUser(profileId)) && recordTypeName == 'Standard_Telia_Lead'){
            if(isLightning || isMobile){
                TypeId = SEUtility.getRecordTypeId('Standard_Telia_Lead');
                LoadScript = true;
                return null;
            }else{
                return createPageReference('/00Q/e', retUrl, recordTypeId); 
            }
            
        //Direct to Pardot Lead Agent Form
        }else if(SEUtility.isLeadsAgent(profileId)){ 
            return createPageReference('/apex/AF_Lead_form', retUrl, recordTypeId);
        
        //Direct to Pardot Sales Rep Form 
        }else{ 
            return createPageReference('/apex/PardotSalesRepForm', retUrl, recordTypeId);
        } 
    }
    
    private PageReference createPageReference(String url, String retUrl, String recordTypeId){
        PageReference pr = new PageReference(url + '?retURL=' + retUrl + '&RecordType=' + recordTypeId + '&ent=Lead&nooverride=1');
        pr.setRedirect(true);
        return pr; 
    }
}