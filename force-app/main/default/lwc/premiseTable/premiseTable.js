import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import LightningConfirm from 'lightning/confirm';


export default class PremiseTable extends OmniscriptBaseMixin(LightningElement) {
    _actionUtil;
    _ns = getNamespaceDotNotation();
    getPremiseDetailsResponse = [];
    @track PremiseData = [];
    @track Answer;
    @track heraType = [{
        'label': 'Primär access', 'value': '1'
    },
    {
        'label': 'Sekundär access', 'value': '2'
    }]
    @track secondaryAccess = true; // to show warning on secondary access
    @track heraInfoArray = [{
        "key": '',
        "addButton": true,
        "siteOptions": this.siteAddresses,
        "heraType": this.heraType,
        "selectedHeraType": '',
        "Input": {
            "otc": "",
            "rc": "",
            "heraNumber": ""
        },
        "isDeleted": true,
        "ServicePointId": ""
    }]
    @track siteAddresses = [];
    @track ServicePointId = '';
    get options() {
        return [
            { label: 'Ja', value: 'Yes' },
            { label: 'Nej', value: 'No' },  
        ];
    }
    connectedCallback() {
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.getDataFromIP();

    }
    getDataFromIP() {
        const options = {};
        const params = {
            input: this.omniJsonData,
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: "PremiseExtract_COcall",
            options: '{}',
        };
        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then((response) => {
                this.getPremiseDetailsResponse = response.result.IPResult;
                this.PremiseData = this.getPremiseDetailsResponse["PremiseData"];

                this.siteAddresses = [];

                if (Array.isArray(this.PremiseData)) {
                    this.PremiseData.forEach(ele => {
                        ele.P_streetName = ele.P_streetName.toUpperCase();
                        ele.P_streetnumber = ele.P_streetnumber.toUpperCase();
                        ele.P_city = ele.P_city.toUpperCase();
                        ele.S_name = ele.S_name;
                        var label = '';
                        var city = ele.P_city ? ele.P_city : '';
                        var st_name = ele.P_city && ele.P_streetName ? ' - ' + ele.P_streetName : ele.P_streetName ? ele.P_streetName : '';
                        var st_number = ele.P_streetnumber ?  ' - ' + ele.P_streetnumber : '';
                        // var lat = ele.P_latitude && (ele.P_city || ele.P_streetName || ele.P_streetnumber) ? '- ' + 'Lat:' + ele.P_latitude : ele.P_latitude ;
                        // var long = ele.P_longitude ? '- ' + 'Long:' + ele.P_longitude : '';

                        label = city + st_name + ' - ' + ele.S_name;

                        // console.log(city, st_name, st_number, lat, long, ele.S_name);
                        this.siteAddresses.push({
                            'label': label,
                            'value': ele.ServicePointId,
                            'QuoteGroupId': ele.QuoteGroupId,
                            'QuoteMemberId': ele.QuoteMemberId,
                            'P_Name': ele.P_Name,
                            'P_gatenumber': ele.P_gatenumber,
                            'P_postalcode': ele.P_postalcode,
                            'P_city': ele.P_city,
                            'P_streetName': ele.P_streetName,
                            'S_name': ele.S_name,
                            // 'latitude': ele.P_latitude,
                            // 'longitude': ele.P_longitude,
                            'P_streetnumber': ele.P_streetnumber,
                        })

                        ele.heraType = this.heraType;
                    })
                }

                this.heraInfoArray.forEach((ele, index) => {
                    ele.key = index;
                })

                this.heraInfoArray = JSON.parse(JSON.stringify(this.heraInfoArray));
                this.siteAddresses = JSON.parse(JSON.stringify(this.siteAddresses));

            })
            .catch((error) => {
                console.error(error, "ERROR");
            });
    }

    addNewHeraInfo(event) {

        const arrayCount = this.heraInfoArray.length - this.heraInfoArray.filter(ele => ele.isDeleted === false).length;

        if (arrayCount >= this.PremiseData.length * 2) {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Alla adresser från leveranskontrollen är inlagda',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        } else {
            this.heraInfoArray.push({
                "key": this.heraInfoArray.length,
                "addButton": true,
                "siteOptions": this.siteAddresses,
                "hearType": this.heraType,
                "selectedHeraType": '',
                "Input": {
                    "otc": "",
                    "rc": "",
                    "heraNumber": ""
                },
                "isDeleted": true,
                "ServicePointId": ""
            })
        }

    }


    selectAddress(event) {
        let currentIndex = event.target.dataset.index;
        let fieldName = 'ServicePointId';
        const index = this.siteAddresses.findIndex(ele => ele.value === event.target.value);
        
        const len = this.heraInfoArray.filter(ele => (ele.ServicePointId === event.target.value) && (ele.isDeleted === true)).length;
        if (len < 2) {
            this.heraInfoArray[currentIndex][fieldName] = event.target.value;
            this.heraInfoArray[currentIndex]['QuoteMemberId'] = this.siteAddresses[index].QuoteMemberId;
            this.heraInfoArray[currentIndex]['QuoteGroupId'] = this.siteAddresses[index].QuoteGroupId;
            this.heraInfoArray[currentIndex]['P_Name'] = this.siteAddresses[index].P_Name;
            this.heraInfoArray[currentIndex]['P_gatenumber'] = this.siteAddresses[index].P_gatenumber;
            this.heraInfoArray[currentIndex]['P_postalcode'] = this.siteAddresses[index].P_postalcode;
            this.heraInfoArray[currentIndex]['P_streetName'] = this.siteAddresses[index].P_streetName;
            this.heraInfoArray[currentIndex]['P_city'] = this.siteAddresses[index].P_city;
            this.heraInfoArray[currentIndex]['S_name'] = this.siteAddresses[index].S_name;
            this.heraInfoArray[currentIndex]['P_streetnumber'] = this.siteAddresses[index].P_streetnumber;

        } else {
            let target = this.template.querySelector(`[data-id="${currentIndex}"]`);
            target.value = '';
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Observera att en adress endast kan ha en primär och en sekundär Hera-typ.', //Please note that an address can only have one primary and one secondary Hera-type.
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }

    }
    selectHera(event) {
        let currentIndex = event.target.dataset.index;
        let fieldName = 'selectedHeraType';
        let duplicate = false;

        let duplicates = {};

        this.heraInfoArray.forEach((item,index) => {
            if(item.isDeleted === true){
                duplicates[item.ServicePointId] = duplicates[item.ServicePointId] || [];
                duplicates[item.ServicePointId].push(index);
            }
        });

        let arr = duplicates[this.heraInfoArray[currentIndex].ServicePointId];
        // console.log('array of this address -> ',arr);

        if(arr.length > 1){
            if(currentIndex != arr[0]){
                if(this.heraInfoArray[arr[0]].selectedHeraType === event.target.value){
                    duplicate = true;
                }
            }else{
                if(this.heraInfoArray[arr[1]].selectedHeraType === event.target.value){
                    duplicate = true;
                }
            }
        }
        




        if (!duplicate) {

            this.heraInfoArray[currentIndex][fieldName] = event.target.value;

        }
        else {
            let target = this.template.querySelector(`[data-id1="${currentIndex}"]`);
            target.value = '';
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Observera att en adress endast kan ha en primär och en sekundär Hera-typ.', //Please note that an address can only have one primary and one secondary Hera-type.
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }
    }

    methodUpdate(event) {
        let currentIndex = event.target.dataset.index;

        if (this.heraInfoArray[currentIndex].ServicePointId == '') {
            let fieldName = event.target.name;
            this.heraInfoArray[currentIndex]['Input'][fieldName] = null;
            this.heraInfoArray = JSON.parse(JSON.stringify(this.heraInfoArray));

            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Välj adress först', // Select a site first to enter details',
                variant: 'error'
            });
            this.dispatchEvent(evt);

        } else {
            let fieldName = event.target.name;
            this.heraInfoArray[currentIndex]['Input'][fieldName] = event.target.value;
        }

        // console.log(this.heraInfoArray);

    }

    async deleteRow(event) {

        let currentIndex = event.target.dataset.index;
        const arrayCount = this.heraInfoArray.length - this.heraInfoArray.filter(ele => ele.isDeleted === false).length;
        if (arrayCount > 1) {
            const result = await LightningConfirm.open({
                message: 'Är du säker att du vill radera?', // Are you sure you want to delete?
                variant: 'headerless',
                label: 'Deleted',
                // setting theme would have no effect
            });

            if (result) {
                this.heraInfoArray[currentIndex].isDeleted = false;
            }

        } else {
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Raden går ej att ta bort', //Cannot delete all sites',
                variant: 'error'
            });
            this.dispatchEvent(evt);

        }

    }

    handleChange(event) {
        if (event.target.value == "Yes") {
            this.Answer = true;
        } else if (event.target.value == "No") {
            this.Answer = false;
        }

    }

    @track updatedHeraInfoArray = [];

    nextStep(event) {


        let duplicates = {};

        this.heraInfoArray.forEach((item,index) => {
            if(item.isDeleted === true){
                duplicates[item.ServicePointId] = duplicates[item.ServicePointId] || [];
                //console.log('duplicates=>',duplicates);
                duplicates[item.ServicePointId].push(index);
                //console.log('index=>',index);
            }
        });

        console.log('duplicates => ',duplicates);
        let count = 0;
        for(let addr in duplicates)
        {
            if(duplicates[addr].length > 1){

                this.updatedHeraInfoArray[count] = JSON.parse(JSON.stringify(this.heraInfoArray[duplicates[addr][0]]));


                let priHeraNumber;
                let secHeraNumber;

                if(this.heraInfoArray[duplicates[addr][0]].selectedHeraType === '1'){
                    priHeraNumber = this.heraInfoArray[duplicates[addr][0]].Input.heraNumber;
                    secHeraNumber = this.heraInfoArray[duplicates[addr][1]].Input.heraNumber;
                }else{

                    priHeraNumber = this.heraInfoArray[duplicates[addr][1]].Input.heraNumber;
                    secHeraNumber = this.heraInfoArray[duplicates[addr][0]].Input.heraNumber;
                }

                this.updatedHeraInfoArray[count].Input.heraNumber = priHeraNumber + ";" + secHeraNumber;
                count++;
                

            }else if(duplicates[addr].length == 1){
                this.updatedHeraInfoArray[count] = JSON.parse(JSON.stringify(this.heraInfoArray[duplicates[addr][0]]));
                count++;
            }
        }


        // console.log('Updated Hera Array => ',this.updatedHeraInfoArray);



        // console.log('Answer =>', this.Answer);
        // console.log('Hera Array--->', this.heraInfoArray);


        let resetvar = this.Answer;
        let Flag = 1;
        if (this.omniJsonData) {
            if (this.Answer) {
                this.heraInfoArray.forEach(ele => {
                    if (ele.isDeleted === true) {
                        if ((String(ele.ServicePointId) == "") || (String(ele.selectedHeraType) == "") || (String(ele.Input.heraNumber) == "") || (String(ele.Input.otc) == "") || (String(ele.Input.rc) == "")) {
                            //console.log('Error case 0');
                            Flag = 0;
                        // } else if ((String(ele.Input.otc) == "") && (String(ele.Input.rc) == "") && (String(ele.Input.heraNumber) == "")) {
                        //     //console.log('Error case 1');
                        //     Flag = 0;
                        // } else if (((String(ele.Input.otc) != "") || (String(ele.Input.rc) != "")) && (String(ele.Input.heraNumber) == "")) {
                        //     //console.log('Error case 2');
                        //     Flag = 0;
                        // } else if ((String(ele.Input.heraNumber) != "") && (String(ele.Input.otc) == "" && String(ele.Input.rc) == "")) {
                        //     //console.log('Error case 3');
                        //     Flag = 0;
                        }
                    }
                });
                if (Flag == 1) {
                    let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
                    updateOmniJsonData.UpdatedPremiseData = this.heraInfoArray;
                    updateOmniJsonData.UpdatedHeraNumberData = this.updatedHeraInfoArray;
                    this.omniApplyCallResp(updateOmniJsonData);
                    this.omniNextStep();
                } else {
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Fyll i alla uppgifter för att gå vidare', //please enter a valid input
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                }
            } else if (this.Answer == false) {
                this.omniNextStep();
            }
            else if (this.Answer == null) {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Fyll i alla uppgifter för att gå vidare', //please enter a valid input
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        }
        this.Answer = resetvar;
    }
}