console.log('QOL DET FOR THIS EXECUTION ', this.quote);
        /*if(this.omniJsonData) {
            let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
            updateOmniJsonData.ProductGroupQuantity = this.quote;
            this.omniApplyCallResp(updateOmniJsonData);
        }*/
        console.log('before EXECUTION' , SuccessFlag);
        
        this.quote.forEach(element => {
            var sumUp=0;
            element['Groups'].forEach(ele => {
                sumUp = sumUp + Number(ele.Quantity);
            });
            console.log('Sum :=>',sumUp);
            console.log('Fa Quantity =>',Number(element.FACallOffQuantity) );
            if(sumUp !== Number(element.FACallOffQuantity)){
                SuccessFlag = 0;
            }
        });

        console.log('AFTER EXECUTION' , SuccessFlag);
        // for(var i in items){
        //     console.log('item on submit',items[i]);
        //     var faQuantity =items[i].FACallOffQuantity;
            
        //     var sum= 0;
        //     for(var j in items[i]['Groups']){
        //         if(items[i]['Groups'][j]['Quantity'] = ""){
        //             sum =sum + 0;
        //         }else{
        //             sum =sum + items[i]['Groups'][j]['Quantity'];
        //         }
                
        //     }

        //     console.log('FA :',faQuantity);
        //     console.log('SUM :',sum);
            
        //     if(sum!=faQuantity){
        //         SuccessFlag=0;
        //         alert('Kindly Enter the Valid Group Quantities for the mentioned Products');
        //         return;
        //     }else{
        //         SuccessFlag = 1;
        //     }
        // }