public class testHookclass {
    public static Map < String, Object > getOffer(Map<String,Object> output){
        Object offers = output.get('offers');
        Map<String, Object> bodyData = new Map<String, Object> {
            'bulkUpload' => false,
            'bundleName' => 'OffersTransformer', //name of the transformer
            'debug' => false,
            'objectList' => new List<Object> { output }
        };
        Map<String, Object> re = (Map<String, Object>) vlocity_cmt.DRGlobal.processPost(bodyData);
        Map<String, Object> resultsData = (Map<String, Object>)re.get('returnResultsData');
        output.put('offers', resultsData.get('offers'));
        return output ;
    }
}