global class MC_SCUserValidation implements vlocity_cmt.VlocityOpenInterface
{
    /*
inputs - arguments - List<Object> of passed in arguments
output - result - The result of the Function being called. Supports single Object values, List<Object> or Map<String, Object>
*/
    global Boolean invokeMethod(String methodName, Map<String, Object> inputs, Map<String, Object> output, Map<String, Object> options)
    {
        // SUM Returns a single value
        if (methodName == 'SCUserValidationFunc')
        {            
            output.put('result', SCUserValidationFunc());
        }
        return true;
    }
    public static Boolean  SCUserValidationFunc(){
        String userName=UserInfo.getUserName();
        // String profileName=(([select Name from Profile where id= :UserInfo.getProfileId()])[0]).Name;
        System.debug(userName);
        List<String> validatedUsers=new List<String>();
        //UserValidationCodes__mdt userValidCode= UserValidationCodes__mdt.getInstance('SC_OFFER');
        String userValidCode=([select UserList__c from UserValidationCodes__mdt where label='SC_OFFER'])[0].UserList__c;
        //List<UserValidationCodes__mdt> userValidList=UserValidationCodes__mdt.getAll().values();
        //String userValidCode=userValidList[0].UserList__c;
        System.debug(userValidCode);
        validatedUsers=userValidCode.split(',');
        if(validatedUsers.contains(userName)){
            System.debug('found user');
            return true;
        }else{
            System.debug('not found');
            return false;
        }
    }
}