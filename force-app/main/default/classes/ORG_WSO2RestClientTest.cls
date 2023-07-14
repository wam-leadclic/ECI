@isTest
global class ORG_WSO2RestClientTest {
	@testSetup
	private static void setup() {

	}

	@isTest
	private static void testGettingAccessToken() {
		Test.setMock(HttpCalloutMock.class, new WSO2HttpResponseGenerator());

		Test.startTest();

		ORG_WSO2RestClient wso2 = new ORG_WSO2RestClient('callout:WSO2_Token','callout:WSO2_Service');
		HttpRequest request = wso2.buildRequest('/service','GET');

		System.assertEquals('callout:WSO2_Service/service', request.getEndpoint());
		System.assertEquals('Bearer 1234567890', request.getHeader('Authorization'));
		System.assertEquals('application/json', request.getHeader('Content-Type'));
		System.assertEquals('application/json', request.getHeader('Accept'));

		HttpResponse response = wso2.sendRequest(request);

		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('{"result": "ok"}', response.getBody());

		Test.stopTest();
	}

	@isTest
	private static void testGettingTokenFromCache() {
		Test.setMock(HttpCalloutMock.class, new WSO2HttpResponseGenerator());

		Test.startTest();

		ORG_WSO2RestClient wso2 = new ORG_WSO2RestClient('callout:WSO2_Token','callout:WSO2_Service');

		// first request
		HttpRequest request = wso2.buildRequest('/service','GET');
		System.assertEquals('callout:WSO2_Service/service', request.getEndpoint());
		System.assertEquals('Bearer 1234567890', request.getHeader('Authorization'));
		HttpResponse response = wso2.sendRequest(request);
		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('{"result": "ok"}', response.getBody());

		// second request
		request = wso2.buildRequest('/service','GET');
		System.assertEquals('callout:WSO2_Service/service', request.getEndpoint());
		//System.assertEquals('Bearer 1234567890', request.getHeader('Authorization'));
		response = wso2.sendRequest(request);
		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('{"result": "ok"}', response.getBody());

		Test.stopTest();
	}

	@isTest
	private static void testWithExpringToken() {
		Test.setMock(HttpCalloutMock.class, new WSO2HttpResponseGenerator());

		Test.startTest();

		ORG_WSO2RestClient wso2 = new ORG_WSO2RestClient('callout:WSO2_Token','callout:WSO2_Expired');
		HttpRequest request = wso2.buildRequest('/service','GET');

		System.assertEquals('callout:WSO2_Expired/service', request.getEndpoint());

		HttpResponse response = wso2.sendRequest(request);

		System.assertEquals(200, response.getStatusCode());
		System.assertEquals('{"result": "expired"}', response.getBody());

		Test.stopTest();
	}

	@isTest
	private static void testErrorGettingToken() {
		Test.setMock(HttpCalloutMock.class, new WSO2HttpResponseGenerator());

		Test.startTest();

		String errorMessage = null;

		ORG_WSO2RestClient wso2 = new ORG_WSO2RestClient('callout:WSO2_TokenError','callout:WSO2_Service');
		try {
			HttpRequest request = wso2.buildRequest('/service','GET');
		}
		catch(Exception e) {
			errorMessage = e.getMessage();
		}

		System.assertEquals(String.format(ORG_WSO2RestClient.errorCannotGetToken, new String[] {'Service down'}), errorMessage);

		Test.stopTest();
	}

	@isTest
	private static void testOthers() {
		Test.setMock(HttpCalloutMock.class, new WSO2HttpResponseGenerator());

		Test.startTest();

		ORG_WSO2RestClient wso2 = new ORG_WSO2RestClient();
		wso2.setTokenNamedCredential('callout:WSO2_Token');
		wso2.setNamedCredential(null);
		HttpRequest request = wso2.buildRequest('http://salesforce.com/service','GET');

		System.assertEquals('http://salesforce.com/service', request.getEndpoint());

		Test.stopTest();
	}

	global virtual class WSO2HttpResponseGenerator implements HttpCalloutMock {
		// Implement this interface method
		global HTTPResponse respond(HTTPRequest request) {
			// Create a fake response
			HttpResponse response = new HttpResponse();

			if(request.getEndpoint().startsWith('callout:WSO2_TokenError')) {
				response.setStatusCode(500);
				response.setStatus('Service down');
			}
			else if(request.getEndpoint().startsWith('callout:WSO2_Token')) {
				System.assertEquals('POST', request.getMethod());
				System.assertEquals('application/x-www-form-urlencoded', request.getHeader('Content-Type'));
				System.assertEquals('grant_type=client_credentials', request.getBody());

				response.setHeader('Content-Type', 'application/json');
				System.debug('X-SF-info: ' + request.getHeader('X-SF-info'));
				if(request.getHeader('X-SF-info') == 'requested') {
					// this means that the token is being refreshed so give a new token
					response.setHeader('X-SF-info', 'refreshed');
					response.setBody('{"success": true, "access_token": "0987654321", "scope": "", "token_type": "Bearer", "expires_in": 300}');
				}
				else {
					// this is the first time we get the token so set the status
					response.setHeader('X-SF-info', 'requested');
					response.setBody('{"success": true, "access_token": "1234567890", "scope": "", "token_type": "Bearer", "expires_in": 300}');
				}

				response.setStatusCode(200);
			}
			else if(request.getEndpoint().startsWith('callout:WSO2_Expired')) {
				System.debug(request.getEndpoint());
				System.debug(request.getHeader('Authorization'));
				if(request.getHeader('Authorization') == 'Bearer 1234567890') {
					response.setStatusCode(401);
				}
				else {
					response.setHeader('Content-Type', 'application/json');
					response.setBody('{"result": "expired"}');
					response.setStatusCode(200);
				}
			}
			else if(request.getEndpoint().startsWith('callout:WSO2_Service')) {
				System.assertEquals('GET', request.getMethod());
				System.assertEquals('application/json', request.getHeader('Content-Type'));

				response.setHeader('Content-Type', 'application/json');
				response.setBody('{"result": "ok"}');
				response.setStatusCode(200);
			}
            else {
				customResponse(request, response);
			}

			return response;
		}

        protected virtual void customResponse(HTTPRequest request, HttpResponse response) {

        }
	}
}