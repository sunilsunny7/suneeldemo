import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { NavigationMixin } from 'lightning/navigation';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class COProductGroup extends OmniscriptBaseMixin(NavigationMixin(LightningElement)) {
   @track addOnBenefitsArray = new Array();
   @track addOnBenefits2=[];
   @track isModalOpen;
   @track isModalOpen2;
   @track systemAdminProfile=false;
   @track recordsFound=false;
   footTableSelected=false;    
   resultArray={"TargetId":"","TargetComments":"","Used":"","SendMail":""};
   connectedCallback() {
   this.addOnBenefits2=this.omniJsonData.AddOnBenefits;
   this.addOnBenefitsArray=JSON.parse(JSON.stringify(this.addOnBenefits2));
   if(this.addOnBenefitsArray.length>0){
      this.addOnBenefitsArray.forEach(element => {
      element.isSelected=false;
      });
    this.recordsFound=true;
    }else{
            this.recordsFound=false;
            console.log('Cannot proceed');
          }
           
          if(this.omniJsonData.userProfile=='System Administrator'){
               this.systemAdminProfile=true;
          }       
       }
      

        handleChange(event){
            this.resultArray.TargetComments =="";
          this.resultArray.TargetId=event.target.value;
          this.resultArray.Used=true;
          this.footTableSelected=false;
          for(var i=0;i<this.addOnBenefitsArray.length;i++){
             if(this.addOnBenefitsArray[i].Id==this.resultArray.TargetId){
                this.addOnBenefitsArray[i].disableEnable=false;
                this.addOnBenefitsArray[i].isSelected=true;
             }else{
                this.addOnBenefitsArray[i].disableEnable=true;
                this.addOnBenefitsArray[i].isSelected=false;
             }
            // if(this.addOnBenefitsArray[i].Id==this.resultArray.TargetId){// && this.resultArray.TargetComments ==""  && this.addOnBenefitsArray[i].Comments !=undefined && this.addOnBenefitsArray[i].Comments !=""
            //     console.log('Inside if');
            //   this.resultArray.TargetComments=this.addOnBenefitsArray[i].Comments;
            // }
           }
       }

         handleChangeForFootTable(event){
           
            this.resultArray.TargetId=event.target.value;
            for(var i=0;i<this.addOnBenefitsArray.length;i++){
              if(this.addOnBenefitsArray[i].Id==event.target.value ){//&& this.addOnBenefitsArray[i].Comments !=undefined){
                this.addOnBenefitsArray[i].isSelected=true;
                this.resultArray.TargetComments=this.addOnBenefitsArray[i].Comments;
              }else{
                this.addOnBenefitsArray[i].isSelected=false;
              }
            }
            this.resultArray.Used=false;
            this.footTableSelected=true;

         }
        changeComments(event){
    //  console.log('event in comm->'+JSON.stringify(event.target.value));
    //   console.log('event in comm id at 28->'+JSON.stringify(event.target.id).split("-"));

    //  console.log('event in comm id at 30->'+(JSON.stringify(event.target.id).split("-"))[0]);
     for(var p=0;p<this.addOnBenefitsArray.length;p++){
         if(this.addOnBenefitsArray[p].Id==((event.target.id).split("-"))[0]){
            this.addOnBenefitsArray[p].Comments=event.target.value;
            this.resultArray.TargetComments=event.target.value;
         }
     }
    // if(this.resultArray.TargetId==((event.target.id).split("-"))[0]){
    //     console.log('inside if');
    //     this.resultArray.TargetComments=event.target.value;
    // }
 // console.log('result array'+JSON.stringify(this.resultArray));

    }
        saveValues(){
            if(this.footTableSelected==true){
                this.isModalOpen2=true;
            }else{
                
                if(this.systemAdminProfile==true){
                 this.submitDetailsForSystemAdmin();
                }else{
                for(var q=0;q<this.addOnBenefitsArray.length;q++){
                    if(this.addOnBenefitsArray[q].isSelected==true){
                      if(this.addOnBenefitsArray[q].Comments !="" && this.addOnBenefitsArray[q].Comments !=undefined){
                        this.isModalOpen=true;
                      }else{
                        const toastEve=new ShowToastEvent({
                            title: 'Error',
                        message: 'Kommentarsfältet är obligatoriskt. Uppdatera kommentarsfältet för att gå vidare.',
                            variant: 'error',
                         });
                         this.dispatchEvent(toastEve);
                      }
                    }
                }

                    // if(this.resultArray.TargetId !=""){
                    //     if(this.resultArray.TargetComments !=""){
                    //         this.isModalOpen=true;
                    //     }
                    // else{
                    //     const toastEve=new ShowToastEvent({
                    //         title: 'Error',
                    //     message: 'Endast samma typ av fömån kan väljas för att skickas till ansvarigt Order-team.Klicka på OK för att gå tillbaka och välja vilken/vilka förmåner du vill skicka.',
                    //         variant: 'error',
                    //      });
                    //      this.dispatchEvent(toastEve);

                    // }
                }
                    
                }
            }
            
           
        
       
        closeModal(){
            this.isModalOpen=false;
            this.isModalOpen2=false;
        }
        
        submitDetails(){
           // console.log('resultarray in submit detail'+this.resultArray);
            this.isModalOpen = false;

            for(var a=0;a<this.addOnBenefitsArray.length;a++){
                if(this.addOnBenefitsArray[a].isSelected==true && this.addOnBenefitsArray[a].Comments!="" && this.addOnBenefitsArray[a].Comments!=undefined){
                 this.resultArray.TargetId=this.addOnBenefitsArray[a].Id;
                 this.resultArray.TargetComments=this.addOnBenefitsArray[a].Comments;
                 this.resultArray.SendMail=true;
                 let updateOmniJsonData1=JSON.parse(JSON.stringify(this.omniJsonData));
                 updateOmniJsonData1.addOnToUpdate=this.resultArray;
                 this.omniApplyCallResp(updateOmniJsonData1);
                 this.omniNextStep();
                }
             }
             //------------------------------------
//Email trigger by Manju
//-----------------------------------------------------
           // var success=false;
           
            // if(this.resultArray.TargetId !=""){
            //     if(this.resultArray.TargetComments !=""){
            //         console.log('Comments are not null');
            //          success=true;
            //     }else{
                //   const toastEve=new ShowToastEvent({
                //         title: 'Error',
                //     message: 'Endast samma typ av fömån kan väljas för att skickas till ansvarigt Order-team.Klicka på OK för att gå tillbaka och välja vilken/vilka förmåner du vill skicka.',
                //         variant: 'error',
                //      });
                //      this.dispatchEvent(toastEve);
                //}
               
                // if(success==true){
                //     console.log('Used for rep success');
                //     let updateOmniJsonData1=JSON.parse(JSON.stringify(this.omniJsonData));
                //     updateOmniJsonData1.addOnToUpdate=this.resultArray;
                //     this.omniApplyCallResp(updateOmniJsonData1);
                //     this.omniNextStep();
                // }
            }
       
        
        submitDetailsForSystemAdmin(){
            this.isModalOpen=false;
            this.isModalOpen2=false;
                for(var a=0;a<this.addOnBenefitsArray.length;a++){
                   if(this.addOnBenefitsArray[a].isSelected==true){
                    this.resultArray.TargetId=this.addOnBenefitsArray[a].Id;
                    this.resultArray.TargetComments=this.addOnBenefitsArray[a].Comments;
                    this.resultArray.SendMail=false;
                    console.log('Inside save values for system Admin');
                    let updateOmniJsonData=JSON.parse(JSON.stringify(this.omniJsonData));
                    updateOmniJsonData.addOnToUpdate=this.resultArray;
                    this.omniApplyCallResp(updateOmniJsonData);
                    this.omniNextStep();
                   }
                }
               
            
           

        }

        backToContractPage() {
           // console.log(this.omniJsonData.ContextId);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.omniJsonData.ContextId,
                    objectApiName: 'Contract',
                    actionName: 'view'
                }
            });
     }
   
 
    

}