/**
 * Created by kwn687 on 2023-01-02.
 */

({
  handleClose: function (component, event, helper) {
    $A.get("e.force:refreshView").fire();
    $A.get("e.force:closeQuickAction").fire();
  }
});