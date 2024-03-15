({
    getAccountData : function(component){
        //Load the Account data from apex
        var action = component.get("c.getMobilRecordsWithParam");
        action.setParams({  accId : component.get("v.recordId")  });
        var recurrence = false;
        var toastReference = $A.get("e.force:showToast");
        var toastReference1 = $A.get("e.force:showToast");
        component.set("v.loading",true);
		
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                var accountWrapper = response.getReturnValue();
                
                if(accountWrapper != null && accountWrapper.mobilabonnemangList != null && accountWrapper.mobilabonnemangList.length >= 0){
                    //Setting data to be displayed in table
                    component.set("v.accountData",accountWrapper.mobilabonnemangList);
                    component.set("v.accountDataToSearch",accountWrapper.mobilabonnemangList);
                    component.set("v.accountName",accountWrapper.accountName);
                    toastReference.setParams({
                        "type" : "Success",
                        "title" : "Success",
                        "message" : accountWrapper.mobilabonnemangList.length+' Subscription Found.',
                        "mode" : "dismissible"
                    });
                    component.set("v.loading",false);
                } // handel server side erroes, display error msg from response 
                else{
                    component.set("v.loading",false);
                    toastReference.setParams({
                        "type" : "Error",
                        "title" : "Error",
                        "message" : 'Please  Contact Administrator...',
                        "mode" : "dismissible"
                    }); 
                }
            } // handel callback error 
            else{
                toastReference.setParams({
                    "type" : "Error",
                    "title" : "Error",
                    "message" : 'An error occurred during initialization '+state,
                    "mode" : "dismissible"
                });
            }
            toastReference.fire();
        });
        $A.enqueueAction(action);
    },
    sortData : function(component,fieldName,sortDirection){
        var data = component.get("v.accountData");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'NumberOfEmployees'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else{// to handel text type fields 
            data.sort(function(a,b){ 
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        //set sorted data to accountData attribute
        component.set("v.accountData",data);
    },
	
	convertArrayOfObjectsToCSV : function(component, objectRecords){
        // declare variables
        var csvStringResult, counter, keys, columnDivider, lineDivider;
       debugger;
        // check if "objectRecords" parameter is null, then return from function
        if (objectRecords == null || !objectRecords.length) {
            return null;
         }
        // store ,[comma] in columnDivider variabel for sparate CSV values and 
        // for start next line use '\n' [new line] in lineDivider varaible  
        columnDivider = ',';
        lineDivider =  '\n';
 
        // in the keys valirable store fields API Names as a key
        // this labels use in CSV file header
        keys = ['Telefonnummer','Användare','Abonnemang','Subventionerat avtal','Bindningstid kvar','Kan bindas om','Avtalsnummer','Bindningstid','Startdatum','Slutdatum','Abonnemangstyp','Telefon'];
        var headerMap = new Map();
        headerMap.set('Telefonnummer', 'Subscription_Id__c');
        headerMap.set('Användare', 'TeliaSE_User_Name__c');
        headerMap.set('Abonnemang', 'TeliaSE_Subscription_Name__c');
        headerMap.set('Subventionerat avtal', 'Subsidized_Subscription__c');
        headerMap.set('Bindningstid kvar', 'Binding_Time_Left__c');
        headerMap.set('Kan bindas om', 'Allowed_To_Bind__c');
        headerMap.set('Avtalsnummer', 'Agreement__c');
        headerMap.set('Bindningstid', 'CommitmentLength__c');
        headerMap.set('Startdatum', 'Start_Date__c');
        headerMap.set('Slutdatum', 'CommitmentEndDate__c');
        headerMap.set('Abonnemangstyp', 'Subscription_Type__c');
        headerMap.set('Telefon', 'Last_Used_Model__c');
        
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
 		//var objectRecords=component.get("v.finalListToAdd");
 		var objectRecords=component.get("v.accountDataToSearch");
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
           debugger;
             for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;  
 
              // add , [comma] after every String value,. [except first]
                  if(counter > 0){ 
                      csvStringResult += columnDivider; 
                   }   
               debugger;
                 var value = objectRecords[i][headerMap.get(skey)] == '' || objectRecords[i][headerMap.get(skey)] == undefined ? '' : objectRecords[i][headerMap.get(skey)];
               csvStringResult += '"'+ value+'"'; 
               
               counter++;
 
            } // inner for loop close 
             csvStringResult += lineDivider;
          }// outer main for loop close 
       
       // return the CSV formate String 
        return csvStringResult;        
    },
})