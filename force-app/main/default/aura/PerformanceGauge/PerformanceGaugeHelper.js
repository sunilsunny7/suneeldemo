({
    loadGauge : function(yps, title, prop) {  
        var value = yps[prop] !== undefined ? yps[prop] : 0;
		
        var g = new JustGage({
            title: title,
            id: prop,
            value: Math.round(value),
            min: 0,
            max: 150,
            relativeGaugeSize: true,
            symbol: "%",
            levelColors: ['#ee1111', '#ffc40d', '#99b433'],
            gaugeWidthScale: 0.5
        }); 
    }
})