({
       obtainReferent :  function(cmp, event) {
           cmp.set("v.showSpinner", true);
           console.log('leadRef:'+cmp.get("v.Record.Lead_Referrer__c"));
           console.log('oppRef:'+cmp.get("v.Record.Lead_Referrer__c"));
           if(cmp.get("v.Record.Lead_Referrer__c")==undefined){
               if(cmp.get("v.Record.Opp_Referrer__c")== undefined){
                   cmp.set("v.requestNotFound",true);
               	   cmp.set("v.requestErrorMessage","No se ha encontrado Registro Origen");
               }else{
                   var oppId = cmp.get("v.Record.Opp_Referrer__c");
                   cmp.set("v.oppId",oppId);
                   this.findOpp(cmp,event);    
               } 
           }else{
               var action = cmp.get("c.getReferent");
               action.setParams({
                   idLeadPre : cmp.get("v.Record.Lead_Referrer__c")
               });
               action.setCallback(this, function(response) {
                   cmp.set("v.showSpinner", false);
                   var state = response.getState();
                   if (state === "ERROR") {
                       console.log("error");
                       var resultsToast = $A.get("e.force:showToast");
                       resultsToast.setParams({
                           "type": "error",
                           "title": "Gestiones Referente",
                           "message": "No se puede buscar en estos momentos"
                       });
                       resultsToast.fire();
                   }else if(state === "SUCCESS"){
                       var leadRef = response.getReturnValue();
                       console.log("IdRefDesdeBD: "+leadRef.Id); 
                       if(leadRef!=null && leadRef!=undefined){
                           console.log("Opp ref: "+leadRef.ConvertedOpportunityId); 
                           var idOppRefer = leadRef.ConvertedOpportunityId;
                           if(idOppRefer == undefined || idOppRefer == null){
                               cmp.set("v.requestNotFound",true);
                               cmp.set("v.requestErrorMessage","No se ha encontrado Oportunidad en Lead Origen");
                           } else {
                               cmp.set("v.requestNotFound",false);
                               cmp.set("v.oppId",leadRef.ConvertedOpportunityId);
                               this.findOpp(cmp,event);    
                           }
                       }
                       
                   }
               });
               $A.enqueueAction(action);
           }
           
       },
       findOpp :  function(cmp, event) {
           console.log('oppId:'+cmp.get("v.oppId"));
           var action = cmp.get("c.getOpp");
           action.setParams({
               idOpp : cmp.get("v.oppId")
           });
           action.setCallback(this, function(response) {
               cmp.set("v.showSpinner", false);
               var state = response.getState();
               if (state === "ERROR") {
                   console.log("error");
                   var resultsToast = $A.get("e.force:showToast");
                   resultsToast.setParams({
                       "type": "error",
                       "title": "Gestiones Referente",
                       "message": "No se puede buscar en estos momentos"
                   });
                   resultsToast.fire();
               }else if(state === "SUCCESS" &&  response.getReturnValue() != null){
                   var records = response.getReturnValue();
                   //encontramos datos.
                   records.forEach(record => {
                       record['Propietario'] = record.Owner.Name;
                   		record['CuentaLink'] = '/lightning/r/Account/' + record.Account.Id + '/view';
                   		record['CuentaName'] = record.Account.Name;
                   		record['LinkName'] =  '/lightning/r/Opportunity/' + record.Id + '/view';
                   });   
                       
                   cmp.set("v.records",records);
               }
           });
           $A.enqueueAction(action);
       }
})