---
layout: post
title: "[code]Generalized Linear Models: Introduction and Implementation in Ruby."
date: 2014-09-21 19:05:21 +0530
comments: true
categories: 
---

## Overview

Most of us are well acquainted with linear regression and its use in analysig the relationship of one dataset with another. Linear regression basically shows the (possibly) linear relationship between one or more independent variables and a single dependent variable. But what if this relationship is not linear and the dependent and independent variables are associated with one another through some special function? This is where Generalized Linear Models (or GLMs) come in. This article will explain some core [GLM](http://en.wikipedia.org/wiki/Generalized_linear_model) concepts and their implementation in Ruby using the [statsample-glm](https://github.com/sciruby/statsample-glm) gem.

## Generalized Linear Models Basics

The basic linear regression equation relating the dependent varible _y_ with the independent variable _x_ looks something like 
$$
\begin{align}
    y = \beta_{0} + x*\beta_{1} 
\end{align}
$$
This is the equation of a straight line, with $$ \beta_{0} $$ denoting the intercept of the line with the Y axis and $$ \beta_{1} $$ denoting the slope of the line. GLMs take this a step further. They try to establish a relationship between _x_ and _y_ through _another function_ **g(x)**, which is called the _link function_. This function depends on the probability distribution displayed by the independent variables and their corresponding y values. In its simplest form, it can be denoted as _y = g(x)_.

GLMs exist in many forms and have different names depending on the distribution of the independent variables. We will first explore the various kinds of GLMs and their defining parameters and then understand the different methods employed in finding the co-efficients. The different kinds of GLMs are:

* Logistic (or logit) regression.
* Normal regression.
* Poisson regression.
* Probit regression.

Let's see all of the above one by one.

#### Logisitic Regression
Logistic, or Logit can be said to be one of the most fundamental of the GLMs. It is mainly used in cases where the independent variables show binomial distribution. In case of binomial distribution, the corresponding _y_ value for each random variable is either 0 or 1. By using logit link function, one can determine the maximum probability of the occurence of each independent random variable. The values so obtained can be used to plot a sigmoid graph of _x_ vs _y_, using which one can predict the probability of occurence of any random varible not already in the dataset. The defining parameter of the logistic is the probability _y_.

The logit link function looks something like 
$$
\begin{align}
    y = \frac{e^{(\beta_{0} + x*\beta_{1})}}{1 + e^{(\beta_{0} + x*\beta_{1})}}
\end{align}
$$
, where y is the probability for the given value of x.

Of special interest is the meaning of the values of the coefficients. In case on linear regression, $$ \beta_{0} $$ merely denotes the intercept while $$ \beta_{1} $$ is the slope of the line. However, here, because of the nature of the link function, the coefficient $$ \beta_{1} $$ of the independent variable is interpreted as "for every 1 increase in _x_ the odds of _y_ increase by $$ e^{\beta_{1}} $$ times".

One thing that puzzled me when I started off with regression was the purpose of having several variables $$ (x_{1}, x_{2}...) $$ in the same regression model at times. The purpose of multiple independent variables against a single dependent is so that we can compare the odds of $$ x_{1} $$ against $$ x_{2} $$.

The logistic graph generally looks like this:

{% img center /images/glm/logistic.gif "Generic Graph of Logistic Regression." %}

#### Normal Regression

Normal regression is used when the indepdent variables exihibit a normal probability distribution. The independents are assumed to be normal even in a simple linear or multiple regression, and the coefficients of a normal are more easily calculated using simple linear regression methods. But since this is another very important and commonly found data set, we will look into it.

Normally distributed data is symmetric about the center and its mean is equal to its median. Commonly found normal distributions are heights of people and errors in measurement. The defining parameters of a normal distribution are the mean $$ \mu $$ and variance $$ \sigma^2 $$. The link function is simply $$ y = x*\beta_{1} $$ if no constant is present. The coefficient of the independent variable is interpreted in exactly the same manner as it is for linear regression.

A normal regression graph generally looks like this:
  
{% img center /images/glm/normal.png "Generic Graph of Normal Regression" %}

#### Poisson Regression

A dataset often posseses a Poisson distribution when the data is measured by taking a very large number of trials, each with a small probability of success. For example, the number of earthquakes taking place in a region per year. It is mainly used in case of count data and contingency tables. Binomial distributions often converge into Poisson.

The poisson is completely defined by the rate parameter $$ \lambda $$. The link function is $$ ln(y) = x*\beta_{1} $$, which can be written as $$ y = e^{x*\beta_{1}} $$. Because the link function is logarithmic, it is also referred to as log-linear regression.

The meaning of the co-efficient in the case of poisson is "for increase 1 of _x_, _y_ changes $$ y = e^\beta_{1} $$ times.". Notice that in logit, every 1 increase in the value of x caused the _odds_ of y to change by $$ y = e^\beta_{1} $$ times.

A poisson graph looks something like this:
  
{% img center /images/glm/poisson.png "Graph of Poisson Regression" %}

#### Probit Regression

Probit is used for modeling binary outcome varialbles. Probit is similar to  logit, the choice between the two largely being a matter of personal preference.

In the probit model, the inverse standard normal distribution of the probability is modeled as a linear combination of the predictors (in simple terms, something like $$ y = \Phi(\beta_{0} + x_{1}*\beta_{1}...) $$ , where $$ \Phi $$ is the CDF of the standard normal). Therefore, the link function can be written as $$ z = \Phi^{-1}(p) $$ where $$ \Phi(z) $$ is the standard normal cumulative density function (here _p_ is probability of the occurence of a random variable _x_ and _z_ is the z-score of the y value).

The fitted mean values of the probit are calculated by setting the upper limit of the normal CDF integral as $$ x*\beta_{1} $$, and lower limit as $$ -\infty $$. This is so because evaluating any normally distributed random number over its CDF will yield the probability of its occurence, which is what we expect from the fitted values of a probit.

The coefficient of _x_ is interpreted as "one unit change in _x_ leads to a change $$ \beta_{1} $$ in the z-score of _y_".

Looking at the graph of probit, one can see the similarities between logit and probit:
  
{% img center /images/glm/probit.png %}

## Finding the coefficients of a GLM

There are two major methods of finding the coefficients of a GLM:

* Maximum Likelihood Estimation (MLE).
* Iteratively Reweighed Least Squares (IRLS).

#### Maximum Likelihood Estimation

The most obvious way of finding the coefficients of the given regression analysis is by maximizing the likelihood function of the distribution that the independent variables belong to. This becomes much easier when we take the natural logarithm of the likelihood function. Hence, the name 'Maximum Likelihood Estimation'. The Newton-Raphson method is used to this effect for maximizing the beta values (coefficients) of the log likelihood function.

The first derivative of the log likelihood wrt to $$ \beta $$ is calculated for all the $$ x_{i} $$ terms (this is the jacobian matrix), and so is the second derivative (this is the hessian matrix). The coefficient is estimated by first choosing an initial estimate for $$ x_{old} $$, and then iteratively correcting this initial estimate by trying to bring the equation

$$ 
\begin{align}
x_{new} = x_{old} - inverse(hessian)*jacobian   ..(1) 
\end{align}
$$

to equality (with a pre-set tolerance level). A good implementation of MLE can be found [here](http://petertessin.com/MaxLik.pdf).

#### Iteratively Reweighed Least Squares

Another useful but somewhat slower method of estimating the regression coefficients of a dataset is Iteratively Reweighed Least Squares. It is slower mainly because of the number of co-efficients involved and the somewhat extra memory that is taken up by the various matrices used by this method. The upside of IRLS is that it is very easy to implement as is easily extensible to any kind of GLM.

The IRLS method also ultimately boils to the equation of the Newton Raphson (1), but the key difference between the two lies in the manner in which the hessian and jacobian matrices are calculated. The IRLS equation is written as:
  
$$
\begin{align}
    b_{new} = b_{old} - inverse(X'*W*X)*(X'*(y - \mu))
\end{align}
$$

Here, the hessian matrix is $$ -(X'*W*X) $$ and the jacobian is $$ (X'*(y - \mu)) $$. Let's see the significance of each term in each of these matrices:

* _X_ - The matrix of independent variables  $$ x_{1}, x_{2},... $$ alongwith the constant vector.
* _X'_ - Transpose of X.
* _W_ - The weight matrix. This is the most important entity in the equation and understanding it completely is paramount to gaining an understanding of the IRLS as whole.
    - The _weight_ matrix is present to reduce favorism of the best fit curve towards larger values of x. Hence, the weight matrix acts as a mediator of sorts between the very small and very large values of x (if any). It is a diagonal matrix with each non-zero value representing the weight for each vector $$ x_{i} $$ in the sample data.
    - Calculation of the weight matrix is dependent on the probability distribution shown by the independent random variables. The weight expression can be calculated by taking a look at the equation of the hessian matrix. So in the case of logistic regression, the weight matrix is a diagonal matrix with the ith entry as $$ p(x_{i}, \beta_{old})*(1 - p(x_{i}, \beta_{old})) $$.
* $$ (y - \mu) $$ - This is a matrix whose ith value the is difference between the actual corresponding value on the y-axis minus $$ \mu = x*b_{old} $$. The value of this term is crucial in determining the error with which the coefficients have been calculated. Frequently an error of 10e-4 is acceptable.

## Generalized Linear Models in Ruby

Calculating the co-efficients and a host of other properties of a GLM is extremely simple and intuitive in Ruby. Let us see some examples of GLM by using the `statsample` and `statsample-glm` gems:

First install `statsample-glm` by running `gem install statsample-glm`, statsample will be downloaded alongwith it if it is not installed directly. Then download the CSV files from [here](https://github.com/SciRuby/statsample-glm/blob/master/spec/data/logistic_mle.csv).

Statsample-glm supports a variety of GLM methods, giving the choice of both, IRLS and MLE algorithms to the user for almost every distribution, and all this through a simple and intutive API. The primary calling function for all distribtions and algorithms is `Statsample::GLM.compute(data_set, dependent, method, options)`. We specify the data set, dependent variable, type of regression and finally an options hash in which one can specify a variety of customization options for the computation.

To compute the co-efficients of a logistic regression, try this code:

```ruby
# Code for computing coefficients and related attributes of a logistic regression.

data_set = Statsample::CSV.read "logistic_mle.csv"
glm = Statsample::GLM.compute data_set, :y, :logistic, {constant: 1, algorithm: :mle} 
# Options hash specifying addition of an extra constants vector all of whose values is '1' and also specifying that the MLE algorithm is to be used.

puts glm.coefficients   
  #=> [0.3270, 0.8147, -0.4031,-5.3658]
puts glm.standard_error
  #=> [0.4390, 0.4270, 0.3819,1.9045]
puts glm.log_likelihood 
  #=> -38.8669
```

Similar to the above code, you can try implementing poisson, normal or probit regression models and use the data files from the link above as sample data. Just go through the tests in the source code on GitHub or read the documentation for further details and feel free to drop me a mail in case you have any doubts/suggestions for improvements.

Cheers!

------------------

###### Further Reading
* [A good explanation of IRLS](https://cise.ufl.edu/class/cis6930sp10esl/downloads/LogisticRegression.pdf).
* [Logistic Regression and Newtons Method](http://www.stat.cmu.edu/~cshalizi/402/lectures/14-logistic-regression/lecture-14.pdf).
* [A good resource on the how and why behind the calculation of standard errors](https://files.nyu.edu/mrg217/public/mle_introduction1.pdf).
* [Logit and Probit](http://www.columbia.edu/~so33/SusDev/Lecture_9.pdf).
* [A very good explanation of the Poisson regression](http://www.nesug.org/Proceedings/nesug10/sa/sa04.pdf).