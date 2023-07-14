({
	doInit : function(cmp, evt, helper) {
        window.setInterval(
        	$A.getCallback(function() {
                helper.getTask(cmp);
            }), 10000
        );
	}
})