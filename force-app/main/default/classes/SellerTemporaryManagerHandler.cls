//*************************************************************************************************************************************
// Name             : SellerTemporaryManagerHandler Class
// Description      : Class to Replace a Manager with a temporary sales manager on certain criteria for may be certain period of time & 
//                    updating the user role in future method and when the Manager is back then updating the temporary sales manager 
//                    role as it was earlier. The Role of the temporary manager is updated in future method       
// Created By       : Shruti Singh
// Created Date     : 15 June 2016
//****************************************************************************************************************************************


public class SellerTemporaryManagerHandler {
   
    public static void updateTemporaryManageronSeller(List<Seller__c> newList, Map<Id, Seller__c> oldMap){
        Map<Id, Id> newTempMgrIdToReplacedManagerMap = new Map<Id, Id>();
        Map<Id, Id> oldTempMgrIdToReplacedManagerMap = new Map<Id, Id>();
        Set<Id> oldTempMgrIds = new Set<Id>();

        List<Seller__c> sellerUpdateList = new List<Seller__c>();
        List<User> userUpdateList = new List<User>();
                
        for(Seller__c s : newList){
            Seller__c oldSeller = oldMap.get(s.Id);

            // The temporary manager is set/updated for a Manager, and Has_Been_Replaced is checked
            if(s.Temporary_Manager__c != oldSeller.Temporary_Manager__c && s.Has_Been_Replaced__c)   {
                if(s.Type__c == SellerTriggerHandler.SELLER_TYPE_SELLER) s.addError('You can only set Temporary Manager for managers and not for sellers.');
                else{
                    if(s.Temporary_Manager__c != null) newTempMgrIdToReplacedManagerMap.put(s.Temporary_Manager__c, s.Id);
                    if(oldSeller.Temporary_Manager__c != null) oldTempMgrIds.add(oldSeller.Temporary_Manager__c);
                }
            }
        }

        if(!newTempMgrIdToReplacedManagerMap.isEmpty()){
            // Load User Role for all the Managers
            Map<Id, Seller__c> managersUserRoleMap = new Map<Id, Seller__c>([SELECT Id, User__c, User__r.UserRoleId FROM Seller__c  WHERE Id IN :newTempMgrIdToReplacedManagerMap.values()]);
            
            // Set the Temporary Manager details for the Sellers who is to become Temp Mgr, and update user role for the related User record
            for(Seller__c newTempMgr : [SELECT Id, Is_Temporary_Manager__c, Replaced_Manager_Lookup__c, User__c, User__r.UserRoleId FROM Seller__c WHERE Id IN :newTempMgrIdToReplacedManagerMap.keySet()]){
                newTempMgr.Replaced_Manager_Lookup__c = newTempMgrIdToReplacedManagerMap.get(newTempMgr.Id);
                newTempMgr.Temporary_Manager_Old_Role_Id__c = newTempMgr.User__r.UserRoleId;
                newTempMgr.Is_Temporary_Manager__c = true;
                sellerUpdateList.add(newTempMgr);
                // Update the User who is temporary manager to have the User Role of the Manager who has been replaced
                userUpdateList.add(new User(Id = newTempMgr.User__c, UserRoleId = managersUserRoleMap.get(newTempMgr.Replaced_Manager_Lookup__c).User__r.UserRoleId));
                // Update the User for the replaced manager to have the User role of the temporary manager
                userUpdateList.add(new User(Id = managersUserRoleMap.get(newTempMgr.Replaced_Manager_Lookup__c).User__c, UserRoleId = newTempMgr.User__r.UserRoleId));
            }
        }

        if(!oldTempMgrIds.isEmpty()){
            // Reset the Temporary Manager details and user role for the Seller who was previously Temp Mgr
            for(Seller__c oldTempMgr : [SELECT Id, Is_Temporary_Manager__c, Replaced_Manager_Lookup__c, User__c, Temporary_Manager_Old_Role_Id__c FROM Seller__c WHERE Id IN :oldTempMgrIds]){
                userUpdateList.add(new User(Id = oldTempMgr.User__c, UserRoleId = oldTempMgr.Temporary_Manager_Old_Role_Id__c));
                oldTempMgr.Replaced_Manager_Lookup__c = null;
                oldTempMgr.Temporary_Manager_Old_Role_Id__c = null;
                oldTempMgr.Is_Temporary_Manager__c = false;
                sellerUpdateList.add(oldTempMgr);
            }
        }

        if(!sellerUpdateList.isEmpty()){
            try {
                update sellerUpdateList;
                if(!userUpdateList.isEmpty()) updateUserRoleId(JSON.serialize(userUpdateList));
            } catch(Exception e) {
                System.debug('SellerTemporaryManagerHandler.updateTemporaryManageronSeller. The following exception has occurred: ' + e.getMessage());
            }
        }
    }

    // Author AN: When checbox Go_Back_to_Original_Manager__c is checked on a seller which is temp manager,
    // reset the temp. manager fields on Seller + Manager-Seller and reset the users User Role.
    public static void goBackToOriginalManager(List<Seller__c> newList, Map<ID, Seller__c> oldMap){
        List<Seller__c> sellerUpdateList = new List<Seller__c>();
        List<User> userUpdateList = new List<User>();
                
        for(Seller__c s : newList){
            // Go_Back_to_Original_Manager is checked
            if(s.Go_Back_to_Original_Manager__c == true && oldMap.get(s.Id).Go_Back_to_Original_Manager__c == false){
                // Reset the temp manager fields for the original Manager
                if(s.Replaced_Manager_Lookup__c != null)
                    sellerUpdateList.add(new Seller__c(Id = s.Replaced_Manager_Lookup__c, Temporary_Manager__c = null, Has_Been_Replaced__c = false));

                if(s.Temporary_Manager_Old_Role_Id__c != null)
                    userUpdateList.add(new User(Id = s.User__c, UserRoleId = s.Temporary_Manager_Old_Role_Id__c));
                
                // Reset the temp manager fields on the seller record
                s.Replaced_Manager_Lookup__c = null;
                s.Temporary_Manager_Old_Role_Id__c = null;
                s.Is_Temporary_Manager__c = false;
                s.Go_Back_to_Original_Manager__c = false;
            }
        }

        if(!sellerUpdateList.isEmpty()){
            try{ 
                update sellerUpdateList;
                if(!userUpdateList.isEmpty()) updateUserRoleId(JSON.serialize(userUpdateList));
            } catch(Exception e){ 
                System.debug('SellerTemporaryManagerHandler.goBackToOriginalManager. The following exception has occurred: ' + e.getMessage());
            }
        }
    }

    public static void updateManagerRole(List<Seller__c> newList, Map<Id, Seller__c> oldMap){
        List<Seller__c> managersReplacedTemporarilyList = new List<Seller__c>();
        List<User> userUpdateList = new List<User>();
                
        for(Seller__c s : newList){
            // The Temporary manager is set for a Manager, need to update the Temporary_Manager_Old_Role_Id__c on Seller record
            if(s.Temporary_Manager__c != null && oldMap.get(s.Id).Temporary_Manager__c == null){
                managersReplacedTemporarilyList.add(s);
            // The Temporary manager is reset for a Manager, need to update user back to original (Manager) user role
            } else if(s.Temporary_Manager__c == null && oldMap.get(s.Id).Temporary_Manager__c != null){
                System.debug('XYLØ for manager seller: ' + s.Id + ', resetting user role to: ' + s.Temporary_Manager_Old_Role_Id__c);
                userUpdateList.add(new User(Id = s.User__c, UserRoleId = s.Temporary_Manager_Old_Role_Id__c));
                s.Temporary_Manager_Old_Role_Id__c = null;
            }
        }

        if(!managersReplacedTemporarilyList.isEmpty()){
            // Fetch the managers User role
            Map<Id, Seller__c> mgrMapWithUserRoles = new Map<Id, Seller__c>([SELECT Id, User__r.UserRoleId FROM Seller__c WHERE Id IN :managersReplacedTemporarilyList]);
            for(Seller__c s : managersReplacedTemporarilyList){
                s.Temporary_Manager_Old_Role_Id__c = mgrMapWithUserRoles.get(s.Id).User__r.UserRoleId;
                System.debug('XYLØ for manager seller: ' + s.Id + ', Temporary_Manager_Old_Role_Id__c id: ' + s.Temporary_Manager_Old_Role_Id__c);
            }
        }

        if(!userUpdateList.isEmpty()) updateUserRoleId(JSON.serialize(userUpdateList));
    }
    
    @future private static void updateUserRoleId(String userListToUpdate){
       List<User> userList = (List<User>) JSON.deserialize(userListToUpdate,List<User>.class);
       System.debug('-listofUserRoleToUpdate-'+userList);
       if(!userList.isEmpty()){
            try{
                update userList;   
            } catch(Exception e){
                System.debug('SellerTemporaryManagerHandler.updateUserRoleId. The following exception has occurred: ' + e.getMessage());  
            }
       }
   }
}