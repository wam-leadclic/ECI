({

    initFetchData :  function(cmp, event) {
        cmp.set("v.showSpinner", true);

        var action = cmp.get("c.getAccountId");
        //FPEREZ. refresco antes de coger parámetros el record loader de leads.
        //cmp.find('leadrecordHandler').reloadRecord(true) ;

        action.setParams({
                        nif : cmp.get("v.leadRecord.document_number__c"),
                        cessId : cmp.get("v.leadRecord.identifier_cess__c"),
                        anetoId : cmp.get("v.leadRecord.identifier_aneto__c"),
                        email : cmp.get("v.leadRecord.Email"),
                        mphone : cmp.get("v.leadRecord.MobilePhone"),
                        phone : cmp.get("v.leadRecord.Phone")
                    });
        action.setCallback(this, function(response) {
            cmp.set("v.showSpinner", false);
            var state = response.getState();
            if (state === "ERROR") {
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "type": "error",
                    "title": "Gestiones Pendientes",
                    "message": "No se puede buscar en estos momentos"
                });
                resultsToast.fire();
            } else if (state === "SUCCESS") {
                if ((response.getReturnValue() == null) || (response.getReturnValue() == "")) {
                    //error, no encuentra datos o hay más de un cliente.
                    cmp.set("v.requestNotFound",true);
                    cmp.set("v.requestErrorMessage","No se han encontrado gestiones pendientes en Salesforce para el cliente.");
                } else {
                    //encontramos datos.
                    cmp.set("v.requestNotFound",false);
                    console.log("respuesta: " + response);
                    cmp.set("v.myAccountId", response.getReturnValue());
                    //FPEREZ: recarga del record loader del componente padre, poruqe no me va bien y se carga vacío.
                    cmp.find('accountRecordLoader').reloadRecord(true) ;
                    //FPEREZ. Con el refresh sí que me saca el nombre, muestra el componente sigleRelated le pasa el id correcto.
                }
            }
        });
        $A.enqueueAction(action)
    }

})