package com.barath.bank.app.configuration;

import javax.servlet.Filter;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.amazonaws.xray.javax.servlet.AWSXRayServletFilter;

@Configuration
public class AWSXRayConfig {
	
	
	  @Bean
	  public Filter TracingFilter() {
	    return new AWSXRayServletFilter("bank-service");
	  }

}
