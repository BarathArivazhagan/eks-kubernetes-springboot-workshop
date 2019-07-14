package com.barath.customer.app.configuration;

import org.apache.http.impl.client.CloseableHttpClient;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;

import com.amazonaws.xray.proxies.apache.http.HttpClientBuilder;


@Configuration
public class RestTemplateConfiguration {
	
	@Bean
	@LoadBalanced
	public RestTemplate restTemplate() {
		CloseableHttpClient httpclient = HttpClientBuilder.create().build();
		HttpComponentsClientHttpRequestFactory requestFactory =new HttpComponentsClientHttpRequestFactory(httpclient);
		return new RestTemplate(requestFactory);
	}

}
