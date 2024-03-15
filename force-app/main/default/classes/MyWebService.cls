global class MyWebService {
    webservice static String makeContact(String contactLastName) {
        String email =[select email from Contact where Name=:contactLastName limit 1]?.email;
        return String.isBlank(email)?'No email found for '+contactLastName:'Email for is '+contactLastName+' '+email;
    }
}