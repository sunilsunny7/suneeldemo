@isTest
public with sharing class FileTypeConverter_Test {
    @isTest
    static void convertFileTypeToMimeType() {
        Test.startTest();
        String mimeType = FileTypeConverter.convertFileTypeToMimeType('pdf');
        Test.stopTest();
        Assert.areEqual('application/pdf', mimeType);
    }
}