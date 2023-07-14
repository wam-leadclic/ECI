({

    init : function(cmp, event, helper) {
       
        cmp.set('v.opptyColumns', [
            { label: 'Oportunidad', fieldName: 'LinkName', type: 'url', typeAttributes: {label: { fieldName: 'Name' }, target: '_top'} },
            { label: 'Etapa', fieldName: 'StageName', type: 'text' },
            { label: 'Cantidad', fieldName: 'Amount', type: 'currency', cellAttributes: { alignment: 'left' } },
            { label: 'FechaCierre', fieldName: 'CloseDate', type:"date-local", typeAttributes:{month:"2-digit", day:"2-digit"} },
            { label: 'Propietario', fieldName: "Propietario", type:"text" }
        ])

        helper.initFetchData(cmp, event);
        
    }
})