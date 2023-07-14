({
//Initialises the Lightning Component
doInit : function(component, event, helper) {
    helper.doInit(component, event);
},

//Refresh the Lightning Data Service
doRefresh : function(component, event, helper) {
    helper.doRefresh(component, event);
},

//Push cancel button
onCancel : function(component, event, helper) {
    helper.handleOnCancel(component, event);
},

//Triggers an action when a row is selected
handleRowSelection: function (component, event, helper) {
    helper.handleSelection(component, event);
},

onSelect : function (component, event, helper){
    helper.handleOnSelect(component, event);
}
})