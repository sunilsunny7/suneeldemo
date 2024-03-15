({
    loadTables : function() {
        $('#account-table').DataTable({
            paging: true,
            select: {
                style: 'multi',
                selector: 'td:first-child'
            }, 
			scrollY:        "257px",
            scrollCollapse: false,
            lengthMenu: [ [5, 10, 25, 50, -1], [5, 10, 25, 50, "Alla"] ],
            language:    {
                "decimal":        "",
                "emptyTable":     "Ingen data tillgänglig",
                "info":           "Visar _START_ till _END_ av _TOTAL_ poster",
                "infoEmpty":      "Visar 0 till 0 av 0 poster",
                "infoFiltered":   "(filtrerad från _MAX_ totala poster)",
                "infoPostFix":    "",
                "thousands":      ",",
                "lengthMenu":     "Visa _MENU_ poster",
                "loadingRecords": "Laddar...",
                "processing":     "Tänker...",
                "search":         "Sök:",
                "zeroRecords":    "Inga matchningar",
                "paginate": {
                    "first":      "Första",
                    "last":       "Sista",
                    "next":       "Nästa",
                    "previous":   "Föregående"
                },
                "aria": {
                    "sortAscending":  ": Aktivera för att sortera kolumn stigande",
                    "sortDescending": ": Aktivera för att sortera kolumn fallande"
                },
                select: {
           		    rows: "%d exkluderade konton"
                }
            },
            columnDefs: [ {
                orderable: false,
                targets:   0,
                render: function (data, type, row){
                    return '<span class="slds-checkbox--add-button">' +
                        '<input type="checkbox" class="slds-assistive-text" name="options"  />' +
                        '<label class="slds-checkbox__label" >' +
                        '<span class="slds-checkbox--faux"></span>' +
                        '</label>' +
                        '</span>';
                }
            }, 
                         {
                             orderable: true,
                             targets:   [1,2,3],
                             render: function (data, type, row){
                                 if(data != undefined){
                                     return ' <div class="slds-truncate">'+ data +'</div>' 
                                 }else{
                                     return ' <div class="slds-truncate"></div>' 
                                 }
                             }
                         }, 
                        ],
                         columns: [
                         { "data": "Id"},
                         { "data": "Parent.Name"},
                         { "data": "Name" },
                         { "data": "Org_Nr__c" },
                         { "data": "Aregion__c" }
                         
                        ]});
        
        
    },
    
    getJsonKeyAccountIds : function(keyAccs){ 
        var keyAccsId = [];
        
        for(var i = 0; i < keyAccs.length; i++){
            keyAccsId.push(keyAccs[i].KeyAccount.Id);
        }
        
        return JSON.stringify(keyAccsId);
    },
    
    getJsonExcludedAccounts : function(excludedAccs){
        var exIds = [];
        
        for(var i = 0; i < excludedAccs.length; i++){
            exIds.push(excludedAccs[i].Id);
        }
        
        return JSON.stringify(exIds); 
    }
})