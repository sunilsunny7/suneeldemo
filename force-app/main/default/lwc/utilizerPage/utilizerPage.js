import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class UtilizerPage extends OmniscriptBaseMixin(LightningElement) {
    _actionUtil;
    @track Utilizerdata = [];
    // Added selectedAll for select all checkbox
    @track selectedAll;
    checkthebox1 = true;
    checkthebox2 = false;
    connectedCallback() {
        const RawUtil = JSON.parse(JSON.stringify(this.omniJsonData.UtilizerInfo.Util));
        console.log('raw thingy', RawUtil);
        this.Utilizerdata = RawUtil;
        console.log('final data', JSON.stringify(this.Utilizerdata));
    }
    changeSolution(event) {
        console.log('Entire Event', JSON.stringify(event.target.value));
        console.log('Entire Event', JSON.stringify(event.target.id));
        var CapturedOrgNum = (event.target.id).split("-")[0];
        var pos = this.Utilizerdata.map(function (e) { return e.OrganizationNumber }).indexOf(CapturedOrgNum);
        if (this.Utilizerdata[pos]['isSolution'] === false) {
            this.Utilizerdata[pos]['isSolution'] = true;
            this.Utilizerdata[pos]['isDaughter'] = false;
        } else {
            this.Utilizerdata[pos]['isSolution'] = false;
        }
        // added below block to uncheck the select-all daughter checkbox if any one of the child solution is selected
        var uncheckDaughter = this.template.querySelector('[data-id="daughterAll"]');
        if (uncheckDaughter.checked == true) {
            uncheckDaughter.checked = event.target.unchecked;
        }
    }
    changeDaughter(event) {
        console.log('Entire Event', JSON.stringify(event.target.value));
        console.log('Entire Event', JSON.stringify(event.target.id));
        var CapturedOrgNum = (event.target.id).split("-")[0];

        var pos = this.Utilizerdata.map(function (e) { return e.OrganizationNumber }).indexOf(CapturedOrgNum);
        console.log('captured org num', CapturedOrgNum, pos);
        if (this.Utilizerdata[pos]['isDaughter'] === false) {
            this.Utilizerdata[pos]['isSolution'] = false;
            this.Utilizerdata[pos]['isDaughter'] = true;
        } else {
            this.Utilizerdata[pos]['isDaughter'] = false;
        }

        // added below block to uncheck the select-all solution checkbox if any one of the child daughter is selected
        var uncheckSolution = this.template.querySelector('[data-id="solutionAll"]');
        if (uncheckSolution.checked == true) {
            uncheckSolution.checked = event.target.unchecked;
        }
    }
    // the below function is a single function for both select-all boxes MCSTO-9489
    changeAll(event) {
        this.selectedAll = event.target.value;
        console.log('Selected checkbox--', this.selectedAll);
        // selectedAll has a value of the checkbox selected 
        var checkedSolution = this.template.querySelector('[data-id="solutionAll"]');
        var checkedDaughter = this.template.querySelector('[data-id="daughterAll"]');
        if (this.selectedAll === "allSolution") {
            let i;
            let checkboxes = this.template.querySelectorAll('[data-id="childSolution"]');
            // checkboxes here is taking all the checkboxes whose data-id is childSolution
            if (checkedSolution.checked == true) {
                //if selected checkbox is select-all solution then all the child solution be checked and respective child daughter be unchecked 
                for (i = 0; i < checkboxes.length; i++) {
                    var CapturedOrgNum = (checkboxes[i].id).split("-")[0];
                    var pos = this.Utilizerdata.map(function (e) { return e.OrganizationNumber }).indexOf(CapturedOrgNum);
                    this.Utilizerdata[pos]['isSolution'] = true;
                    this.Utilizerdata[pos]['isDaughter'] = false;
                }
                // below block is to uncheck the select-all daughter if that checkbox is checked before
                var uncheckDaughter = this.template.querySelector('[data-id="daughterAll"]');
                if (uncheckDaughter.checked == true) {
                    uncheckDaughter.checked = event.target.unchecked;
                }
            }
            // this bolck is to uncheck the child solutions when select-all solution is unchecked
            else if (checkedSolution.checked == false) {
                for (i = 0; i < checkboxes.length; i++) {
                    var CapturedOrgNum = (checkboxes[i].id).split("-")[0];
                    var pos = this.Utilizerdata.map(function (e) { return e.OrganizationNumber }).indexOf(CapturedOrgNum);
                    this.Utilizerdata[pos]['isSolution'] = false;
                }
            }
        }
        else if (this.selectedAll === "allDaughter") {
            let i;
            let checkboxes = this.template.querySelectorAll('[data-id="childDaughter"]');
            // checkboxes here is taking all the checkboxes whose data-id is childDaughter            
            if (checkedDaughter.checked == true) {
                //if selected checkbox is select-all daughter then all the child daughters be checked and respective child solutions be unchecked 
                for (i = 0; i < checkboxes.length; i++) {
                    //console.log("id",checkboxes[i].id,"value",checkboxes[i].value);
                    var CapturedOrgNum = (checkboxes[i].id).split("-")[0];
                    var pos = this.Utilizerdata.map(function (e) { return e.OrganizationNumber }).indexOf(CapturedOrgNum);
                    this.Utilizerdata[pos]['isSolution'] = false;
                    this.Utilizerdata[pos]['isDaughter'] = true;
                }
                // below block is to uncheck the select-all solution if that checkbox is checked before
                var uncheckSolution = this.template.querySelector('[data-id="solutionAll"]');
                if (uncheckSolution.checked == true) {
                    uncheckSolution.checked = event.target.unchecked;
                }
            }
            // this bolck is to uncheck the child daughters when select-all daughter is unchecked
            else if (checkedDaughter.checked == false) {
                for (i = 0; i < checkboxes.length; i++) {
                    var CapturedOrgNum = (checkboxes[i].id).split("-")[0];
                    var pos = this.Utilizerdata.map(function (e) { return e.OrganizationNumber }).indexOf(CapturedOrgNum);
                    this.Utilizerdata[pos]['isDaughter'] = false;
                }
            }

        }
    }

    nextStep() {
        console.log('FINALIZED', JSON.stringify(this.Utilizerdata));
        let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
        updateOmniJsonData.UpdatedUtilizerInfo = this.Utilizerdata;
        this.omniApplyCallResp(updateOmniJsonData);
        this.omniNextStep();
    }
    previousStep() {
        this.omniPrevStep();
    }

}