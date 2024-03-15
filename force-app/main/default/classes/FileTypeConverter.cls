public with sharing class FileTypeConverter {
    public static String convertFileTypeToMimeType(String fileType) {
        String mimeType = '';
        Map<String, String> fileTypeMappings = new Map<String, String>();
        for (MIME_Type__mdt miType : MIME_Type__mdt.getAll().values()) {
            fileTypeMappings.put(miType.Label, miType.MIME_Type__c);
        }
        if (fileTypeMappings.containsKey(fileType.toLowerCase())) {
            mimeType = fileTypeMappings.get(fileType.toLowerCase());
        }
        return mimeType;
    }
}