//Js part of DatePickerChild (There is no html part of this component)
import { api } from 'lwc';
import VlocityDatePicker from 'vlocity_cmt/datePicker';

export default class DatePickerChild extends VlocityDatePicker {
    @api disableDays; // disable particular day of the week e.g weekends, set 0 for Sunday and 6 for Saturday
    @api disablePrevMonthDays;//Disable previous month days shown on current month on calendar
    @api disableNextMonthDays;//Disable next months days shown on current month on calendsar
    @api set disableDates(val) {
        if (val) {
            this._disabledDates = val.split(",");
        }
    }
    get disableDates() {
        return this._disabledDates;
    }

    setThePrintLoopAux(s, d, n, y, m) {
        this.DayArray = [{}];
        let j = 0;
        do {
            this.DayArray[j] = [];
            this.DayArray[j].id = j + 10;
            j++;
        } while (j < 6);
        let idOverride;
        let start = s - 1;
        let nextMonDays = 1;
        let b = 6;
        let k = 0;
        for (let i = 0; i < 42; i++) {
            let idPrefix = "dayId";
            let dateClass = `day-val day ${this.theme}-day`;
            idOverride = NaN;
            if ((this.minDate || this.maxDate || this.disableDates) && y && m) {
                let num = (i - s + 1).length > 1 ? i - s + 1 : "0" + (i - s + 1);
                let presentDate = new Date(parseInt(y, 10), parseInt(m - 1, 10), parseInt(num, 10));
                let min = this.minDate;
                let max = this.maxDate;
                if ((min && presentDate < min) || (max && presentDate > max) || (this.disableDates && this.disableDates.find(item => this.valuesAreEqual(item, presentDate)))) {
                    dateClass += ` ${this.theme}-disabled-text`;
                }
            }
            /* Custom Logic Start*/
            if (this.disableDays) {
                const days = this.disableDays.split(',');
                days.forEach(day => {
                    if (i % 7 === parseInt(day, 10)) dateClass += ` ${this.theme}-disabled-text`;
                })
            }
            /* Custom Logic End*/

            if (!(i >= s && i - s < d)) {
                if (i >= s) {
                    if (nextMonDays) {
                        idPrefix = "next-month-dayId";
                        idOverride = nextMonDays;
                        dateClass += ` ${this.theme}-day_adjacent-month next-month dayId-next`;
                        if (this.disableNextMonthDays) dateClass = `${this.theme}-disabled-text ${dateClass}`
                        if (this.DayArray[4].length < 7) k = 4;
                        else if (this.DayArray[5].length < 7) k = 5;
                        nextMonDays++;
                    }
                } else {
                    if (n - start) {
                        idPrefix = "prev-month-dayId";
                        idOverride = n - start;
                        dateClass += ` ${this.theme}-day_adjacent-month prev-month dayId-prev`;
                        if (this.disablePrevMonthDays) dateClass = `${this.theme}-disabled-text ${dateClass}`
                        k = 0;
                        start--;
                    }
                }
            } else {
                dateClass += " dayId";
                if (i > b) {
                    b = b + 7;
                    k = k + 1;
                }
            }
            let val = Number(isNaN(idOverride) ? i - s + 1 : idOverride);
            let dayObj = {
                value: val,
                id: idPrefix + val,
                class: dateClass + val
            };
            this.DayArray[k].push(dayObj);
        }
        this.built = true;
        Promise.resolve().then(() => {
            this.setDate();
        });
    }
}