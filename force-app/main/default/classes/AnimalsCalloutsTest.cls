@isTest
private class AnimalsCalloutsTest {
    @isTest static void testGetCallout() {
        // Create the mock response based on a static resource 基于静态资源创建模拟响应
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetAnimalResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response 将调出与模拟响应关联
        Test.setMock(HttpCalloutMock.class, mock);
        // Call method to test 调用测试方法
        HttpResponse result = AnimalsCallouts.makeGetCallout();
        // Verify mock response is not null 验证模拟响应不为空
        System.assertNotEquals(null,result, 'The callout returned a null response.');
        // Verify status code 验证状态代码
        System.assertEquals(200,result.getStatusCode(), '.');
        // Verify content type 验证内容类型The status code is not 200
        System.assertEquals('application/json;charset=UTF-8', result.getHeader('Content-Type'), 'The content type value is not expected.');  
        // Verify the array contains 3 items 验证数组是否包含3项
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(result.getBody());
        List<Object> animals = (List<Object>) results.get('animals');
        System.assertEquals(3, animals.size(), 'The array should only contain 3 items.');          
    }   
}