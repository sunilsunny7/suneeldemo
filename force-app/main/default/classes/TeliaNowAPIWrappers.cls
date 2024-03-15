public with sharing class TeliaNowAPIWrappers {
    public static String replaceProtectedKeywords(String json) {
        if (json.length() > 3000000)
            throw new AuraHandledException('Response too BIG');
        String replacedJSON = json.replaceAll('\"type\"', '\"type_safe\"');
        replacedJSON = replacedJSON.replaceAll('\"date\"', '\"date_safe\"');
        replacedJSON = replacedJSON.replaceAll('\"from\"', '\"from_safe\"');
        replacedJSON = replacedJSON.replaceAll('\"number\"', '\"number_safe\"');
        replacedJSON = replacedJSON.replaceAll('\"time\"', '\"time_safe\"');
        replacedJSON = replacedJSON.replaceAll('\"@type\"', '\"type_safe\"');
        replacedJSON = replacedJSON.replaceAll('\"@baseType\"', '\"baseType_safe\"');
        replacedJSON = replacedJSON.replaceAll('\"@schemaLocation\"', '\"schemaLocation_safe\"');
        replacedJSON = replacedJSON.replaceAll('\"@referredType\"', '\"referredType_safe\"');
        return replacedJSON;
    }
    public class TeliaNowContactInfo {
        public Result result;
    }
    public class Result {
        public Integer status;
        public List<Contacts> contacts;
        public Integer count;
    }

    public class Contacts {
        public String sysId;
        public String firstName;
        public String lastName;
        public String email;
        public String number_safe;
        public String businessNumber;
        public String tcwssId;
        public String sourceId;
        public String preferredContactMethod;
        public String description;
        public Account account;
    }
    public class Account {
        public String tscId;
        public String legalId;
        public String name;
    }
    public static TeliaNowContactInfo parseTeliaNowContact(String json) {
        return (TeliaNowContactInfo) System.JSON.deserialize(replaceProtectedKeywords(json), TeliaNowContactInfo.class);
    }
    public class TeliaNowNewContact {
        public String firstName;
        public String lastName;
        public String tscId;
        public String email;
    }
    public class NewCase {
        public String description; //Case.Description
        public String name; //Case.Subject
        public String category;
        public Boolean internal; //Case.Internal_case__c
        public String ticketType;
        public String severity;
        public String impact;
        public String assignmentGroupId; //Case.Assignment_group_to_TNOW__c
        public Channel channel;
        public RelatedParty[] relatedParty;
        public ThirdPartyReference[] thirdPartyReference;
    }
    public class Channel {
        public String id;
    }
    public class RelatedParty {
        public String id;
        public String role;
        public String referredType;
        public String type;
    }
    public class ThirdPartyReference {
        public String id;
        public String source;
    }
    public class Attachment {
        public String name;
        public String mimeType;
        public String content;
    }
}