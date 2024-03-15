export const OMNIDEF = {"userTimeZone":120,"userProfile":"System Administrator","userName":"mihir.rahul-joshi@capgemini.com.basedevpro","userId":"0050800000Ej3rPAAR","userCurrencyCode":"SEK","timeStamp":"2023-07-14T06:32:13.352Z","sOmniScriptId":"a537a000002TB7eAAG","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"wpm":false,"visualforcePagesAvailableInPreview":{},"trackingCustomData":{},"timeTracking":true,"stylesheet":{"newport":"","lightning":""},"stepChartPlacement":"right","ssm":false,"showInputWidth":false,"seedDataJSON":{},"saveURLPatterns":{},"saveObjectId":"%ContextId%","saveNameTemplate":null,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveContentEncoded":false,"rtpSeed":false,"pubsub":false,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge"}],"message":{},"lkObjName":null,"knowledgeArticleTypeQueryFieldsMap":{},"includeCustomization":true,"hideStepChart":false,"errorMessage":{"custom":[]},"enableKnowledge":false,"elementTypeToHTMLTemplateMapping":{},"disableUnloadWarn":true,"customPages":{"ContractPreview":"ContractAmendmentPreview?verticalMode=true"},"currencyCode":"","consoleTabTitle":null,"consoleTabLabel":"New","consoleTabIcon":"custom:custom18","cancelType":"SObject","cancelSource":"%ContextId%","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","bLK":false,"autoSaveOnStepNext":false,"autoFocus":false,"allowSaveForLater":true,"allowCancel":true},"prefillJSON":"{}","lwcId":"ea6e4434-7ca5-550d-d06f-5bcaaf7134e9","labelMap":{"Done":"JobSubmitted:Done","CreateSubContractLinesApexJobId":"JobSubmitted:CreateSubContractLinesApexJobId","CreateParentContractLinesApexJobId":"JobSubmitted:CreateParentContractLinesApexJobId","ParentContractId":"JobSubmitted:ParentContractId","SubContractIsFrameAgreement":"SubContractDetails:SubContractIsFrameAgreement","SubContractRecordType":"SubContractDetails:SubContractRecordType","SubContractTerm":"SubContractDetails:SubContractTerm","SubContractStartDate":"SubContractDetails:SubContractStartDate","ParentIsFrameAgreement":"ParentContractDetails:ParentIsFrameAgreement","ParentRecordType":"ParentContractDetails:ParentRecordType","ParentTerm":"ParentContractDetails:ParentTerm","ParentStartDate":"ParentContractDetails:ParentStartDate","ContractHierarchyType":"EnterDetails:ContractHierarchyType","ProcessSubQuotes":"EnterDetails:ProcessSubQuotes","ObjectId":"EnterDetails:ObjectId","JobSubmitted":"JobSubmitted","AsyncQuoteToContract":"AsyncQuoteToContract","SetValues":"SetValues","SubContractDetails":"SubContractDetails","ParentContractDetails":"ParentContractDetails","ExtractGroupQuote":"ExtractGroupQuote","ContractRecordType":"ContractRecordType","EnterDetails":"EnterDetails"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[false,false],"show":null,"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Next","message":{},"label":"Enter Details","knowledgeOptions":{"remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","cancelMessage":"Are you sure?","cancelLabel":"Cancel","allowSaveForLater":true,"uiElements":{"EnterDetails":"","ObjectId":"","ProcessSubQuotes":"","ContractHierarchyType":""},"aggElements":{}},"offSet":0,"name":"EnterDetails","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text","rootIndex":0,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"Object Id","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":"%ContextId%","debounceValue":0,"controlWidth":12,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"ObjectId","level":1,"JSONPath":"EnterDetails:ObjectId","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc00-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Checkbox","rootIndex":0,"response":null,"propSetMap":{"show":null,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"label":"Process Sub Quotes","hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":true,"controlWidth":3,"conditionType":"Hide if False","checkLabel":"Process Sub Quotes","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"ProcessSubQuotes","level":1,"JSONPath":"EnterDetails:ProcessSubQuotes","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bCheckbox":true,"lwcId":"lwc01-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Select","rootIndex":0,"response":null,"propSetMap":{"showInputWidth":false,"show":{"group":{"rules":[{"field":"ProcessSubQuotes","data":"true","condition":"="}],"operator":"AND"}},"required":true,"repeatClone":false,"repeat":false,"readOnly":false,"options":[{"value":"Flat","name":"Flat"},{"value":"Two Level","name":"Two Level"}],"optionSource":{"type":"","source":""},"label":"Contract Hierarchy Type","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":"Flat","controllingField":{"source":"","element":""},"controlWidth":9,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"ContractHierarchyType","level":1,"JSONPath":"EnterDetails:ContractHierarchyType","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bSelect":true,"lwcId":"lwc02-0"}],"bHasAttachment":false}],"bAccordionOpen":true,"bAccordionActive":true,"bStep":true,"isStep":true,"JSONPath":"EnterDetails","lwcId":"lwc0"},{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[false,false],"show":null,"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"ContractRecordType","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"dataRaptor Input Parameters":[],"controlWidth":12,"bundle":"ExtractContractRecordTypes","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"ContractRecordType","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"ContractRecordType","lwcId":"lwc1"},{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[false,false],"show":null,"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"Extract Group Quote","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"dataRaptor Input Parameters":[{"inputParam":"contextId","element":"EnterDetails:ObjectId"}],"controlWidth":12,"bundle":"ExtractGroupQuote","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"ExtractGroupQuote","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"ExtractGroupQuote","lwcId":"lwc2"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[false,false],"show":null,"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Next","message":{},"label":"Parent Contract Details","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"ParentContractDetails":"","ParentStartDate":"","ParentTerm":"","ParentRecordType":"","ParentIsFrameAgreement":""},"aggElements":{}},"offSet":0,"name":"ParentContractDetails","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Date","rootIndex":3,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"modelDateFormat":"yyyy-MM-dd","minDate":"","maxDate":"","label":"Parent Contract Start Date","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"dateType":"string","dateFormat":"MM-dd-yyyy","controlWidth":12,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"ParentStartDate","level":1,"JSONPath":"ParentContractDetails:ParentStartDate","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bDate":true,"lwcId":"lwc30-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Number","rootIndex":3,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","mask":null,"label":"Parent Contract Term","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":12,"debounceValue":0,"controlWidth":12,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"ParentTerm","level":1,"JSONPath":"ParentContractDetails:ParentTerm","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bNumber":true,"lwcId":"lwc31-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Select","rootIndex":3,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"options":[],"optionSource":{"type":"Custom","source":"dataSourceDR","element":"ContractRecordType"},"lwcComponentOverride":"vlocity_cmt__clmOsCustomSelect","label":"Parent Contract Record Type","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"controllingField":{"source":"","element":""},"controlWidth":12,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"ParentRecordType","level":1,"JSONPath":"ParentContractDetails:ParentRecordType","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bClmOsCustomSelect":true,"lwcId":"lwc32-0","ns":"vlocity_cmt"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":3,"eleArray":[{"type":"Checkbox","rootIndex":3,"response":null,"propSetMap":{"show":null,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"label":"Frame Agreement","hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":false,"controlWidth":12,"conditionType":"Hide if False","checkLabel":"Frame Agreement","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"ParentIsFrameAgreement","level":1,"JSONPath":"ParentContractDetails:ParentIsFrameAgreement","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bCheckbox":true,"lwcId":"lwc33-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"ParentContractDetails","lwcId":"lwc3"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"ContractHierarchyType","data":"Flat","condition":"<>"},{"field":"ProcessSubQuotes","data":"true","condition":"="}],"operator":"AND"}},"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Next","message":{},"label":"Sub-Contract Details","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"SubContractDetails":"","SubContractStartDate":"","SubContractTerm":"","SubContractRecordType":"","SubContractIsFrameAgreement":""},"aggElements":{}},"offSet":0,"name":"SubContractDetails","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Date","rootIndex":4,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"modelDateFormat":"MM/dd/yyyy","minDate":"","maxDate":"","label":"Sub-Contract Start Date","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"dateType":"string","dateFormat":"MM/dd/yyyy","controlWidth":12,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"SubContractStartDate","level":1,"JSONPath":"SubContractDetails:SubContractStartDate","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bDate":true,"lwcId":"lwc40-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Number","rootIndex":4,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":true,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","pattern":"","mask":null,"label":"Sub-Contract Term","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":12,"debounceValue":0,"controlWidth":12,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"SubContractTerm","level":1,"JSONPath":"SubContractDetails:SubContractTerm","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bNumber":true,"lwcId":"lwc41-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Select","rootIndex":4,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"options":[],"optionSource":{"type":"Custom","source":"dataSourceDR","element":"ContractRecordType"},"lwcComponentOverride":"vlocity_cmt__clmOsCustomSelect","label":"Sub-Contract Record Type","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"controllingField":{"source":"RecordType.SobjectType","element":"ContractRecordType"},"controlWidth":12,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"SubContractRecordType","level":1,"JSONPath":"SubContractDetails:SubContractRecordType","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bClmOsCustomSelect":true,"lwcId":"lwc42-0","ns":"vlocity_cmt"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":3,"eleArray":[{"type":"Checkbox","rootIndex":4,"response":null,"propSetMap":{"show":null,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"label":"Frame Agreement","hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":false,"controlWidth":12,"conditionType":"Hide if False","checkLabel":"Frame Agreement","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"SubContractIsFrameAgreement","level":1,"JSONPath":"SubContractDetails:SubContractIsFrameAgreement","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bCheckbox":true,"lwcId":"lwc43-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"SubContractDetails","lwcId":"lwc4"},{"type":"Set Values","propSetMap":{"wpm":false,"validationRequired":"None","ssm":false,"showPersistentComponent":[false,false],"show":null,"pubsub":false,"message":{},"label":null,"elementValueMap":{"subContractTerm":"=%SubContractDetails:SubContractTerm%","subContractStartDate":"=%SubContractDetails:SubContractStartDate%","subContractRecordType":"=%SubContractDetails:SubContractRecordType%","processSubQuotes":"=%EnterDetails:ProcessSubQuotes%","parentContractTerm":"=%ParentContractDetails:ParentTerm%","parentContractStartDate":"=%ParentContractDetails:ParentStartDate%","parentContractRecordType":"=%ParentContractDetails:ParentRecordType%","objectId":"=%EnterDetails:ObjectId%","isFrameAgreementSub":"=%SubContractDetails:SubContractIsFrameAgreement%","isFrameAgreementParent":"=%ParentContractDetails:ParentIsFrameAgreement%","groupsToExcludeList":"[]","contractHierarchyType":"=%EnterDetails:ContractHierarchyType%","batchSize":10},"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SetValues","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetValues","lwcId":"lwc5"},{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[false,false],"show":null,"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"useFuture":false,"preTransformBundle":"","postTransformBundle":"","chainable":false},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"Async Quote to Contract","integrationProcedureKey":"clm_asyncQuoteToContract","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"AsyncQuoteToContract","level":0,"indexInParent":6,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"AsyncQuoteToContract","lwcId":"lwc6"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[false,false],"show":null,"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":0,"previousLabel":"Previous","nextWidth":3,"nextLabel":"Next","message":{},"label":"Job Submitted","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","allowSaveForLater":false,"HTMLTemplateId":"","uiElements":{"JobSubmitted":"","ParentContractId":"","CreateParentContractLinesApexJobId":"","CreateSubContractLinesApexJobId":""},"aggElements":{}},"offSet":0,"name":"JobSubmitted","level":0,"indexInParent":7,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text","rootIndex":7,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":true,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"Parent Contract Id","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":"%parentContractId%","debounceValue":0,"controlWidth":12,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"ParentContractId","level":1,"JSONPath":"JobSubmitted:ParentContractId","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc70-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Text","rootIndex":7,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":true,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"Create Parent Contract Lines Apex Job Id","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":"%createParentContractLinesApexJobId%","debounceValue":0,"controlWidth":12,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"CreateParentContractLinesApexJobId","level":1,"JSONPath":"JobSubmitted:CreateParentContractLinesApexJobId","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc71-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Text","rootIndex":7,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":true,"ptrnErrText":"","pattern":"","minLength":0,"maxLength":255,"mask":"","label":"Create Sub Contract Lines Apex Job Id","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":"%createSubContractLinesApexJobId%","debounceValue":0,"controlWidth":12,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"CreateSubContractLinesApexJobId","level":1,"JSONPath":"JobSubmitted:CreateSubContractLinesApexJobId","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bText":true,"lwcId":"lwc72-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":3,"eleArray":[{"type":"Navigate Action","rootIndex":7,"response":null,"propSetMap":{"wpm":false,"variantOptions":["brand","outline-brand","neutral","success","destructive","text-destructive","inverse","link"],"variant":"brand","validationRequired":"none","targetTypeOptions":["App","Component","Current Page","Knowledge Article","Login","Named Page","Community Named Page","Navigation Item","Object","Record","Record Relationship","Web Page","Vlocity OmniScript"],"targetType":"Record","targetName":"Quote","targetLWCLayoutOptions":["lightning","newport"],"targetLWCLayout":"lightning","targetId":"%ContextId%","targetFilter":"Recent","ssm":false,"show":null,"replaceOptions":[{"value":false,"label":"No"},{"value":true,"label":"Yes"}],"replace":true,"recordActionOptions":["clone","edit","view"],"recordAction":"view","pubsub":false,"objectActionOptions":["home","list","new"],"objectAction":"home","message":{},"loginActionOptions":["login","logout"],"loginAction":"login","label":"Done","iconVariant":"","iconPositionOptions":["left","right"],"iconPosition":"left","iconName":"","disOnTplt":false,"controlWidth":12,"HTMLTemplateId":""},"name":"Done","level":1,"JSONPath":"JobSubmitted:Done","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bNavigate":true,"lwcId":"lwc73-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"JobSubmitted","lwcId":"lwc7"}],"bReusable":false,"bpVersion":2,"bpType":"clm","bpSubType":"asyncQuoteToContract","bpLang":"English","bHasAttachment":false,"lwcVarMap":{}};