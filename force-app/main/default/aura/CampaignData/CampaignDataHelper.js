({
    loadTables : function() {
        $('#campaign-data-table').DataTable({
            paging: true,
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
                }
            },
            columns: [
                { "data": "Key"},
                { "data": "Value"}
                
            ]
        });
    }
})