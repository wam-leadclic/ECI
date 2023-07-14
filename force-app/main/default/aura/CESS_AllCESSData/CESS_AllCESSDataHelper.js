({

    initialise : function(component, event) {

        component.set("v.showSpinner", false);
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
        }
    },

    getPData : function (component, event){
        $A.createComponent("c:CESS_ConsultaPolizas", { 
            "recordId": component.get("{!v.recordId}"), 
            "sObjectName": component.get("{!v.sObjectName}"), 
            "a_hideCheckboxColumn": "true", 
            "a_maxRowSelection": "0", 
            "a_showButtons": "false"
            }, function(newCmp) {
                if (component.isValid()) {
                    component.set("v.PComp", newCmp);
                }
            });
    },

    getCLData : function (component, event){
        $A.createComponent("c:CESS_ConsultaCESSFromLead", { 
            "recordId": component.get("{!v.recordId}"), 
            "sObjectName": component.get("{!v.sObjectName}"), 
            "a_hideCheckboxColumn": "true", 
            "a_maxRowSelection": "0", 
            "a_showButtons": "false"
            }, function(newCmp) {
                if (component.isValid()) {
                    component.set("v.CComp", newCmp);
                }
            });
    },

    getDGData  : function(component, event) {

        var vIdCess;
        var vIdAneto;

        if (component.get("v.sObjectName") == 'Lead'){
            vIdCess = component.get("v.objectFields.identifier_cess__c");
            vIdAneto = component.get("v.objectFields.identifier_aneto__c");
        }else if (component.get("v.sObjectName") == 'Opportunity'){
            vIdCess = component.get("v.objectFields.Account.identifier_cess__pc");
            vIdAneto = component.get("v.objectFields.Account.identifier_aneto__pc");
        }else{//Account
            vIdCess = component.get("v.objectFields.identifier_cess__pc");
            vIdAneto = component.get("v.objectFields.identifier_aneto__pc");
        }

        var action = component.get("c.getDGRecords");
        
        action.setParams({
            identifier_cess : vIdCess,
            identifier_aneto : vIdAneto
        });
        action.setCallback(this, function(response) {
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
                    component.set("v.requestNotFound",true);
                } else {
                     //tenemos respuesta, la pasamos a gestionesData y creamos las columnas.
                     console.log("respuesta: " + response);
                     this.configurarTablaDG(component, event, response);
                }
            }
        });
        $A.enqueueAction(action);
    },

    configurarTablaDG : function(component, event, response) {

        component.set('v.gestionesColumns', [
                                    {label: 'Numero Gestion', fieldName: 'task_number', type: 'text'},
                                    {label: 'Fecha Proxima Gestion', fieldName: 'next_date', type: 'text'},
                                    {label: 'Titulo Gestion', fieldName: 'task_subject', type: 'text'},
                                    {label: 'Colaborador Asignado', fieldName: 'collaborator_number', type: 'text'},
                                    {label: 'Datos Colaborador', fieldName: 'collaborator_name', type: 'text'},
                                    {label: 'Delegación Asignada', fieldName: 'assigned_office', type: 'text'},
                                    {label: 'Descripción delegación', fieldName: 'branch_description', type: 'text'},
                                    {label: 'Fecha apertura', fieldName: 'open_date', type: 'text'},
                                    {label: 'Observaciones', fieldName: 'comentarios', type: 'text'}
        ]);

        for (var pos in response.getReturnValue()) {
            //console.log(response.getReturnValue()[pos]);
            response.getReturnValue()[pos].comentarios = response.getReturnValue()[pos].comments.toString();
        }
        

        component.set("v.gestionesData",response.getReturnValue());

    }
    
})