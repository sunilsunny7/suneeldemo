public class PriceMatrixAPICallMock implements HttpCalloutMock {
    public HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
		res.setBody('[{"REC_MNTH_DISC_PERCENTAGE":0.00,"REC_MNTH_CM_MANDATE_DISC":0.00,"REC_MNTH_SD_MANDATE_DISC":0.00,"REC_MNTH_SM_MANDATE_DISC":0.00,"REC_MNTH_AM_MANDATE_DISC":0.00,"REC_MNTH_STD_PRC":250.00,"OT_STD_PRC":0.00,"PriceMatrix_24M_Hardware__TargetProductName":"OnePlus 8 128GB Glacial Green","PriceMatrix_24M_Hardware__PricePlanCode":"NA","PriceMatrix_24M_Hardware__MCCMMandateDiscount":0.0,"PriceMatrix_24M_Hardware__MCSDMandateDiscount":0.0,"PriceMatrix_24M_Hardware__MCSMMandateDiscount":0.0,"PriceMatrix_24M_Hardware__MCAMMandateDiscount":0.0,"PriceMatrix_24M_Hardware__MCDiscountPercentage":0.0,"PriceMatrix_24M_Hardware__NRC":"0","PriceMatrix_24M_Hardware__MRC":"250","ID":"input"}]');
        res.setStatusCode(200);
        return res;
    }
}