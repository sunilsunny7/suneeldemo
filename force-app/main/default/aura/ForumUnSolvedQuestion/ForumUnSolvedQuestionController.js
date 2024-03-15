({
    doInit: function(component, event, helper) { 
        // Fetch the account list from the Apex controller   
        var map = {}; 
        var recordId = component.get('v.recordId'); 
        var action = component.get("c.getQuestionCatalogue"); 
        action.setCallback(this, function(response){      
            var state = response.getState();
            var result = response.getReturnValue();
            console.log(result);
            if (state === 'SUCCESS' && result.length != 0){
                map["Aff_rsm_jlighet"] = "Affärsmöjlighet";
                map["Inloggningsfr_gor"] = "Inloggningsfrågor";
                map["M_ten_H_ndelser_Uppgifter"] = "Möten/Händelser/Uppgifter";
                map["Rapporter_Instrumentpaneler"] = "Rapporter & Instrumentpaneler";
                map["S_kring"] = "Säkring";
                map["renden"] = "Ärenden";
                map["vrigt"] = "Övrigt";
                map["Business_Board"] = "Business Board";
                
                for (var i  in result){
                    result[i].DataCategoryName = map[result[i].DataCategoryName] != undefined ? map[result[i].DataCategoryName] : result[i].DataCategoryName;
                    console.log('Result:-'+result);
                }
                component.set("v.container",result);
                component.set("v.totalrec",result.length);
                component.set("v.displayBlock",true);
                var heightcount = 330+ (30*(result.length));
                if(heightcount > 450){
                    component.set("v.dynamicheight",450); 
                }else{
                    component.set("v.dynamicheight",heightcount);
                }
            }
            if (state === 'SUCCESS' && result.length == 0){
                component.set("v.displayBlock",false);
                component.set("v.totalrec",0);
            }
        });
        $A.enqueueAction(action);
        
        //Get the profile Header details
        var profileaction = component.get("c.getProfiledata");
        profileaction.setCallback(this, function(response){      
            var state = response.getState();
            if (state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                console.log(result);
                component.set("v.TotalQusCount", result['TotalQusCount']);
                component.set("v.BestAnsCount", result['BestAnsCount']);
                if(component.get('v.BestAnsCount') >= 0 && component.get('v.BestAnsCount') < 5){
                    var a = component.find("colorId");
                    $A.util.addClass(a, 'slds-badge');
                    $A.util.addClass(a, 'slds-colorOrange');
                    component.set("v.userrank","Rookie");
                }else if(component.get('v.BestAnsCount') >= 5 && component.get('v.BestAnsCount') < 10){
                    var a = component.find("colorId");
                    $A.util.addClass(a, 'slds-badge');
                    $A.util.addClass(a, 'slds-colorPurple');
                    component.set("v.userrank","Nybörjare");
                }else if(component.get('v.BestAnsCount') >= 10 && component.get('v.BestAnsCount') < 20){
                    var a = component.find("colorId");
                    $A.util.addClass(a, 'slds-badge');
                    $A.util.addClass(a, 'slds-colorBlue');
                    component.set("v.userrank","Lärling"); 
                }else if(component.get('v.BestAnsCount') >= 20 && component.get('v.BestAnsCount') < 35){
                    var a = component.find("colorId");
                    $A.util.addClass(a, 'slds-badge');
                    $A.util.addClass(a, 'slds-colorGreen');
                    component.set("v.userrank","Expert");
                }else if(component.get('v.BestAnsCount') >= 35 && component.get('v.BestAnsCount') < 50){
                    var a = component.find("colorId");
                    $A.util.addClass(a, 'slds-badge');
                    $A.util.addClass(a, 'slds-colorRed');
                    component.set("v.userrank","Magiker");
                }else if(component.get('v.BestAnsCount') >= 50){
                    var a = component.find("colorId");
                    $A.util.addClass(a, 'slds-badge');
                    $A.util.addClass(a, 'slds-colorBlack');
                    component.set("v.userrank","Ninja");
                }
            }
        });
        $A.enqueueAction(profileaction);
        
    },
    showSpinner : function (component, event, helper) {        
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-hide');
        $A.util.addClass(spinner, 'slds-show');  
    }
    ,
    hideSpinner  : function (component, event, helper) { 
        var spinner = component.find('spinner');
        $A.util.removeClass(spinner, 'slds-show');
        $A.util.addClass(spinner, 'slds-hide');    
    },
    gotoURL : function(component, event, helper) {
        var locUrl = "https://"+window.location.hostname+"/_ui/chatter/service/ChatterAnswersUi?c=09a240000004fNl&isdtp=nv";
        window.open(locUrl);
    }
})