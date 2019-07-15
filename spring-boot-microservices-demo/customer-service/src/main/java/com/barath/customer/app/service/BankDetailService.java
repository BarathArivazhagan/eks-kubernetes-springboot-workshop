package com.barath.customer.app.service;

import java.lang.invoke.MethodHandles;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.amazonaws.xray.spring.aop.XRayEnabled;
import com.barath.customer.app.dto.Bank;


@Service
@XRayEnabled
public class BankDetailService{
	
	private static final Logger logger = LoggerFactory.getLogger(MethodHandles.lookup().lookupClass());
	private RestTemplate restTemplate;	
	
	@Value("${bank.service.name:bank-service}")
	private String bankServiceName;

	public BankDetailService(RestTemplate restTemplate) {
		this.restTemplate = restTemplate;
	}

	public Bank getBankDetails(Long bankId) {
		String url = String.format(bankServiceName.concat("/bank?id=%d"),bankId);
		logger.info("url formed {} and serviceName {}", url, bankServiceName);
		return this.restTemplate.getForObject(url, Bank.class);
	}
	
	
}