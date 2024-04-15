baseCtrl.prototype.$scope.calculateProgressWidth = function() {
     if($('.slds-progress__list').find('.nds-progress__visited').length>0)
          return $('.slds-progress__list').find('.nds-progress__visited').last().position().left + 15;
}