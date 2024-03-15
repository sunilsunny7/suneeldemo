@isTest
private class Test_JsonParser {

    public static testmethod void jsonMethod() {
        Test.StartTest();
        JsonParser js = new JsonParser();
        js.coverage = 'abc';
        js.MDUIPTVName = new List < String > {'test1','test2'};
        js.MDUIPTVNDFName = new List < String > {'test3','test4'};
        js.MDUCOAXTVName = new List < String > {'test5','test6'};
        js.MDUCHT1707Name = new List < String > {'test7','test8'};
        js.MDUSHName = new List < String > {'test7','test8'};

        JsonParser.Store s = new JsonParser.Store();

        s.TypeOfInstallationHelp1 = 'test';
        s.Is_MDULES1729 = 'test';
        s.KoperNumberOfPremises1 = 'test';
        s.KoperNumberOfHouseholds1 = 'test';
        s.KoperNumberOfOtherPorts1 = 'test';
        s.KoperNumberOfPort1 = 'test';
        s.Quantity_MDULES1729 = 'test';
        s.FiberNumberOfOtherPorts1 = 'test';
        s.FiberNumberOfPremises1 = 'test';
        s.FiberNumberOfPort1 = 'test';
        s.FiberNumberOfHouseholds1 = 'test';
        s.BuildAreaNetwork1 = 'test';
        s.HeraNo1 = 'test';
        s.Fastighetsnat1 = 'test';
        s.NewProductionOfBuilding1 = 'test';
        s.ExternalFiber = 'test';
        s.ExternalOwnerName = 'test';
        s.ContractTerm1 = '123';
        s.OccupancyDate = 'test';
        s.WishedDeliveryDate1 = 'test';
        s.Stage = 'test';
        s.WishedDeliveryDateCoax1 = 'test';
        s.SurfZone = 'test';
        s.ContractTerminationDate1 = 'test';
        
        JsonParser.FlitDetailsList f = new JsonParser.FlitDetailsList();
        f.Address='test';
        f.NumberOfApartments='test';
        f.Price='test';
        
        JsonParser.Other o = new JsonParser.Other();
        //JsonParser.FlitDetails odf = new JsonParser.FlitDetails();
        o.StationsName='test';
        o.OtherInformation='test';
        o.Customer_OwnedNetwork='test';
        Test.StopTest();
    }
        
}