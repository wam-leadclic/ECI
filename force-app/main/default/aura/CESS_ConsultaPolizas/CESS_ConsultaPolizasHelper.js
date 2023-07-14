/********************************************************************************** 
 * @author       Francisco José Pérez - franciscojose.perez@salesforce.com
 * @date         23/04/2019
 * @group        Console
 * @description  Helper of the Lightning Component 'CESS_ConsultaPolizas'
 * @Revision
**********************************************************************************/

({
    doInit : function(component, event) {
    },

    doRefresh : function(component, event) {

        var changeType = event.getParams().changeType;

        if(changeType === "ERROR") {
            console.log('Error: ' + component.get("v.recordError"));
        }else if ( (changeType === "CHANGED") || (changeType === "REMOVED") ){ 
            console.log ("LDS changed or removed");
            component.find("recordHandler").reloadRecord();
        }else if (changeType === "LOADED") {
            console.log ("LDS Loaded");
            //Call the integration 1 time after the record was be loaded. Only the first time that the record is loaded
            if (component.get("v.activateButtons") == false){
                this.getCessPolicyHelper(component, event);
                component.set("v.activateButtons", true);
            }
        }
    },

    handleOnCancel : function(component, event) {

        component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                console.log("Save completed successfully.");
            } else if (saveResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (saveResult.state === "ERROR") {
                console.log('Problem saving record, error: ' + 
                            JSON.stringify(saveResult.error));
            } else {
                console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
            }
        }));
    },

    getCessPolicyHelper : function(component, event) {
        
        component.set("v.showSpinner", true);
        var vIdCess;
        var vIdAneto;

        var action = component.get("c.getCESSPolicyRecords");
    
        if (component.get("v.sObjectName") == 'Lead'){
            vIdCess = component.get("v.objectFields.identifier_cess__c");
            vIdAneto = component.get("v.objectFields.identifier_aneto__c");
        }else if (component.get("v.sObjectName") == 'Opportunity'){
            vIdCess = component.get("v.objectFields.Account.identifier_cess__pc");
            vIdAneto = component.get("v.objectFields.Account.identifier_aneto__pc");
        }else{//account
            vIdCess = component.get("v.objectFields.identifier_cess__pc");
            vIdAneto = component.get("v.objectFields.identifier_aneto__pc");        
        }
        
        console.log('Parametros getCESSPolicyRecords: idCess: ' + vIdCess + ' idAneto: ' + vIdAneto );

        //control the cessId o anetoId
        if ( (vIdCess == null || vIdCess == '') && (vIdAneto == null || vIdAneto == '') ){
            component.set("v.showSpinner", false);
            component.set("v.sinCessId", true);
        }else{
            action.setParams({
                identifier_cess : vIdCess,
                identifier_aneto : vIdAneto
            });
            action.setCallback(this, function(response) {
                component.set("v.showSpinner", false);
                var state = response.getState();
                if (state === "ERROR") {
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "error",
                        "title": "Acción incompleta",
                        "message": "El servicio de consulta de datos en CESS no está disponible. Inténtelo de nuevo más tarde por favor."
                    });
                    resultsToast.fire();
                } else if (state === "SUCCESS") {
                    if ( (response.getReturnValue() == null) || (response.getReturnValue()[0].return_code == 'KO') ){
                        //no hay datos
                        component.set("v.requestNotFound",true);
                    } else {
                        console.log("respuesta: " + response);
                        this.configurarTablaPolizas(component, event, response);
                    }
                }
            });
            $A.enqueueAction(action);
        }//else
   },

   configurarTablaPolizas : function(component, event, response) {
            component.set('v.cessColumns', [
                                        {label: 'Compañía', fieldName: 'company', type: 'text'},
                                        {label: 'Desc. Compañía', fieldName: 'company_description', type: 'text'},
                                        {label: 'Tipo Seguro', fieldName: 'insurance_type', type: 'text'},
                                        {label: 'Desc. Producto', fieldName: 'product_description', type: 'text'},
                                        {label: 'Ramo', fieldName: 'insurance_line', type: 'text'},
                                        {label: 'Desc. Ramo', fieldName: 'line_description', type: 'text'},
                                        {label: 'Num. Póliza', fieldName: 'policy_number', type: 'text'},
                                        {label: 'Num. Certificado', fieldName: 'certificate_number', type: 'text'},
                                        {label: 'Num. Solicitud', fieldName: 'request_number', type: 'text'},
                                        {label: 'Estado', fieldName: 'status', type: 'text'},
                                        {label: 'Desc. Estado', fieldName: 'status_description', type: 'text'},
                                        {label: 'Fecha Efecto', fieldName: 'start_date', type: 'text'},
                                        {label: 'Fecha Vencimiento', fieldName: 'end_date', type: 'text'},
                                        {label: 'Fecha Anulación', fieldName: 'expiration_date', type: 'text'},
                                        {label: 'Tipo Anulación', fieldName: 'cancelation_type', type: 'text'},
                                        {label: 'Motivo Anulación', fieldName: 'cancelation_reason', type: 'text'},
                                        {label: 'Desc. Motivo anulación', fieldName: 'cancelation_description', type: 'text'},
                                        {label: 'Riesgo Asegurado', fieldName: 'insured_risk', type: 'text'},
                                        {label: 'Origen', fieldName: 'origin_system', type: 'text'},
                                        {label: 'Prima Anual', fieldName: 'anual_quota', type: 'text'},
                                        {label: 'Cod. Delegación', fieldName: 'branch_code', type: 'text'},
                                        {label: 'Desc. Delegación', fieldName: 'branch_description', type: 'text'},
                                        {label: 'Cod. Colaborador', fieldName: 'collaborator_code', type: 'text'},
                                        {label: 'Colaborador Nombre', fieldName: 'collaborator_name', type: 'text'},
                                        {label: 'Colaborador Apellido 2', fieldName: 'collaborator_surname1', type: 'text'},
                                        {label: 'Colaborador Apellido 2', fieldName: 'collaborator_surname2', type: 'text'}
            ]);
 
            component.set("v.cessData",response.getReturnValue());
    
        },

    handleSelection : function(component, event) {
        //sólo tenemos 1 registro selecionado.
        component.set("v.selectedRows",event.getParam('selectedRows'));
    },

    handleOnSelect: function (component, event){

        var selectedRows = component.get("v.selectedRows");

        if (selectedRows.length == 0){
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                type: "error",
                mode: "pester",
                duration: ' 2500',
                title: "Póliza no seleccionada",
                message: "Seleccione la póliza adecuada, por favor."
            });
            resultsToast.fire();
        }else{
            //mapeo de los campos de pólizas de CESS a los de oportunidad.
            var objeto = component.get("v.sObjectName");
            var originObject = component.get("v.objectFields");

            //n solicitud, n opp, n certificado, prima, cod comp, cod prod, n poliza
            //aplication_number__c,opportunity_number__c,policy_certificate__c,Amount,policy_insurancecode__c,policy_productcode__c,policy_number__c

            if (objeto == 'Opportunity'){
                
                originObject.aplication_number__c = selectedRows[0].request_number;
                originObject.policy_certificate__c = selectedRows[0].certificate_number;
                originObject.policy_number__c = selectedRows[0].policy_number;
                originObject.Amount = selectedRows[0].anual_quota;
                originObject.policy_insurancecode__c = selectedRows[0].company;
                originObject.policy_productcode__c = selectedRows[0].insurance_type;
                
                component.set("v.objectFields",originObject);

                component.find("recordHandler").saveRecord($A.getCallback(function(saveResult) {
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        console.log("Save completed successfully."); 
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": "success",
                            "title": "Acción completa",
                            "message": "Datos de póliza del cliente actualizados"
                        });
                        resultsToast.fire();           
                        //Close the modal
                        $A.get("e.force:closeQuickAction").fire();
                    } else if (saveResult.state === "INCOMPLETE") {
                        console.log("User is offline, device doesn't support drafts.");
                    } else if (saveResult.state === "ERROR") {
                        console.log('Problem saving record, error: ' + 
                            JSON.stringify(saveResult.error));
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": "error",
                            "title": "Acción incompleta",
                            "message": "No se ha podido actualizar los datos de la póliza del cliente. Inténtelo de nuevo más tarde por favor."
                        });
                        resultsToast.fire();
                    } else {
                        console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                    }
                }));

            }//opp
        }
    }

})