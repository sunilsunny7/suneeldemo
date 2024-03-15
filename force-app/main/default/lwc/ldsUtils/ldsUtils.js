/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 * 
 * Retrieved from lwc-recipes:
 * https://github.com/trailheadapps/lwc-recipes/blob/main/force-app/main/default/lwc/ldsUtils/ldsUtils.js
 * [Latest Commit: https://github.com/trailheadapps/lwc-recipes/commit/07f0b85799b6343a1b1d66a10bcaa6de8cac5291]
 * 
 * Modifications: 26.10.2022 [Tomass Brazovskis] SALEF-7482 - Introduced. (Retrieved only).
 */
 export function reduceErrors(errors) {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map((e) => e.message);
                }
                // Page level errors
                else if (
                    error?.body?.pageErrors &&
                    error.body.pageErrors.length > 0
                ) {
                    return error.body.pageErrors.map((e) => e.message);
                }
                // Field level errors
                else if (
                    error?.body?.fieldErrors &&
                    Object.keys(error.body.fieldErrors).length > 0
                ) {
                    const fieldErrors = [];
                    Object.values(error.body.fieldErrors).forEach(
                        (errorArray) => {
                            fieldErrors.push(
                                ...errorArray.map((e) => e.message)
                            );
                        }
                    );
                    return fieldErrors;
                }
                // UI API DML page level errors
                else if (
                    error?.body?.output?.errors &&
                    error.body.output.errors.length > 0
                ) {
                    return error.body.output.errors.map((e) => e.message);
                }
                // UI API DML field level errors
                else if (
                    error?.body?.output?.fieldErrors &&
                    Object.keys(error.body.output.fieldErrors).length > 0
                ) {
                    const fieldErrors = [];
                    Object.values(error.body.output.fieldErrors).forEach(
                        (errorArray) => {
                            fieldErrors.push(
                                ...errorArray.map((e) => e.message)
                            );
                        }
                    );
                    return fieldErrors;
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    );
}