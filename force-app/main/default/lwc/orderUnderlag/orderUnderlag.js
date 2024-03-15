import { LightningElement, track, api } from 'lwc';
import { AllmantTab } from 'c/allmantTab';
import { Kundaninformation } from 'c/kundaninformation';
import { Flit } from 'c/flit';
import { Kontaktpersoner } from 'c/kontaktpersoner'
import { AffarInformation } from 'c/affarInformation'
import { Anslutning } from 'c/anslutning'
import { Ovrigt } from 'c/ovrigt';
import { Hardvara } from 'c/hardvara';
import { ProdukterTab } from 'c/produkterTab';
import { Fatjanster } from 'c/fatjanster';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { ServiceAvtal } from 'c/serviceAvtal';
import { Nathyara } from 'c/nathyara';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class OrderUnderlag extends OmniscriptBaseMixin(LightningElement) {

    @track data = [];
    @track jsondata;
    @track version;
    @track activationLabel;
    @track activationtypemapinprodukter = [];
    @track proCode1 = [];
    @track activeTabAllmantTabs = '1';
    @track toggleOptionalTab3 = false;
    @track activeTabProdukterTabs = 'Hardvara';
    @track activeServiceTab = 'service';
    @api activeTabValue = 1;
    @track dataFromChild = {};
    @track dataFromChild2 = {};
    @track dataFromChild3 = {};
    @track dataFromChild4 = {};
    @track dataFromChild5 = {};
    @track errorCheck = [];
    @track tabVisited = [];
    @track confirmationModal = false;
    @track activeTab = 'one';
    @track skapabutton = true;
    @track skapabuttonlight = true;
    @api
    get customTest() {
        return this.data;
    }

    set customTest(value1) {
        this.data = JSON.parse(JSON.stringify(value1));
    }

    get bool() {
        return [
            { label: 'Ja', value: 'Ja' },
            { label: 'Nej', value: 'Nej' },
        ];
    }

    connectedCallback() {
        this.data = JSON.parse(JSON.stringify(this.data));
        let updateOmniJsonData = JSON.parse(JSON.stringify(this.omniJsonData));
        this.version = updateOmniJsonData.version;
        this.activationlabel = updateOmniJsonData.activationlabel;
        console.log('activationlabel>>>'+this.activationlabel);
        this.activationtypemapinprodukter =updateOmniJsonData.activationtypemapinprodukter;
        console.log('activationtypemapinprodukterorder>>>'+(JSON.stringify(this.activationtypemapinprodukter)));
        for (let i = 0; i <= 2; i++) {
            this.errorCheck[i] = true;
            this.tabVisited[i] = false;
        }
    }

    getDat(event) {
        this.jsondata = event.detail;
    }

    getDataFromChild2(event) {
        this.dataFromChild2['serviceAvtal'] = event.detail;
        this.omniApplyCallResp(this.dataFromChild2);
    }

    getDataFromNathyara(event) {
        this.dataFromChild3['nathyara'] = event.detail;
        this.omniApplyCallResp(this.dataFromChild3);
    }

    getDataFromChild4(event) {
        let y = this.activeTabProdukterTabs;
        this.dataFromChild4[y] = event.detail;
        this.omniApplyCallResp(this.dataFromChild4);
    }

    getDataFromChild5(event) {
        this.dataFromChild5['flit'] = event.detail;
        this.omniApplyCallResp(this.dataFromChild5);

    }
    getDataFromChild(event) {
        let x = this.activeTabAllmantTabs;
        this.dataFromChild[x] = event.detail;
        if (this.dataFromChild["1"].offertype == "FLIT (Capex)" || this.dataFromChild["1"].offertype == "FLIT Nätanslutning (0 Capex)") {
            this.toggleOptionalTab3 = true;
        }
        else {
            this.toggleOptionalTab3 = false;
        }

        this.omniApplyCallResp(this.dataFromChild);
    }

    get bDisablePrevBtn() {
        return Number(this.activeTabAllmantTabs) == 1 ? true : false;
    }
    get bDisableNext3Button() {
        return this.activeServiceTab == 'nathyara' && this.toggleOptionalTab3 == false;
    }


    handleActive(event) {
        this.lastActiveTab = this.activeTabAllmantTabs;
        this.activeTabAllmantTabs = event.target.value;
        this.validationCheck(event.target.value, '', 'handleChange');
    }

    handleActiveProdukterTab(event) {
        this.lastActiveTab = this.activeTabProdukterTabs;
        this.activeTabProdukterTabs = event.target.value;
    }

    validationCheck(value, button, handler) {
        let x = 0;

        if (button === 'next') {
            x = Number(value) - 1;
        } else if (button === 'prev') {
            x = Number(value) + 1;
        } else if (handler === 'handleChange') {
            x = Number(this.lastActiveTab);
        }

        switch (x) {
            case 1:
                if ('1' in this.dataFromChild) {
                    this.tabVisited[0] = true;
                    if (this.dataFromChild['1'].Brand == '' || this.dataFromChild['1'].typeofAffar == '' && this.dataFromChild['1'].typeAffar == '') {
                        this.errorCheck[0] = true;
                        const evt = new ShowToastEvent({
                            message: 'Fyll i tvingande fält i Varumärke och Typ av affär och gå sedan vidare.',
                            variant: 'error',
                            mode: ''
                        });
                        this.dispatchEvent(evt);
                    } else {
                        this.errorCheck[0] = false;
                        if (button === 'next') {
                            x = x + 1;
                            this.activeTabAllmantTabs = x.toString();
                        } else if (handler === 'handleChange') {
                            this.activeTabAllmantTabs = this.lastActiveTab;
                        }

                    }
                }
                break;
            case 2:
                if ('2' in this.dataFromChild) {
                    this.tabVisited[1] = true;
                    if (this.dataFromChild['2'].KundGatuadress == '' || this.dataFromChild['2'].KundPostnummer == '' || this.dataFromChild['2'].KundPostort == '') {
                        this.errorCheck[1] = true;
                        const evt = new ShowToastEvent({
                            message: 'Fyll i tvingande fält i Fakturaadress - Gatuadress, Postnummer samt Postort och gå sedan vidare.',
                            variant: 'error',
                            mode: ''
                        });
                        this.dispatchEvent(evt);
                    } else {
                        this.errorCheck[1] = false;
                        if (button === 'next') {
                            x = x + 1;
                            this.activeTabAllmantTabs = x.toString();
                        } else if (button === 'prev') {
                            x = x - 1;
                            this.activeTabAllmantTabs = x.toString();
                        } else if (handler === 'handleChange') {
                            this.activeTabAllmantTabs = this.lastActiveTab;
                        }
                    }
                } else if (this.tabVisited[1]) {
                    this.errorCheck[1] = false
                    const evt = new ShowToastEvent({
                        message: 'Fyll i tvingande fält i XYZ-kolumnen och gå sedan vidare.',
                        variant: 'error',
                        mode: ''
                    });
                    this.dispatchEvent(evt);
                }

                break;
            case 3:
                if ('3' in this.dataFromChild) {
                    this.tabVisited[2] = true;
                    if (this.dataFromChild['3'].BestallareNamn == '' || this.dataFromChild['3'].BestallareTelefonnummer == '' || this.dataFromChild['3'].BestallareEpost == '' || this.dataFromChild['3'].Kontaktperson1Namn == '' || this.dataFromChild['3'].Kontaktperson1Telefonnummer == '' || this.dataFromChild['3'].Kontaktperson1Epost == '' || this.dataFromChild['3'].Kontaktperson1Gatuadress == '' || this.dataFromChild['3'].Kontaktperson1Postnummer == '' || this.dataFromChild['3'].Kontaktperson1Postort == '') {
                        this.errorCheck[2] = true;
                        const evt = new ShowToastEvent({
                            message: 'Fyll i tvingande fält i Beställare hos avtalspart - Namn, Telefonnummer, Epost. Kontaktperson 1: Namn, Telefonnummer, Epost, Gatuadress, Postnummer, Postort och gå sedan vidare.',
                            variant: 'error',
                            mode: ''
                        });
                        this.dispatchEvent(evt);
                    } else {
                        this.errorCheck[2] = false;
                        if (button === 'next') {
                            x = x + 1;
                            this.activeTabAllmantTabs = x.toString();
                        } else if (button === 'prev') {
                            x = x - 1;
                            this.activeTabAllmantTabs = x.toString();
                        } else if (handler === 'handleChange') {
                            this.activeTabAllmantTabs = this.lastActiveTab;
                        }
                    }
                } else if (this.tabVisited[2]) {
                    const evt = new ShowToastEvent({
                        message: 'Fyll i tvingande fält i XYZ-kolumnen och gå sedan vidare.',
                        variant: 'error',
                        mode: ''
                    });
                    this.dispatchEvent(evt);
                }

                break;
            case 4:
                if (button === 'next') {
                    x = x + 1;
                    this.activeTabAllmantTabs = x.toString();
                } else if (button === 'prev') {
                    x = x - 1;
                    this.activeTabAllmantTabs = x.toString();
                } else if (handler === 'handleChange') {
                    this.activeTabAllmantTabs = this.lastActiveTab;
                }
                break;

            case 5:
                if (button === 'next') {
                    x = x + 1;
                    this.activeTabAllmantTabs = x.toString();
                } else if (button === 'prev') {
                    x = x - 1;
                    this.activeTabAllmantTabs = x.toString();
                } else if (handler === 'handleChange') {
                    this.activeTabAllmantTabs = this.lastActiveTab;
                }
                break;

            case 6:
                if (button === 'prev') {
                    x = x - 1;
                    this.activeTabAllmantTabs = x.toString();
                } else if (handler === 'handleChange') {
                    this.activeTabAllmantTabs = this.lastActiveTab;
                }
                break;


            default:
                break;
        }
    }

    goNext() {
        this.activeTabValue = Number(this.activeTabAllmantTabs) + 1;
        if (this.activeTabValue == 7) {
            this.activeTab = 'two';
            this.activeTabProdukterTabs = 'Hardvara';
        } else {
            this.validationCheck(this.activeTabValue, 'next', '');
        }

    }

    goBack() {
        this.activeTabValue = Number(this.activeTabAllmantTabs) - 1;
        this.validationCheck(this.activeTabValue, 'prev', '');
    }

    goNext2() {
        this.activeTabProdukterTabs = this.activeTabProdukterTabs === 'Hardvara' ? 'FAtjanster' : this.activeTabProdukterTabs === 'FAtjanster' ? 'Produkter' : '';
        if (this.activeTabProdukterTabs === 'Produkter') {
            if (this.data.isMDUFSWAN === "true") {
                if (this.dataFromChild4['FAtjanster'].Centralpunktsadress == '' || this.dataFromChild4['FAtjanster'].FNTnummer == '' || this.dataFromChild4['FAtjanster']['natbrygga'] == '' || this.dataFromChild4['FAtjanster'].Servicetyp == '') {
                    const evt = new ShowToastEvent({
                        message: 'Fyll i tvingande fält i Centralpunktsadress, FNT-nummer, Är det en ny nätbrygga?, Servicetyp och gå sedan vidare.',
                        variant: 'error',
                        mode: ''
                    });
                    this.dispatchEvent(evt);
                    this.activeTabProdukterTabs = 'FAtjanster';
                }
            }
        } if (this.activeTabProdukterTabs == '') {
            this.activeTab = 'Serviceavtal';
        }
    }

    goBack2() {
        this.activeTabProdukterTabs = this.activeTabProdukterTabs === 'Produkter' ? 'FAtjanster' : this.activeTabProdukterTabs === 'FAtjanster' ? 'Hardvara' : '';

        if (this.activeTabProdukterTabs == '') {
            this.activeTab = 'one';
            this.activeTabAllmantTabs = '6';
        }
    }

    goNext3() {
        this.activeServiceTab = this.activeServiceTab == 'service' ? 'nathyara' : '';

        if (this.activeServiceTab == '' && this.toggleOptionalTab3) {
            this.activeTab = 'flit';
        }
    }

    goBack3() {
        this.activeServiceTab = this.activeServiceTab == 'nathyara' ? 'service' : '';

        if (this.activeServiceTab == '') {
            this.activeTab = 'two';
            this.activeTabProdukterTabs = 'Produkter';
        }
    }

    goBack4() {
        this.activeTab = 'Serviceavtal';
        this.activeServiceTab = 'nathyara';
    }

    get bNextStepDisable() {
        if (this.activeServiceTab == 'nathyara' && this.toggleOptionalTab3 == false) {
            this.skapabutton = false;
            return this.skapabutton;
        }
        else if (this.activeTab == 'flit' && this.toggleOptionalTab3 == true) {
            this.skapabutton = false;
            return this.skapabutton;
        }
        else {
            return this.skapabutton;
        }
    }


    get bNextStepDisablelight() {
        if (this.activeTabValue == 6) {
            this.skapabuttonlight = false;
            return this.skapabuttonlight;
        }
        else
            return this.skapabuttonlight;
    }

    OpenConfirmationModal() {
        this.confirmationModal = true;
    }

    Cancel() {
        this.confirmationModal = false;
    }

    Confirm() {
        this.confirmationModal = false;
        this.omniApplyCallResp(this.dataFromChild);
        this.omniNextStep();
    }

}