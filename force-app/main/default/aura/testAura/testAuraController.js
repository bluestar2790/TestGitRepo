({
    doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        console.log('recordId', recordId);

        var action = component.get('c.getUserId');
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var resValue = response.getReturnValue();
                console.log('resValue', resValue)
                component.set("v.test", resValue);
            } else if (state === 'ERROR') {
                var errors = response.getError();
                console.log('error', errors)
            }
        });
        $A.enqueueAction(action);

    },
})