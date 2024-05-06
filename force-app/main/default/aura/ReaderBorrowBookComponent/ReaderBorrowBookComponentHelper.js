({
    helperMethod : function() {
    
    },

    /********************************************************************
    * Purpose:调用ReaderBorrowBookComponentController里getbookDetails方法。
              并把返回的数据显示到前端
    ********************************************************************/
    getData : function(cmp) {
        var action = cmp.get('c.getbookDetails');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    },

    /********************************************************************
    * Purpose:调用ReaderBorrowBookComponentController里setBorrowinfo方法。
              并把返回的数据显示到前端
    ********************************************************************/
    setBorrowBook : function(cmp, readerIdValue, bookDetailsIdValue) {
        var bookDetailsList = cmp.get('v.bookDetailsIdList');
        var action = cmp.get('c.setBorrowinfo');
        action.setParams({
            'readerIdList' : event,
            'bookDetailsIdList': bookDetailsList
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }
})