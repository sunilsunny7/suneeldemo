/*________________________________________________________________________________________________*/
//This class will update the display name of the attributes.
//This is a quick fix so the variables inside the are not dynamic.


global with sharing class AttributeLabelFix implements Database.Batchable<sObject>
{
	private String query='';
	private List<Id> productIds;
	private Boolean updateJSONAttributes = false;

	global AttributeLabelFix(List<Id> productIds, Boolean updateJSONAttributes)
    {
        this(productIds);
        this.updateJSONAttributes = updateJSONAttributes;
    }

    global AttributeLabelFix(List<Id> productIds)
    {
        this.productIds = productIds;
        String fields = 'Id, vlocity_cmt__AttributeId__c, vlocity_cmt__AttributeDisplayName__c, vlocity_cmt__AttributeDisplayNameOverride__c, vlocity_cmt__ObjectId__c, vlocity_cmt__ValueDataType__c, vlocity_cmt__PicklistId__c, vlocity_cmt__Value__c, vlocity_cmt__ExcludedPicklistValues__c, vlocity_cmt__DefaultPicklistValueId__c, vlocity_cmt__UIDisplayType__c, vlocity_cmt__ValidValuesData__c';
        query = 'select '+fields+' from vlocity_cmt__AttributeAssignment__c where vlocity_cmt__ObjectId__c IN :productIds';
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext context, List<SObject> scope)
    {
		List<vlocity_cmt__AttributeAssignment__c> addchanges = new List<vlocity_cmt__AttributeAssignment__c>();
        List<vlocity_cmt__AttributeAssignment__c> attrassignList = (List<vlocity_cmt__AttributeAssignment__c>)scope;
        for(vlocity_cmt__AttributeAssignment__c attributeLabelChange : attrassignList)
        {
            if(attributeLabelChange.vlocity_cmt__AttributeDisplayNameOverride__c !=null && attributeLabelChange.vlocity_cmt__AttributeDisplayNameOverride__c !='')
			{
				attributeLabelChange.vlocity_cmt__AttributeDisplayNameOverride__c = '';
				addchanges.add(attributeLabelChange);
			}
        }
		Database.update(addchanges, false);
    }
    global void finish(Database.BatchableContext BC)
    {
        System.debug('Success');
    }
}