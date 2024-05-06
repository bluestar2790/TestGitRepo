({
    myAction : function(component, event, helper) {
    
    },

    addBook : function(cmp, event, helper) {
        var readerIdValue = cmp.find("readerId").get("v.value");
        cmp.set('v.mycolumns', [
            { label: '图书详细编号', fieldName: 'Name', type: 'text'},
            { label: '图书名称', fieldName: 'bookName__c', type: 'text'},
            { label: '图书状态', fieldName: 'bookDetailsBStatus__c', type: 'text'},
            { label: '图书价格', fieldName: 'bookPrice__c', type: 'currency'}
        ]);
        console.log(readerIdValue);
        if (readerIdValue != null) {
            var bookDetailsIdValue = cmp.find("bookDetailsId").get("v.value");
            if (bookDetailsIdValue != null) {
                helper.addBookHelper(cmp, readerIdValue, bookDetailsIdValue);
            }
        } else {

        }
    },

    selfBorrowBook : function(cmp, event, helper) {
        var readerIdValue = cmp.find("readerId").get("v.value");
        helper.selfBorrowBookHelper(cmp, readerIdValue);
    },

    clearFlag : function(cmp, event, helper) {
        helper.clearFlagHelper(cmp);
    }
})