({
    loadTables : function() {
        $('#req-table').dataTable().fnClearTable();
        $('#req-table').DataTable().destroy();
        
        var table = $('#req-table').DataTable({
            paging: true,
            select: {
                style: 'multi',
                selector: 'td:first-child'
            },    
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
                             targets:   [2,3,4,5,6],
                             render: function (data, type, row){
                                 if(data !== undefined){
                                     return ' <div class="slds-truncate">'+ data +'</div>' 
                                 }else{
                                     return ' <div class="slds-truncate"></div>' 
                                 }
                                 
                             }
                         },  
                         {
                             orderable: true,
                             targets:   [1],
                             render: function (data, type, row){
                                 return ' <div class="slds-truncate"><a href="/' + row.Id +'">' + data +'</a></div>' 
                             }
                         }, 
                        ],
                         columns: [
                         { "data": "IsConnected" },
                         { "data": "Name" },
                         { "data": "Description" },
                         { "data": "Status" },
                         { "data": "RelatedSolution" },
                         { "data": "OwnerAlias"},
                         { "data": "ExternalId"}
                         
                        ]});
        
        
    }
})