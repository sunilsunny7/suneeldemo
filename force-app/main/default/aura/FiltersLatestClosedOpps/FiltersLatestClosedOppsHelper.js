({
    /**
     * Description:
     * Fire FilterChangeLatestClosedOpps-type event,
     * setting the User-selected values as params.
     * Modifications:
     * 26.06.2023 [TB] LTAT-10218 - Introduced.
     **/
    fireFilterChangeEvent : function(component) {
        var rangeChangeEvent = component.getEvent('filterChange');
        rangeChangeEvent.setParams({
            filterByRegion: component.find('filterByRegion').get("v.value")
        });
        rangeChangeEvent.fire();
    }
})