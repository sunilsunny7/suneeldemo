public with sharing class AttendeeScannerController {

    public class ScannerResponse
    {
        @AuraEnabled
        public String Status { get; set; }

        @AuraEnabled
        public CampaignMember Member { get; set; }

        @AuraEnabled
        public SObject Contact { get; set; }

        public ScannerResponse(String status)
        {
            this.Status = status;
        }

        public ScannerResponse(String status, CampaignMember member)
        {
            this.Status = status;
            this.Member = member;

            if (member.Contact != null) {
                this.Contact = member.Contact;
            } else {
                this.Contact = member.Lead;
            }
        }
    }

    public static final String MEMBER_STATUS = 'Attended';
    @AuraEnabled
    public static ScannerResponse processContact(String barcodeId, String campaignId) {
        try
        {
            Contact[] contacts = [SELECT Id FROM Contact WHERE Barcode_Id__c = :barcodeId];
            CampaignMember campaignMember = new CampaignMember(CampaignId = campaignId, Status = MEMBER_STATUS);

            if (contacts.size() > 0) {
                campaignMember.ContactId = contacts[0].Id;
            } else {
                return new ScannerResponse('notfound');
            }

            List<CampaignMemberStatus> cms = [SELECT Id FROM CampaignMemberStatus WHERE CampaignId = :campaignId AND Label = :MEMBER_STATUS];
            if (cms.isEmpty()) {
                insert new CampaignMemberStatus(
                        CampaignId = campaignId,
                        HasResponded = true,
                        IsDefault = false,
                        Label = MEMBER_STATUS
                );
            }

            CampaignMember[] campaignMembers = [SELECT Id, Status, Campaign.Name, Contact.Id, Contact.Name, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Barcode_ID__c FROM CampaignMember WHERE ContactId = :campaignMember.ContactId AND LeadId = :campaignMember.LeadId AND CampaignId = :campaignMember.CampaignId];

            if (campaignMembers.size() == 0) {
                insert campaignMember;

                campaignMember = [SELECT Id, Name, Status, Campaign.Name, Contact.Id, Contact.Name, Contact.FirstName, Contact.LastName, Contact.Email, Contact.Barcode_ID__c FROM CampaignMember WHERE Id = :campaignMember.Id];

                return new ScannerResponse('added', campaignMember);
            }

            campaignMember = campaignMembers[0];

            if (campaignMember.Status == MEMBER_STATUS) {
                return new ScannerResponse('statusalreadyset', campaignMember);
            } else {
                campaignMember.Status = MEMBER_STATUS;
                update campaignMember;
                System.debug('###campaignMember - ' + campaignMember.Contact);
                return new ScannerResponse('updated', campaignMember);
            }
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}