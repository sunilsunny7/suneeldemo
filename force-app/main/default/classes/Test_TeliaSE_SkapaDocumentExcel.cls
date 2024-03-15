@isTest
private class Test_TeliaSE_SkapaDocumentExcel {

    public static testmethod void invokeMethod() {
        test.starttest();
        Account newA = test_DataFactory.createOneLargeStandardAccount();
        newA.Name = 'Testkknr';
        newA.Org_Nr__c = '5555555555';
        insert newA;
        Contract newC = new Contract();
        newC.Name = 'TestContract';
        newC.AccountId = newA.Id;
        newC.Agreement_KO_nr__c = '6765';
        newC.HERA_Number__c = '23232';
        insert newC;
        Object obj = (Object) newC.Id;
        String jsonInput = getJsonString();

        Map < String, Object > inputMap = (Map < String, Object > ) JSON.deserializeUntyped(jsonInput);
        inputMap.put('id', obj);
        TeliaSE_SkapaDocumentExcelConversion tc = new TeliaSE_SkapaDocumentExcelConversion();
        tc.invokeMethod('excelConvert', inputMap, inputMap, inputMap);
        test.stoptest();
    }
    // 


    public static testmethod String getJsonString() {
        String jsonStr = '{\n' +
            ' "MDUCHT1707Name" :["MDU_CollHW_Tvbox_1707","MDU_CollBB_250Mbit_1707"],\n' +
            ' "MDUCOAXTVName" :["MDU_CoaxTV_1707"],\n' +
            ' "MDUIPTVNDFName" :["MDU_CollIPTV_Denmark_1707"],\n' +
            ' "MDUIPTVName" :["MDU_CollIPTV_BAS_1707"],\n' +
            ' "MDUCHW1707Name" :["MDU_CollHW_WirelessTV_1707"],\n' +
            ' "MDUSHName" :["MDU_SmarttHome"],\n' +
            ' "Orderunderlag": { ' +
            ' "General": {' +
            ' "OfferType":"", ' +
            ' "WBSnumber":"09888994", ' +
            ' "TypeOfBusiness":"" },\n' +            
            ' "Other": {' +
            ' "OtherInformation":"", ' +
            ' "ProductCodeInAlpha":"09888994", ' +
            ' "Customer_OwnedNetwork":"" },\n' +            
            ' "Hardware": {' +
            ' "Quantity_MDUCHT1707":"1", ' +
            ' "Name_MDUCHT1707":"MDU_CollHW_Tvbox_1707", ' +
            ' "Quantity_MDUCRF5370":"9", ' +
            ' "NumberOfMCs_WholePackage":"", ' +
            ' "NumberOfCollectiveBB_SCTSBroadbandSwitch":"", ' +
            ' "BroadbandSwitch":"", ' +
            ' "SwitchReplacement1":"" },\n' +              
            ' "CollectiveActivation": {' +
            ' "ExistingCableTv":"1", ' +
            ' "CollectiveCableTvActivationType":"test1", ' +
            ' "RCT_MDUCOAXTV":"9", ' +
            ' "Name_MDUCOAXTV":"test2", ' +
            ' "Name_MDUIPTVNDF":"test3", ' +
            ' "RCT_MDUIPTV":"1", ' +
            ' "Name_MDUIPTV":"test4", ' +
            ' "RCT_MDUCOLVOIP":"9", ' +
            ' "VOIPActivationType":"test5", ' +
            ' "Name_MDUCOLVOIP":"test6", ' +
            ' "CollectiveBroadbandActivationType":"1", ' +
            ' "RCT_MDUCOLBB":"111", ' +
            ' "Name_MDUCOLBB":"test8" },\n' +             
            ' "ServiceAgreement": {' +
            ' "SpecificInfoInAgreementTeliaOfficersSAprocess":"1", ' +
            ' "SpecificInfoToTeliaAdministratorSAprocess":"test1", ' +
            ' "InfoToExternalServiceProvider":"9", ' +
            ' "AdditionalInfoForTechnicians":"test2", ' +
            ' "InfoForTechniciansSpecifictoParticularKOagreement":"test3", ' +
            ' "ONEcommonContactPathForEntireKOagreement":"1", ' +
            ' "InfoAboutTechnicalContactPerson":"test4", ' +
            ' "InfoNotIncludedInRegistration":"9", ' +
            ' "InstructionsFor1stTechnicianUnlinkErrorType":"test5", ' +
            ' "AdditionalInfo_ServiceSupport":"ok", ' +
            ' "FurtherInfoForBilling":"ok", ' +
            ' "OneOrMoreContactPersonsForService":"test8" },\n' +                                                 
            ' "FA_Services": {' +
            ' "ServiceAgreementCableTV_PricePerMonth":"1", ' +
            ' "ServiceAgreementCableTV":"MDU_CollHW_Tvbox_1707", ' +
            ' "ServiceAgreement_PricePerMonthCopperOrFTTB":"9", ' +
            ' "ServiceAgreement_NumberOfPorts_CopperOrFTTB":"", ' +
            ' "ServiceAgreement_PricePerMonthFiberOrFTTH":"", ' +
            ' "ServiceAgreement_NumberOfPorts_FiberOrFTTH":"1", ' +
            ' "ServiceAgreementServiceSpacer":"MDU_CollHW_Tvbox_1707", ' +
            ' "RCT_MDUFNC1718":"9", ' +
            ' "Name_MDUFNC1718":"", ' +
            ' "FS_Nat_TotalPricePerMonth":"", ' +
            ' "FS_NetworkNumberOfPorts":"1", ' +
            ' "IsItANewBridge":"MDU_CollHW_Tvbox_1707", ' +
            ' "FNTnumber":"9", ' +
            ' "CentralPointAddress":"", ' +
            ' "FullMeshOrHubSpooke":"", ' +
            ' "RCT_MDUFWC21613":"1", ' +
            ' "Quantity_MDUFWC21613":"MDU_CollHW_Tvbox_1707", ' +
            ' "Name_MDUFWC21613":"9", ' +
            ' "RCT_MDUFWC1613":"", ' +
            ' "Quantity_MDUFWC1613":"", ' +
            ' "Name_MDUFWC1613":"1", ' +
            ' "RCT_MDUFWA1001613":"MDU_CollHW_Tvbox_1707", ' +
            ' "Quantity_MDUFWA1001613":"9", ' +
            ' "Name_MDUFWA1001613":"", ' +
            ' "RCT_MDUFWA101613":"", ' +
            ' "Quantity_MDUFWA101613":"1", ' +
            ' "Name_MDUFWA101613":"MDU_CollHW_Tvbox_1707", ' +
            ' "Quantity_MDUCRF5370":"9", ' +
            ' "RCT_MDUFWA21613":"", ' +
            ' "Quantity_MDUFWA21613":"", ' +
            ' "Name_MDUFWA21613":"1", ' +
            ' "RCT_MDUFWA1613":"MDU_CollHW_Tvbox_1707", ' +
            ' "Quantity_MDUFWA1613":"9", ' +
            ' "Name_MDUFWA1613":"", ' +
            ' "RCT_MDUFE100A1613":"", ' +
            ' "Quantity_MDUFE100A1613":"", ' +
            ' "Name_MDUFE100A1613":"", ' +
            ' "RCT_MDUFE10A1613":"", ' +
            ' "Quantity_MDUFE10A1613":"", ' +
            ' "Name_MDUFE10A1613":"", ' +
            ' "RCT_MDUFEA1613":"", ' +
            ' "Quantity_MDUFEA1613":"", ' +
            ' "Name_MDUFEA1613":"", ' +
            ' "RCT_MDUFBC1613":"", ' +
            ' "Quantity_MDUFBC1613":"", ' +
            ' "Name_MDUFBC1613":"", ' +  
            ' "RCT_MDUFBA1613":"", ' +
            ' "Name_MDUFE10AF1613":"",' +
            ' "Quantity_MDUFE10AF1613":"",' +
            ' "RCT_MDUFE10AF1613":"",' +
            ' "Name_MDUFE100AF1613":"",' +
            ' "Quantity_MDUFE100AF1613":"",' +
            ' "RCT_MDUFE100AF1613":"",' +
            ' "Name_MDUFSEXTRAAccessFiber1613":"",' +
            ' "Quantity_MDUFSEXTRAAccessFiber1613":"",' +
            ' "RCT_MDUFSEXTRAAccessFiber1613":"",' +
            ' "Name_MDUFSWANAccess1001617":"",' +
            ' "Quantity_MDUFSWANAccess1001617":"",' +
            ' "RCT_MDUFSWANAccess1001617":"",' +
            ' "Name_MDUFSWANNatAccess101744":"",' +
            ' "Quantity_MDUFSWANNatAccess101744":"",' +
            ' "RCT_MDUFSWANNatAccess101744":"",' +
            ' "Name_MDUFSWANNatAccess1001744":"",' +
            ' "Quantity_MDUFSWANNatAccess1001744":"",' +
            ' "RCT_MDUFSWANNatAccess1001744":"",' +
            ' "Quantity_MDUFBA1613":"", ' +
            ' "Name_MDUFBA1613":"", ' +     
            ' "OneTimeFeeTeliaPropertyManagement":"", ' +         
            ' "OnetimePropertyOwner1":"9" },\n' +            
            ' "Store": {' +
            ' "Quantity_MDULES1729":"1", ' +
            ' "Is_MDULES1729":"Yes", ' +
            ' "TypeOfInstallationHelp1":"Bulk", ' +
            ' "KoperNumberOfOtherPorts1":"", ' +
            ' "KoperNumberOfPremises1":"", ' +
            ' "KoperNumberOfHouseholds1":"", ' +
            ' "KoperNumberOfPort1":"", ' +
            ' "FiberNumberOfOtherPorts1":"5", ' +
            ' "FiberNumberOfPremises1":"4", ' +
            ' "FiberNumberOfHouseholds1":"3", ' +
            ' "FiberNumberOfPort1":"2", ' +
            ' "BuildAreaNetwork1":"1", ' +
            ' "Fastighetsnat1":"1", ' +
            ' "HeraNo1":"1111", ' +
            ' "NewProductionOfBuilding1":"3", ' +
            ' "ContractTerminationDate1":"2020", ' +
            ' "Promiseddeliverytime1":"2020",' +
            ' "WishedDeliveryDateCoax1":"1", ' +
            ' "WishedDeliveryDate1":"2020", ' +
            ' "ContractTerm1":"12", ' +
            ' "ExternalFiber":"Yes", ' +
            ' "ExternalOwnerName":"Test", ' +
            ' "OccupancyDate":"2020", ' +
            ' "Stage":"Test" },\n' +
            ' "Customer_Information": {' +
            ' "SellerName1":"Test1", ' +
            ' "SellerPhone1":"6666666", ' +
            ' "Business1":"Test", ' +
            ' "KONumber":"545454554", ' +
            ' "OrgNumber1":"45454545", ' +
            ' "ContractNumber1":"5555", ' +
            ' "SellerEmail1":"test@test.com", \n' +
            ' "AdditionalCustomerDetails": {' +
            ' "ContactPersonFSServicce":"Test124", ' +
            ' "ContactPersonMarketingMaterials":"Test12", ' +
            ' "PostalAddress":"Test12",' +
            ' "OutgoingCustomerOrgNr":"Test12", ' +
            ' "BillingAdress2":"Test12", ' +
            ' "OutgoingCustomer":"Test12",' +
            ' "BillingContact":"Test12", ' +
            ' "FiberBaseContractNumber1":"Test12", ' +
            ' "ContractNumber1":"Test12"},\n' +
            ' "ClientContactDetails": {' +
            ' "ContactEmail1":"Sweden", ' +
            ' "ContactPhone1":"55552", ' +
            ' "ContactName1":"Test12"},\n' +
            ' "BillingAdress1": {' +
            ' "BillingCountry1":"Sweden", ' +
            ' "BillingState1":"Sweden", ' +
            ' "BillingCity1":"Test",' +
            ' "BillingPostalCode1":"Test",' +
            ' "BillingStreet1":"Test"}}}\n' +
            '}';

        return jsonStr;
    }
}