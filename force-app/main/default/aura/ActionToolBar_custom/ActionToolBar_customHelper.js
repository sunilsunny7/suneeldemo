({
    initHelper : function(cmp) {
        var action = cmp.get('c.getAllActions');
        var baseurl = cmp.get('c.getCommunityBaseURL');
        var namespace = cmp.get('c.getNameSpacePrefix');
        //var linkTypes = cmp.get("c.getLinkTypes");
        //Get Actions
        action.setParams({
            objType : cmp.get('v.objType'),
            sFilterContextId : cmp.get('v.recordId'),
            sDisplayOn : cmp.get('v.displayOn'),
            sLinkType : cmp.get('v.linkType')
        });
        action.setCallback(this, function(a) {
            var returnObjects = JSON.parse(a.getReturnValue());
            var vlocButtons = [];
            var vlocDropDown = [];
            if (returnObjects.length > 6) {
                vlocButtons = returnObjects.slice(0, 6);
                vlocDropDown = returnObjects.slice(6);
                cmp.set('v.vlocButtons', vlocButtons);
                cmp.set('v.vlocDropDown', vlocDropDown);
            } else {
                cmp.set('v.vlocButtons', returnObjects);
                cmp.set('v.vlocDropDown', vlocDropDown);
            }
            cmp.set('v.vlocActions', returnObjects);
            
            //Set Orientation:
            var orientation = cmp.get('v.style');
            if (orientation === 'vertical') {
                cmp.set('v.styleHtml', 'action-container action-vertical community');
            }else {
                cmp.set('v.styleHtml', 'action-container action-horizontal');
            }
            
        });
        //Get Base URL
        $A.enqueueAction(action);
        baseurl.setCallback(this, function(b) {
            var returnObjects = b.getReturnValue();
            cmp.set('v.baseURL', returnObjects);
        });
        $A.enqueueAction(baseurl);
        //Get nsPrefix
        namespace.setCallback(this, function(response) {
            var state = response.getState();
            if (cmp.isValid() && state === 'SUCCESS') {
                var nsPrefix = response.getReturnValue();
                cmp.set('v.nsPrefix', nsPrefix);
            }
            
        });
        $A.enqueueAction(namespace);
    },
    showAlert : function(cmp, type, message, isPopUp) {
        var isNotPopUp = false;
        var validationErrorHandler = {};
        validationErrorHandler['type'] = type;
        validationErrorHandler['message'] = message;
        cmp.set('v.validationErrorHandler', validationErrorHandler);
        cmp.set('v.isPopUp', isPopUp);
    },
    onNavigate : function(cmp, url, label, urlOpenMode, subTabUrl, input, interactionId, interactionName) {
        // var workspace = cmp.find('workspace');
        //var utilityAPI = cmp.find('utilitybar');
        var doneData;
        var isAbsoluteUrl = new RegExp('^(?:[a-z]+:)?//', 'i');
        var oldStyleOmniRegex = new RegExp("/OmniScriptType/([^/]*)/OmniScriptSubType/([^/]*)/OmniScriptLang/([^/]*)/ContextId/([^/]*)/");
        subTabUrl = '';
        if (isAbsoluteUrl.test(url)) {
            var params = (urlOpenMode === 'New Tab / Window') ? '_blank' : '_self';
            if (params === '_self') {
                window.open(url, params);
            }
        } else if (url.indexOf('apex') < 0) {
            url = '#/sObject/' + url;
            label = '';
        } else {
            var matches = oldStyleOmniRegex.exec(url);
            if(matches !== null && matches.length > 0) {
                var urlObj = {
                    componentDef : "contract_test01:OmniScript",
                    attributes: {
                        type: matches[1],
                        subtype: matches[2],
                        language: matches[3],
                        recordId: (matches[4] || this.getUrlParam(url, 'ContextId') || this.getUrlParam(url, 'id'))
                    }
                };
                var lightningRedirect = JSON.stringify(urlObj);
                var lightningInstanceUrl = '/one/one.app#' + window.btoa(lightningRedirect);
                url = lightningInstanceUrl;
            } else {
                var urlObj = {
                    componentDef : "one:alohaPage",
                    attributes: {
                        values: {
                            address : url
                        },
                        history: []
                    }
                };
                var lightningRedirect = JSON.stringify(urlObj);
                var lightningInstanceUrl = '/one/one.app#' + window.btoa(lightningRedirect);
                url = lightningInstanceUrl;
            }
        }
        
        var actionData = {
            currentUrl: url,
            currentLabel: label
        };
        var isInConsole = true;
    },
    getUrlParam: function(url, paramName) {
        var paramMatch = new RegExp(paramName + '=([^&#=]*)', 'i').exec(url);
        if (paramMatch && paramMatch.length > 1) {
            return decodeURIComponent(paramMatch[1]);
        }
        return null;
    },
    handleUrl: function(cmp, url, isredirect) {
        var hostRoot, urlEvent;
        if (/livepreview/.test(window.location.host)) {
            hostRoot = window.location.protocol + '//' + window.location.host + '/sfsites/c';
        } else {
            hostRoot = window.location.protocol + '//' + window.location.host + window.location.pathname.split('/s/')[0];
        }
        if (/^\/[a-zA-Z0-9]{15,18}(\?.*)*$/.test(url)) {
            // special case for view object
            urlEvent = $A.get('e.force:navigateToSObject');
            urlEvent.setParams({
                'recordId': url.substring(1),
                'isredirect': !!isredirect
            });
            urlEvent.fire();
        } else if (/^\/([a-zA-Z0-9]{15,18})\/e(\?.*)*$/.test(url)) {
            // special case for edit object
            var result = /^\/([a-zA-Z0-9]+)\/e(\?.*)*$/.exec(url);
            urlEvent = $A.get('e.force:editRecord');
            urlEvent.setParams({
                'recordId': result[1],
                'isredirect': !!isredirect
            });
            urlEvent.fire();
        } else {
            var protocolRegex = new RegExp('://'),
                urlHelper = document.createElement('a');
            urlHelper.href = ((!protocolRegex.test(url) && url.charAt(0) !== '/') ? '/' : '') + url;
            if (this.isApexPage(this.ie11pathnameFix(urlHelper))) {
                var types = {
                    '/native/bridge.app': 'hybrid',
                    '/one/one.app': 'web'
                };
                var queryStringObj = {
                    omniIframeEmbedded: true,
                    omniCancelAction: 'back',
                    tour: '',
                    isdtp: 'p1',
                    sfdcIFrameOrigin: this.getOrigin(),
                    sfdcIFrameHost: 'sfNativeBridge' in window ? 'hybrid' : types[window.location.pathname.toLowerCase()] || 'web'
                };
                var queryString = Object.keys(queryStringObj).reduce(function(queryString, key) {
                    return queryString + (queryString.length > 1 ? '&' : '') + encodeURIComponent(key) + '=' + encodeURIComponent(queryStringObj[key]);
                }, 'omniCancelAction=back');
                urlHelper.search += (urlHelper.search.length === 0 ? '?' : '&') + queryString;
                /*$A.createComponent('contract_test01:vlocityIframeComponent', {
                    url: hostRoot + this.ie11pathnameFix(urlHelper) + urlHelper.search + urlHelper.hash
                }, function handleComponentCreation(component, status, errorMessage) {
                    if (status === 'SUCCESS') {
                        var body = cmp.get('v.body');
                        body.push(component);
                        cmp.set('v.body', body);
                    } else if (status === 'INCOMPLETE') {
                        console.log('No response from server or client is offline.');
                    } else if (status === 'ERROR') {
                        console.log('Error: ' + errorMessage);
                    }
                });*/
                urlEvent = $A.get('e.force:navigateToURL');
                urlEvent.setParams({
                    'url': url,
                    'isredirect': !!isredirect
                });
                urlEvent.fire();
            } else {
                urlEvent = $A.get('e.force:navigateToURL');
                urlEvent.setParams({
                    'url': url,
                    'isredirect': !!isredirect
                });
                urlEvent.fire();
            }
        }
    },
    setupExtraParams: function(cmp, source) {
        var regex = new RegExp('"', 'g'),
            extraParams = {};
        if (source[0] === '?') {
            source = source.substring(1);
        }
        if (source[source.length - 1] === '&') {
            source = source.substring(0, source.length - 1);
        }
        var asString = '{"' + decodeURI(source).replace(regex, '\\"').replace(/&/g, '","').replace(/=/g,'":"') + '"}';
        try {
            extraParams = JSON.parse(asString);
        } catch (e) { /* log and swallow bad parsing.*/
            console.error('Could not generate extraParams from: ' + asString);
        }
        cmp.set('v.extraParams', extraParams);
    },
    getUrlParam: function(url, paramName) {
        var paramMatch = new RegExp(paramName + '=([^&#=]*)', 'i').exec(url);
        if (paramMatch && paramMatch.length > 1) {
            return decodeURIComponent(paramMatch[1]);
        }
        return null;
    },
    isApexPage: function(url) {
        return new RegExp('^/apex/').test(url);
    },
    /* https://news.ycombinator.com/item?id=3939454 */
    ie11pathnameFix: function(urlHelper) {
        return urlHelper.pathname.replace(/(^\/?)/,"/");
    },
    getOrigin: function() {
        return 'origin' in window.location ? window.location.origin :
        [window.location.protocol, '//', window.location.hostname, window.location.port ? ':' + window.location.port : ''].join('');
    },
    getPageName: function(url) {
        if (this.isApexPage(url)) {
            var parts = url.split(/(\/|\?|#)/);
            return parts.filter(function(str) {
                return str.length > 0;
            })[3];
        }
        return null;
    },
    invokeVOIMethod : function(cmp, recordId, selectedAction, input, option,helper, verifyAction) {
        var baseURL = cmp.get('v.baseURL');
        if(verifyAction)
        {
            var option = {};
            var action = cmp.get('c.invokeVOIMethod');
            action.setParams({ 'className' : selectedAction.validationClassName ,
                              'methodName' : selectedAction.validationMethodName,
                              inputJson : JSON.stringify(input),
                              optionJson : JSON.stringify(option) });
            
            action.setCallback(this, function(result) {
                var remoteResp = JSON.parse(result.getReturnValue());
                console.log('invokeVOIMethod: ', result);
                if (remoteResp && remoteResp.Error !== 'OK') {
                    this.showAlert(cmp,'error',remoteResp.Error, true);
                    //window.alert(remoteResp.Error);
                } else if( remoteResp && remoteResp.Warning ) {
                    this.showAlert(cmp,'warning',remoteResp.Warning,true);
                }
                cmp.set('v.selectedAction', selectedAction);
                console.log('verifyAction found, action invoked.');
                return;
            });
            $A.enqueueAction(action);
        }
        else if (selectedAction && selectedAction.url && !selectedAction.className && !selectedAction.methodName) {
            var isLEX;
            if (baseURL.includes('one.app')) {
                isLEX = true;
            }else {
                isLEX = false;
            }
            var customCommunityPage = cmp.get('v.customCommunityPage');
            var path = baseURL + selectedAction.url;
            if (selectedAction.url != undefined && selectedAction.url.includes('/apex/')) {
                if (!isLEX) {
                    path = baseURL + customCommunityPage + '?actionUrl=' + selectedAction.url;
                }else {
                    path = selectedAction.url;
                }
            }
            this.handleUrl(cmp, selectedAction.url);
        }
            else if (selectedAction.className && selectedAction.methodName) {
                var option = {};
                var parentActionUrl, actionUrl, doneData;
                console.log('input in checkFieldVerificationAndProcess callback', input);
                console.log('passing input stringified: ', input);
                var action = cmp.get('c.invokeVOIMethod');
                action.setParams({ 'className' : selectedAction.className ,
                                  'methodName' : selectedAction.methodName,
                                  inputJson : JSON.stringify(input),
                                  optionJson : JSON.stringify(option) });
                action.setCallback(this, function(result) {
                    var remoteResp = JSON.parse(result.getReturnValue());
                    console.log('invokeVOIMethod: ', result);
                    if (remoteResp && remoteResp.Error !== 'OK') {
                        this.showAlert(cmp,'error',remoteResp.Error,true);
                        //window.alert(remoteResp.Error);
                    } else {
                        if (selectedAction.url) {
                            // URL & caseId
                            console.log('>>SelectedAction.url>>>')
                            var isLEX;
                            if (baseURL.includes('one.app')) {
                                isLEX = true;
                            }else {
                                isLEX = false;
                            }
                            var customCommunityPage = cmp.get('v.customCommunityPage');
                            var path = baseURL + selectedAction.url;
                            if (selectedAction.url != undefined && selectedAction.url.includes('/apex/')) {
                                if (!isLEX) {
                                    path = baseURL + customCommunityPage + '?actionUrl=' + selectedAction.url;
                                }else {
                                    path = selectedAction.url;
                                }
                            }
                            this.handleUrl(cmp, selectedAction.url);
                        }
                        else {
                            $A.get('e.force:refreshView').fire();
                        }
                    }
                });
                $A.enqueueAction(action);
            } else {
                this.showAlert(cmp,'error','Action Button not configured correctly.',true);
                //window.alert(remoteResp.Error);
                return;
            }
    }
})