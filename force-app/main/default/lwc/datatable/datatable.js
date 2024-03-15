import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { OmniscriptBaseMixin } from 'vlocity_cmt/omniscriptBaseMixin';
import { getNamespaceDotNotation } from 'vlocity_cmt/omniscriptInternalUtils';
import { OmniscriptActionCommonUtil } from 'vlocity_cmt/omniscriptActionUtils';

export default class Datatable extends OmniscriptBaseMixin(LightningElement) {
    @track gridData = [];
    @track temp = [];
    @track disableGroupChecks = false;
    @track disableSiteChecks = false;

    @track currentSelectedRows = [];
    @track selectedSites = [];
    @track selectedGroups = [];
    @track groupsLimit = 11;
    _actionUtil;
    _ns = getNamespaceDotNotation();
    @track selectedGroupName = 'select';
    @track groupNames = [];
    @track finalValidation = false;
    @track finalGroupingList = [];

    connectedCallback() {
        this._actionUtil = new OmniscriptActionCommonUtil();
        this.getDataFromIP();
    }

    getDataFromIP() {
        const options = {};
        const params = {
            input: this.omniJsonData,
            sClassName: `${this._ns}IntegrationProcedureService`,
            sMethodName: "Process_Groups",
            options: '{}',
        };
        this._actionUtil
            .executeAction(params, null, this, null, null)
            .then((response) => {
                this.gridData = response.result.IPResult.processedGroups;

                var ungroupCheck = this.gridData.findIndex(ele => ele.GroupName === "Ej grupperade adresser")
                if (ungroupCheck !== -1) {
                    var element = this.gridData[ungroupCheck];
                    this.gridData.splice(ungroupCheck, 1);
                    this.gridData.splice(0, 0, element);
                } else {
                    this.gridData.unshift({
                        GroupId: 'Ej grupperade adresser',
                        GroupName: 'Ej grupperade adresser',
                        // EmptyField: '   ',
                        _children: []
                    })
                }

                if (this.gridData.length > 0) {
                    this.gridData.forEach(ele => {
                        if (ele.GroupName !== 'Ej grupperade adresser') {
                            this.groupNames.push({ 'label': ele.GroupName, 'value': ele.GroupId });
                        }

                    });

                    this.groupNames = JSON.parse(JSON.stringify(this.groupNames)); //its assigning the values to UI after array is prepared

                    this.refreshData(this.gridData);
                }

            })
            .catch((error) => {
                const evt = new ShowToastEvent({
                    title: 'Error Occured',
                    message: 'Unexpected error occured. Please contact Salesforce Administrator',
                    variant: 'error'
                });
                this.dispatchEvent(evt);
            });
    }

    refreshData(data) { //setting checked node as false and emptying all the temporary arrays.
        // console.log(data);
        data.forEach(ele => {
            ele.checked = false;
            if (ele._children !== undefined && ele._children.length > 0) {
                ele._children.forEach(el => {
                    el.checked = false;
                    el.City = el.City.toUpperCase();
                    el.StreetAddress = el.StreetAddress.toUpperCase();
                    el.StreetNumber = el.StreetNumber.toUpperCase();
                });
            }
        });

        this.gridData = JSON.parse(JSON.stringify(data));

        this.selectedSites = [];
        this.selectedGroups = [];
        this.disableGroupChecks = false;
        this.disableSiteChecks = false;
    }

    addSitesToGroup(event) {
        this.selectedGroupName = event.detail.value;
		// console.log('selectedGroupName',this.selectedGroupName);
        var position = this.gridData.findIndex(item => item.GroupId === event.detail.value);

        if (this.selectedSites.length > 0) {
            
		// console.log('selectedsites',this.selectedSites);
            var copyofarray = [...this.gridData];

            this.selectedSites.forEach(e => {
                copyofarray.forEach(element => {
                    var x = element._children.findIndex(item => item.ServicePointId === e.ServicePointId);
                    if (x != -1) {
                        element.checked = false;
                        this.temp.push(element._children[x]);
                    }
                });
            });

            var array1 = [];

            copyofarray.forEach((ele, index) => {

                // console.log(ele);
                var filtered = [];
                ele._children.forEach((item, index2) => {
                    filtered = ele._children.filter(item => !this.temp.includes(item));
                });
                // console.log(filtered);
                array1[index] = {};
                array1[index].GroupId = ele.GroupId
                array1[index].GroupName = ele.GroupName;
                // array1[index].EmptyField = '  ';
                array1[index].checked = ele.checked;
                array1[index]._children = [];
                array1[index]._children = filtered;
            });

            // console.log('array11',array1);

            this.temp.forEach(ele => {
                array1[position]._children.push(ele);
            });

            // console.log('array1',array1);

            this.gridData = [];

            array1.forEach(ele => {
                // console.log(ele);
                this.gridData.push(ele);
            });

            // this.gridData = JSON.parse(JSON.stringify(array1));

            this.template.querySelectorAll('lightning-combobox').forEach(each => {
                each.value = undefined;
                this.selectedGroupName = undefined;
            });
			// console.log('griddata',this.gridData);
            this.refreshData(this.gridData);



        } else {

            this.template.querySelectorAll('lightning-combobox').forEach(each => {
                each.value = undefined;
                this.selectedGroupName = undefined;
            });
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'No sites are selected',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }

        this.temp = [];
        this.selectedSites = [];
        this.selectedGroups = [];
        this.disableGroupChecks = false;
        this.disableSiteChecks = false;

    }

    removeSitesFromGroup() {
        this.selectedSites.forEach(ele => {
            this.gridData.forEach(e => {
                var x = e._children.findIndex(item => item.ServicePointId === ele.ServicePointId);
                if (x !== -1) {
                    e.checked = false;
                    this.temp.push(e._children[x]);
                    e._children.splice(x, 1);
                }
            });
        });

        var x = this.gridData.findIndex(item => item.GroupName === 'Ej grupperade adresser')
        this.temp.forEach(ele => {
            this.gridData[x]._children.push(ele);
        });

        this.refreshData(this.gridData);

        this.temp = [];

        this.gridData = JSON.parse(JSON.stringify(this.gridData));
    }

    handleCheckbox(event) {
        if (event.detail.checked && event.target.dataset.set === "site") {
            this.gridData[event.target.dataset.groupindex]._children[event.target.dataset.index].checked = true;
            this.disableGroupChecks = true;
            this.selectedSites.push({
                ServicePointId: event.target.name,
                value: event.target.value
            });
        } else if (event.detail.checked && event.target.dataset.set === "group") {
            this.gridData[event.target.dataset.index].checked = true;
            this.disableSiteChecks = true;
            this.selectedGroups.push({
                GroupId: event.target.name,
                GroupName: event.target.value
            });
        } else if (!event.detail.checked) {
            if (event.target.dataset.set === "site") {
                this.gridData[event.target.dataset.groupindex]._children[event.target.dataset.index].checked = false;
                var position = this.selectedSites.indexOf(e => e.GroupId === event.target.GroupId);
                this.selectedSites.splice(position, 1);
            } else if (event.target.dataset.set === "group") {
                this.gridData[event.target.dataset.index].checked = false;
                var position = this.selectedSites.indexOf(e => e.GroupId === event.target.GroupId);
                this.selectedGroups.splice(position, 1);
            }
            if (this.selectedSites.length === 0 && this.selectedGroups.length === 0) {
                this.disableGroupChecks = false;
                this.disableSiteChecks = false;
            }
        }
    }

    deleteGroup(event) {
        if (this.selectedGroups !== undefined && this.selectedGroups.length > 0 && this.gridData !== undefined) {
            this.selectedGroups.forEach(e => {
                var x = this.gridData.findIndex(item => item.GroupId === e.GroupId)

                var y = this.groupNames.findIndex(item => item.value === e.GroupId);

                if (y !== -1) {
                    this.groupNames.splice(y, 1);

                    this.groupNames = JSON.parse(JSON.stringify(this.groupNames));
                }
                if (x !== -1 && this.gridData[x].GroupName !== 'Ej grupperade adresser') {
                    if (this.gridData[x]._children !== undefined) {
                        if (this.gridData[x]._children.length > 0 && this.gridData[x].GroupName !== 'Ej grupperade adresser') {
                            var x1 = this.gridData.findIndex(item => item.GroupName === 'Ej grupperade adresser');
                            this.gridData[x]._children.forEach(ee => {
                                this.gridData[x1]._children.push(ee);
                            });
                            this.gridData.splice(x, 1);
                        } else if (this.gridData[x]._children.length === 0 && this.gridData[x].GroupName !== 'Ej grupperade adresser') {
                            this.gridData.splice(x, 1);
                        }

                        this.selectedGroups = [];

                        this.refreshData(this.gridData);
                    } else {
                        this.gridData.splice(x, 1);
                        this.selectedGroups = [];

                        this.refreshData(this.gridData);
                    }
                } else {
                    this.selectedGroups = [];

                    this.refreshData(this.gridData);
                    const evt = new ShowToastEvent({
                        title: 'Error Occured',
                        message: 'Selected group could not be deleted',
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                }
            });
        }

        this.gridData = JSON.parse(JSON.stringify(this.gridData));
    }

    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }
    @track i = 0;
    @track isModalOpen = false;
    @track textvalue = '';
    handleChange(event) {
        this.textvalue = event.detail.value;
    }
    submitDetails(event) {
        this.isModalOpen = false;


        if (this.gridData.length < this.groupsLimit) {
            var nameGrp = 'group'.concat(this.i);
            this.gridData.push({
                GroupId: nameGrp,
                GroupName: this.textvalue,
                // EmptyField : '  ',
                checked: false,
                _children: []
            });
            this.i++;

            this.groupNames.push({ 'label': this.textvalue, 'value': nameGrp });

            this.groupNames = JSON.parse(JSON.stringify(this.groupNames));
            this.textvalue = '';
        } else {
            this.textvalue = '';
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Du kan ha max 10 grupper',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }

    }

    nextStep() {

        var iterator = 1;
        for (var i = 0; i < this.gridData.length; i++) {
            if (this.gridData[i]._children !== undefined && this.gridData[i]._children.length > 0) {

                if (this.gridData[i].GroupName !== 'Ej grupperade adresser') {
                    this.finalValidation = true;
                    this.gridData[i]['Desciption'] = 'Group ' + iterator;
                    this.finalGroupingList.push(this.gridData[i]);
                    iterator++;
                } else {
                    this.finalValidation = false;
                }
            } else {
                this.finalValidation = false;
            }
        }
        // console.log(JSON.stringify(this.gridData), this.finalValidation);

        if (this.omniJsonData && this.finalValidation === true) {
            var ungroupSitesPosition = this.gridData.findIndex(ele => ele.GroupName === 'Ej grupperade adresser');

            if (ungroupSitesPosition !== -1) {
                this.gridData.splice(ungroupSitesPosition, 1);
            }
            let updateJson = JSON.parse(JSON.stringify(this.omniJsonData));
            updateJson.finalGroupList = this.finalGroupingList;
            this.omniApplyCallResp(updateJson);
            // console.log('finalList',this.finalGroupingList);
            this.omniNextStep();
        } else {
            const evt = new ShowToastEvent({
                title: 'Error Occured',
                message: 'Grouping is not completed on the page',
                variant: 'error'
            });
            this.dispatchEvent(evt);
        }
    }

    previousStep() {
        this.omniPrevStep();
    }
}