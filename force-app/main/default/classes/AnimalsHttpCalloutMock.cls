@isTest
global class AnimalsHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method 实现此接口方法
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response 创造一个虚假的response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
        response.setStatusCode(200);
        return response; 
    }

    @isTest static void testPostCallout() {
        // Set mock callout class 设置模拟标注类
        Test.setMock(HttpCalloutMock.class, new AnimalsHttpCalloutMock()); 
        // This causes a fake response to be sent  发送一个假response
        // from the class that implements HttpCalloutMock. 从实现HttpCalloutMock的类。
        HttpResponse response = AnimalsCallouts.makePostCallout();
        // Verify that the response received contains fake values 验证接收到的响应包含假值
        String contentType = response.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = response.getBody();
        System.debug(response.getBody());
        String expectedValue = '{"animals": ["majestic badger", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, response.getStatusCode());
    }
}