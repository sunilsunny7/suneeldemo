export const OMNIDEF = {"userTimeZone":120,"userProfile":"System Administrator","userName":"mihir.rahul-joshi@capgemini.com.basedevpro","userId":"0050800000Ej3rPAAR","userCurrencyCode":"SEK","timeStamp":"2023-07-14T06:50:51.140Z","sOmniScriptId":"a537a000002TB1WAAW","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"wpm":false,"visualforcePagesAvailableInPreview":{},"trackingCustomData":{},"timeTracking":false,"stylesheet":{"newportRtl":"","newport":"","lightningRtl":"","lightning":""},"stepChartPlacement":"right","ssm":false,"showInputWidth":false,"seedDataJSON":{},"saveURLPatterns":{},"saveObjectId":"%ContextId%","saveNameTemplate":null,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveContentEncoded":false,"rtpSeed":false,"pubsub":false,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge"}],"message":{},"lkObjName":null,"knowledgeArticleTypeQueryFieldsMap":{},"hideStepChart":false,"errorMessage":{"custom":[]},"enableKnowledge":false,"elementTypeToLwcTemplateMapping":{"Cancel Action":"patchedLwcCancelAction"},"elementTypeToHTMLTemplateMapping":{},"disableUnloadWarn":true,"currencyCode":"","consoleTabTitle":null,"consoleTabLabel":"New","consoleTabIcon":"custom:custom18","cancelType":"Redirect","cancelSource":"%ContextId%","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","bLK":false,"autoSaveOnStepNext":false,"autoFocus":false,"allowSaveForLater":false,"allowCancel":true},"prefillJSON":"{}","lwcId":"85bb2f06-668e-d619-3ff8-525b4761a7b0","labelMap":{"Messaging":"ErrorCheck:Messaging","Comment1":"ApprovalData:Comment1","CustomLWC2":"ApprovalData:CustomLWC2","CustomLWC1":"ApprovalData:CustomLWC1","Info1":"ApprovalData:Info1","NavigateAction1":"NavigateAction1","ErrorCheck":"ErrorCheck","Sent":"Sent","SetValues6":"SetValues6","ApprovalData":"ApprovalData","ExtractQuoteLineItemsFiber":"ExtractQuoteLineItemsFiber","ExtractFiberQuoteData":"ExtractFiberQuoteData","RedirectToQuoteIfCustomerApproved":"RedirectToQuoteIfCustomerApproved","RedirectToQuote":"RedirectToQuote","changeFiberQuoteStatusToApproved":"changeFiberQuoteStatusToApproved","FiberSetStatus":"FiberSetStatus","FiberDiscountCalculation":"FiberDiscountCalculation","RedirectToQuoteIfFAQuote":"RedirectToQuoteIfFAQuote","changeFiberQuoteStatusToApprovedCAwFA":"changeFiberQuoteStatusToApprovedCAwFA","FiberSetStatusCAwFA":"FiberSetStatusCAwFA","FiberQuote":"FiberQuote","CANCEL":"CANCEL"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Cancel Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":null,"targetUrl":"/apex/vlocity_cmt__HybridCPQ?type=Contract&id=%ContextId%","targetType":"Web Page","targetName":"","targetLWCLayout":"lightning","targetId":"%ContextId%","targetFilter":"Recent","ssm":false,"showCancelPrompt":true,"show":null,"replace":false,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"Avbryt","iconVariant":"","iconPosition":"left","iconName":"","disOnTplt":false,"controlWidth":12,"cancelMessage":"Är du säker på att du vill avbryta?","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"CANCEL","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"bPatchedLwcCancelAction":true,"JSONPath":"CANCEL","lwcId":"lwc0"},{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"None","ssm":false,"showPersistentComponent":[false,false],"show":null,"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"Quote","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"dataRaptor Input Parameters":[{"inputParam":"Id","element":"ContextId"}],"controlWidth":12,"bundle":"Fiber_TeliaSE_ExtractQuoteDR","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"FiberQuote","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"FiberQuote","lwcId":"lwc1"},{"type":"Set Values","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"Quote:Type","data":"FA Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote of FA","condition":"="}],"operator":"OR"}},"pubsub":false,"message":{},"label":"FiberSetStatusCAwFA","elementValueMap":{"FiberStatus":"Price Approved"},"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"FiberSetStatusCAwFA","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"FiberSetStatusCAwFA","lwcId":"lwc2"},{"type":"DataRaptor Post Action","propSetMap":{"wpm":false,"validationRequired":"Submit","ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"Quote:Type","data":"FA Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote of FA","condition":"="}],"operator":"OR"}},"sendJSONPath":"","sendJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postTransformBundle":"","postMessage":"Done","message":{},"label":"changeFiberQuoteStatusToApproved","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":12,"bundle":"FiberChangeStatusToCA","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"changeFiberQuoteStatusToApprovedCAwFA","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"bDataRaptorPostAction":true,"JSONPath":"changeFiberQuoteStatusToApprovedCAwFA","lwcId":"lwc3"},{"type":"Navigate Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"none","targetType":"Record","targetName":"Quote","targetLWCLayout":"lightning","targetId":"%ContextId%","targetFilter":"Recent","ssm":false,"show":{"group":{"rules":[{"field":"Quote:Type","data":"FA Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote of FA","condition":"="}],"operator":"OR"}},"replace":false,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":null,"iconVariant":"","iconPosition":"left","iconName":"","disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"RedirectToQuoteIfFAQuote","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"RedirectToQuoteIfFAQuote","lwcId":"lwc4"},{"type":"Remote Action","propSetMap":{"wpm":false,"validationRequired":"Step","svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"Quote:Type","data":"Individual Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote of FA","condition":"="}],"operator":"OR"}},"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"discount","remoteClass":"TeliaSE_Offerhelper","redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"FiberDiscountCalculation","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"FiberDiscountCalculation","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"bRemoteAction":true,"JSONPath":"FiberDiscountCalculation","lwcId":"lwc5"},{"type":"Set Values","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"discountFlag","data":"true","condition":"="},{"group":{"rules":[{"field":"Quote:Type","data":"Individual Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote of FA","condition":"="},{"field":"Quote:Type","data":"CA Quote","condition":"="}],"operator":"OR"}}],"operator":"AND"}},"pubsub":false,"message":{},"label":"FiberSetStatus","elementValueMap":{"FiberStatus":"Price Approved"},"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"FiberSetStatus","level":0,"indexInParent":6,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"FiberSetStatus","lwcId":"lwc6"},{"type":"DataRaptor Post Action","propSetMap":{"wpm":false,"validationRequired":"Submit","ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"discountFlag","data":"true","condition":"="},{"field":"Quote:Status","data":"Customer Approved","condition":"<>"},{"group":{"rules":[{"field":"Quote:Type","data":"Individual Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote of FA","condition":"="},{"field":"Quote:Type","data":"CA Quote","condition":"="}],"operator":"OR"}}],"operator":"AND"}},"sendJSONPath":"","sendJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postTransformBundle":"","postMessage":"Done","message":{},"label":"changeFiberQuoteStatusToApproved","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":12,"bundle":"FiberChangeStatusToCA","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"changeFiberQuoteStatusToApproved","level":0,"indexInParent":7,"bHasAttachment":false,"bEmbed":false,"bDataRaptorPostAction":true,"JSONPath":"changeFiberQuoteStatusToApproved","lwcId":"lwc7"},{"type":"Navigate Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"none","targetType":"Record","targetName":"Quote","targetLWCLayout":"lightning","targetId":"%ContextId%","targetFilter":"Recent","ssm":false,"show":{"group":{"rules":[{"field":"discountFlag","data":"true","condition":"="},{"group":{"rules":[{"field":"Quote:Type","data":"Individual Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote of FA","condition":"="},{"field":"Quote:Type","data":"CA Quote","condition":"="}],"operator":"OR"}}],"operator":"AND"}},"replace":false,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":null,"iconVariant":"","iconPosition":"left","iconName":"","disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"RedirectToQuote","level":0,"indexInParent":8,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"RedirectToQuote","lwcId":"lwc8"},{"type":"Navigate Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"none","targetType":"Record","targetName":"Quote","targetLWCLayout":"lightning","targetId":"%ContextId%","targetFilter":"Recent","ssm":false,"show":{"group":{"rules":[{"field":"Quote:Status","data":"Customer Approved","condition":"="},{"group":{"rules":[{"field":"Quote:Type","data":"Individual Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote of FA","condition":"="},{"field":"Quote:Type","data":"CA Quote","condition":"="}],"operator":"OR"}}],"operator":"AND"}},"replace":false,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":null,"iconVariant":"","iconPosition":"left","iconName":"","disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"RedirectToQuoteIfCustomerApproved","level":0,"indexInParent":9,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"RedirectToQuoteIfCustomerApproved","lwcId":"lwc9"},{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"Quote:Type","data":"Individual Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote of FA","condition":"="},{"field":"Quote:Type","data":"CA Quote","condition":"="}],"operator":"OR"}},"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"ExtractFiberQuoteData","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"dataRaptor Input Parameters":[{"inputParam":"Id","element":"ContextId"}],"controlWidth":12,"bundle":"TeliaSE_ExtractFiberQuoteData","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"ExtractFiberQuoteData","level":0,"indexInParent":10,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"ExtractFiberQuoteData","lwcId":"lwc10"},{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"Quote:Type","data":"Individual Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote","condition":"="},{"field":"Quote:Type","data":"CA Quote of FA","condition":"="}],"operator":"OR"}},"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"ExtractQuoteLineItemsFiber","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"dataRaptor Input Parameters":[{"inputParam":"Id","element":"ContextId"}],"controlWidth":12,"bundle":"TeliaSE_Fiber_QutoeLinesExtract","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"ExtractQuoteLineItemsFiber","level":0,"indexInParent":11,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"ExtractQuoteLineItemsFiber","lwcId":"lwc11"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":false,"ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"discountFlag","data":"false","condition":"="},{"field":"Quote:Status","data":"Sent for Approval","condition":"<>"},{"field":"isFiberFlow","data":null,"condition":"<>"},{"field":"isFiberFlow","data":"true","condition":"="}],"operator":"AND"}},"saveMessage":"","saveLabel":"","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":0,"previousLabel":"","nextWidth":5,"nextLabel":"Skicka för godkännande","message":{},"label":"Ansökan om godkännande av pris","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Är du säker?","cancelLabel":"Avbryt","allowSaveForLater":false,"HTMLTemplateId":"","uiElements":{"ApprovalData":"","Comment1":""},"aggElements":{"CustomLWC1":"","CustomLWC2":""}},"offSet":0,"name":"ApprovalData","level":0,"indexInParent":12,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Text Block","rootIndex":12,"response":null,"propSetMap":{"textKey":"","text":"<p>Det finns produkter som har ett pris utanf&ouml;r ditt mandat. Var v&auml;nlig och kommentera det &ouml;nskade priset nedan.</p>","show":null,"sanitize":false,"label":"TextBlock1","disOnTplt":false,"dataJSON":false,"controlWidth":12,"HTMLTemplateId":""},"name":"Info1","level":1,"JSONPath":"ApprovalData:Info1","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bTextBlock":true,"lwcId":"lwc120-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":1,"eleArray":[{"type":"Custom Lightning Web Component","rootIndex":12,"response":null,"propSetMap":{"show":null,"lwcName":"vPLQuoteforApproval_Fiber","label":"CustomLWC1","hide":false,"disOnTplt":false,"customAttributes":[{"source":"%Approval1:Line2%","name":"line-items"}],"controlWidth":12,"conditionType":"Hide if False","bStandalone":false},"name":"CustomLWC1","level":1,"JSONPath":"ApprovalData:CustomLWC1","indexInParent":1,"index":0,"children":[],"bHasAttachment":false,"bcustomlightningwebcomponent1":true,"lwcId":"lwc121-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":2,"eleArray":[{"type":"Custom Lightning Web Component","rootIndex":12,"response":null,"propSetMap":{"show":null,"lwcName":"vPLSelectLinesforApproval_Fiber","label":"CustomLWC2","hide":false,"customAttributes":[{"source":"%Approval1:Line1%","name":"product-items"}],"controlWidth":12,"conditionType":"Hide if False","bStandalone":false},"name":"CustomLWC2","level":1,"JSONPath":"ApprovalData:CustomLWC2","indexInParent":2,"index":0,"children":[],"bHasAttachment":false,"bcustomlightningwebcomponent2":true,"lwcId":"lwc122-0"}],"bHasAttachment":false},{"response":null,"level":1,"indexInParent":3,"eleArray":[{"type":"Text Area","rootIndex":12,"response":null,"propSetMap":{"showInputWidth":false,"show":null,"required":false,"repeatLimit":null,"repeatClone":false,"repeat":false,"readOnly":false,"ptrnErrText":"Max antal tecken 1000","pattern":"","minLength":0,"maxLength":1000,"label":"KOMMENTARER","inputWidth":12,"hide":false,"helpText":"","help":false,"disOnTplt":false,"defaultValue":null,"debounceValue":0,"controlWidth":8,"conditionType":"Hide if False","accessibleInFutureSteps":false,"HTMLTemplateId":""},"name":"Comment1","level":1,"JSONPath":"ApprovalData:Comment1","indexInParent":3,"index":0,"children":[],"bHasAttachment":false,"bTextarea":true,"lwcId":"lwc123-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"ApprovalData","lwcId":"lwc12"},{"type":"Set Values","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[false,false],"show":null,"pubsub":false,"message":{},"label":"SetValues6","elementValueMap":{"FinalComment":"%ApprovalData:Comment1%","Approval1":"%ApprovalData%"},"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SetValues6","level":0,"indexInParent":13,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SetValues6","lwcId":"lwc13"},{"type":"Remote Action","propSetMap":{"wpm":false,"validationRequired":"None","svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"discountFlag","data":"false","condition":"="},{"field":"Quote:Status","data":"Sent for Approval","condition":"<>"}],"operator":"AND"}},"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"preTransformBundle":null,"postTransformBundle":null},"remoteMethod":"FiberApproval","remoteClass":"TeliaSE_Offerhelper","redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"Submit for Approval","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"controlWidth":6,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"Sent","level":0,"indexInParent":14,"bHasAttachment":false,"bEmbed":false,"bRemoteAction":true,"JSONPath":"Sent","lwcId":"lwc14"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[false,false],"show":{"group":{"rules":[{"field":"options","data":"Error","condition":"="}],"operator":"AND"}},"saveMessage":"","saveLabel":"","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":3,"previousLabel":"Tidigare","nextWidth":3,"nextLabel":"Nästa","message":{},"label":null,"knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"disOnTplt":false,"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Är du säker?","cancelLabel":"Avbryt","allowSaveForLater":true,"HTMLTemplateId":"","uiElements":{"ErrorCheck":""},"aggElements":{}},"offSet":0,"name":"ErrorCheck","level":0,"indexInParent":15,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Validation","rootIndex":15,"response":null,"propSetMap":{"validateExpression":{"group":{"rules":[{"field":"options","data":"Error","condition":"="}],"operator":"AND"}},"show":null,"messages":[{"value":true,"type":"Comment","text":"Either Role is Missing or Quote is already in Approval Process","active":true},{"value":false,"type":"Requirement","text":"","active":false}],"label":null,"hideLabel":true,"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":""},"name":"Messaging","level":1,"JSONPath":"ErrorCheck:Messaging","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bMessaging":true,"lwcId":"lwc150-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"ErrorCheck","lwcId":"lwc15"},{"type":"Navigate Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"none","targetType":"Record","targetName":"Quote","targetLWCLayout":"lightning","targetId":"%ContextId%","targetFilter":"Recent","ssm":false,"show":null,"replace":false,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"NavigateAction1","iconVariant":"","iconPosition":"left","iconName":"","disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"NavigateAction1","level":0,"indexInParent":16,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"NavigateAction1","lwcId":"lwc16"}],"bReusable":false,"bpVersion":1,"bpType":"Fiber","bpSubType":"FiberApproval","bpLang":"English","bHasAttachment":false,"lwcVarMap":{"Approval1":{"Line2":null,"Line1":null}}};