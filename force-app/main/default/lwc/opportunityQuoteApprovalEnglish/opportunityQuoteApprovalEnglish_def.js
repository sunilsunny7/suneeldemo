export const OMNIDEF = {"userTimeZone":120,"userProfile":"System Administrator","userName":"mihir.rahul-joshi@capgemini.com.basedevpro","userId":"0050800000Ej3rPAAR","userCurrencyCode":"SEK","timeStamp":"2023-07-14T07:39:34.961Z","sOmniScriptId":"a537a000002TB2KAAW","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"wpm":false,"visualforcePagesAvailableInPreview":{},"trackingCustomData":{},"timeTracking":false,"stylesheet":{"newportRtl":"","newport":"","lightningRtl":"","lightning":""},"stepChartPlacement":"right","ssm":false,"showInputWidth":false,"seedDataJSON":{},"scrollBehavior":"auto","saveURLPatterns":{},"saveObjectId":"%ContextId%","saveNameTemplate":null,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveContentEncoded":false,"rtpSeed":false,"pubsub":false,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge","dispOutsideOmni":false}],"message":{},"mergeSavedData":false,"lkObjName":null,"knowledgeArticleTypeQueryFieldsMap":{},"isSeoEnabled":false,"hideStepChart":false,"errorMessage":{"custom":[]},"enableKnowledge":false,"elementTypeToHTMLTemplateMapping":{},"disableUnloadWarn":true,"currentLanguage":"en_US","currencyCode":"","consoleTabTitle":null,"consoleTabLabel":"New","consoleTabIcon":"custom:custom18","cancelType":"SObject","cancelSource":"%ContextId%","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","bLK":false,"autoSaveOnStepNext":false,"autoFocus":false,"allowSaveForLater":true,"allowCancel":true},"prefillJSON":"{}","lwcId":"b36486df-c88e-2b76-2d39-f1ef9aa2936c","labelMap":{"MessagingNavigate":"AppRequired0:MessagingNavigate","ApprovalTextBox2":"Approval0:ApprovalTextBox2","ApprovalTextBox1":"Approval0:ApprovalTextBox1","NavigateStep2":"NavigateStep2","NavigateActionGoToOpportunity":"NavigateActionGoToOpportunity","AppRequired0":"AppRequired0","ApprovalRequied":"ApprovalRequied","SetValues1":"SetValues1","Approval0":"Approval0"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":null,"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Föregående","nextWidth":3,"nextLabel":"Nästa","message":{},"label":"Skicka mandatförfrågan?","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":"Skicka mandatförfrågan?","cancelMessage":"Är du säker?","cancelLabel":"Avbryt","businessEvent":"","businessCategory":"","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"Approval0":"","ApprovalTextBox2":""},"aggElements":{}},"offSet":0,"name":"Approval0","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text Block","rootIndex":0,"response":null,"propSetMap":{"textKey":"","text":"<h3 style=\"color: #800080;\">Detta erbjudande beh&ouml;ver godk&auml;nnande</h3>","show":null,"sanitize":false,"label":"ApprovalTextBox1","dataJSON":false,"controlWidth":12,"HTMLTemplateId":""},"name":"ApprovalTextBox1","level":1,"JSONPath":"Approval0:ApprovalTextBox1","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc00-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Text Area","rootIndex":0,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"","placeholder":"","pattern":"","minLength":0,"maxLength":1000,"label":"KOMMENTARER","inputWidth":12,"hide":false,"helpTextPos":"","helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"debounceValue":0,"controlWidth":12,"conditionType":"Hide if False","autocomplete":null,"accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"ApprovalTextBox2","level":1,"JSONPath":"Approval0:ApprovalTextBox2","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bTextarea":true,"lwcId":"lwc01-0"}],"bHasAttachment":false}],"bAccordionOpen":true,"bAccordionActive":true,"bStep":true,"isStep":true,"JSONPath":"Approval0","lwcId":"lwc0"},{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[null,null],"show":null,"pubsub":false,"message":{},"label":"SetValues1","elementValueMap":{"FinalComment":"%Approval0:ApprovalTextBox2%"},"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SetValues1","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetValues1","lwcId":"lwc1"},{"type":"Remote Action","propSetMap":{"wpm":false,"validationRequired":"Step","svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[false,false],"show":null,"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"Approval","remoteClass":"TeliaSE_Offerhelper","redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"RemoteAction5","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{"RenegotiationIdentifier":"%QuoteDetails:RenegotiationIdentifier%"},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"ApprovalRequied","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"bRemoteAction":true,"JSONPath":"ApprovalRequied","lwcId":"lwc2"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[false,false],"show":null,"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Föregående","nextWidth":3,"nextLabel":"Nästa","message":{},"label":"Mandatförfrågan skickad","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":"Mandatförfrågan skickad","cancelMessage":"Är du säker?","cancelLabel":"Avbryt","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"AppRequired0":""},"aggElements":{}},"offSet":0,"name":"AppRequired0","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Validation","rootIndex":3,"response":null,"propSetMap":{"validateExpression":null,"show":null,"messages":[{"value":true,"type":"Comment","text":"Godkännande begäran skickas till Försäljningschef/Försäljningsdirektören","active":true},{"value":false,"type":"Requirement","text":"","active":false}],"label":"MessagingNavigate","hideLabel":true,"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":""},"name":"MessagingNavigate","level":1,"JSONPath":"AppRequired0:MessagingNavigate","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bMessaging":true,"lwcId":"lwc30-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"AppRequired0","lwcId":"lwc3"},{"type":"Navigate Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"Submit","targetType":"Record","targetLWCLayout":"lightning","targetId":"%ContextId%","targetFilter":"Recent","ssm":false,"show":{"group":{"rules":[{"field":"MessagingNavigate","data":"true","condition":"="}],"operator":"AND"}},"replace":false,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"NavigateActionGoToOpportunity","iconVariant":"","iconPosition":"left","iconName":"","disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"NavigateActionGoToOpportunity","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"NavigateActionGoToOpportunity","lwcId":"lwc4"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"MessagingNavigate","data":"true","condition":"="}],"operator":"AND"}},"saveMessage":"Are you sure you want to save it for later?","saveLabel":"Save for later","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":0,"previousLabel":"Previous","nextWidth":0,"nextLabel":"Next","message":{},"label":"NavigateStep2","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"NavigateStep2":""},"aggElements":{}},"offSet":0,"name":"NavigateStep2","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"NavigateStep2","lwcId":"lwc5"}],"bReusable":true,"bpVersion":1,"bpType":"Opportunity","bpSubType":"QuoteApproval","bpLang":"English","bHasAttachment":false,"lwcVarMap":{}};