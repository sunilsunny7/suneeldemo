import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';
export default class AddressValidation extends OmniscriptBaseMixin(LightningElement) {

    @track link = 'https://arsprodweb.han.telia.se/arsys/forms/arsprod/HERA/WebbHera_Registrera';

    // searchOptions = [
    //     { label: 'Adress', value: '1' },
    //     { label: 'Koordinater', value: '2' }
    // ];

    // @track setFlag = false;

    @track siteList = [{
        addButton: true,
        // searchOption: '1',
        // addressType: this.searchOptions,
        // xCoordinate: '',
        // yCoordinate: '',
        // readonlyAddress: false,
        // readonlyCoordinates: true,
        city: '',
        postalCode: '',
        streetName: '',
        streetNumber: '',
        gateNumber: '',
        aptno: '',
        errorMessage: '',
        isValidated: false,
        checkServicePoints: false,
        isServicePointSelected: false,
        defaultServicePoint: false,
        isDeleted: false,
        isDisabled: false,
        servicePoints: Array(),
        selectedServicePoint: {},
        accountId: '',
        opportunityId: ''
    }];

    //used to save data temporarily in this variable
    @track tempData;
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    //used to save the service points response
    @track repos;
    //This variable is used to track the current row/id which is selected for any change in the page
    @track currentIndex;

    @track limitOnPage = 100;

    @track fileName;

    @track deleteAllCheck = false;

    @track showFileName = false;

    @track deleteMessage = '';
    @track getCount; //to get the count of service points received from API call.
    @track currentCount; //to track the number of sites which are not marked as deleted

    @track token;

    @track error_codes;

    @track invalid_error = '';

    @track required_error = '';

    @track AccountId = '';

    @track opportunityId = '';

    @track csvTemplateURL = '';

    @track validateAllEvent = false;
    @track validationInProcess = false;
    @track processing = false;
    // @track radius = '';

    _actionUtilClass;
    _ns = getNamespaceDotNotation();

    connectedCallback() {
        this.processing = false;
        if (this.omniJsonData.ContextId !== '') {
            this.AccountId = this.omniJsonData.OpportunityList.AccountId;
            this.opportunityId = this.omniJsonData.ContextId;
            this.siteList[0].accountId = this.AccountId;
            this.siteList[0].opportunityId = this.opportunityId;
        }

        this._actionUtilClass = new OmniscriptActionCommonUtil();

        const params = {
            input: this.omniJsonData,
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'Premise_getData',
            options: '{}',
        };
        //Calling IP to fetch all premise objects available with that opportunity ID
        this._actionUtilClass.executeAction(params, null, this, null, null)
            .then(response => {
                var list = response.result.IPResult.Opportunity;
                this.error_codes = response.result.IPResult.EC; //Error Messages from custom settings are read here

                // console.log(this.error_codes);

                if (this.error_codes !== "") {
                    this.invalid_error = this.error_codes.find(x => x.ErrorCode === 'EM7').ErrorTranslation;
                    this.required_error = this.error_codes.find(x => x.ErrorCode === 'EM8').ErrorTranslation;
                    // this.radius = this.error_codes.find(x => x.ErrorCode === 'Radius').ErrorDescription;

                    // console.log(this.radius);
                }

                if (list.length > 0) {
                    if (this.siteList.length === 1 && this.siteList[0].city === '' && this.siteList[0].streetName === '') {
                        this.siteList.splice(0, 1);
                    }

                    this.processing = true;

                    list.forEach((ele, i) => {
                        var isServicePointAvailable = ele.ServicePointNo !== '' ? true : false;
                        var st_number = ele.StreetNumber ? ele.StreetNumber : '';
                        var gate_number = ele.GateNumber && ele.StreetNumber ? '-' + ele.GateNumber : ele.GateNumber ? ele.GateNumber : '';
                        var apt_no = ele.AptNo && ele.S_fftx ? '-' + ele.AptNo : ele.AptNo ? ele.AptNo : '';
                        var fttx = ele.S_fftx ? '-' + 'FTTx' : '';
                        var searchOption = ele.xCoordinate || ele.yCoordinate ? '2' : '1';

                        var servicePointNameStr = '';
                        if (searchOption === '2') {
                            var servicePointNumber = ele.ServicePointNo;
                            servicePointNameStr = st_number + gate_number + apt_no + servicePointNumber + fttx;
                        } else {
                            servicePointNameStr = st_number + gate_number + apt_no + fttx;
                            if (servicePointNameStr === '') {
                                servicePointNameStr = ele.ServicePointNo;
                            }
                        }

                        this.siteList.push({
                            addButton: true,
                            // addressType: this.searchOptions,
                            // searchOption: searchOption,
                            // xCoordinate: ele.xCoordinate,
                            // yCoordinate: ele.yCoordinate,
                            // readonlyAddress: true,
                            // readonlyCoordinates: true,
                            city: ele.City ? ele.City.toUpperCase() : '',
                            postalCode: ele.Postalcode,
                            streetName: ele.StreetAddress ? ele.StreetAddress.toUpperCase() : '',
                            streetNumber: ele.StreetNumber ? ele.StreetNumber.toUpperCase() : '',
                            gateNumber: ele.GateNumber ? ele.GateNumber : '',
                            aptno: ele.AptNo ? ele.AptNo : '',
                            isValidated: true,
                            isServicePointSelected: isServicePointAvailable,
                            checkServicePoints: false,
                            defaultServicePoint: isServicePointAvailable,
                            isDeleted: false,
                            isDisabled: true,
                            servicePoints: Array(),
                            selectedServicePoint: {
                                servicePointName: servicePointNameStr,
                                servicePointId: ele.ServicePointNo,
                                servicePointFttx: ele.S_fftx
                            },
                            accountId: this.AccountId,
                            opportunityId: this.opportunityId
                        });

                        // setTimeout(() => {
                        //     var target = this.template.querySelector(`[data-item="${i}"]`);
                        //     target.selectedIndex = searchOption == '2' ? 1 : 0;
                        // }, 200);

                    });

                    this.positionOfAddButton();

                } else {
                    this.processing = true;
                }

            })
            .catch(error => {
                this.processing = true;
                window.console.log(error);
            });

        this.getToken();
    }

    getCurrentCount() {
        this.currentCount = this.siteList.filter(function (item) {
            if (item.isDeleted === false) {
                return true;
            } else {
                return false;
            }
        }).length;
    }

    addRow() {

        this.getCurrentCount();

        if (this.currentCount < this.limitOnPage) {
            this.siteList.push({
                addButton: true,
                // searchOption: '1',
                // addressType: this.searchOptions,
                // xCoordinate: '',
                // yCoordinate: '',
                // readonlyAddress: false,
                // readonlyCoordinates: true,
                city: '',
                postalCode: '',
                streetName: '',
                streetNumber: '',
                gateNumber: '',
                aptno: '',
                errorMessage: '',
                isValidated: false,
                isServicePointSelected: false,
                checkServicePoints: false,
                defaultServicePoint: false,
                isDeleted: false,
                isDisabled: false,
                servicePoints: Array(),
                selectedServicePoint: {},
                accountId: this.AccountId,
                opportunityId: this.opportunityId
            });

            this.positionOfAddButton();
        } else {
            if (this.error_codes !== undefined) {
                var error_object = this.error_codes.find(x => x.ErrorCode === 'EM11')
                const evt = new ShowToastEvent({
                    message: error_object.ErrorTranslation,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            } else {
                console.log('Error messages not received from DR');
            }
        }

    }

    editRow(event) {
        const currentIndex = event.target.dataset.opp;
        this.siteList[currentIndex]['isEdited'] = true;
        if (this.siteList[currentIndex]['previousServiceId'] == undefined) {
            this.siteList[currentIndex]['previousServiceId'] = this.siteList[currentIndex].selectedServicePoint;
        }
        this.siteList[currentIndex].isDisabled = false;
        this.siteList[currentIndex].isValidated = false;
        this.siteList[currentIndex].isServicePointSelected = false;
        this.siteList[currentIndex].servicePoints = [];
        this.siteList[currentIndex].selectedServicePoint = {};

        // if (this.siteList[currentIndex].searchOption == '1') {
        //     this.siteList[currentIndex].readonlyAddress = false;
        // } else {
        //     this.siteList[currentIndex].readonlyCoordinates = false;
        // }

        let target = this.template.querySelector(`[data-id1="${currentIndex}"]`);
        target.value = '';
    }

    deleteRow(event) {
        this.getCurrentCount();

        this.deleteMessage = 'Är du säker på att du vill radera raden?';
        if (this.currentCount > 1 || this.currentCount === 1) {
            this.openModal();
            this.currentIndex = event.target.dataset.opp;
        }
    }

    confirmDelete() {
        if (this.deleteAllCheck && (this.siteList.length > 1 || this.siteList.length === 1)) {
            this.siteList.forEach(element => {
                element.isDeleted = true;
            });

            this.deleteAllCheck = false;
            this.siteList.push({
                addButton: true,
                // searchOption: '1',
                // addressType: this.searchOptions,
                // xCoordinate: '',
                // yCoordinate: '',
                // readonlyAddress: false,
                // readonlyCoordinates: true,
                city: '',
                postalCode: '',
                streetName: '',
                streetNumber: '',
                gateNumber: '',
                aptno: '',
                errorMessage: '',
                isValidated: false,
                checkServicePoints: false,
                isServicePointSelected: false,
                defaultServicePoint: false,
                isDeleted: false,
                isDisabled: false,
                servicePoints: Array(),
                selectedServicePoint: {},
                accountId: this.AccountId,
                opportunityId: this.opportunityId
            });


            Promise.resolve().then(() => {
                const allValid = [...this.template.querySelectorAll('lightning-input')]
                    .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
                    }, true);
                this.deleteAllCheck = false;
                this.template.querySelector('.selectServicePoints').value = '';
            //     let target = this.template.querySelector(`[data-item="${this.siteList.length - 1}"]`);

            //    target.value = '1';
            });



        } else if (this.currentCount > 1) {
            var currentIndex = Number(this.currentIndex);
            this.siteList[this.currentIndex].isDeleted = true;

            setTimeout(() => {
                if (currentIndex !== this.siteList.length - 1) {
                    for (var i = currentIndex + 1; i < this.siteList.length; i++) {
                        if (this.siteList[i].isServicePointSelected && !this.siteList[i].isDeleted && !this.siteList[i].isDisabled) {
                            let target = this.template.querySelector(`[data-id1="${i}"]`);
                            target.value = this.siteList[i].selectedServicePoint.servicePointId;
                        } else if (!this.siteList[i].isDeleted && !this.siteList[i].isDisabled) {
                            let target = this.template.querySelector(`[data-id1="${i}"]`);
                            target.value = '';
                        }
                        //added for handling addressType on delete
                        // if (!this.siteList[i].isDeleted) {

                        //     let target = this.template.querySelector(`[data-item="${i}"]`);

                        //     target.value = this.siteList[i].searchOption;

                        // }
                    }
                }

                this.siteList = JSON.parse(JSON.stringify(this.siteList));
            }, 100);

        } else if (this.currentCount === 1) {
            this.siteList[this.currentIndex].isDeleted = true;
            this.siteList.push({
                addButton: true,
                // searchOption: '1',
                // addressType: this.searchOptions,
                // xCoordinate: '',
                // yCoordinate: '',
                // readonlyAddress: false,
                // readonlyCoordinates: true,
                city: '',
                postalCode: '',
                streetName: '',
                streetNumber: '',
                gateNumber: '',
                aptno: '',
                errorMessage: '',
                isValidated: false,
                isServicePointSelected: false,
                checkServicePoints: false,
                defaultServicePoint: false,
                isDeleted: false,
                isDisabled: false,
                servicePoints: Array(),
                selectedServicePoint: {},
                accountId: this.AccountId,
                opportunityId: this.opportunityId
            });

            Promise.resolve().then(() => {
                const allValid = [...this.template.querySelectorAll('lightning-input')]
                    .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
                    }, true);
                this.template.querySelector('.selectServicePoints').value = '';

                // var i = this.siteList.length - 1;
                // let target = this.template.querySelector(`[data-item="${i}"]`);
                // target.value = '1';
            });

        }
        this.deleteMessage = '';
        this.positionOfAddButton();
        this.closeModal();

    }

    cancelDelete() {
        this.deleteAllCheck = false;
        this.closeModal();
    }

    deleteAll() {
        this.deleteMessage = 'Är du säker på att du vill radera alla rader?';
        this.openModal();
        this.deleteAllCheck = true;
    }

    positionOfAddButton() {
        //this method is called everytime there is a change in the number of rows so that '+' sign button is positioned at the bottom always
        const lastIndexOf = (array) => {
            for (let i = array.length - 1; i >= 0; i--) {
                if (array[i].isDeleted === false)
                    return i;
            }
            return -1;
        };
        const lastIndexOfAddButton = lastIndexOf(this.siteList);
        for (var i = 0; i < this.siteList.length; i++) {
            this.siteList[i].addButton = false;
            if (i === lastIndexOfAddButton) {
                this.siteList[i].addButton = true;
            }

            // if(this.siteList[i].readonlyAddress == false){
            //     this.siteList[i]['placeholder'] = 'lgh 1102';
            // }
        }
    }


    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    // handleSearch(event) {
    //     const index = event.target.dataset.opp;
    //     const selectedValue = event.target.value;

    //     this.siteList[index].searchOption = selectedValue;
    //     this.siteList[index].isValidated = false;
    //     this.siteList[index].isServicePointSelected = false;
    //     this.siteList[index].servicePoints = [];

    //     var list = this.template.querySelectorAll(".selectServicePoints");
    //     if (list.length > 1) {
    //         list.forEach((e, i) => {
    //             if (e.dataset.id1 == index) {
    //                 e.value = '';
    //             }
    //         });
    //     } else if (list.length === 1) {
    //         list.forEach((e, i) => {
    //             e.value = '';
    //         });
    //     }

    //     if (selectedValue == '2') {
    //         this.siteList[index].readonlyAddress = true;
    //         this.siteList[index].readonlyCoordinates = false;
    //         this.siteList[index].city = '',
    //         this.siteList[index].postalCode = '',
    //         this.siteList[index].streetName = '',
    //         this.siteList[index].streetNumber = '',
    //         this.siteList[index].gateNumber = '',
    //         this.siteList[index].aptno = ''
    //         this.siteList[index]['placeholder'] = '';
    //     } else if (selectedValue == '1') {
    //         this.siteList[index].readonlyAddress = false;
    //         this.siteList[index].readonlyCoordinates = true;
    //         this.siteList[index].xCoordinate = '';
    //         this.siteList[index].yCoordinate = '';
    //         this.siteList[index]['placeholder'] = 'lgh 1102';
    //     }


    //     this.siteList = JSON.parse(JSON.stringify(this.siteList));
    // }

    async validateAddress(index) {

        if (this.token == null || this.token == undefined || this.token == '') {
            await this.getToken();
        }

        // if (this.siteList[index].searchOption === '2') {
        //     if (this.validateAllEvent === false) { //check if input validity is required or not.
        //         const allValid = this.template.querySelectorAll('[data-opp="' + index + '"]');
        //         var valid = true;

        //         if (!(allValid[7].validity.valid && allValid[8].validity.valid)){
        //             valid = false;
        //         }
        //     }

        //     if (valid || this.validateAllEvent === true) {
        //         if (this.siteList[index].xCoordinate !== '' && this.siteList[index].yCoordinate !== '') {

        //             const inputData = {
        //                 token: this.token,
        //                 radius: this.radius,
        //                 latitude: this.siteList[index].yCoordinate,
        //                 longitude: this.siteList[index].xCoordinate
        //             };

        //             console.log(inputData);

        //             const options = {
        //                 chainable: true
        //             }
        //             const params = {
        //                 input: inputData,
        //                 sClassName: `${this._ns}IntegrationProcedureService`,
        //                 sMethodName: 'MassCustomized_CO_Coordinates',
        //                 options: JSON.stringify(options),
        //             }

        //             await this._actionUtilClass
        //                 .executeAction(params, null, this, null, null)
        //                 .then(response => {
        //                     console.log(JSON.parse(JSON.stringify(response)));
        //                     if (response.result.IPResult.Response.ServicePointsDetail) {
        //                         const servicePoints = response.result.IPResult.Response.ServicePointsDetail;
        //                         this.siteList[index].servicePoints = Array();
        //                         if (servicePoints.length > 0) {
        //                             this.siteList[index].isServicePointSelected = false;
        //                             this.siteList[index].isValidated = true;
        //                             this.siteList[index].selectedServicePoint = {};
        //                             this.siteList[index].defaultServicePoint = servicePoints.length === 1 ? true : false;
        //                             this.siteList[index].checkServicePoints = servicePoints.length > 15 ? true : false;
        //                             var copyOfServicePoints = servicePoints;
        //                             copyOfServicePoints.forEach(ele => {
        //                                 var st_number = ele.StreetNumber && ele.GAFlag ? ele.StreetNumber + ' - Dedikerad' : ele.StreetNumber ? ele.StreetNumber : '';
        //                                 var gate_number = ele.GateNumber ? '-' + ele.GateNumber : '';
        //                                 var apt_no = ele.FlatNumber ? '-' + ele.FlatNumber : '';
        //                                 var pointId = '-' + ele.servicePointId;
        //                                 var fttx = ele.FTTxFlag ? '- FTTx' : '';
        //                                 var servicePointName = st_number + gate_number + apt_no + pointId + fttx;
        //                                 ele.servicePointName = servicePointName;
        //                                 this.siteList[index].servicePoints.push(ele);
        //                             })
        //                             if (this.siteList[index].defaultServicePoint) {

        //                                 if (this.siteList.some(el => parseInt(el.selectedServicePoint.servicePointId) === parseInt(this.siteList[index].servicePoints[0].servicePointId) && el.isDeleted === false)) {
        //                                     this.siteList[index].defaultServicePoint = false;
        //                                     this.siteList[index].isValidated = false;
        //                                     this.siteList[index].isServicePointSelected = false;
        //                                     this.siteList[index].errorMessage = 'Denna anslutningspunkt är redan vald';
        //                                 } else {
        //                                     if (this.siteList[index].servicePoints[0].servicePointName === '') {
        //                                         this.siteList[index].isValidated = false;
        //                                         this.siteList[index].isServicePointSelected = false;
        //                                         this.siteList[index].errorMessage = response.result.IPResult.HttpResponse.status_message ? response.result.IPResult.HttpResponse.status_message : 'A technical error has occured please contact your administrator';
        //                                     } else {
        //                                         this.siteList[index].defaultServicePoint = true;
        //                                         this.siteList[index].selectedServicePoint = this.siteList[index].servicePoints[0];
        //                                         this.siteList[index].city = servicePoints[0].City;
        //                                         this.siteList[index].streetName = servicePoints[0].StreetName;
        //                                         this.siteList[index].streetNumber = servicePoints[0].StreetNumber;
        //                                         this.siteList[index].postalCode = servicePoints[0].Postcode;
        //                                         this.siteList[index].isServicePointSelected = true;
        //                                     }
        //                                 }

        //                             }
        //                         }
        //                     }
        //                     else {
        //                         if (response.result.IPResult.ErrorResponse !== '' ){
        //                             var error_code = response.result.IPResult.ErrorResponse.ErrorCode;
        //                             if (error_code !== "") {
        //                                 var error_message = this.error_codes.find(x => x.ErrorCode === error_code);
        //                             } 
        //                             this.siteList[index].errorMessage = error_code !== '' && error_message !== undefined && error_message.ErrorTranslation !== '' ? error_message.ErrorTranslation : 'A technical error has occured please contact your administrator';
        //                         } else {
        //                             this.siteList[index].errorMessage = 'Koordinater saknas i AM';
        //                         }
                               
                                
        //                     }
        //                 }, 
        //                 error => { });
        //         }
        //         else {
        //             var error_object = this.error_codes.find(x => x.ErrorCode === 'EM91');
        //             const evt = new ShowToastEvent({
        //                 message: error_object.ErrorTranslation,
        //                 variant: 'error'
        //             });
        //             this.dispatchEvent(evt);
        //         }
        //     } else {
        //         //Throws an error if all the inputs for that index are not valid
        //         var error_object = this.error_codes.find(x => x.ErrorCode === 'EM7'); //Invalid input error
        //         const evt = new ShowToastEvent({
        //             title: error_object.ErrorDescription,
        //             message: error_object.ErrorTranslation,
        //             variant: 'error'
        //         });
        //         this.dispatchEvent(evt);

        //     }

        // }
        // else
         if (this.siteList[index].isValidated === false && this.siteList[index].isDeleted === false && this.siteList[index].city !== '' && this.siteList[index].streetName !== '' && this.siteList[index].streetNumber !== '') {

            if (this.validateAllEvent === false) { //check if input validity is required or not.
                const allValid = this.template.querySelectorAll('[data-opp="' + index + '"]')
                var valid = true;

                for (var i = 0; i <= 5; i++) { //Change this from 0 and 5 to 1 and 6 for co-ordinates 
                    if (!allValid[i].validity.valid) {
                        valid = false;
                    }
                }
            }

            if (valid || this.validateAllEvent === true) {
                //Emptying the array if user has already called validation before for this index.
                this.siteList[index].servicePoints = Array();
                this.siteList[index].selectedServicePoint = {};

                this.siteList[index].city = this.siteList[index].city ? this.siteList[index].city.toUpperCase() : '';
                this.siteList[index].streetName = this.siteList[index].streetName ? this.siteList[index].streetName.toUpperCase() : '';
                this.siteList[index].streetNr = this.siteList[index].streetNr ? this.siteList[index].streetNr.toUpperCase() : '';
                this.siteList[index].aptno = this.siteList[index].aptno ? this.siteList[index].aptno.toUpperCase() : '';
                this.siteList[index].gateNumber = this.siteList[index].gateNumber ? this.siteList[index].gateNumber.toUpperCase() : '';

                const inputData = {
                    city: this.siteList[index].city,
                    streetName: this.siteList[index].aptno ? '' : this.siteList[index].streetName,
                    streetNr: this.siteList[index].aptno ? '' : this.siteList[index].streetNumber,
                    streetNrSuffix: this.siteList[index].aptno ? '' : this.siteList[index].gateNumber,
                    postalCode: this.siteList[index].postalCode,
                    aptno: this.siteList[index].aptno ? this.siteList[index].streetName + ' ' + this.siteList[index].streetNumber + ' ' + this.siteList[index].gateNumber + ' ' + this.siteList[index].aptno : '',
                    token: this.token
                }
                const options = {
                    chainable: true
                }
                const params = {
                    input: inputData,
                    sClassName: `${this._ns}IntegrationProcedureService`,
                    sMethodName: 'MassCustomized_CO_AddressValidation',
                    options: JSON.stringify(options),
                }

                await this._actionUtilClass
                    .executeAction(params, null, this, null, null)
                    .then(response => {

                        console.log(JSON.parse(JSON.stringify(response)));
                        
                        if (Array.isArray(response.result.IPResult.Response.ServicePointsDetail) && response.result.IPResult.Response.ServicePointsDetail.length > 0 && response.result.IPResult.Response.ServicePointsDetail[0].GAFlag == true) {
                            this.siteList[index].servicePoints = response.result.IPResult.Response.ServicePointsDetail;
                            this.getCount = response.result.IPResult.Response.ServicePointsDetail.length;
                            //checking if API has returned an array and length of array is greater than 0
                            if (Array.isArray(this.siteList[index].servicePoints) && this.siteList[index].servicePoints.length) {
                                this.siteList[index].postalCode = this.siteList[index].servicePoints[0].Postcode && this.siteList[index].servicePoints[0].Postcode !== undefined && this.siteList[index].servicePoints[0].Postcode !== null ? this.siteList[index].servicePoints[0].Postcode : '';
                                //setting service point Names in a format required by the USER. 

                                var copyOfArray = this.siteList[index].servicePoints;

                                this.siteList[index].servicePoints = [];

                                copyOfArray.forEach(ele => {
                                    if (!(ele.LAFlag && !ele.GateNumber && !ele.FlatNumber) && this.siteList[index].servicePoints.length <= 15) {
                                        var st_number = ele.StreetNumber && ele.GAFlag ? ele.StreetNumber + ' - Dedikerad' : ele.StreetNumber ? ele.StreetNumber : '';
                                        var gate_number = ele.GateNumber ? '-' + ele.GateNumber : '';
                                        var apt_no = ele.FlatNumber ? '-' + ele.FlatNumber : '';
                                        var fttx = ele.FTTxFlag ? '- FTTx' : '';
                                        var servicePointName = st_number + gate_number + apt_no + fttx;

                                        if(servicePointName == ''){
                                            servicePointName = ele.servicePointId;
                                        }
                                        ele.servicePointName = servicePointName;
                                        this.siteList[index].servicePoints.push(ele);
                                    }
                                });

                                this.siteList[index].isValidated = true;
                                if (this.siteList[index].servicePoints.length === 1) {
                                    if (this.siteList.some(el => parseInt(el.selectedServicePoint.servicePointId) === parseInt(this.siteList[index].servicePoints[0].servicePointId) && el.isDeleted === false)) {
                                        this.siteList[index].defaultServicePoint = false;
                                        this.siteList[index].isValidated = false;
                                        this.siteList[index].isServicePointSelected = false;
                                        this.siteList[index].errorMessage = 'Denna anslutningspunkt är redan vald';
                                    } else {
                                        if (this.siteList[index].servicePoints[0].servicePointName === '') {
                                            this.siteList[index].isValidated = false;
                                            this.siteList[index].isServicePointSelected = false;
                                            this.siteList[index].errorMessage = response.result.IPResult.HttpResponse.status_message ? response.result.IPResult.HttpResponse.status_message : 'A technical error has occured please contact your administrator';
                                        } else {
                                            this.siteList[index].defaultServicePoint = true;
                                            this.siteList[index].selectedServicePoint = this.siteList[index].servicePoints[0];
                                            this.siteList[index].isServicePointSelected = true;
                                        }
                                    }
                                } else if (this.getCount > 15) {
                                    this.siteList[index].isServicePointSelected = false;
                                    this.siteList[index].defaultServicePoint = false;
                                    this.siteList[index].checkServicePoints = true;
                                } else {
                                    this.siteList[index].isServicePointSelected = false;
                                    this.siteList[index].defaultServicePoint = false;
                                    this.siteList[index].checkServicePoints = false;
                                }
                            } else {

                                if (response.result.IPResult.HttpResponse.reason === 'Expired credentials' || response.result.IPResult.HttpResponse.reason === 'Invalid credentials') {
                                    this.getToken();
                                    this.validateAddress(index);
                                } else {
                                    var error_code = response.result.IPResult.HttpResponse.code;

                                    if (this.error_codes !== undefined) {
                                        var error_object = this.error_codes.find(x => x.ErrorCode === error_code.toString());
                                        this.siteList[index].errorMessage = error_object.ErrorTranslation;
                                    }

                                }

                            }
                        } else {
                            if (response.result.IPResult.HttpResponse === '') {
                                this.siteList[index].errorMessage = 'Inget svar mottaget på grund av felaktig datainmatning';
                            } else if (response.result.IPResult.HttpResponse.reason === 'Expired credentials' || response.result.IPResult.HttpResponse.reason === 'Invalid credentials') {
                                this.getToken();
                                this.validateAddress(index);
                            } else if (response.result.IPResult.HttpResponse === null) {
                                this.siteList[index].errorMessage = 'No response received please try with different input';
                            } else {
                                var error_code = response.result.IPResult.HttpResponse.code;
                                if (this.error_codes !== undefined) {
                                    var error_object = this.error_codes.find(x => x.ErrorCode === error_code.toString());
                                    this.siteList[index].errorMessage = error_object.ErrorTranslation;
                                }
                            }
                        }
                    })
                    .catch(error => {
                        //If API call fails
                        window.console.log(error);
                    });
            } else {
                //Throws an error if all the inputs for that index are not valid
                var error_object = this.error_codes.find(x => x.ErrorCode === 'EM20');
                const evt = new ShowToastEvent({
                    title: error_object.ErrorDescription,
                    message: error_object.ErrorTranslation,
                    variant: 'error'
                });
                this.dispatchEvent(evt);

            }
        } else {
            //Throws an Error if the user has not given any input for mandatory fields
            if (this.siteList[index].isDeleted === false && Array.isArray(this.error_codes)) {
                var error_object = this.error_codes.find(x => x.ErrorCode === 'EM5');
                const evt = new ShowToastEvent({
                    title: error_object.ErrorDescription,
                    message: error_object.ErrorTranslation,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            } else {
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'An unexpected error has occured, please contact an administrator',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        }

    }


    //for each input field change or service point selection this function is called to capture the value in the siteList array and display it.
    handleChange(event) {
        const fieldName = event.target.name;
        //if the fieldName is selectedServicePoint its a dropdown list of all service points, capturing the value of the selected service point
        if (fieldName === 'selectedServicePoint') {
            if (event.target.value === '') {
                this.siteList[event.target.dataset.opp].isServicePointSelected = false;
                this.siteList[event.target.dataset.opp].selectedServicePoint = {};
                const list1 = this.siteList[event.target.dataset.opp].servicePoints;
                for (let i = 0; i < list1.length; i++) {
                    if (list1[i] != undefined && Boolean(list1[i].isSelected) === true) {
                        list1[i].isSelected = false;
                    }
                }
            }
            else {
                this.siteList[event.target.dataset.opp].isValidated = true;
                this.siteList[event.target.dataset.opp].selectedServicePoint = this.siteList[event.target.dataset.opp].servicePoints[event.target.selectedIndex - 1];
                this.siteList[event.target.dataset.opp].isServicePointSelected = true;

                // this.siteList[event.target.dataset.opp].city = this.siteList[event.target.dataset.opp].servicePoints[event.target.selectedIndex - 1].City;
                // this.siteList[event.target.dataset.opp].streetName = this.siteList[event.target.dataset.opp].servicePoints[event.target.selectedIndex - 1].StreetName;
                // this.siteList[event.target.dataset.opp].streetNumber = this.siteList[event.target.dataset.opp].servicePoints[event.target.selectedIndex - 1].StreetNumber;
                // this.siteList[event.target.dataset.opp].postalCode = this.siteList[event.target.dataset.opp].servicePoints[event.target.selectedIndex - 1].Postcode;

                this.siteList[event.target.dataset.opp].servicePoints.forEach((item2, index) => {
                    if (index === event.target.selectedIndex - 1) {
                        this.siteList[event.target.dataset.opp].servicePoints[event.target.selectedIndex - 1].isSelected = true;
                        this.siteList[event.target.dataset.opp].servicePoints[event.target.selectedIndex - 1].Id = this.siteList[event.target.dataset.opp].selectedServicePoint.servicePointId;
                    } else {
                        this.siteList[event.target.dataset.opp].servicePoints[event.target.selectedIndex - 1].isSelected = false;
                    }
                })

                let duplicates = {};

                this.siteList.forEach((item, index) => {

                    if (item.isDeleted === false && item.selectedServicePoint.servicePointId !== undefined) {
                        duplicates[item.selectedServicePoint.servicePointId] = duplicates[item.selectedServicePoint.servicePointId] || [];
                        duplicates[item.selectedServicePoint.servicePointId].push(index);
                    }
                });

                for (let name in duplicates) {
                    var indices = [];
                    if (duplicates[name].length > 1) {
                        indices = duplicates[name];
                        if (indices[0] == event.target.dataset.opp) {
                            indices.pop();
                        } else {
                            indices.shift();
                        }

                        indices.forEach(ele => {
                            this.siteList[ele].isValidated = false;
                            this.siteList[ele].errorMessage = 'Denna anslutningspunkt är redan vald';
                            this.siteList[ele].isServicePointSelected = false;
                            this.siteList[ele].defaultServicePoint = false;
                            this.siteList[ele].selectedServicePoint = {};
                            this.siteList[ele].selectedServicePoint.servicePointId = '';
                            // this.siteList[event.target.dataset.opp].city = '';
                            // this.siteList[event.target.dataset.opp].streetName = '';
                            // this.siteList[event.target.dataset.opp].streetNumber = '';
                            // this.siteList[event.target.dataset.opp].postalCode  = '';
                        })
                    }
                }

            }
        } else {
            this.siteList[event.target.dataset.opp].isValidated = false;
            this.siteList[event.target.dataset.opp].isServicePointSelected = false;
            this.siteList[event.target.dataset.opp].defaultServicePoint = false;
            this.siteList[event.target.dataset.opp].servicePoints = Array();
            this.siteList[event.target.dataset.opp][fieldName] = event.target.value;
            let target = this.template.querySelector(`[data-id1="${event.target.dataset.opp}"]`);
            target.value = '';

        }
    }


    handleValidation(event) {
        this.validateAddress(event.target.dataset.opp);
    }

    async validateAll(_event) {

        await this.getToken();

        if (this.token.length > 0) {
            this.validationInProcess = true;
            const allValid = [...this.template.querySelectorAll('lightning-input')]
                .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
                }, true);
            if (allValid) {
                this.validateAllEvent = true;
                for (var i = 0; i < this.siteList.length; i++) {
                    this.validationInProcess = true;
                    if (this.siteList[i].isValidated === false && this.siteList[i].isDeleted === false) {
                        // console.log('Inside For loop', i);
                        await this.validateAddress(i, this.token);
                    }
                }
            }
            this.validationInProcess = false;
        } else {
            this.validateAllEvent = false;
            var error_object = this.error_codes.find(x => x.ErrorCode === 'EM20');
            const evt = new ShowToastEvent({
                title: error_object.ErrorDescription,
                message: error_object.ErrorTranslation,
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }

        this.validateAllEvent = false;

    }

    getToken() {
        const inputData = {
            "SetEndPoint": {
                "APIToken": "MC_CO_APIGarden_token"
            }
        }
        const params = {
            input: JSON.stringify(inputData),
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'MassCustomized_APIGarden',
            options: '{}',
        }
        
        return this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                this.token = response.result.IPResult.AuthToken;

                if (this.token == '' || this.token == undefined || this.token == null) {
                    const evt = new ShowToastEvent({
                        title: 'Error Occurred',
                        message: 'Uppdatera sidan och försök validera adresserna igen', //Meaning : refresh the page and try validation again.
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                }
            })
            .catch(error => {
                console.log(error);
            })
    }

    nextStep() {
        console.log(this.siteList);
        let array = this.siteList.filter(function (e) {
            return e.isDeleted === false;
        });
        //checking if any site is not validated or any service point is not selected
        const ValidationError = array.some(el => el.isValidated === false);
        const servicePointError = array.some(el => el.isServicePointSelected === false);
        const total_items = array.length;
        if (!ValidationError && !servicePointError) {
            if (this.omniJsonData) {
                let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
                updateOmniJsonData.siteList = this.siteList;
                updateOmniJsonData.fullPrecheck = true;
                updateOmniJsonData.partialPrecheck = false;
                updateOmniJsonData.totalItems = total_items;
                this.omniApplyCallResp(updateOmniJsonData); //updating OS data JSON
            }
            this.omniNextStep();
        } else {
            if (this.error_codes !== undefined) {
                var error_object = this.error_codes.find(x => x.ErrorCode === 'EM6')
                const evt = new ShowToastEvent({
                    title: error_object.ErrorDescription,
                    message: error_object.ErrorTranslation,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        }
    }
    nextStep1() {
        let array = this.siteList.filter(function (e) {
            return e.isDeleted === false;
        });
        //checking if any site is not validated or any service point is not selected
        const ValidationError = array.some(el => el.isValidated === false);
        const servicePointError = array.some(el => el.isServicePointSelected === false);
        const total_items = array.length;
        if (!ValidationError && !servicePointError) {
            if (this.omniJsonData) {
                let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
                updateOmniJsonData.siteList = this.siteList;
                updateOmniJsonData.partialPrecheck = true;
                updateOmniJsonData.fullPrecheck = false;
                updateOmniJsonData.totalItems = total_items;
                this.omniApplyCallResp(updateOmniJsonData); //updating OS data JSON
            }
            this.omniNextStep();
        } else {
            if (this.error_codes !== undefined) {
                var error_object = this.error_codes.find(x => x.ErrorCode === 'EM6')
                const evt = new ShowToastEvent({
                    title: error_object.ErrorDescription,
                    message: error_object.ErrorTranslation,
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        }
    }

    checkValidationOfFields() {
        const allValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
    }

    emptyFileSelector(event) {
        event.target.value = '';
    }

    getFileName(event) {
        this.showFileName = false;

        if (event.target.files.length > 0) {
            this.fileName = event.target.files[0].name;
            var fileExtension = this.fileName.split('.');
            this.showFileName = true;
            if (fileExtension[1] !== 'csv') {
                this.showFileName = false;
                const evt = new ShowToastEvent({
                    message: 'Fel filtyp vald, du kan bara ladda upp filtyp (.csv)',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
        }
    }

    readFiles() {

        if (this.showFileName && this.fileName !== '') {
            [...this.template
                .querySelector('input[type="file"]')
                .files].forEach(async file => {
                    try {
                        const dummyvar = file.toString();
                        const result = await this.load(file);
                        var lines = this.processData(result);
                        this.tempData = lines;
                        var i = 0;
                        this.getCurrentCount();
                        const checkCount = (this.currentCount === 1 && this.siteList[this.siteList.length - 1].city === '' && this.siteList[this.siteList.length - 1].streetName === '' && this.siteList[this.siteList.length - 1].streetNumber === '') ? 0 : this.currentCount;

                        if (this.tempData.length <= this.limitOnPage - checkCount) {
                            if (this.tempData.length > 1 && this.currentCount === 1 && this.siteList[this.siteList.length - 1].city === '' && this.siteList[this.siteList.length - 1].streetName === '' && this.siteList[this.siteList.length - 1].streetNumber === '') {
                                this.siteList.splice(this.siteList.length - 1, 1);
                            } else if (this.tempData.length > 1 && this.siteList[this.siteList.length - 1].city === '' && this.siteList[this.siteList.length - 1].streetName === '' && this.siteList[this.siteList.length - 1].streetNumber === '') {
                                this.siteList.splice(this.siteList.length - 1, 1)
                            }

                            let currentIndex = this.siteList.length - 1;

                            this.tempData.forEach(element => {
                                // var searchOption = element[i].toLowerCase() === 'address' ? '1' : '2';

                                this.siteList.push({
                                    addButton: true,
                                    // searchOption: searchOption,
                                    // addressType: this.searchOptions,
                                    city: element[i],
                                    postalCode: element[i + 1],
                                    streetName: element[i + 2],
                                    streetNumber: element[i + 3],
                                    gateNumber: element[i + 4],
                                    aptno: element[i + 5],
                                    // xCoordinate: element[i + 8],
                                    // yCoordinate: element[i + 7],
                                    // readonlyAddress: element[i].toLowerCase() === 'address' ? false : true,
                                    // readonlyCoordinates: element[i].toLowerCase() === 'address' ? true : false,
                                    errorMessage: '',
                                    isValidated: false,
                                    checkServicePoints: false,
                                    isServicePointSelected: false,
                                    defaultServicePoint: false,
                                    isDeleted: false,
                                    isDisabled: false,
                                    servicePoints: [],
                                    selectedServicePoint: {},
                                    accountId: this.AccountId,
                                    opportunityId: this.opportunityId
                                });
                                // setTimeout(() => {
                                //     currentIndex++;
                                //     var target = this.template.querySelector(`[data-item="${currentIndex}"]`);
                                //     target.selectedIndex = searchOption == '2' ? 1 : 0;
                                // }, 200);
                            });

                            this.positionOfAddButton();

                            //if file is uploaded successfully. 
                            const evt = new ShowToastEvent({
                                message: 'Filen har laddats upp',
                                variant: 'success',
                            });
                            this.dispatchEvent(evt);



                        } else {
                            // if file has more than the limit of the page.
                            const evt = new ShowToastEvent({
                                message: 'Filen du har valt är innehåller för många adresser',
                                variant: 'error'
                            });
                            this.dispatchEvent(evt);
                        }
                    } catch (e) {
                        const evt = new ShowToastEvent({
                            message: 'Error Occured',
                            variant: 'error'
                        });
                        this.dispatchEvent(evt);
                    }
                });
        } else {
            const evt = new ShowToastEvent({
                title: 'Ingen fil vald',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }
    }
    async load(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = function () {
                resolve(reader.result);
            };
            reader.onerror = function () {
                reject(reader.error);
            };

            reader.readAsText(file);
        });
    }

    processData(allText) {
        var allTextLines = allText.split(/\r\n|\n/);
        var headers;
        allTextLines.pop();
        if (allTextLines[0].includes(',')) {
            headers = allTextLines[0].split(',');
        }
        else if (allTextLines[0].includes(';')) {
            headers = allTextLines[0].split(';');
        }
        var lines = [];

        for (var i = 1; i < allTextLines.length; i++) {
            var data;
            if (allTextLines[i].includes(',')) {
                data = allTextLines[i].split(',');
            }
            else if (allTextLines[i].includes(';')) {
                data = allTextLines[i].split(';');
            }
            if (data.length == headers.length) {

                var tarr = [];
                for (var j = 0; j < headers.length; j++) {
                    tarr.push(data[j]);
                }
                lines.push(tarr);
            }
        }
        return lines;
    }

    downloadCSVFile() {

        const params = {
            input: '{}',
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'ExcelDownload_SampleTemplate',
            options: '{}',
        }

        this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                const excelString = response.result.IPResult.URL;

                if (excelString !== null) {
                    window.open(excelString);
                }
            })
            .catch(error => {
                console.log(error);
            })
    }

    get increamentalPrecheck() {
        //new items added
        let array = this.siteList.filter(function (e) {
            return e.isDeleted === false && e.isDisabled === false;
        });

        // any items if deleted
        let arr1 = this.siteList.filter(ele => {
            return ele.isDeleted === true;
        });

        //items already present in database
        let arr2 = this.siteList.filter(ele => {
            return ele.isDisabled === true;
        });

        if (arr1.length > 0 || (array.length > 0 && arr2.length > 0)) {
            return false;
        } else {
            return true;
        }
    }

    deleteFile(event) {
        event.preventDefault();
        this.fileName = '';
    }

}