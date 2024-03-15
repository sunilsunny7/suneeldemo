@isTest
public class Test_CustomLevelBasedImplementation {
    public static testmethod void invokeMethod(){
        User salesManager;         
        Id pricebookId;
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        System.runAs(new User(Id = Userinfo.getUserId())){
            salesManager = Test_DataFactory.createSalesManagerUsers(1)[0];
            salesManager.Bypass_VR__c = true;
            insert salesManager;
        }
        System.runAs(salesManager){
            
            Opportunity opp = new Opportunity();
            opp.Name='opp1';
            opp.CloseDate = System.today();
            opp.StageName='Needs Analysis';  
            opp.Pricebook2Id=Test.getStandardPricebookId();
            opp.TeliaSE_SharingSetting_Flag__c = false;
            insert opp;
           
            
            Quote qut = new Quote();
            qut.Name='test Quote';
            qut.status = 'Draft';
            qut.opportunityId = opp.id;
            insert qut;
			
            Map<String,Object> inputMap = new Map<String,Object>();
            Map<String,Object> outMap = new Map<String,Object>();
            Map<String,Object> optMap = new Map<String,Object>();
            inputMap.put('cartId', qut.id);
            
            CustomLevelBasedImplementation cls = new CustomLevelBasedImplementation();
            cls.invokeMethod('getLevelBasedApproach', inputMap, outMap, optMap);
            cls.invokeMethod('', inputMap, outMap, optMap);
		}
    }
}