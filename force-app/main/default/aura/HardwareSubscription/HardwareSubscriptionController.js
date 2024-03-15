({
    /*
    MSISDN__c, Agreement__c, Category__c, Subscription_Type__c, Offering_Name__c, 
    GPRS_Service_Allowance__c, Roaming_Service_Descr__c, Start_Date__c, Account__c
    */
    onInit : function(component,event,helper){
        // Setting column information.To make a column sortable,set sortable as true on component load
        component.set("v.accountColumns",[
            {
                label : 'Telefonnummer',
                fieldName : 'Subscription_Id__c',
                type : 'text',
                sortable : true
            },
            {
                label : 'Användare',
                fieldName : 'TeliaSE_User_Name__c',
                type : 'text',
                sortable : true
            },
            {
                label : 'Abonnemang',
                fieldName : 'TeliaSE_Subscription_Name__c',
                type : 'text',
                sortable : true
            }, 
			{
                label : 'Subventionerat avtal',
                fieldName : 'Subsidized_Subscription__c',
                type : 'text',
                sortable : true
            },
			 {
                label : 'Bindningstid kvar',
                fieldName : 'Binding_Time_Left__c',
                type : 'text',
                sortable : true
            },
			 {
                label : 'Kan bindas om',
                fieldName : 'Allowed_To_Bind__c',
                type : 'text',
                sortable : true
            },
			{
                label : 'Avtalsnummer',
                fieldName : 'Agreement__c',
                type : 'text',
                sortable : true
            },
			{
                label : 'Bindningstid',
                fieldName : 'CommitmentLength__c',
                type : 'text',
                sortable : true
            },
			{
                label : 'Startdatum',
                fieldName : 'Start_Date__c',
                type : 'text',
                sortable : true
            },
			{
                label : 'Slutdatum',
                fieldName : 'CommitmentEndDate__c',
                type : 'text',
                sortable : true
            },
			{
                label : 'Abonnemangstyp',
                fieldName : 'Subscription_Type__c',
                type : 'text',
                sortable : true
            },
            {
                label : 'Telefon',
                fieldName : 'Last_Used_Model__c',
                type : 'text',
                sortable : true
            }
            
        ]);
        // call helper function to fetch account data from apex
        helper.getAccountData(component);
    },
    
    //Method gets called by onsort action,
    handleSort : function(component,event,helper){
        //Returns the field which has to be sorted
        var sortBy = event.getParam("fieldName");
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortBy",sortBy);
        component.set("v.sortDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection);
    },
    
    searchTable : function(cmp,event,helper) {
        var allRecords = cmp.get("v.accountDataToSearch");
        var searchFilter = event.getSource().get("v.value").toUpperCase();
        debugger;
        var tempArray = [];
        var i;

        for(i=0; i < allRecords.length; i++){
            if((allRecords[i].MSISDN__c && allRecords[i].MSISDN__c.toUpperCase().indexOf(searchFilter) != -1) ||
               (allRecords[i].Subscription_Id__c && allRecords[i].Subscription_Id__c.toUpperCase().indexOf(searchFilter) != -1) ||
               (allRecords[i].Agreement__c && allRecords[i].Agreement__c.toUpperCase().indexOf(searchFilter) != -1 ) ||
               (allRecords[i].Subscription_Type__c && allRecords[i].Subscription_Type__c.toUpperCase().indexOf(searchFilter) != -1 ) ||
               (allRecords[i].Offering_Name__c && allRecords[i].Offering_Name__c.toUpperCase().indexOf(searchFilter) != -1 ) || 
               (allRecords[i].Category__c && allRecords[i].Category__c.toUpperCase().indexOf(searchFilter) != -1 ) )
            {
                tempArray.push(allRecords[i]);
            }
        }
        cmp.set("v.accountData",tempArray);
    },
	
	// ## function call on Click on the "Download As CSV" Button. 
    downloadCsv : function(component,event,helper){
        
        // get the Records list from 'accountDataToSearch' attribute 
        var accData = component.get("v.accountDataToSearch");
        //debugger;
		console.log('accountDataToSearch : '+accData);
		//var allSelectedCase=component.get("v.CaseList");
        var accListAdd=[];
        for(var i=0;i < accData.length;i++)
            {
                //if(accData[i].check==true)
                //{
                 
                    accListAdd.push(accData[i].obj);

                //}
             
            }
        component.set("v.finalListToAdd",accListAdd);
        var finalListToDownload=component.get("v.finalListToAdd");
		// call the helper function which "return" the CSV data as a String   
        var csv=helper.convertArrayOfObjectsToCSV(component,accListAdd); 
        
        
         if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = 'ExportData.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
        }, 
})