import { api } from "lwc";
import OmniscriptCancelAction from "vlocity_cmt/omniscriptCancelAction";
import {pageReferenceTypes} from "vlocity_cmt/navigationUtils";
import tmpl_slds from './patchedLwcCancelAction_slds.html';
import tmpl_nds from './patchedLwcCancelAction_nds.html';

export default class PatchedLwcCancelAction extends OmniscriptCancelAction {
    
    patchedTargetType = pageReferenceTypes.CURRENT_PAGE;
    patchedTargetParams = 'c__target=lightning:button';
    patchedReplace = true;

    renderedCallback() {
        if (this._initialRender) {
            this._CURRENT_PAGE_WORKAROUND = this.template.querySelector('[data-patched-navigate-action]');
        }

        super.renderedCallback();

        if (!this._navigateAction) {
            this._navigateAction = this.template.querySelector('[data-navigate-action]');
        }
    }

    /**
     * Execute the configured navigate action. Fired by omniscriptHeader.
     * @scope api (public)
     * @returns {Promise<any>}
     */
     @api cancel() {
        return Promise.resolve()
            .then(() => {
                if (this.jsonDef.propSetMap.showCancelPrompt)
                    return OmniscriptCancelAction.cancelPrompt(this, this._propSetMap.cancelMessage, this.allCustomLabelsUtil);

                return OmniscriptCancelAction.CANCEL_RESOLVED;
            })
            .then(result => this._CURRENT_PAGE_WORKAROUND.navigate().then(() => result))
            .then(result => this._navigateAction.navigate().then(() => result));
     }
    
    /**
     * @scope private
     * @description Overwrites the native LWC render.
     * @returns {Template}
     */
    render() {
        return this.layout === 'newport' ? tmpl_nds : tmpl_slds;
    }
}