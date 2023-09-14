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

    },
})