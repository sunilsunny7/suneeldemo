/****************************************************************************************************************************
* @author                 Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @modifiedBy             Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @maintainedBy           Suneel Shivanna   <suneel.g-shivanna@capgemini.com>
* @version                1.0
* @created                2021-08-20
* @modified               2021-08-20
******************************************************************************************************************************/

trigger OrderTrigger on Order (after update) {
   MCOnline_OrderTriggerHandler.handerMethod(Trigger.old,Trigger.new,Trigger.oldMap,Trigger.newMap,Trigger.operationType);
}