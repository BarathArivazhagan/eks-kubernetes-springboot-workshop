package com.barath.customer.app.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.amazonaws.xray.spring.aop.XRayEnabled;
import com.barath.customer.app.dto.Bank;


@Service
@XRayEnabled
public class BankDetailService{
	
	private RestTemplate restTemplate;	
	
	@Value("${bank.service.name:bank-service}")
	private String bankServiceName;

	public BankDetailService(RestTemplate restTemplate) {
		this.restTemplate = restTemplate;
	}

	public Bank getBankDetails(Long bankId) {
		
		
		String url = String.format(bankServiceName.concat("/bank?id=%d"),bankId);
		System.out.println("URL ==> "+url);
		return this.restTemplate.getForObject(url, Bank.class);
	}
	
	
}