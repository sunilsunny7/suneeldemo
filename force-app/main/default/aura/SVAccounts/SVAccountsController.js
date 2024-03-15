({
    showSpinner : function (component, event, helper) {        
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-show');      
    },
    
    hideSpinner  : function (component, event, helper) {
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-show');
        $A.util.addClass(spinner,  'slds-hide');    
    },
    
    update : function (component, event, helper) {
        $('#acc-table').DataTable().destroy(true);
    },
    
    afterScriptsLoaded: function (component, event, helper){
        var table = $('#acc-table').DataTable({
            paging: false,
            select: {
                style: 'multi',
                selector: 'td:first-child'
            },    
            searching: false,
            columnDefs: [{
                orderable: true,
                targets:   [1],
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
                             targets:   [0],
                             render: function (data, type, row){
                                 return ' <div class="slds-truncate"><a href="/' + row.Id +'">' + data +'</a></div>' 
                             }
                         }, 
                         
                        ],
                         columns: [
                         { "data": "Name" },
                         { "data": "Business_unit__c" }
                        ]});
        
        var recordId = component.get('v.recordId');
        var action = component.get("c.getAccounts");
        action.setParams({ solutionId : recordId}); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            if (state === 'SUCCESS'){
                if(response.getReturnValue().length > 0){
                    component.set("v.Accounts", response.getReturnValue());
                    $('#acc-table').dataTable().fnAddData(response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(action); 
        
    }
})