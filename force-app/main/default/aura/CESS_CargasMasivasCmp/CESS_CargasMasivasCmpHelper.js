({
    createCSVObject : function(cmp, csv) {
        var action = cmp.get('c.getCsvObject');
        action.setParams({
            csvStr : csv
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
	    	if(state == "SUCCESS") {
				var csvObject =  response.getReturnValue();
                var numLines = csvObject.lines.length;
                console.log(csvObject);
                cmp.set("v.csvObject", csvObject);
                cmp.set("v.infoProcess", numLines + ' registros');
                var end = $A.get("$Label.c.ORG_lbl_csvMaxLines");
                if (end == '0') {
                    end = '';
                } 
                cmp.set("v.end", end);
	    	}
        });
        $A.enqueueAction(action);
    },
    
    eliminarLeads : function(cmp, csvObject) {
        console.log('entra');
        var action = cmp.get('c.deleteLeadsCTI');
        action.setParams({
            csvObject : csvObject
        });
        console.log('eliminarLeads');
        action.setCallback(this, function(response) {
            var state = response.getState();
            var value = response.getReturnValue();
	    	if(state == "SUCCESS") {
                
                this.setIntervalLeadsCTI(cmp, csvObject);
            }
        });
        $A.enqueueAction(action);
    },
     actualizarLeads : function(cmp, csvObject) {
        console.log('entra');
        var action = cmp.get('c.updateLeadsCTI');
        action.setParams({
            csvObject : csvObject
        });
        console.log('actualizarLeads');
        action.setCallback(this, function(response) {
            var state = response.getState();
            var value = response.getReturnValue();
	    	if(state == "SUCCESS") {
                
                this.eliminarLeadsSF(cmp, csvObject);
            }
        });
        $A.enqueueAction(action);
    },
   setIntervalLeadsCTI : function(cmp, csvObject) {
       console.log('setIntervalLeadsCTI');
       var retries = cmp.get("v.retries");
       cmp.set("v.retries",retries+1);
       console.log(retries);
       if(retries<=6){      
        var timer3 = setTimeout((() => {
            this.comprobarLeadsDelCTI(cmp,csvObject);
        }), 10000);
         // setTimeout(function => ( { this.comprobarLeadsDelCTI(cmp,csvObject); }), 20000);
        }else{
            this.eliminarLeadsSF(cmp,csvObject);
            //ya puedes eliminar de salesforce;          
        }	
    },
     comprobarLeadsDelCTI : function(cmp, csvObject) {
       console.log('comprobarIntegrationCTI');
         var action = cmp.get('c.comprobarIntegrationCTI');
         action.setParams({
             csvObject : csvObject
         });
         console.log('comprobarIntegrationCTI');
         action.setCallback(this, function(response) {
             var state = response.getState();
             var value = response.getReturnValue();
             console.log(response.getReturnValue());
             if(value == false){
                 this.setIntervalLeadsCTI(cmp,csvObject);
             } else{
                 this.eliminarLeadsSF(cmp,csvObject);
                 //ya puedes eliminar de salesforce;
             }
         });
         $A.enqueueAction(action);
        
    },
    
    eliminarLeadsSF : function(cmp, csvObject) {
        var action = cmp.get('c.eliminarLeads');
        action.setParams({
            csvObject : csvObject
        });
        console.log('eliminarLeads');
        action.setCallback(this, function(response) {
            var state = response.getState();
            var value = response.getReturnValue();
            if(state == "SUCCESS"){
                cmp.set("v.infoProcess", '');
            }
        });
        $A.enqueueAction(action);
    },
    cargarLeads : function(cmp, csvObject) {
        var action = cmp.get('c.cargarLeads');
        action.setParams({
            csvObject : csvObject
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var value = response.getReturnValue();
	    	if(state == "SUCCESS") {
                cmp.set("v.infoProcess", '');
            }
        });
        $A.enqueueAction(action);
    },
})