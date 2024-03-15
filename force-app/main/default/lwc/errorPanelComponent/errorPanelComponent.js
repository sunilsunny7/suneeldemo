/**
 * Panel to display error messages.
 * Retrieved from lwc-recipes:
 * https://github.com/trailheadapps/lwc-recipes/tree/main/force-app/main/default/lwc/errorPanel
 * [Latest Commit: https://github.com/trailheadapps/lwc-recipes/commit/62fe3757464040254af7023941449b143077b001]
 * 
 * Modifications: 26.10.2022 [Tomass Brazovskis] SALEF-7482 - Introduced. (Retrieved only). Renamed to 'errorPanelComponent'.
 **/
import { LightningElement, api } from 'lwc';
import { reduceErrors } from 'c/ldsUtils';
import noDataIllustration from './templates/noDataIllustration.html';
import inlineMessage from './templates/inlineMessage.html';

export default class ErrorPanelComponent extends LightningElement {
    /** Single or array of LDS errors */
    @api errors;
    /** Generic / user-friendly message */
    @api friendlyMessage = 'Error retrieving data';
    /** Type of error message **/
    @api type;

    viewDetails = false;

    get errorMessages() {
        return reduceErrors(this.errors);
    }

    handleShowDetailsClick() {
        this.viewDetails = !this.viewDetails;
    }

    render() {
        if (this.type === 'inlineMessage') return inlineMessage;
        return noDataIllustration;
    }
}