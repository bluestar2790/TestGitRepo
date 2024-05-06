({
    myAction : function(component, event, helper) {
    
    },

    /********************************************************************
    * Purpose:
    ********************************************************************/
    init : function (cmp, event, helper) {
        cmp.set('v.mycolumns', [
            { label: '图书详细编号', fieldName: 'Name', type: 'text'},
            { label: '图书名称', fieldName: 'bookName__c', type: 'text'},
            { label: '图书状态', fieldName: 'bookDetailsBStatus__c', type: 'text'},
            { label: '图书价格', fieldName: 'bookPrice__c', type: 'currency'}
        ]);
        helper.getData(cmp);
    },

    /********************************************************************
    * Purpose:获取选中行的Id
    ********************************************************************/
    getSelected : function(cmp, event, helper) {
        var selectedRow = event.getParam('selectedRows');
        var bookDetailsList = new Array();
        for (var i = 0; i < selectedRow.length; i++){
            bookDetailsList.push(selectedRow[i].Id);
        }
        cmp.set('v.bookDetailsIdList', bookDetailsList);
    },

    /********************************************************************
    * Purpose:借书按钮事件,调用ReaderBorrowBookComponentHelper里setBorrowBook方法。
    ********************************************************************/
    borrowBook: function (cmp, event, helper) {
        var readerIdValue = cmp.find("readerId").get("v.value");
        cmp.set('v.mycolumns', [
            { label: '图书详细编号', fieldName: 'Name', type: 'text'},
            { label: '图书名称', fieldName: 'bookName__c', type: 'text'},
            { label: '图书状态', fieldName: 'bookDetailsBStatus__c', type: 'text'},
            { label: '图书价格', fieldName: 'bookPrice__c', type: 'currency'}
        ]);
        helper.setBorrowBook(cmp, readerIdValue);
    }
})