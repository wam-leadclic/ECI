/********************************************************************************** 
 * @author       Francisco José Pérez - franciscojose.perez@salesforce.com
 * @date         23/04/2019
 * @group        Console
 * @description  Helper of the Lightning Component 'CESS_ConsultaCESSFromLead'
 * @Revision
 *          AUTOR       FECHA           DESCRIPCION
            LCS - MMV   17/10/2022      Se muestra un mensaje de OK o KO al actualizar el lead, sobre todo para mostrar error por duplicado
            LCS - MMV   26/10/2022      Hace un reload del registro para evitar que la cache tenga datos obsoletos
**********************************************************************************/

({
    initialise : function(component, event) {

        //FPEREZ. quitado de aquí porque se lanzaba antes de que se cargaran los registros del LDS
        //this.getCessDataHelper(component, event);

    },

    doRefresh : function(component, event) {

        var changeType = event.getParams().changeType;

//        if (changeType === "ERROR") { /* handle error; do this first! */ }
//        else if (changeType === "LOADED") { /* handle record load */ }
//        else if (changeType === "REMOVED") { /* handle record removal */ }
//        else if (changeType === "CHANGED") { /* handle record change */ }
        if(changeType === "ERROR") {
            console.log('Error: ' + component.get("v.recordError"));
        }else if ( (changeType === "CHANGED") || (changeType === "REMOVED") ){ 
            console.log ("LDS changed or removed");
            component.find("recordHandler").reloadRecord(true);
        }else if (changeType === "LOADED") {
            console.log ("LDS Loaded");
            // Reload Record to avoid obsolete data
            if (component.get("v.reloadRecord") == true){
                component.set("v.reloadRecord", false);
                component.find("recordHandler").reloadRecord(true);
            }else if (component.get("v.activateButtons") == false){
                //Call the integration 1 time after the record was be loaded. Only the first time that the record is loaded
                this.getCessDataHelper(component, event);
                component.set("v.activateButtons", true);
            }
        }
    },

    handleOnCancel : function(component, event) {
        component.set("v.objectFields.show_cessinfo__c", false);
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

    getCessDataHelper : function(component, event) {
        
        component.set("v.showSpinner", true);

        var action = component.get("c.getCESSClientRecords");
       // no funciona esta forma de definir el Map. -> var myMap = new Map();

        var myMap = component.get("v.theMap");
        var vDocNum;
        var vIdCess;
        var vIdAneto;
        var vDocType;
    
        // --- A0T0 (Telefono fijo), A3E0 (Email), A1M0 (Teléfono móvil)
        if (component.get("v.sObjectName") == 'Lead'){
            //map.set no funciona. hay que definir el valor en atributo del componente y cambiar la notación a esta.
            myMap["A0T0"] = component.get("v.objectFields.Phone");
            myMap["A3E0"] = component.get("v.objectFields.Email");
            myMap["A1M0"] = component.get("v.objectFields.MobilePhone");
            vDocNum = component.get("v.objectFields.document_number__c");
            vDocType = component.get("v.objectFields.document_type__c");
            vIdCess = component.get("v.objectFields.identifier_cess__c");
            vIdAneto = component.get("v.objectFields.identifier_aneto__c");
        }else if (component.get("v.sObjectName") == 'Opportunity'){
            myMap["A0T0"] = component.get("v.objectFields.Account.Phone");
            myMap["A3E0"] = component.get("v.objectFields.Account.PersonEmail");
            myMap["A1M0"] = component.get("v.objectFields.Account.PersonMobilePhone");
            vDocNum = component.get("v.objectFields.Account.personal_document__pc");
            vIdCess = component.get("v.objectFields.Account.identifier_cess__pc");
            vIdAneto = component.get("v.objectFields.Account.identifier_aneto__pc");
            vDocType = component.get("v.objectFields.Account.document_type__pc");
        }else{//Account
            myMap["A0T0"] = component.get("v.objectFields.Phone");
            myMap["A3E0"] = component.get("v.objectFields.PersonEmail");
            myMap["A1M0"] = component.get("v.objectFields.PersonMobilePhone");
            vDocNum = component.get("v.objectFields.personal_document__pc");
            vIdCess = component.get("v.objectFields.identifier_cess__pc");
            vIdAneto = component.get("v.objectFields.identifier_aneto__pc");
            vDocType = component.get("v.objectFields.document_type__pc");       
        }

        console.log('MyMap: ' + myMap);
        console.log('MyMap: ' + myMap['A0T0']);
        console.log('Datos enviaados: vDocNum=' + vDocNum + '  vDocType=' + vDocType);

        action.setParams({
            document_type : vDocType,
            document_number : vDocNum,
            contact_list : myMap,
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
                if (response.getReturnValue() == null) {
                    //no hay datos
                    component.set("v.requestNotFound",true);
                    this.handleOnCancel(component,event);
                } else {
                     console.log("respuesta: " + response);
                     //check log error message
                    if (response.getReturnValue()[0].message == null){
                        this.configurarTablaCliente(component, event, response);
                    }else{
                        //hay error, así que no tenemos datos
                        component.set("v.requestNotFound",true);
                        this.handleOnCancel(component,event);
                    }
                }
            }
        });
        $A.enqueueAction(action);
   },

   configurarTablaCliente : function(component, event, response) {
            component.set('v.cessColumns', [
                                        {label: 'Id Cess', fieldName: 'cess_identifier', type: 'text'},
                                        {label: 'Id Aneto', fieldName: 'aneto_identifier', type: 'text'},
                                        {label: 'Tipo Documento', fieldName: 'document_type', type: 'text'},
                                        {label: 'N. Documento', fieldName: 'document_number', type: 'text'},
                                        {label: 'Secuencia', fieldName: 'sequence', type: 'text'},
                                        {label: 'Nombre', fieldName: 'first_name', type: 'text'},
                                        {label: 'Primer Apellido', fieldName: 'surname_first', type: 'text'},
                                        {label: 'Segundo Apellido', fieldName: 'surname_second', type: 'text'},
                                        {label: 'Fecha Nacimiento', fieldName: 'birthdate', type: 'text'},
                                        {label: 'Fijo', fieldName: 'fijo', type: 'text'},
                                        {label: 'Email', fieldName: 'email', type: 'text'},
                                        {label: 'Movil', fieldName: 'movil', type: 'text'},
    //ramos prohibidos no lo pueden ver. 
    //var userId = $A.get("$SObjectType.CurrentUser.Id"); or ProfileId
    //                                   {label: 'Ramos Prohibidos', fieldName: 'businesslines_prohibited', type: 'text'},
    //                                   {label: 'Ramos 2 Prohibidos', fieldName: 'result_descriptions', type: 'text'},
    //hasta aqui.
                                       {label: 'Sexo', fieldName: 'gender', type: 'text'},
                                        {label: 'Tarjeta Eci', fieldName: 'eci_card', type: 'text'},
                                        {label: 'Cesión de grupo', fieldName: 'group_permission', type: 'text'}
            ]);
 
            // Actualizamos la lista de contactos recibidos. A0T0 (Telefono fijo), A3E0 (Email), A1M0 (Teléfono móvil)
            for (var pos in response.getReturnValue()) {
                //console.log(response.getReturnValue()[pos]);
                response.getReturnValue()[pos].list_contact_dc.forEach( element => {
                    //se agregan los valores de existir, no tienen que estar definidos en el dto.
                    if (element.contact_type == 'A0T0') response.getReturnValue()[pos].fijo = element.contact_data;
                    if (element.contact_type == 'A3E0') response.getReturnValue()[pos].email = element.contact_data;
                    if (element.contact_type == 'A1M0') response.getReturnValue()[pos].movil = element.contact_data;
                });
                response.getReturnValue()[pos].list_document.forEach( element => {
                    response.getReturnValue()[pos].document_type = this.getDocumentTypeValue(element.document_type);
                    if (response.getReturnValue()[pos].document_type == 'PASSPORT') response.getReturnValue()[pos].document_type = 'Pasaporte';
                    response.getReturnValue()[pos].document_number = element.document_number;
                    response.getReturnValue()[pos].sequence = element.sequence;
                });
                response.getReturnValue()[pos].line_forbidden.forEach( element => {
                    //console.log(element);
                    if (response.getReturnValue()[pos].businesslines_prohibited == undefined)
                        response.getReturnValue()[pos].businesslines_prohibited = element.insurance_description;
                    else 
                        response.getReturnValue()[pos].businesslines_prohibited += '; ' + element.insurance_description;
                });
            }

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
                title: "Cliente no seleccionado",
                message: "Seleccione el cliente adecuado, por favor."
            });
            resultsToast.fire();
        }else{
            //mapeo de los campos de CESS a los que no estén rellenos de lead, en opportunity actualizo.
            var objeto = component.get("v.sObjectName");
            var originObject = component.get("v.objectFields");
			console.log(objeto);
            
            if (objeto == 'Lead'){
                //En lead enriquecemos campos.

                if (originObject.birthdate__c == "" || originObject.birthdate__c == null) 
                    originObject.birthdate__c = new Date(selectedRows[0].birthdate);
                if (originObject.share_personaldata__c == "" || originObject.share_personaldata__c == null){
                    originObject.share_personaldata__c = this.getBooleanTypeValue(selectedRows[0].group_permission);
                }
                if (originObject.document_number__c == "" || originObject.document_number__c == null){
                    if (originObject.document_type__c == "" || originObject.document_type__c == null){
                        originObject.document_type__c = this.getDocumentTypeValue(selectedRows[0].document_type);
                        originObject.document_number__c = selectedRows[0].document_number;
                    }
                }
                if (originObject.gender__c == "" || originObject.gender__c == null) 
                    originObject.gender__c = this.geGenderTypeValue(selectedRows[0].gender);
                if (originObject.eci_cardnumber__c == "" || originObject.eci_cardnumber__c == null) 
                    originObject.eci_cardnumber__c = selectedRows[0].eci_card;
                if (originObject.Email == "" || originObject.Email == null) 
                    originObject.Email = selectedRows[0].Email;
                if (originObject.Phone == "" || originObject.Phone == null) 
                    originObject.Phone = selectedRows[0].Phone;
                if (originObject.MobilePhone == "" || originObject.MobilePhone == null) 
                    originObject.MobilePhone = selectedRows[0].MobilePhone;
                if (originObject.businesslines_prohibited__c == "" || originObject.businesslines_prohibited__c == null) 
                    originObject.businesslines_prohibited__c = selectedRows[0].result_descriptions;

                //Sólo se actualizan los id's, name y el flag que controla el componente.
                originObject.show_cessinfo__c = false;
                originObject.identifier_cess__c = selectedRows[0].cess_identifier;
                originObject.identifier_aneto__c = selectedRows[0].aneto_identifier;
                originObject.FirstName = selectedRows[0].first_name;
                originObject.surname_first__c = selectedRows[0].surname_first;
                originObject.LastName = selectedRows[0].surname_first + ' ' + selectedRows[0].surname_second;
                originObject.surname_second__c = selectedRows[0].surname_second;
				originObject.Bypass_ValidacionConsultaCESS__c = true;
                component.set("v.objectFields",originObject);
                var saveObject = component.find("recordHandler");
                
                saveObject.saveRecord($A.getCallback(function(saveResult) {
                    if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                        console.log("Save completed successfully.");
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            type: "success",
                            mode: "pester",
                            duration: '5000',
                            title: "Éxito",
                            message: "Lead actualizado correctamente"
                        });
                        resultsToast.fire();

                    } else if (saveResult.state === "INCOMPLETE") {
                        console.log("User is offline, device doesn't support drafts.");
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            type: "error",
                            mode: "pester",
                            duration: '5000',
                            title: "INCOMPLETE",
                            message: "User is offline, device doesn't support drafts."
                        });
                        resultsToast.fire();
                    } else if (saveResult.state === "ERROR") {
                        console.log('Problem saving record, error: ' + JSON.stringify(saveResult.error));
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            type: "error",
                            mode: "pester",
                            duration: '5000',
                            title: 'Error al actualizar el Lead',
                            message: 'Duplicado detectado. Los datos seleccionados ya existen en el sistema por lo que no puede seleccionar ese Cliente'
                        });
                        resultsToast.fire();
                    } else {
                        console.log('Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error));
                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            type: "error",
                            mode: "pester",
                            duration: '5000',
                            title: 'Unknown problem',
                            message: saveResult.state + ', error: ' + JSON.stringify(saveResult.error)
                        });
                        resultsToast.fire();
                    }
                }));               

                
            }else{  //objeto es opp.
                //actualizamos Person Account. Llamo al controller, desde aquí no puedo sacar LDS de Account

                var action = component.get("c.updateAccountFromOpp");
                console.log("mandamos a actualizar: " + JSON.stringify(selectedRows[0]));
            
                action.setParams({
                    accountId : component.get("v.objectFields.AccountId"),
                    datos : JSON.stringify(selectedRows[0])
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "ERROR") { 

                        var resultsToast = $A.get("e.force:showToast");
                        resultsToast.setParams({
                            "type": "error",
                            "title": "Acción incompleta",
                            "message": "No se ha podido actualizar los datos del cliente, DUPLICADO detectado"
                        });
                        resultsToast.fire();
                        
                    } else if (state === "SUCCESS") {

                        if (response.getReturnValue() == null) {
                            var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                "type": "error",
                                "title": "Acción incompleta",
                                "message": "Error en datos del cliente"
                            });
                            resultsToast.fire();
                        } else if (response.getReturnValue() == false) {
                            // Si es false es un error del proceso
                            
                            var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                "type": "error",
                                "title": "Acción incompleta",
                                "message": "No se ha podido actualizar los datos del cliente, DUPLICADO detectado"
                            });
                            resultsToast.fire();

                        } else {
                            var resultsToast = $A.get("e.force:showToast");
                            resultsToast.setParams({
                                "type": "success",
                                "title": "Acción completa",
                                "message": "Datos del cliente actualizados"
                            });
                            resultsToast.fire();
                            component.getEvent("changePolicy").fire();
                            console.log("Event changePolicy launched");
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        }
    },

    //métodos usados en ORG_LeadLogic.cls, pero por ser asíncronos no los puedo meter en la asignación.
    //tenerlo en cuenta para modificaciones de las piklists.
    getDocumentTypeValue: function (value){
        switch(value) {
            case 'A001':
                return "NIF";
                break;
            case 'C003':
                return "NIE";
                break;
            case 'F006':
                return "PASSPORT";
                break;
            case 'E005':
                return "CIF";
                break;                    
            case 'Pasaporte':
                return "PASSPORT";
                break;                    
            default:
                return value;
        //BI, DNI, CIF, OTHERS, RESIDENTIAL_CARD, NFC
        }
    },

    getBooleanTypeValue: function (value){
        switch(value) {
            case 'Y':
                return true;
                break;
            default:
                return false;
        } 

    },

    geGenderTypeValue: function (value){
        switch(value) {
            case 'V':
                return "MALE";
                break;
            case 'M':
                return "FEMALE";
                break;
            default:
                return "";
        } 

    }

})