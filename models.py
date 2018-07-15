from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier, GradientBoostingClassifier, GradientBoostingRegressor
from sklearn.model_selection import GridSearchCV, cross_val_predict
from sklearn.tree import DecisionTreeClassifier
from sklearn.preprocessing import OneHotEncoder
from sklearn.model_selection import train_test_split

def logit(X_train, y_train, X_test):
    model = LogisticRegression()
    fit = model.fit(X_train,y_train)
    y_hat_probit = fit.predict_proba(X_test)[:,1]
    return y_hat_probit

def RF(X_train, y_train,X_test):
    parameters = {'class_weight':['balanced', None],
                'max_depth': [10,12,14],
                'max_features': [9,11,13]
                }
    gscv = GridSearchCV(RandomForestClassifier(), parameters)
    fit = gscv.fit(X_train, y_train)
    print('Best parameters for RF: {}'.format(fit.best_params_))
    y_hat_RF = fit.predict_proba(X_test)[:,1]
    return y_hat_RF

def GBC(X_train, y_train,X_test):
    parameters = {'learning_rate':[0.1],
                    'n_estimators':  [300,400]
                    }
    decisionTree = GradientBoostingClassifier()
    gscv = GridSearchCV(decisionTree, parameters,scoring = 'roc_auc')
    fit = gscv.fit(X_train, y_train)
    print('Best parameters for GBC: {}'.format(fit.best_params_))
    y_hat_GBC = fit.predict_proba(X_test)[:,1]
    return y_hat_GBC

def ABC(X_train, y_train,X_test):
    parameters = {'learning_rate':[0.1],
                    'n_estimators':  [200,150]
                    }
    decisionTree = AdaBoostClassifier(DecisionTreeClassifier(max_depth=3))
    gscv = GridSearchCV(decisionTree, parameters,scoring = 'roc_auc')
    fit = gscv.fit(X_train, y_train)
    print('Best parameters for ABC: {}'.format(fit.best_params_))
    y_hat_ABC = fit.predict_proba(X_test)[:,1]
    return y_hat_ABC


def GBC_Logit(X_train,y_train,X_test):
    X_train, X_train_lr, y_train, y_train_lr = train_test_split(X_train,
                                                            y_train,
                                                            test_size=0.5)
    grd = GradientBoostingClassifier(n_estimators=200,learning_rate=0.1)
    grd_enc = OneHotEncoder()
    grd_lm = LogisticRegression()
    grd.fit(X_train, y_train)
    grd_enc.fit(grd.apply(X_train)[:, :, 0])
    grd_lm.fit(grd_enc.transform(grd.apply(X_train_lr)[:, :, 0]), y_train_lr)
    y_hat_GBC_log = grd_lm.predict_proba(
    grd_enc.transform(grd.apply(X_test)[:, :, 0]))[:, 1]
    return y_hat_GBC_log

def RF_Logit(X_train,y_train,X_test):
    X_train, X_train_lr, y_train, y_train_lr = train_test_split(X_train,
                                                            y_train,
                                                            test_size=0.5)
    grd = RandomForestClassifier(max_depth=10,max_features=9)
    grd_enc = OneHotEncoder()
    grd_lm = LogisticRegression()
    grd.fit(X_train, y_train)
    grd_enc.fit(grd.apply(X_train))
    grd_lm.fit(grd_enc.transform(grd.apply(X_train_lr)), y_train_lr)
    y_hat_RF_log = grd_lm.predict_proba(
    grd_enc.transform(grd.apply(X_test)))[:, 1]
    return y_hat_RF_log
