export const OMNIDEF = {"userTimeZone":60,"userProfile":"System Administrator","userName":"rahul.d.kadam@capgemini.com.telia.amandadev2","userId":"0050800000F3n9nAAB","userCurrencyCode":"SEK","timeStamp":"2024-02-07T07:15:16.713Z","sOmniScriptId":"a537a000002TAyhAAG","sobjPL":{},"RPBundle":"","rMap":{},"response":null,"propSetMap":{"wpm":false,"visualforcePagesAvailableInPreview":{},"trackingCustomData":{},"timeTracking":false,"stylesheet":{"newportRtl":"","newport":"","lightningRtl":"","lightning":"radioButtonOmniscript"},"stepChartPlacement":"right","ssm":false,"showInputWidth":false,"seedDataJSON":{},"scrollBehavior":"auto","saveURLPatterns":{},"saveObjectId":"%ContextId%","saveNameTemplate":null,"saveForLaterRedirectTemplateUrl":"vlcSaveForLaterAcknowledge.html","saveForLaterRedirectPageName":"sflRedirect","saveExpireInDays":null,"saveContentEncoded":false,"rtpSeed":false,"pubsub":false,"persistentComponent":[{"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"vlcProductConfig.html","modalController":"ModalProductCtrl"},"label":"","itemsKey":"cartItems","id":"vlcCart"},{"render":false,"remoteTimeout":30000,"remoteOptions":{"preTransformBundle":"","postTransformBundle":""},"remoteMethod":"","remoteClass":"","preTransformBundle":"","postTransformBundle":"","modalConfigurationSetting":{"modalSize":"lg","modalHTMLTemplateId":"","modalController":""},"label":"","itemsKey":"knowledgeItems","id":"vlcKnowledge","dispOutsideOmni":false}],"message":{},"mergeSavedData":false,"lkObjName":null,"knowledgeArticleTypeQueryFieldsMap":{},"hideStepChart":true,"errorMessage":{"custom":[]},"enableKnowledge":false,"elementTypeToLwcTemplateMapping":{"Cancel Action":"patchedLwcCancelAction"},"elementTypeToHTMLTemplateMapping":{},"disableUnloadWarn":true,"designTokenOverride":"--lwc-brandAccessible : #0176d3;\n--lwc-brandAccessibleActive: #014486;","currentLanguage":"en_US","currencyCode":"","consoleTabTitle":null,"consoleTabLabel":"New","consoleTabIcon":"custom:custom18","cancelType":"SObject","cancelSource":"%ContextId%","cancelRedirectTemplateUrl":"vlcCancelled.html","cancelRedirectPageName":"OmniScriptCancelled","bLK":false,"autoSaveOnStepNext":false,"autoFocus":false,"allowSaveForLater":true,"allowCancel":true},"prefillJSON":"{}","lwcId":"d18c17bb-9060-d218-159b-fba9359c983a","labelMap":{"NavigateAction3":"NavigateAction3","SV_CancelURL":"SV_CancelURL","DR_BandwidthExtract":"DR_BandwidthExtract","SV_OppList_Bandwidth":"SV_OppList_Bandwidth","Precheck":"Precheck","NavigateAction1":"NavigateAction1","TextBlock1":"Precheck:TextBlock1","CustomLWC1":"Precheck:CustomLWC1","IP_PreCheck":"IP_PreCheck","SV_PartialPrecheckFlag":"SV_PartialPrecheckFlag","SV_FullPrecheckFlag":"SV_FullPrecheckFlag","IP_InsertDeletePremiseAndServicePoint":"IP_InsertDeletePremiseAndServicePoint","AddressValidation":"AddressValidation","DR_ExtractProductFamily":"DR_ExtractProductFamily","SV_SetOppAccIds":"SV_SetOppAccIds","CANCEL":"CANCEL"},"labelKeyMap":{},"errorMsg":"","error":"OK","dMap":{},"depSOPL":{},"depCusPL":{},"cusPL":{},"children":[{"type":"Cancel Action","propSetMap":{"wpm":false,"variant":"neutral","validationRequired":"Submit","targetType":"Record","targetLWCLayout":"lightning","targetId":"%ContextId%","targetFilter":"Recent","ssm":false,"showCancelPrompt":true,"show":null,"replace":true,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"Avbryt","iconVariant":"","iconPosition":"left","iconName":"","controlWidth":12,"cancelMessage":"Är du säker på att du vill avbryta valideringsprocessen?","businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"CANCEL","level":0,"indexInParent":0,"bHasAttachment":false,"bEmbed":false,"bPatchedLwcCancelAction":true,"JSONPath":"CANCEL","lwcId":"lwc0"},{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[false,false],"show":null,"pubsub":false,"message":{},"label":"SetValues3","elementValueMap":{"OpportunityList":{"OpportunityId":"%ContextId%","AccountId":"%AccountId%"}},"disOnTplt":false,"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SV_SetOppAccIds","level":0,"indexInParent":1,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SV_SetOppAccIds","lwcId":"lwc1"},{"type":"DataRaptor Extract Action","propSetMap":{"wpm":false,"validationRequired":"Step","ssm":false,"showPersistentComponent":[null,null],"show":null,"responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"postMessage":"Done","message":{},"label":"DR_ExtractProductFamily","inProgressMessage":"In Progress","ignoreCache":false,"failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"disOnTplt":false,"dataRaptor Input Parameters":[],"controlWidth":12,"bundle":"DR_ExtractSystemLabels","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"DR_ExtractProductFamily","level":0,"indexInParent":2,"bHasAttachment":false,"bEmbed":false,"bDataRaptorExtractAction":true,"JSONPath":"DR_ExtractProductFamily","lwcId":"lwc2"},{"type":"Step","propSetMap":{"wpm":false,"validationRequired":true,"ssm":false,"showPersistentComponent":[true,false],"show":null,"saveMessage":"","saveLabel":"","remoteTimeout":30000,"remoteOptions":{},"remoteMethod":"","remoteClass":"","pubsub":false,"previousWidth":"0","previousLabel":"","nextWidth":0,"nextLabel":"","message":{},"label":"Leveranskontroll","knowledgeOptions":{"typeFilter":"","remoteTimeout":30000,"publishStatus":"Online","language":"English","keyword":"","dataCategoryCriteria":""},"instructionKey":"","instruction":"","errorMessage":{"default":null,"custom":[]},"conditionType":"Hide if False","completeMessage":"Are you sure you want to complete the script?","completeLabel":"Complete","chartLabel":null,"cancelMessage":"Are you sure?","cancelLabel":"Cancel","businessEvent":"","businessCategory":"","allowSaveForLater":false,"HTMLTemplateId":"","uiElements":{"AddressValidation":""},"aggElements":{"CustomLWC1":""}},"offSet":0,"name":"AddressValidation","level":0,"indexInParent":3,"bHasAttachment":false,"bEmbed":false,"response":null,"inheritShowProp":null,"children":[{"response":null,"level":1,"indexInParent":0,"eleArray":[{"type":"Custom Lightning Web Component","rootIndex":3,"response":null,"propSetMap":{"show":null,"lwcName":"addressValidation","label":"CustomLWC1","hide":false,"customAttributes":[{"source":"%OpportunityList:AccountId%","name":"AccountId"}],"controlWidth":12,"conditionType":"Hide if False","bStandalone":false},"name":"CustomLWC1","level":1,"JSONPath":"AddressValidation:CustomLWC1","indexInParent":0,"index":0,"children":[],"bHasAttachment":false,"bcustomlightningwebcomponent1":true,"lwcId":"lwc30-0"}],"bHasAttachment":false}],"bAccordionOpen":false,"bAccordionActive":false,"bStep":true,"isStep":true,"JSONPath":"AddressValidation","lwcId":"lwc3"},{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[true,false],"show":null,"sendJSONPath":"","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"useFuture":false,"preTransformBundle":"","postTransformBundle":"","chainable":false},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"IP_InsertDeletePremiseAndServicePoint","integrationProcedureKey":"MassCustomized_PremiseAndServicePointInsert","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"IP_InsertDeletePremiseAndServicePoint","level":0,"indexInParent":4,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"IP_InsertDeletePremiseAndServicePoint","lwcId":"lwc4"},{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"fullPrecheck","data":"true","condition":"="}],"operator":"AND"}},"pubsub":false,"message":{},"label":"SV_FullPrecheckFlag","elementValueMap":{"Finalsitelist":"=%siteList%"},"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SV_FullPrecheckFlag","level":0,"indexInParent":5,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SV_FullPrecheckFlag","lwcId":"lwc5"},{"type":"Set Values","propSetMap":{"wpm":false,"ssm":false,"showPersistentComponent":[true,false],"show":{"group":{"rules":[{"field":"fullPrecheck","data":"false","condition":"="}],"operator":"AND"}},"pubsub":false,"message":{},"label":"SV_PartialPrecheckFlag","elementValueMap":{"Finalsitelist":"=%newsiteList%"},"controlWidth":12,"HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"SV_PartialPrecheckFlag","level":0,"indexInParent":6,"bHasAttachment":false,"bEmbed":false,"bSetValues":true,"JSONPath":"SV_PartialPrecheckFlag","lwcId":"lwc6"},{"type":"Integration Procedure Action","propSetMap":{"wpm":false,"validationRequired":"Step","useContinuation":false,"toastComplete":true,"svgSprite":"","svgIcon":"","ssm":false,"showPersistentComponent":[true,false],"show":null,"sendJSONPath":"Finalsitelist","sendJSONNode":"","responseJSONPath":"","responseJSONNode":"","remoteTimeout":30000,"remoteOptions":{"useFuture":false,"queueableChainable":true,"preTransformBundle":"","postTransformBundle":"","fullPrecheck":"%fullPrecheck%","chainable":true},"redirectTemplateUrl":"vlcAcknowledge.html","redirectPreviousWidth":3,"redirectPreviousLabel":"Previous","redirectPageName":"","redirectNextWidth":3,"redirectNextLabel":"Next","pubsub":false,"preTransformBundle":"","postTransformBundle":"","postMessage":"Done","message":{},"label":"IP_PreCheck","invokeMode":"fireAndForget","integrationProcedureKey":"PreCheck_loop","inProgressMessage":"In Progress","failureNextLabel":"Continue","failureGoBackLabel":"Go Back","failureAbortMessage":"Are you sure?","failureAbortLabel":"Abort","extraPayload":{"productFamily":"%productFamily%","fullPrecheck":"%fullPrecheck%","OpportunityId":"%OpportunityList:OpportunityId%","AccountId":"%OpportunityList:AccountId%"},"errorMessage":{"default":null,"custom":[]},"enableDefaultAbort":false,"enableActionMessage":false,"controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"IP_PreCheck","level":0,"indexInParent":7,"bHasAttachment":false,"bEmbed":false,"bIntegrationProcedureAction":true,"JSONPath":"IP_PreCheck","lwcId":"lwc7"},{"inheritShowProp":null,"bEmbed":true,"bHasAttachment":false,"indexInParent":8,"level":0,"name":"SV_CancelURL","offSet":8,"propSetMap":{"HTMLTemplateId":"","controlWidth":12,"disOnTplt":false,"elementValueMap":{"url":"=IF(%quoteId% == null, STRING('/%ContextId%'), STRING('/apex/vlocity_cmt__HybridCPQ?id=%quoteId%'))"},"label":"SetValues2","message":{},"pubsub":false,"show":null,"showPersistentComponent":[false,false],"ssm":false,"wpm":false,"aggElements":{}},"type":"Set Values","bSetValues":true,"JSONPath":"SV_CancelURL","lwcId":"lwc8"},{"inheritShowProp":null,"bEmbed":true,"bHasAttachment":false,"indexInParent":9,"level":0,"name":"CANCEL","offSet":8,"propSetMap":{"HTMLTemplateId":"","businessCategory":"","businessEvent":"","cancelMessage":"Är du säker på att du vill avbryta valideringsprocessen?","controlWidth":12,"iconName":"","iconPosition":"left","iconVariant":"","label":"Avbryt","loginAction":"login","message":{},"objectAction":"home","pubsub":false,"recordAction":"view","replace":true,"show":null,"showCancelPrompt":true,"ssm":false,"targetFilter":"Recent","targetId":"%ContextId%","targetLWCLayout":"lightning","targetType":"Web Page","targetUrl":"%url%","validationRequired":"Submit","variant":"neutral","wpm":false,"aggElements":{}},"type":"Cancel Action","bPatchedLwcCancelAction":true,"JSONPath":"CANCEL","lwcId":"lwc9"},{"inheritShowProp":null,"bEmbed":true,"bHasAttachment":false,"indexInParent":10,"level":0,"name":"DR_ExtractProductFamily","offSet":8,"propSetMap":{"HTMLTemplateId":"","bundle":"DR_ExtractSystemLabels","controlWidth":12,"dataRaptor Input Parameters":[],"disOnTplt":false,"enableActionMessage":false,"enableDefaultAbort":false,"errorMessage":{"custom":[],"default":null},"failureAbortLabel":"Abort","failureAbortMessage":"Are you sure?","failureGoBackLabel":"Go Back","failureNextLabel":"Continue","ignoreCache":false,"inProgressMessage":"In Progress","label":"DR_ExtractProductFamily","message":{},"postMessage":"Done","pubsub":false,"redirectNextLabel":"Next","redirectNextWidth":3,"redirectPageName":"","redirectPreviousLabel":"Previous","redirectPreviousWidth":3,"redirectTemplateUrl":"vlcAcknowledge.html","remoteTimeout":30000,"responseJSONNode":"","responseJSONPath":"","show":null,"showPersistentComponent":[null,null],"ssm":false,"validationRequired":"Step","wpm":false,"aggElements":{}},"type":"DataRaptor Extract Action","bDataRaptorExtractAction":true,"JSONPath":"DR_ExtractProductFamily","lwcId":"lwc10"},{"inheritShowProp":null,"bEmbed":true,"bHasAttachment":false,"indexInParent":11,"level":0,"name":"DR_BandwidthExtract","offSet":8,"propSetMap":{"HTMLTemplateId":"","bundle":"MC_COBandwidthExtract","controlWidth":12,"dataRaptor Input Parameters":[{"element":"productFamily","inputParam":"productFamily"}],"disOnTplt":false,"enableActionMessage":false,"enableDefaultAbort":false,"errorMessage":{"custom":[],"default":null},"failureAbortLabel":"Abort","failureAbortMessage":"Are you sure?","failureGoBackLabel":"Go Back","failureNextLabel":"Continue","ignoreCache":false,"inProgressMessage":"In Progress","label":"DataRaptorExtractAction1","message":{},"postMessage":"Done","pubsub":false,"redirectNextLabel":"Next","redirectNextWidth":3,"redirectPageName":"","redirectPreviousLabel":"Previous","redirectPreviousWidth":3,"redirectTemplateUrl":"vlcAcknowledge.html","remoteTimeout":30000,"responseJSONNode":"","responseJSONPath":"","show":null,"showPersistentComponent":[false,false],"ssm":false,"validationRequired":"Step","wpm":false,"aggElements":{}},"type":"DataRaptor Extract Action","bDataRaptorExtractAction":true,"JSONPath":"DR_BandwidthExtract","lwcId":"lwc11"},{"inheritShowProp":null,"bEmbed":true,"bHasAttachment":false,"indexInParent":12,"level":0,"name":"SV_OppList_Bandwidth","offSet":8,"propSetMap":{"HTMLTemplateId":"","controlWidth":12,"disOnTplt":false,"elementValueMap":{"OpportunityList":{"AccountId":"%AccountId%","OpportunityId":"%ContextId%"}},"label":"SV_OppList_BandWidth","message":{},"pubsub":false,"show":null,"showPersistentComponent":[false,false],"ssm":false,"wpm":false,"aggElements":{}},"type":"Set Values","bSetValues":true,"JSONPath":"SV_OppList_Bandwidth","lwcId":"lwc12"},{"bAccordionActive":false,"bAccordionOpen":false,"children":[{"bHasAttachment":false,"eleArray":[{"bHasAttachment":false,"children":[],"index":0,"indexInParent":0,"JSONPath":"Precheck:TextBlock1","level":1,"name":"TextBlock1","propSetMap":{"HTMLTemplateId":"","controlWidth":12,"dataJSON":false,"disOnTplt":false,"label":"TextBlock1","sanitize":false,"show":{"group":{"operator":"AND","rules":[{"condition":"=","data":"true","field":"isPrecheckLoopDone"}]}},"text":"<p><span style=\"background-color: #339966; color: #ffffff;\">precheck completed</span></p>","textKey":""},"response":null,"rootIndex":5,"type":"Text Block","bTextBlock":true,"lwcId":"lwc130-0"}],"indexInParent":0,"level":1,"response":null},{"bHasAttachment":false,"eleArray":[{"bHasAttachment":false,"children":[],"index":0,"indexInParent":1,"JSONPath":"Precheck:CustomLWC1","level":1,"name":"CustomLWC1","propSetMap":{"bStandalone":false,"conditionType":"Hide if False","controlWidth":12,"customAttributes":[{"name":"custom-products","source":"%availableOffering%"},{"name":"custom-bandwidth","source":"%ProductBandwidth%"},{"name":"custom-product-family","source":"%productFamily%"}],"hide":false,"label":"CustomLWC1","lwcName":"productsAndBandwidth","show":null},"response":null,"rootIndex":5,"type":"Custom Lightning Web Component","bcustomlightningwebcomponent2":true,"lwcId":"lwc131-0"}],"indexInParent":1,"level":1,"response":null}],"inheritShowProp":null,"response":null,"bEmbed":true,"bHasAttachment":false,"indexInParent":13,"level":0,"name":"Precheck","offSet":8,"propSetMap":{"HTMLTemplateId":"","allowSaveForLater":false,"businessCategory":"","businessEvent":"","cancelLabel":"Cancel","cancelMessage":"Are you sure?","chartLabel":null,"completeLabel":"Complete","completeMessage":"Are you sure you want to complete the script?","conditionType":"Hide if False","errorMessage":{"custom":[],"default":null},"instruction":"","instructionKey":"","knowledgeOptions":{"dataCategoryCriteria":"","keyword":"","language":"English","publishStatus":"Online","remoteTimeout":30000,"typeFilter":""},"label":"Sammanställning","message":{},"nextLabel":"nästa","nextWidth":0,"previousLabel":"Tillbaka Till Leveranskontroll","previousWidth":0,"pubsub":false,"remoteClass":"","remoteMethod":"","remoteOptions":{},"remoteTimeout":30000,"saveLabel":"","saveMessage":"Are you sure you want to save it for later?","show":null,"showPersistentComponent":[true,false],"ssm":false,"validationRequired":true,"wpm":false,"uiElements":{"Precheck":""},"aggElements":{"CustomLWC1":""}},"type":"Step","bStep":true,"isStep":true,"JSONPath":"Precheck","lwcId":"lwc13"},{"inheritShowProp":null,"bEmbed":true,"bHasAttachment":false,"indexInParent":14,"level":0,"name":"NavigateAction1","offSet":8,"propSetMap":{"HTMLTemplateId":"","businessCategory":"","businessEvent":"","controlWidth":12,"iconName":"","iconPosition":"left","iconVariant":"","label":"NavigateAction1","loginAction":"login","message":{},"objectAction":"home","pubsub":false,"recordAction":"view","replace":true,"show":null,"ssm":false,"targetFilter":"Recent","targetId":"%ContextId%","targetLWCLayout":"lightning","targetName":"Opportunity","targetType":"Record","validationRequired":"Submit","variant":"brand","wpm":false,"aggElements":{}},"type":"Navigate Action","bNavigate":true,"JSONPath":"NavigateAction1","lwcId":"lwc14"},{"type":"Navigate Action","propSetMap":{"wpm":false,"variant":"brand","validationRequired":"Submit","targetType":"Record","targetParams":"","targetName":"Opportunity","targetLWCLayout":"lightning","targetId":"%ContextId%","targetFilter":"Recent","ssm":false,"show":null,"replace":true,"recordAction":"view","pubsub":false,"objectAction":"home","message":{},"loginAction":"login","label":"NavigateAction1","iconVariant":"","iconPosition":"left","iconName":"","disOnTplt":false,"controlWidth":12,"businessEvent":"","businessCategory":"","HTMLTemplateId":"","aggElements":{}},"offSet":0,"name":"NavigateAction3","level":0,"indexInParent":15,"bHasAttachment":false,"bEmbed":false,"bNavigate":true,"JSONPath":"NavigateAction3","lwcId":"lwc15"}],"bReusable":false,"bpVersion":1,"bpType":"PreCheck","bpSubType":"Validation","bpLang":"English","bHasAttachment":false,"lwcVarMap":{"OpportunityList":{"AccountId":null},"availableOffering":null,"ProductBandwidth":null,"productFamily":null}};