({
    handleUploadFinished : function(component, event, helper) {
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        if(file) {
            var reader = new FileReader();
            reader.readAsText(file, 'UTF-8');
            reader.onload = function(evt) {
                var csv = evt.target.result;
                component.set("v.csvString", csv);
                component.find("btnEjecutar").getElement().disabled = false;
            }
        }
    },

    handleGetCSV : function(component, event, helper) {
        var csv = component.get("v.csvString");
        if(csv != null) {
            helper.createCSVObject(component, csv);
        }
    },

    cleanData : function(component, event, helper) {
        component.set("v.csvString", null);
        component.set("v.csvObject", null);
        component.set("v.infoProcess", null);
        component.find("file").getElement().value = '';
        component.find("btnEjecutar").getElement().disabled = false;
    },
    
    ejecutar : function(component, event, helper) {       
        var operation = component.get("v.operacion");
    	var csvObject = component.get("v.csvObject");  
        component.set("v.retries",0); 
        if (csvObject != null) {
            if(operation == ''){
                component.set("v.infoProcess", $A.get("$Label.c.CESS_lbl_notMasivaLeadSelectOp"))
            }else{
              event.currentTarget.disabled = true;
              component.set("v.infoProcess", $A.get("$Label.c.CESS_lbl_notMasivaLead"));
              if(operation == 'Cargar') helper.cargarLeads(component, csvObject);
              //if(operation =='Eliminar') helper.eliminarLeads(component, csvObject); 
              if(operation =='Eliminar') helper.actualizarLeads(component, csvObject);
            }
            
        }
    },
    selectFunction : function(component,event,helper){
       var operacion = component.find("selectFuncion").get("v.value");
       component.set("v.operacion",operacion);
        if(operacion!=""){
            component.set("v.selectFile",true);
            
        }else{
            component.set("v.selectFile",false);   
            component.set("v.infoProcess", '');
            
        }
	}
})