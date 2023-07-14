public with sharing class ORG_WSO2RestClient {
	public static final Integer TIMEOUT = 60000;
	public static final String WSO_TOKEN_NAMED_CREDENTIAL = 'callout:WSO2_Token';

	private static final String WSO2_CACHE_SESSION_TOKEN = 'wso2SessionToken';
	private static final Integer WSO2_CACHE_SESSION_MAX_TIME = 8 * 60 * 60; // the maximum number of seconds to store something in session cache
	private static final Integer WSO2_CACHE_SESSION_MIN_TIME = 5 * 60; // the minimum number of seconds to store something in session cache
	private static final String WS02_CACHE_CRYPTO_IV = '00000000000000000000000000000000';
	
	@TestVisible private static final String errorCannotGetToken = 'Cannot get an access token: {0}';

	private String namedCredential;
	private String tokenNamedCredential;

	// this is only used for tests
	private String testInfo;

	public ORG_WSO2RestClient() {
	}

    public ORG_WSO2RestClient(String tokenNamedCredential, String namedCredential) {
		this(namedCredential);
		this.tokenNamedCredential = tokenNamedCredential;
    }

	public ORG_WSO2RestClient(String namedCredential) {
		tokenNamedCredential = WSO_TOKEN_NAMED_CREDENTIAL;
		this.namedCredential = namedCredential;
    }
    
    public void setTokenNamedCredential(String namedCredential) {
        this.tokenNamedCredential = namedCredential;
    }
    
    public void setNamedCredential(String namedCredential) {
        this.namedCredential = namedCredential;
    }    

	public HttpResponse sendRequest(HttpRequest request) {
		Http http = new Http();		
		HttpResponse response = http.send(request);

		System.debug(response.getStatusCode() + ' ' + response.getStatus());
		System.debug(response.getBody());

		if(response.getStatusCode() == 401) { // token is expired, get a new token
			System.debug('token is expired, renew it');
			String accessToken = getAccessToken(false);
			addAuthenticationHeader(request, accessToken);
			response = http.send(request);
		}

		return response;
	}

	public HttpRequest buildRequest(String path, String httpMethod) {
		return buildRequest(path, httpMethod, null);
	}
    
    public HttpRequest buildRequest(String path, String httpMethod, String body) {
		String accessToken = getAccessToken(true);

		HttpRequest request = new HttpRequest();
        if(String.isNotBlank(body)) request.setBody(body); 
		request.setMethod(httpMethod);        
		if(String.isNotBlank(namedCredential))
            request.setEndpoint(namedCredential + path);
        else
            request.setEndpoint(path);
		request.setTimeout(TIMEOUT);
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Accept', 'application/json');
		addAuthenticationHeader(request, accessToken);

		return request;
	}

	public void addAuthenticationHeader(HttpRequest request, String accessToken) {
		request.setHeader('Authorization', 'Bearer ' + accessToken);
	}	

	private String getAccessToken(Boolean useCache) {
		String accessToken = null;
		
		if(useCache) {
			try {
				if (Cache.Session.isAvailable() && Cache.Session.contains(WSO2_CACHE_SESSION_TOKEN)) {
					System.debug('Obtaining token from cache');
					String decryptedToken = Crypto.decryptWithManagedIV('AES256', Blob.valueOf(WS02_CACHE_CRYPTO_IV) , EncodingUtil.Base64Decode((String)Cache.Session.get(WSO2_CACHE_SESSION_TOKEN))).toString();
					if(isTokenValid(decryptedToken)) {
						accessToken = decryptedToken;
					}
				}
			} catch (Exception e) {
				system.debug('Failed using Cache.');
			}
		}

		if(String.isNotBlank(accessToken)) return accessToken;

		System.debug('Obtaining new access token');
		TokenInfo token = refreshToken();
		accessToken = token.access_token;

		try {
			if (Cache.Session.isAvailable()) {
				Blob encryptedToken = Crypto.encryptWithManagedIV('AES256', Blob.valueOf(WS02_CACHE_CRYPTO_IV), Blob.valueOf(accessToken)); 
				Cache.Session.put(WSO2_CACHE_SESSION_TOKEN, EncodingUtil.Base64Encode(encryptedToken), Math.max(WSO2_CACHE_SESSION_MIN_TIME, (Integer)Math.min(WSO2_CACHE_SESSION_MAX_TIME, Long.valueOf(token.expires_in))));
			}
		} catch (Exception e) {
			system.debug('Failed using Cache.');
		}

		return accessToken;
	}

	private Boolean isTokenValid(String accessToken) {
		return true;
	}

	private TokenInfo refreshToken() {
		try {
			Http http = new Http();
			HttpRequest request = new HttpRequest();
			request.setMethod('POST');        
			request.setEndpoint(tokenNamedCredential);
			request.setHeader('Content-Type','application/x-www-form-urlencoded');
			request.setTimeout(TIMEOUT);
			request.setBody('grant_type=client_credentials');
			if(Test.isRunningTest() && String.isNotBlank(testInfo)) request.setHeader('X-SF-info', testInfo);
			HttpResponse response = http.send(request);

			if(response.getStatusCode() != 200) {
                System.debug(response.getStatus() + ' ' + response.getStatusCode());
				throw new ORG_WSO2RestClientException(response.getStatus());
			}

			if(Test.isRunningTest() && String.isNotBlank(response.getHeader('X-SF-info'))) testInfo = response.getHeader('X-SF-info');

 			TokenInfo token = parseTokenInfo(response.getBody());
			System.debug('token received: ' + token);
			return token;
		}
		catch(Exception e) {
			throw new ORG_WSO2RestClientException(String.format(errorCannotGetToken, new String[] { e.getMessage() }));
		}
	}

	private static TokenInfo parseTokenInfo(String json) {
		return (TokenInfo) System.JSON.deserialize(json, TokenInfo.class);
	}

	/**
     * @description Class that represents a RefreshTokenResponse.
     */
    public class TokenInfo {
        public Boolean success;
        public String access_token;
        public String scope;
        public String token_type;
        public String expires_in;
    }

    //-- CUSTOM EXCEPTION
    /**
     * Custom exception for unexpected situations.
     */
    public class ORG_WSO2RestClientException extends Exception {}   	
}