let definition =
      {"states":[{"fields":[],"conditions":{"id":"state-condition-object","isParent":true,"group":[]},"definedActions":{"actions":[]},"name":"Active","isSmartAction":false,"smartAction":{},"styleObject":{"padding":[{"type":"around","size":"x-small"}],"margin":[{"type":"bottom","size":"x-small"}],"container":{"class":"slds-card"},"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12","class":"slds-card slds-p-around_x-small slds-m-bottom_x-small"},"components":{"layer-0":{"children":[{"name":"Name","element":"outputField","size":{"isResponsive":false,"default":"4"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Name","label":"Name","card":"{card}","type":"text"},"type":"field","styleObject":{"sizeClass":"slds-size_4-of-12 ","size":{"isResponsive":false,"default":"4"}},"elementLabel":"Name-0"},{"name":"RecordTypeId","element":"outputField","size":{"isResponsive":false,"default":"4"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"RecordTypeId","label":"RecordTypeId","card":"{card}","type":"text"},"type":"field","styleObject":{"sizeClass":"slds-size_4-of-12 ","size":{"isResponsive":false,"default":"4"}},"elementLabel":"RecordTypeId-1"},{"name":"Id","element":"outputField","size":{"isResponsive":false,"default":"4"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Id","label":"Id","card":"{card}","type":"text"},"type":"field","styleObject":{"sizeClass":"slds-size_4-of-12 ","size":{"isResponsive":false,"default":"4"}},"elementLabel":"Id-2"}]}},"childCards":[],"actions":[],"omniscripts":[],"documents":[]}],"dataSource":{"type":"Query","value":{"dsDelay":"","query":"select Id, Name, CreatedDate from Quote where (Status='Approved' and TeliaSE_Approval_Count__c = 0 and RecordType.DeveloperName = 'Contract' and TeliaSE_Locked__c=false) OR (Status='Approved' and TeliaSE_Approval_Count__c = 0 and RecordType.DeveloperName = 'Contract' and TeliaSE_Locked__c=false AND TeliaSE_MC_Sales_Flow_Identifier__c='Inforhandling')","resultVar":""},"orderBy":{"name":"","isReverse":""},"contextVariables":[]},"title":"Test123","enableLwc":true,"isFlex":true,"theme":"slds","selectableMode":"Multi","lwc":{"DeveloperName":"cfTest123_1_Telia","Id":"0Rb5r0000016YJTCA2","MasterLabel":"cfTest123_1_Telia","NamespacePrefix":"c","ManageableState":"unmanaged"},"Name":"Test123","uniqueKey":"Test123_undefined_undefined","Id":"a6l5r000000HEUjAAO","vlocity_cmt__GlobalKey__c":"Test123/Telia/1/1711624993984","vlocity_cmt__IsChildCard__c":false};
  export default definition