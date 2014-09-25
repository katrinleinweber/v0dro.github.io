---
layout: post
title: "[code]Generalized Linear Models: Introduction and Implementation in Ruby."
date: 2014-09-21 19:05:21 +0530
comments: true
categories: 
---

## Overview

Most of us are well acquainted with linear regression and its use in analysig the relationship of one dataset with another. Linear regression basically shows the (possibly) linear relationship between one or more independent variables and a single dependent varible. But what if this relationship is not linear and the dependent and independent variables are associated with one another through some special function? This is where Generalized Linear Models (or GLMs) come in. This article will break down certain concepts behind GLMs which I found were explained in too complicated a manner in most other posts and their implementation in Ruby using the [statsample-glm](https://github.com/sciruby/statsample-glm) gem.

## Generalized Linear Models Basics

The basic linear regression equation relating the dependent varible (y) with the independent variable (x) looks something like y = beta0 + x*beta1. This is the equation of a straight line, with beta0 denoting the intercept of the line with the Y axis and beta1 denoting the slope of the line. GLMs take this a step further. They try to establish a relationship between x and y _through another function_ **g**, which is called the _link function_. This function depends on the probability distribution displayed by the independent variables and their corresponding y values. In its simplest form, it can be denoted as _y = g(x)_.

GLMs exist in many forms and have different names depending on the distribution of the independent variables. We will first explore the various kinds of GLMs and their defining parameters and then understand the different methods employed in finding the co-efficients. The different kinds of GLMs are:
* Logistic (or logit) regression.
* Normal regression.
* Poisson regression.
* Probit regression.

Let's see all of the above one by one.

#### Logisitic Regression
Logistic, or Logit can be said to be one of the most fundamental of the GLMs. It is mainly used in cases where the independent variables show binomial distribution. In case of binomial distribution, the corresponding y value for each random variable is either 0 or 1. By using logit link function, one can determine the maximum probability of the occurence of each random variable. The values so obtained can be used to plot a sigmoid graph of x vs y, using which one can predict the probability of occurence of any random varible not already in the dataset. The defining parameter of the logistic is the probability y.

The logit link function looks something like y = exp(beta0 + x\*beta1)/(1 + exp(beta0 + x\*beta1)), where y is probability for the given value of x.

Of special interest is the meaning of the values of beta0 and beta1. In case on linear regression, beta0 merely denoted the intercept while beta1 the slope of the line. However, here, because of the nature of the link function, the coefficient beta1 of the independent variable is interpreted as "for every 1 increase in x the odds of y increase by exp(beta1) times".

One thing that puzzled me when I started off with regression was that why do we have multiple independent variables (x1, x2...) sometimes. The purpose of multiple independent variables against a single dependent is so that we can compare the odds of x1 against x2.
<!-- TODO: Put a graph of logit here -->

#### Normal Regression

Normal regression is used when the indepdent variables exihibit a normal probability distribution. The independents are assumed to be normal even in a simple linear or multiple regression, and the coefficients of a normal are more easily calculated using simple linear regression methods. But since this is another very important and commonly found data set, we will look into it.

Normally distributed data is symmetric about the center and its mean is equal to its median. Commonly found normal distributions are heights of people and errors in measurement. The defining parameters of a normal distribution are the mean mu and variance sigma^2. The link function is simply y = x\*beta1 if no constant is present. The coefficient of the independent variable is interpreted in exactly the same manner as it is for linear regression.

<!-- TODO: Graph of normal -->

#### Poisson Regression

A dataset often posseses a Poisson distribution when the data is measured by taking a very large number of trials, each with a small probability of success, for example, the number of earthquakes taking place in a region per year, mainly count data and contingency tables. Binomial distributions often converge into Poisson.

The poisson is completely defined by the rate parameter lambda. The link function is ln(y) = x\*beta1, which can be written as y = exp(x\*beta1). Because the link function is logarithmic, it is also referred to as log-linear regression.

The meaning of the co-efficient in the case of poisson is "for increase 1 of x, y changes exp(beta1) times.". Notice that in logit, every 1 increase in the value of x caused the _odds_ of y to change by exp(beta1) times.

<!-- TODO: Graph poisson regression -->

#### Probit Regression

Probit is used for modeling binary outcome varialbles. Probit is similar to  logit, the choice between the two largely being a matter of personal preference.

In the probit model, the inverse standard normal distribution of the probability is modeled as a linear combination of the predictors (in simple terms, something like y = phi(beta0 + x1\*beta1...), phi is the CDF of the standard normal). Therefore, the link function can be written as z = phi^-1(p) where phi(z) is the standard normal cumulative density function (here p is probability of the occurence of a random variable x and z is the z-score of the y value).

The fitted mean values of the probit are calculated by setting the upper limit of the normal CDF integral as x\*beta1, and lower limit as -inifinity. This is so because evaluating any normally distributed random number over its CDF will yield the probability of its occurence, which is what we expect from the fitted values of a probit.

The coefficient of x is interpreted as "one unit change in x leads to a change beta1 in the z-score of y".

<!-- TODO: Graph of probit -->

## Finding the coefficients of a GLM

There are two major methods of finding the coefficients of a GLM: 
* Newton-Raphson.
* Iteratively Reweighed Least Squares (IRLS).

#### Newton-Raphson

The Newton-Raphson aims to find the co-efficients by trying to maximize the log likelihood function of the given distribution. The first derivative of the log likelihood wrt to beta is calculated (this is the jacobian), and so is the second derivative (this is the hessian). The coefficient is estimated by first choosing an initial estimate for x\_old, and then iteratively correcting this initial estimate by trying to bring the equation x\_new = x\_old - inverse(hessian)*jacobian to equality (with a pre-set tolerance level).
