import { LightningElement, track, api } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';
import { GuidedSellingInfo } from 'c/guidedSellingInfo';

export default class StaticPage extends OmniscriptBaseMixin(LightningElement) {
    @track items = [
        {
            label: 'Question 1',
            name: '1',
            expanded: false,
            items: [
                {
                    label: 'label 222',
                    name: '3',
                    metatext: 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.It has survived not only five centuries, but also the leap into electronic',
                    expanded: false,
                    items: [],
                },
            ],
        },
        {
            label: 'Question 2',
            name: '1',
            expanded: false,
            items: [
                {
                    label: 'Answer text',
                    name: '3',
                    expanded: false,
                    items: [],
                },
            ],
        },
        {
            label: 'Question 3',
            name: '1',
            expanded: false,
            items: [
                {
                    label: 'Answer text',
                    name: '3',
                    expanded: false,
                    items: [],
                },
            ],
        },
    ];

    @track mapMarkers = [
        {
            location: {
                // Location Information
                City: 'San Francisco',
                Country: 'USA',
                PostalCode: '94105',
                State: 'CA',
                Street: '50 Fremont St',
            },

            // For onmarkerselect
            value: 'SF1',

            // Extra info for tile in list & info window
            icon: 'standard:account',
            title: 'Julies Kitchen', // e.g. Account.Name
            description: 'This is a long description',
        },
        {
            location: {
                // Location Information
                City: 'San Francisco',
                Country: 'USA',
                PostalCode: '94105',
                State: 'CA',
                Street: '30 Fremont St.',
            },

            // For onmarkerselect
            value: 'SF2',

            // Extra info for tile in list
            icon: 'standard:account',
            title: 'Tender Greens', // e.g. Account.Name
        },
    ];

    @track selectedItem = 'reports_recent';
    @track currentContent = 'reports_recent';
    @track updatedCount = 12;
    @track recentlyviewed = true;
    @track value1 = '';
    @track value2 = '';
    @track vlaue3 = '';
    @track data = [];
    @track finalArray = [];
    @track dataObject = {}
    @track imagesURL;
    @api 
    get drImages(){
        return this.imagesURL;
    }
    set drImages(value){
        if(value === null){
            this.imagesURL = false;
        } else {
            this.imagesURL = value;
        }
    }
    _actionUtilClass;
    _ns = getNamespaceDotNotation();


    connectedCallback() {
        this._actionUtilClass = new OmniscriptActionCommonUtil();
        this.data = this.omniJsonData.AnswersArr;

        if (this.data !== null && Array.isArray(this.data)) {
            for (var i = 0; i < this.data.length; i++) {
                this.dataObject[this.data[i].QuestionLabel] = this.data[i].Notes;
            }
        }
    }

    renderedCallback(){
        this.template.querySelector('c-guided-selling-info').handleData(this.imagesURL);
    }

    handleChange(event) {
        // console.log(event.target.name, event.target.value);

        this.dataObject[event.target.name] = event.target.value;
    }

    nextStep() {

        const objectArray = Object.entries(this.dataObject);
        objectArray.forEach(([key, value]) => {

            this.finalArray.push({
                'QuestionLabel': key,
                'Notes': value
            })
        });

        const inputData = {
            'OpportunityId': this.omniJsonData.ContextId,
            'AnswersArr': this.finalArray
        }

        const params = {
            input: inputData,
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: 'TeliaSE_MC_CO_SaveAnswersIP',
            options: '{}',
        };

        this._actionUtilClass
            .executeAction(params, null, this, null, null)
            .then(response => {
                console.log(response);
                this.omniNextStep();
            })
            .catch(error => {
                console.log(error);
            });
    }
}