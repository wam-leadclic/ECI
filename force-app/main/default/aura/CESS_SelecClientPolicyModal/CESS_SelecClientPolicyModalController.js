({
    handleChangePolicyEvent : function(component, event, helper) {
        component.set("v.showSpinner",true);
        $A.get('e.force:refreshView').fire();
        helper.refreshData(component, event, helper);
    },

    updateRecordHanler : function(component, event, helper) {

        var changeType = event.getParams().changeType;

        if (changeType === "CHANGED") { 
            console.log ("Modal LDS changed");
            component.find("recordHandler").reloadRecord();
            if (component.get("v.objectFields.Account.identifier_cess__pc") || component.get("v.objectFields.Account.identifier_aneto__pc")){
                component.set("v.showPolicy",true);
                component.set("v.showSpinner", false);
            }else{
                component.set("v.showPolicy",false);
                component.set("v.showSpinner", false);
            }
        }else if (changeType === "LOADED") {
            console.log ("Modal LDS Loaded");
            if (component.get("v.objectFields.Account.identifier_cess__pc") || component.get("v.objectFields.Account.identifier_aneto__pc")){
                component.set("v.showPolicy",true);
                component.set("v.showSpinner", false);
            }else{
                component.set("v.showPolicy",false);
                component.set("v.showSpinner", false);
            }
        }

        if(component.get("v.objectFields.CTI_Campaign__c")!= null && component.get("v.objectFields.CTI_Campaign__c").includes('BLECIS') ){
            component.set("v.showLegalInformation", true);
            if(component.get("v.objectFields.Account.PersonEmail") != null){
                component.set("v.legalInformartionMessage",$A.get("$Label.c.InformacionLegalEmail")+component.get("v.objectFields.Account.PersonEmail"));
            }else if(component.get("v.objectFields.Account.PersonMobilePhone") != null && (component.get("v.objectFields.Account.PersonMobilePhone").startsWith('6') || component.get("v.objectFields.Account.PersonMobilePhone").startsWith('7'))){
                component.set("v.legalInformartionMessage",$A.get("$Label.c.InformacionLegalSMS")+component.get("v.objectFields.Account.PersonMobilePhone"));
            }else if(component.get("v.objectFields.Account.Phone") != null && ( component.get("v.objectFields.Account.Phone").startsWith('6') || component.get("v.objectFields.Account.Phone").startsWith('7') )){
                component.set("v.legalInformartionMessage",$A.get("$Label.c.InformacionLegalSMS")+component.get("v.objectFields.Account.Phone"));
            }else{
                component.set("v.legalInformartionMessage",$A.get("$Label.c.InfomracionLegalLocucion"));
            }
        }else{
            component.set("v.showLegalInformation", false);
        }


        

    },
})