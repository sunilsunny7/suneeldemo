({
  toggleSection: function(component, event, helper) {
    if (!component.get("v.isSidebarCollapsed")) {
      var cmpTarget = component.find('changeIt');
      $A.util.removeClass(cmpTarget, 'slds-size_8-of-12');
      $A.util.addClass(cmpTarget, 'slds-size_12-of-12');
    }else{
      var cmpTarget = component.find('changeIt');
      $A.util.removeClass(cmpTarget, 'slds-size_12-of-12');
      $A.util.addClass(cmpTarget, 'slds-size_8-of-12');
    }
    component.set("v.isSidebarCollapsed",!component.get("v.isSidebarCollapsed")
    );
  }
});