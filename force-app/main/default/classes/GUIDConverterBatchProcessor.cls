public class GUIDConverterBatchProcessor implements Database.Batchable<sObject>, Database.Stateful
{
    private static final String namespacePrefix = 'vlocity_cmt__';

    private static final String rootItemIdFieldName = namespacePrefix + 'RootItemId__c';
    private static final String parentItemIdFieldName = namespacePrefix + 'ParentItemId__c';
    private static final String assetReferenceIdFieldName = namespacePrefix + 'AssetReferenceId__c';

    // set of fields queries for each line item. line items will also be queries with an additional field (the
    // container id field) which is determined in the constructor.
    private static final List<String> lineItemFieldSet = new List<String> {
        assetReferenceIdFieldName, parentItemIdFieldName, rootItemIdFieldName};

    private static final Map<String, Map<String, String>> containerNameToLineItemInfoMap =
        new Map<String, Map<String, String>> {
            'quote' => new Map<String, String>{'LineItemType' => 'QuoteLineItem', 'containerIdFieldName' => 'QuoteId'}
        };

    public enum Options {COUNT_ONLY, SUPPLY_IDS_ONLY, CONVERT}

    public static final List<String> allowedContainerNames = new List<String> {
      'quote'
    };

    private String containerTypeNameLower;
    private Options option;
    private String containerIdQueryString;
    private String containerIdFieldName;
    private String lineItemTypeName;
    private String lineItemQueryString;
    private Integer containersAnalyzedCount = 0;
    private Integer needConvertingContainerCount = 0;

    // For SUPPLY_IDS_ONLY operations, all containers that have been successfully analyzed and found to need conversion
    // will be in this list.
    @TestVisible
    private List<Id> needConvertingContainerIdList = new List<Id>();

    // For CONVERT oeprations, if an error occurs during the conversion of a container its id will be placed here.
    private List<Id> conversionErrorContainerIdList = new List<Id>();

    // For all operations, if an error occurs during the analysis of a container its id will be placed here.
    @TestVisible
    private List<Id> analysisErrorContainerIdList = new List<Id>();

    // For CONVERT operations, all successfully converted container ids will be in this list.
    private List<Id> convertedContainerIdList = new List<Id>();

    // Exceptions that occur outside the analsis and conversion steps abort the entire batch. All such aborted container
    // ids are put in this list.
    private List<Id> batchErrorContainerIdList = new List<Id>();

    // Set of ids of containers to skip that were specified in the constructor. May be null.
    private Set<Id> containerIdsToSkip = null;

    /**
     * Container type must be one of Account, Order, Quote or Opportunity.
     */
    public GUIDConverterBatchProcessor(String containerTypeName, Options option, Set<Id> containerIdsToSkip,Integer i)
    {
        containerTypeNameLower = containerTypeName.toLowerCase();

        Map<String, String> lineItemInfoMap = containerNameToLineItemInfoMap.get(containerTypeNameLower);
        if (lineItemInfoMap == null)
        {
            throwException('containerTypeName must be one of: ' +
                JSON.serialize(containerNameToLineItemInfoMap.keySet()));
        }

        this.option = option;

        containerIdFieldName = lineItemInfoMap.get('containerIdFieldName');

        if(i != null && i>0){
            containerIdQueryString = 'SELECT Id FROM ' + containerTypeNameLower + ' WHERE (TeliaSE_Record_Type_Name__c =\'Individual_Quote\' OR TeliaSE_Record_Type_Name__c =\'TeliaSE_Fiber_CA_Quote_of_FA\' OR TeliaSE_Record_Type_Name__c =\'TeliaSE_Fiber_CA_Quote\' OR TeliaSE_Record_Type_Name__c =\'TeliaSE_Fiber_FA_Quote\') and status!=\'Cancelled\' limit '+i;
        }
        else {
            containerIdQueryString = 'SELECT Id FROM ' + containerTypeNameLower + ' WHERE  (TeliaSE_Record_Type_Name__c =\'Contract\' or TeliaSE_Record_Type_Name__c =\'Individual_Quote\' OR TeliaSE_Record_Type_Name__c =\'TeliaSE_Fiber_CA_Quote_of_FA\' OR TeliaSE_Record_Type_Name__c =\'TeliaSE_Fiber_CA_Quote\' OR TeliaSE_Record_Type_Name__c =\'TeliaSE_Fiber_FA_Quote\') and status!=\'Cancelled\'';
        }

        lineItemTypeName = lineItemInfoMap.get('LineItemType');

        List<String> completeFieldSet = new List<String>(lineItemFieldSet);
        completeFieldSet.add(containerIdFieldName);

        lineItemQueryString = 'SELECT ' + String.join(completeFieldSet,',') + ' FROM ' + lineItemTypeName +
            ' WHERE ' + containerIdFieldName + ' IN :containerIdsToQuerySet ' +
            ' ORDER BY ' + containerIdFieldName;
        System.debug('Query'+lineItemQueryString);
        if (containerIdsToSkip != null)
        {
            this.containerIdsToSkip = new Set<Id>(containerIdsToSkip);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC)
    {
        System.debug('Query'+containerIdQueryString);
        return Database.getQueryLocator(containerIdQueryString);
    }

    public void throwException(String message)
    {
        System.debug(LoggingLevel.ERROR, message);

        throw new GUIDConverterBatchException(message);
    }

    private void handleError(String errorMessage)
    {
        System.debug(LoggingLevel.ERROR, errorMessage);
    }

    private void logException(Exception e)
    {
        System.debug(LoggingLevel.ERROR, e.getMessage());
        System.debug(LoggingLevel.ERROR, e.getStackTraceString());
    }

    /**
     * Returns true if the supplied line item list is empty or if all the contained line items are using asset reference
     * id values in the hierarchy establishing fields ParentItemId__c and RootItemId__c.
     */
    private Boolean doesLineItemListNeedConverting(List<SObject> lineItemList)
    {
        Set<String> lineItemIdsAsStringSet = new Set<String>();
        Set<String> assetReferenceIdsAsStringSet = new Set<String>();
        for (SObject lineItemAsSObject : lineItemList)
        {
            lineItemIdsAsStringSet.add(lineItemAsSObject.Id);
            assetReferenceIdsAsStringSet.add((String) lineItemAsSObject.get(assetReferenceIdFieldName));
        }

        for (SObject lineItemAsSObject : lineItemList)
        {
            String rootItemIdStringValue = (String) lineItemAsSObject.get(rootItemIdFieldName);
            String parentItemIdStringValue = (String) lineItemAsSObject.get(parentItemIdFieldName);

            if (lineItemIdsAsStringSet.contains(rootItemIdStringValue) ||
                lineItemIdsAsStringSet.contains(parentItemIdStringValue))
            {
                // The line item's parentItemId or rootItemId are referring to a Salesforce id of another line item in
                // the same container. This normally means that the container needs to be converted. However,
                // it's possible that the container is one that was created when Salesforce Id values were used for
                // AssetReferenceId__c values. if so, then the root and parent item ids would also match the
                // asset reference id value. Such a container does not need to be converted, so we exclude them here.

                if (assetReferenceIdsAsStringSet.contains(rootItemIdStringValue) &&
                    assetReferenceIdsAsStringSet.contains(parentItemIdStringValue))
                {
                    continue;
                }

                // container needs to be converted.

                return true;
            }
        }

        return false;
    }
  @TestVisible
    public void handleAnalysisException(Exception e, Id containerId)
    {
        logException(e);

        analysisErrorContainerIdList.add(containerId);
    }
  @TestVisible
    public void handleConversionException(Exception e, Id containerId)
    {
        logException(e);

        conversionErrorContainerIdList.add(containerId);
    }

    public void execute(Database.BatchableContext BC, List<SObject> scope)
    {
        try
        {
            // define and populate a set of container ids taken from the container sobjects in the scope.
            // note: this variable must be called 'containerIdsToQuerySet' to match the reference in the
            // lineItemQueryString. do not change the variable name without changing the reference as well.
            Set<Id> containerIdsToQuerySet = new Set<Id>();
            for (SObject currentContainer : scope)
            {
                Id currentContainerId = currentContainer.Id;

                // if this container was listed in the ids to skip (likely because it was problematic for some reason),
                // then don't incldue it in the container query. This is especially important if the container is
                // being skipped because it has an unusually high number of line items.
                if ((containerIdsToSkip != null) && containerIdsToSkip.contains(currentContainerId))
                {
                    continue;
                }

                containerIdsToQuerySet.add(currentContainer.Id);
            }

            // abort if there are no remaining containers. This is unexpected unless the batch size is extremely low
            // and the containerIdsToSkip is not empty.
            if (containerIdsToQuerySet.isEmpty())
            {
                System.debug(LoggingLevel.DEBUG, 'no actionable container ids in scope: ' +
                    JSON.serialize(scope));
                return;
            }

            // fetch all the line items in the scope (minus the skipped containers) at once. we need to fetch them all
            // in a list rather than iterating through chunks in a loop because they need to be collated against the
            // container id.
            List<SObject> lineItemsInScopeList = Database.query(lineItemQueryString);

            Integer lineItemScanIndex = 0;
            while (lineItemScanIndex < lineItemsInScopeList.size())
            {
                Id currentContainerId = (Id) lineItemsInScopeList[lineItemScanIndex].get(containerIdFieldName);

                Integer currentContainerLineItemStartIndex = lineItemScanIndex;

                // loop through the line items in sequence starting from the next line item. the line items are sorted
                // by container id, so this will scan until the index of the first line item from another container.
                lineItemScanIndex++;
                while (lineItemScanIndex < lineItemsInScopeList.size())
                {
                    Id scanningContainerId = (Id) lineItemsInScopeList[lineItemScanIndex].get(containerIdFieldName);
                    if (scanningContainerId != currentContainerId)
                    {
                        break;
                    }

                    lineItemScanIndex++;
                }

                // the index of the last line item in the current container (inclusive) is the one just before the
                // current scan index.
                Integer currentContainerLineItemEndIndex = lineItemScanIndex - 1;

                // copy the set of line items in the current container into a separate list
                List<SObject> lineItemList = new List<SObject>();
                for (Integer currentIndex = currentContainerLineItemStartIndex;
                             currentIndex <= currentContainerLineItemEndIndex;
                             currentIndex++)
                {
                    lineItemList.add(lineItemsInScopeList[currentIndex]);
                }

                Boolean needsConverting = null;
                try
                {
                    needsConverting = doesLineItemListNeedConverting(lineItemList);
                }
                catch (exception e)
                {
                    handleAnalysisException(e, currentContainerId);
                    continue;
                }

                // if we get here we've successfully analyzed the container's line items and have a yes or no answer
                // as to whether it needs conversion.

                containersAnalyzedCount += 1;

                // regardless of option chosen, we don't need to do anything more if the container does not need to
                // be converted.
                if (! needsConverting)
                {
                    continue;
                }

                needConvertingContainerCount += 1;

                // if we're performing a count of containers only then we don't need to do anything else.
                if (option == Options.COUNT_ONLY)
                {
                    continue;
                }

                // if we're collecting ids of containers that need conversion then add the current container to that
                // list and we're done for this container.
                if (option == Options.SUPPLY_IDS_ONLY)
                {
                    needConvertingContainerIdList.add(currentContainerId);
                    continue;
                }

                // if we get here the option must be CONVERT and the container needs conversion.

                try
                {
                    ConversionResult conversionResult = convertLineItems(lineItemList, currentContainerId);

                    if (conversionResult.updateRequired)
                    {
                        update lineItemList;
                        // System.debug(LoggingLevel.ERROR, 'would update these line items: ' +
                        //     JSON.serialize(lineItemList));

                        convertedContainerIdList.add(currentContainerId);
                    }
                }
                catch (exception e)
                {
                    handleConversionException(e, currentContainerId);
                }
            }
        }
        catch (Exception e)
        {
            // exceptions handled here abort the entire batch. this is only for exceptions that occur outside of the
            // analysis and conversion steps - those exceptions are caught earlier and abort only processing for the
            // specific container.

            logException(e);

            for (SObject currentContainerAsSObject : scope)
            {
                batchErrorContainerIdList.add(currentContainerAsSObject.Id);
            }
        }
    }

    public void finish(Database.BatchableContext batchContext)
    {
        notifyUser(batchContext);
    }
  @TestVisible
    private String getCountResultDescription()
    {
        Boolean completeFailure = false;

        String statusString;

        if ((analysisErrorContainerIdList.size() > 0) || (batchErrorContainerIdList.size() > 0))
        {
            if (containersAnalyzedCount > 0)
            {
                statusString = 'was partially successful.';
            }
            else
            {
                completeFailure = true;
                statusString = 'failed. ';
            }

            Integer containerFailedCount = analysisErrorContainerIdList.size() + batchErrorContainerIdList.size();
            statusString += '. ' + containerFailedCount + ' containers could not be analyzed. ';
        }
        else
        {
            statusString = 'succeeded.';
        }


        if (! completeFailure)
        {
            statusString += '\n\n' + containersAnalyzedCount + ' ' + containerTypeNameLower +
                's were successfully analyzed and ' + needConvertingContainerCount + ' need to be converted.\n\n';
        }
        else
        {
            statusString += '\n\n';
        }

        // add skipped id lists
        if ( (containerIdsToSkip != null) && containerIdsToSkip.size() > 0)
        {
            statusString += ' The following container ids were not considered by request: \n';
            statusString += String.join(new List<Id>(containerIdsToSkip), ',') + '.\n\n';
        }

        return statusString;
    }
  @TestVisible
    private String getSupplyIdsOnlyResultDescription()
    {
        // start with the count description.
        String statusString = getCountResultDescription();

        // add id list of containers requiring conversion.
        if (needConvertingContainerIdList.size() > 0)
        {
            statusString += containerTypeNameLower + 's with the following ids require conversion:\n\n';
            statusString += String.join(needConvertingContainerIdList, ',') + '.\n';
        }

        // add single-error id lists.
        if (analysisErrorContainerIdList.size() > 0)
        {
            statusString += containerTypeNameLower + 's with the following ids could not be analyzed:\n\n';
            statusString += String.join(analysisErrorContainerIdList, ',') + '.\n';
        }

        // add error id-list of containers that were not analyzed because the entire batch failed.
        if (batchErrorContainerIdList.size() > 0)
        {
            statusString += containerTypeNameLower +
                's with the following ids could not be analyzed due to failed batch processing:\n\n';
            statusString += String.join(batchErrorContainerIdList, ',') + '.\n';
        }

        return statusString;
    }

    private String getConvertResultDescription()
    {
        Boolean completeFailure = false;

        String statusString = '';

        if ((analysisErrorContainerIdList.size() > 0) || (batchErrorContainerIdList.size() > 0) ||
            (conversionErrorContainerIdList.size() > 0))
        {
            if (containersAnalyzedCount > 0)
            {
                statusString = 'was partially successful. ';
            }
            else
            {
                completeFailure = true;
                statusString = 'failed. ';
            }

            Integer containerFailedCount = analysisErrorContainerIdList.size() + batchErrorContainerIdList.size() +
                conversionErrorContainerIdList.size();
            statusString += '. ' + containerFailedCount + ' containers could not be converted.\n\n';
        }
        else
        {
            statusString += 'succeeded.\n\n';
        }

        if (! completeFailure)
        {
            statusString += containersAnalyzedCount + ' were successfully analyzed and ' +
                needConvertingContainerCount + ' needed to be converted.\n\n';

            if (convertedContainerIdList.size() > 0)
            {
                statusString += convertedContainerIdList.size() + ' containers were successfully converted.\n\n';
            }
        }

        // add skipped id lists
        if ((containerIdsToSkip != null) && containerIdsToSkip.size() > 0)
        {
            statusString += ' The following container ids were not considered by request: \n';
            statusString += String.join(new List<Id>(containerIdsToSkip), ',') + '.\n';
        }

        // add error id lists.

        if (analysisErrorContainerIdList.size() > 0)
        {
            statusString += ' The following container ids could not be analyzed: \n';
            statusString += String.join(analysisErrorContainerIdList, ',') + '.\n';
        }

        if (conversionErrorContainerIdList.size() > 0)
        {
            statusString += ' The following container ids could not be converted: \n';
            statusString += String.join(conversionErrorContainerIdList, ',') + '.\n';
        }

        if (batchErrorContainerIdList.size() > 0)
        {
            statusString += ' The following container ids could not be converted due to failed batch processing: \n';
            statusString += String.join(batchErrorContainerIdList, ',') + '.\n';
        }

        return statusString;
    }

    private void notifyUser(Database.BatchableContext batchContext)
    {
        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :batchContext.getJobId()];

        String userEmail = Job.CreatedBy.Email;

        if (String.isEmpty(userEmail))
        {
            System.debug(LoggingLevel.ERROR, 'could not send result email because user email is empty for job id: ' +
                batchContext.getJobId());
            return;
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {userEmail};
        mail.setToAddresses(toAddresses);

        String body;
        mail.setSubject('Vlocity GUID Conversion Batch Job (' + batchContext.getJobId() + ') ' + job.Status);

        body = 'The GUID batch job (' + batchContext.getJobId() + ') operating on container type: ' +
            containerTypeNameLower + ', for operation type: ' + String.valueOf(option) + ', ';

        if (option == Options.COUNT_ONLY)
        {
            body += getCountResultDescription();
        }
        else if (option == Options.SUPPLY_IDS_ONLY)
        {
            body += getSupplyIdsOnlyResultDescription();
        }
        else
        {
            body += getConvertResultDescription();
        }

        mail.setPlainTextBody(body);
        try
        {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch (Exception e)
        {
            System.debug(LoggingLevel.ERROR, 'The following exception has occurred: ' + e.getMessage() + '\n ' +
                e.getStackTraceString());
        }
    }

    private class ConversionResult
    {
        public Boolean errorOccurred;
        public Boolean updateRequired;

        public ConversionResult(Boolean errorOccurred, Boolean updateRequired)
        {
            this.errorOccurred = errorOccurred;
            this.updateRequired = updateRequired;
        }
    }

    public static final Boolean CONVERT_ERROR_OCCURRED = true;
    public static final Boolean NO_CONVERT_ERROR = false;

    public static final Boolean UPDATE_REQUIRED = true;
    public static final Boolean NO_UPDATE_REQUIRED = false;

    public static final ConversionResult errorConversionResult =
        new ConversionResult(CONVERT_ERROR_OCCURRED, NO_UPDATE_REQUIRED);

    private ConversionResult convertLineItems(List<SObject> lineItemList, Id currentContainerId)
    {
        Map<Id, String> lineItemIdToAssetReferenceIdMap = new Map<Id, String>();
        Set<String> assetReferenceIdSet = new Set<String>();
        for (SObject currentLineItem : lineItemList)
        {
            String assetReferenceIdValue = (String) currentLineItem.get(assetReferenceIdFieldName);

            lineItemIdToAssetReferenceIdMap.put(currentLineItem.Id, assetReferenceIdValue);
            assetReferenceIdSet.add(assetReferenceIdValue);
        }

        // Convert the line items to use proper AssetReferenceId values in the hierarchy fields.

        Boolean anyLineItemValueChanged = false;
        for (SObject currentLineItem : lineItemList)
        {
            String rootItemIdStringValue = (String) currentLineItem.get(rootItemIdFieldName);

            if ((! String.isEmpty(rootItemIdStringValue)) &&
                (! assetReferenceIdSet.contains(rootItemIdStringValue)))
            {
                String rootItemAssetReferenceId = lineItemIdToAssetReferenceIdMap.get(rootItemIdStringValue);

                if (String.isEmpty(rootItemAssetReferenceId))
                {
                    handleError('While attempting to convert this container: ' + currentContainerId +
                        ', encountered unrecognized root item id value: ' + rootItemIdStringValue +
                        '. Aborting container conversion.');
                    return errorConversionResult;
                }

                anyLineItemValueChanged = true;
                currentLineItem.put(rootItemIdFieldName, rootItemAssetReferenceId);
            }

            String parentItemIdStringValue = (String) currentLineItem.get(parentItemIdFieldName);

            if ((! String.isEmpty(parentItemIdStringValue)) &&
                (! assetReferenceIdSet.contains(parentItemIdStringValue)))
            {
                String parentItemAssetReferenceId = lineItemIdToAssetReferenceIdMap.get(parentItemIdStringValue);
                if (String.isEmpty(parentItemAssetReferenceId))
                {
                    // this is an error because the parent item id value was not empty, but can't be converted.
                    handleError('While attempting to convert this container: ' + currentContainerId +
                        ', encountered unrecognized parent item id value: ' + parentItemIdStringValue +
                        '. Aborting container conversion.');
                    return errorConversionResult;
                }

                anyLineItemValueChanged = true;
                currentLineItem.put(parentItemIdFieldName, parentItemAssetReferenceId);
            }
        }

        return new ConversionResult(NO_CONVERT_ERROR, anyLineItemValueChanged);
    }

    public class GUIDConverterBatchException extends Exception {}
}