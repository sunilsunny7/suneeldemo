global class MC_RunIntegrationProcedure
{
    global static void runFutureIp(String procedureName,Map <String, Object> ipInput,Map <String, Object> ipOptions)
    {
        vlocity_cmt.IntegrationProcedureService.runIntegrationServiceFuture(procedureName,Json.serialize(ipInput), Json.serialize(ipOptions));
    }
    
    global static void runQueueableIp(String procedureName,Map <String, Object> ipInput,Map <String, Object> ipOptions)
    {
        vlocity_cmt.IntegrationProcedureService.runIntegrationProcedureQueueable(procedureName,ipInput,ipOptions);
    }
}