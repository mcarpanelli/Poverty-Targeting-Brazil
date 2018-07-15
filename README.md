# Poverty Prediction in Brazil

## Problem
Most countries measure poverty with absolute income thresholds (i.e. a fixed standard values considered as the minimum income to meet their basic needs). Among the multiple challenges faced by poverty metrics, obtaining reliable income information is probably the biggest.

## Data
This project uses  survey data from the Brazilian Pesquisa Nacional por Amostra de Domicilios (PNAD)  2012,  the  largest  national  household  survey  in  Brazil.  Households  in  the database  have   been  classified  as  poor  using  a  very  simple  comparison  of  their  income with  the  respective  regional  poverty  line.

The models used predict household poverty using PNAD's rich data on individual and household characteristics--broadly  classified  into demographics,  education,  housing,  assets,  employment,  and  access  to  services.

## Approach

The analysis evaluates AUC performance of six different algorithms: Logistic Regression, Random Forest Classifier, Gradient Boosting Classifier, AdaBoost Classifier, and two ensemble models: Logistic Regression + Random Forest Classifier, and Gradient Boosting Classifier.

Moreover, policy implications in terms of targeting leakage and undercoverage are taken into account through a baseline cost-benefit analysis.

## Final note

This repo builds on work for Advanced Quantitative Methods (API-209) of the [MPA/ID Curriculum](https://www.hks.harvard.edu/educational-programs/masters-programs/master-public-administration-international-development-0) at Harvard Kennedy School.