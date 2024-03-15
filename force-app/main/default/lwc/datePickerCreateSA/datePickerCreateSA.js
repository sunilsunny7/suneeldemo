import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class DatePickerCreateSA extends OmniscriptBaseMixin(LightningElement) {

    @track minDate1;
    @track disabledDays1;
    @track disableDates1;
    @track products = [];

    @api
    get disableDates() {
        return this.disableDates1;
    }
    set disableDates(value) {
        if (value === undefined) {
            this.disableDates1 = false;
        } else {
            this.disableDates1 = value;
        }
    }

    @api
    get customProducts() {
        return this.products;
    }
    set customProducts(val) {
        if (val === undefined) {
            this.products = false;
            this.disableDates1 = false;
        } else {
            this.products = val;
        }
    }

    @api
    get madamAgreementNumber() {
        return this.madamAgreementNr;
    }
    set madamAgreementNumber(val) {
        if (val == undefined) {
            this.madamAgreementNr = false;
        } else {
            this.madamAgreementNr = val;
        }
    }

    @api
    get madamAgreementDate() {
        return this.madamAgreementEndDate;
    }
    set madamAgreementDate(val) {
        if (val === undefined) {
            this.madamAgreementEndDate = false;
        } else {
            this.madamAgreementEndDate = val;
        }
    }


    mobileCommitmentPeriod;
    tpCommitmentPeriod;
    tppCommitmentPeriod;
    scCommitmentPeriod;
    ocCommitmentPeriod;

    @track isCommitmentPeriodSame = false;
    @track istppMobileCommitmentSame = false;
    @track isScMobileCommitmentSame = false;
    @track isTppProductPresent = false;
    @track isOcMobileCommitmentSame = false;
    @track displayMadamMessage = false;

    connectedCallback() {
        this.products = JSON.parse(JSON.stringify(this.products));
        this.disableDays = "0,6";

        if (this.madamAgreementNumber != null && this.madamAgreementDate != null && this.madamAgreementNumber != '' && this.madamAgreementDate != '') {
            this.displayMadamMessage = true;
        }

        if (this.products.length > 0) {
            this.products.forEach(ele => {
                ele['originalStartDate'] = ele.startDate;
                ele['originalEndDate'] = ele.endDate;
                ele['disabledCheckbox'] = ele.InitialValue ? true : false;
                ele['originalEndMinDate'] = ele.minEndTime;

                if(ele.disableDate == true || ele.InitialValue == false){
                    ele['hideOrShowCheckbox'] = false;
                } else {
                    ele['hideOrShowCheckbox'] = true;
                }

                if (ele.ProductCode.includes('MOB_MULTI_ALL_IN_PLUS') || ele.ProductCode.includes('MOB_MULTI_TOTAL')) {
                    this.mobileCommitmentPeriod = ele.CommitmentPeriod;
                }
                if (ele.ProductCode.includes('TP_OFFER')) {
                    this.tpCommitmentPeriod = ele.CommitmentPeriod;
                }
                if (ele.ProductCode.includes('TPP_OFFER')) {
                    this.tppCommitmentPeriod = ele.CommitmentPeriod;
                    this.isTppProductPresent = true;
                }
                if (ele.ProductCode.includes('SC_OFFER')) {
                    this.scCommitmentPeriod = ele.CommitmentPeriod;
                }
                if (ele.ProductCode.includes('OC_OFFER')) {
                    this.ocCommitmentPeriod = ele.CommitmentPeriod;
                }
            });
        }
        this.isCommitmentPeriodSame = this.checkCommitmentPeriod(this.mobileCommitmentPeriod, this.tpCommitmentPeriod);
        this.istppMobileCommitmentSame = this.checkCommitmentPeriod(this.mobileCommitmentPeriod, this.tppCommitmentPeriod);
        this.isScMobileCommitmentSame = this.checkCommitmentPeriod(this.mobileCommitmentPeriod, this.scCommitmentPeriod);
        this.isOcMobileCommitmentSame = this.checkCommitmentPeriod(this.mobileCommitmentPeriod, this.ocCommitmentPeriod)
        this.products = JSON.parse(JSON.stringify(this.products));
    }

    renderedCallback() {
        const todaysDate = new Date();
        this.products.forEach((e, index) => {
            const startDate = new Date(e.startDate);
            if (startDate < todaysDate) {
                let target = this.template.querySelectorAll(`[data-opp="${index}"]`);
                target.forEach(e => {
                    e.classList.add('datePickerColorBlack');
                    e.classList.remove('datepickerColorWhite');
                })
            }
        });
    }


    checkCommitmentPeriod(val1, val2) {
        if (val1 === val2) {
            return false;
        } else if (val2 == null || val2 == '' || val2 === undefined || val1 == null || val1 == '' || val1 === undefined) {
            return false;
        } else {
            return true;
        }
    }

    jobmobilProducts = ["MOB_MULTI_ALL_IN_PLUS",
        "MOB_MULTI_ALL_IN_PLUS_V2",
        "MOB_MULTI_ALL_IN_PLUS_V3",
        "MOB_MULTI_TOTAL",
        "MOB_MULTI_TOTAL_V2",
        "MOB_MULTI_TOTAL_V3"
    ];

    otherProducts = [
        "TP_OFFER",
        "TPP_OFFER",
        "SC_OFFER",
        "OC_OFFER"
    ];

    jobmobilFound = false;
    otherProductsPresent = false;
    finalDate;
    calculateEndDate;
    errorMessageForOtherProducts = false;
    productcodes = [];

    handleChange(event) {
        if (event.target.value == null) {
            this.products[event.target.dataset.opp].startDate = this.products[event.target.dataset.opp].startDate;
            this.changeColor(event.target.dataset.opp, 'white');
        } else {

            const selectedDate = new Date(event.target.value);
            this.products[event.target.dataset.opp].startDate = event.target.value;

            this.products[event.target.dataset.opp].InitialValue = false;
            const productCode = event.target.dataset.productcode;
            const productName = this.products[event.target.dataset.opp].ProductName;

            this.products = JSON.parse(JSON.stringify(this.products));


            if (this.products[event.target.dataset.opp].endDate != null && this.products[event.target.dataset.opp].endDate != '' && this.products[event.target.dataset.opp].endDate != undefined) {
                this.calculateEndDate = new Date(this.products[event.target.dataset.opp].endDate);
            } else {
                this.calculateEndDate = new Date(this.products[event.target.dataset.opp].minEndTime);
            }

            var month;

            if (this.products[event.target.dataset.opp].CommitmentPeriod == '1 month') {
                var month = String(parseInt(selectedDate.getMonth()) + 2);
            } else if (this.products[event.target.dataset.opp].CommitmentPeriod == 'Uncommitted') {
                this.finalDate = this.products[event.target.dataset.opp].originalEndDate;
            } else {
                var month = String(parseInt(selectedDate.getMonth()) + 1);
            }

            const year = this.calculateEndDate.getFullYear();
            const endTime = String(year) + '-' + month + '-' + String(selectedDate.getDate());


            if (this.products[event.target.dataset.opp].CommitmentPeriod != 'Uncommitted') {
                this.finalDate = new Date(endTime);
                if (this.finalDate.getDay() == 6) {
                    this.finalDate.setDate(this.finalDate.getDate() + 2);
                } else if (this.finalDate.getDay() == 0) {
                    this.finalDate.setDate(this.finalDate.getDate() + 1);
                }
            } else {
                this.finalDate = this.products[event.target.dataset.opp].originalEndDate;
            }


            this.products[event.target.dataset.opp].endDate = this.finalDate;
            this.products = JSON.parse(JSON.stringify(this.products));
            if (productCode == 'TP_OFFER' || productCode == 'TPP_OFFER' || productCode == 'SC_OFFER' || productCode == 'OC_OFFER') {
                const datesToCompare = this.searchForJobMobilProducts(this.jobmobilProducts, 'start');
                const jobMobilvalues = Object.values(datesToCompare);

                if (Array.isArray(jobMobilvalues) && jobMobilvalues.length > 0) {
                    jobMobilvalues.forEach(ele => {
                        this.jobmobilFound = false;
                        const checkDate = new Date(ele.date);

                        var mobileDateNotSelected = false;
                        let target = this.template.querySelectorAll(`[data-opp="${ele.index}"]`);

                        target.forEach(domElement => {
                            if (domElement.classList.contains('datepickerColorWhite') && this.products[ele.index].InitialValue == false) {
                                mobileDateNotSelected = true;
                            }
                        });

                        if (mobileDateNotSelected) {
                            this.products[event.target.dataset.opp].startDate = this.products[event.target.dataset.opp].originalStartDate;
                            this.products[event.target.dataset.opp].endDate = this.products[event.target.dataset.opp].originalEndDate;
                            var confirmed = confirm('Vänligen välj startdatum för Jobbmobil först.');
                            if (confirmed) {
                                this.products = JSON.parse(JSON.stringify(this.products));
                                this.changeColor(event.target.dataset.opp, 'white');
                            }
                        } else {
                            if (selectedDate < checkDate) {
                                this.products[event.target.dataset.opp].startDate = this.products[event.target.dataset.opp].originalStartDate;
                                this.products[event.target.dataset.opp].endDate = this.products[event.target.dataset.opp].originalEndDate;
                                this.jobmobilFound = true;
                                this.changeColor(event.target.dataset.opp, 'white');
                            } else {
                                this.products[event.target.dataset.opp].startDate = event.target.value;
                                this.changeColor(event.target.dataset.opp, 'black');

                            }
                            if (this.jobmobilFound) {
                                var confirmed = confirm('Vänligen välj ett startdatum för ' + productName + ' som inträffar samtidigt eller efter startdatum för Jobbmobil.');
                                if (confirmed) {
                                    this.products = JSON.parse(JSON.stringify(this.products));
                                    this.changeColor(event.target.dataset.opp, 'white');
                                }
                            }
                        }


                    })
                }

            } else if (this.jobmobilProducts.includes(productCode)) {
                this.products.forEach((ele, index) => {

                    const dateChanged = false;
                    let target = this.template.querySelectorAll((`[data-opp="${index}"]`)); //Checking if user has changed date for Other products which are dependent on mobile.


                    target.forEach(domElement => {
                        if (domElement.classList.contains('datepickerColorBlack')) {
                            dateChanged = true;
                        }
                    });


                    if (this.otherProducts.includes(ele.ProductCode) && dateChanged) {
                        if (new Date(ele.startDate) < selectedDate) {
                            this.errorMessageForOtherProducts = true;
                            this.productcodes.push({ 'code': ele.ProductCode, 'name': ele.ProductName, 'index': index });
                        }
                    }
                });

                if (this.errorMessageForOtherProducts) {
                    this.productcodes.forEach(ele => {

                        this.products[ele.index].startDate = this.products[event.target.dataset.opp].originalStartDate;
                        this.products[ele.index].endDate = this.products[event.target.dataset.opp].originalEndDate;
                        const abc = this.changeColor(ele.index, 'white');
                        const ProductName = ele.name;
                        const evt = new ShowToastEvent({
                            message: 'Vänligen välj ett startdatum för ' + ProductName + ' som inträffar samtidigt eller efter startdatum för Jobbmobil',
                            variant: 'error'
                        });
                        this.dispatchEvent(evt);
                    })
                } else {
                    this.products[event.target.dataset.opp].startDate = event.target.value;
                    this.changeColor(event.target.dataset.opp, 'black');
                }
            }
            else {
                this.products[event.target.dataset.opp].startDate = event.target.value;
                this.changeColor(event.target.dataset.opp, 'black');
            }

            setTimeout(() => {
                this.products = JSON.parse(JSON.stringify(this.products));
            }, 500);
        }

    }

    changeColor(index, color) {
        const currentIndex = index;
        let target = this.template.querySelectorAll(`[data-opp="${currentIndex}"]`);

        if (color == 'black') {
            target.forEach(e => {
                e.classList.add('datePickerColorBlack');
                e.classList.remove('datepickerColorWhite');
            });
        }
        if (color == 'white') {
            target.forEach(e => {
                e.classList.add('datepickerColorWhite');
                e.classList.remove('datePickerColorBlack');
            });
        }
    }

    alertForLesserThan = false;
    alertForGreaterThan = false;
    uncommittedError = false;
    handleChangeEndDate(event) {
        this.products[event.target.dataset.opp].endDate = event.target.value;
        const productCode = event.target.dataset.productcode;
        const productName = this.products[event.target.dataset.opp].ProductName;
        const commitmentPeriod = this.products[event.target.dataset.opp].CommitmentPeriod;
        const selectedDate = new Date(event.target.value);

        this.products = JSON.parse(JSON.stringify(this.products));

        if (productCode == 'TP_OFFER' || productCode == 'TPP_OFFER' || productCode == 'SC_OFFER' || productCode == 'OC_OFFER') {
            const datesToCompare = this.searchForJobMobilProducts(this.jobmobilProducts, 'end');
            const jobMobilvalues = Object.values(datesToCompare);

            if (Array.isArray(jobMobilvalues) && jobMobilvalues.length > 0) {
                jobMobilvalues.forEach(ele => {
                    const checkDate = new Date(ele.date);
                    if (selectedDate < checkDate) { //selected date is other product end Date & check date is mobile product date
                        this.alertForLesserThan = true;
                    } else if (selectedDate > checkDate) {
                        this.alertForGreaterThan = true;
                    } else if (selectedDate < new Date() && commitmentPeriod == 'Uncommitted') {
                        this.uncommittedError = true;
                    }
                });

                if (this.alertForLesserThan) {
                    alert('OBS! Du har valt ett slutdatum för ' + productName + ' som slutar tidigare än Mobilt. Vi rekommenderar att du väljer samma datum, men om du vill fortsätta, glöm inte att förklara konsekvenserna av detta för din kund.')
                }
                if (this.alertForGreaterThan) {
                    alert('OBS! Du har valt ett slutdatum för Mobilt som slutar tidigare än ' + productName + ' Glöm inte att förklara konsekvenserna av detta för din kund')
                }
                if (this.uncommittedError) {
                    if (productCode == 'SC_OFFER' || productCode == 'OC_OFFER') {
                        alert('Kunden har ett obundet mobilavtal. Vänligen välj ett slutdatum för ' + productName + ' som är 3 månader från startdatum.');
                    }
                }
            }
        }
    }

    arrayOfDates = [];
    searchForJobMobilProducts(jobmobilProducts, value) {
        this.arrayOfDates = [];
        this.products.forEach((ele, index) => {
            if (jobmobilProducts.includes(ele.ProductCode)) {
                if (value == 'start') {
                    this.arrayOfDates.push({ 'date': ele.startDate, 'index': index });
                }
                if (value == 'end') {
                    this.arrayOfDates.push({ 'date': ele.startDate, 'index': index });
                }
            }
        });

        if (Array.isArray(this.arrayOfDates) && this.arrayOfDates.length > 0) {
            return this.arrayOfDates;
        } else {
            return false;
        }

    }

    searchForTpTppScOc(otherProducts) {
        var arrayOfDates = [];
        this.products.forEach((ele) => {
            if (otherProducts.includes(ele.ProductCode)) {
                arrayOfDates.push(ele.startDate);
            }
        });

        if (Array.isArray(arrayOfDates) && arrayOfDates.length > 0) {
            return arrayOfDates;
        } else {
            return false;
        }
    }

    isEmpty = false;
    nextStep() {
        if (Array.isArray(this.products)) {
            this.products.forEach((ele, index) => {

                if (ele.InitialValue === false) {
                    this.isEmpty = false;
                    let target = this.template.querySelectorAll(`[data-opp="${index}"]`);

                    target.forEach(domElement => {
                        if (domElement.classList.contains('datepickerColorWhite')) {
                            this.isEmpty = true;
                        }
                    });
                }

            });

            if (this.isEmpty) {
                const evt = new ShowToastEvent({
                    message: 'Vänligen välj start och/eller slutdatum för alla valda produkter innan du går vidare till nästa steg.',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            }
            else {
                if (this.products.length > 0) {
                    this.products.forEach(ele => {
                        if (typeof (ele.startDate) == 'string') {
                            const x = new Date(ele.startDate);
                            const month = String(x.getMonth() + 1).length === 1 ? '0' + String(x.getMonth() + 1) : String(x.getMonth() + 1);
                            const dateNr = String(x.getDate()).length === 1 ? '0' + String(x.getDate()) : String(x.getDate());
                            ele.startDate = String(x.getFullYear()) + '-' + month + '-' + dateNr;
                        }
                        if (typeof (ele.endDate) == 'string') {
                            const y = new Date(ele.endDate);
                            const month = String(y.getMonth() + 1).length === 1 ? '0' + String(y.getMonth() + 1) : String(y.getMonth() + 1);
                            const dateNr = String(y.getDate()).length === 1 ? '0' + String(y.getDate()) : String(y.getDate());
                            ele.endDate = String(y.getFullYear()) + '-' + month + '-' + dateNr;
                        }

                    });

                    if (this.omniJsonData) {
                        let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
                        updateOmniJsonData.Quote.Line = this.products;
                        this.omniApplyCallResp(updateOmniJsonData);
                        this.omniNextStep();
                    }
                }

            }
        }
    }

    handleCheckbox(event) {
        const currentIndex = event.target.dataset.checkboxid;
        if (event.target.checked === true) {
            this.products[currentIndex].startDate = this.products[currentIndex].minStartTime;
            this.products[currentIndex].endDate = this.products[currentIndex].minEndTime;
            this.products[currentIndex].InitialValue = false;
            this.changeColor(currentIndex, 'white');
        } else {
            this.products[currentIndex].startDate = this.products[currentIndex].originalStartDate;
            this.products[currentIndex].endDate = this.products[currentIndex].originalEndDate;
            this.products[currentIndex].InitialValue = true;
            this.changeColor(currentIndex, 'black');
        }

        this.products = JSON.parse(JSON.stringify(this.products));
    }



}