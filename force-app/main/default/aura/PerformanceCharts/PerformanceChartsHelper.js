/**
 * Description:
 * Aura Lightning component is used in MyPerformance Aura component to display the
 * performance-related data in a chart format.
 *
 * Modifications:
 * 16.12.2022 [Tomass Brazovskis] SALEF-7206 - Accommodate for the removal of the Almond package.
 */
({
    
    setupChart : function(data, element){
        var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
        var dataSet = this.createDataset(data);                          
        var chartData = {
            labels: months,
            datasets: dataSet
        };
        var context = element.getContext("2d");
        return new Chart(context).Line(chartData, { responsive: true});   
        
    },

    /**
     * Description:
     * Modifications:
     *  16.12.2022 [TB] SALEF-7206 - Remove the action calling the Apex controller's getYearlyCompetenceScore(), as the objects
     *              storing the score information are being removed along with the the Almond package.
     **/ 
    loadCharts : function(component, yps) {
        var getContribution = component.get("c.getYearlyContributionScore");
        getContribution.setParams({ userId : yps.User_Performance__r.User__r.Id});
        getContribution.setCallback(this, function(response){
            var parsedData = JSON.parse(response.getReturnValue());
            if(!this.isEmpty(parsedData)){               
                var element = component.find("monthlyContributionChart").getElement();
                component.set("v.contChart", this.setupChart(parsedData, element));
            }else{
                component.set("v.contMissingData", true);
            }                    
        });
        $A.enqueueAction(getContribution);

        // SALEF-7206 - Competence score removed
        component.set("v.compMissingData", true);
    },
    
    isEmpty : function (obj) {
        for(var prop in obj) {
            if(obj.hasOwnProperty(prop))
                return false;
        }        
        return true;
    },
    
    createDataset : function (data){
        var dataset = [];
        var counter = 3;
        for(var prop in data){
            
            var color = "rgba(23, 151, 192," + counter / 10 + ")";
            dataset.push({
                label: prop,
                fillColor: color,
                strokeColor: color,
                pointColor: color,
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: color,
                data: data[prop]
            });
            counter = counter + 2;
        }
        
        return dataset;
    }   
})