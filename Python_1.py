# HENOK FASIL TELILA, AUG 2020
# Correlation analysis between multiple pairs of electronic products.
# The data are gathered from mySql database called MariaDB


import os
from sqlalchemy import create_engine
from datetime import datetime, timedelta
import warnings
from pandas.tseries.offsets import BDay
import pandas as pd
import config as cf
import random
import mysql.connector
from mysql.connector import Error
from datetime import date
from dateutil.rrule import rrule, DAILY
from dateutil.rrule import rrule, WEEKLY
stringa_config = str('mysql+pymysql://' + cf.username + ':' + cf.password + '@' + cf.indirizzo + '/' + cf.database)
engine = create_engine(stringa_config); connection = engine.raw_connection(); cursor = connection.cursor()
def fxn():
   warnings.warn("deprecated", DeprecationWarning)

def read_sql(x):
    #read table , rename data column and extract only %Y-%m-%d
    nu = pd.read_sql_table(x, con=engine)
    nu = nu.rename(columns={'event_time': 'date'})
    #nu['date'] = nu.date.map(lambda x: x.strftime('%Y-%m-%d'))
    return nu

# 1) Number of crash errors
andro1 = 'abt_crashlytics_android_bancoposta' ; ios1 = 'abt_crashlytics_ios_bancoposta'
crash_andr = read_sql(andro1)
#crash_andr['issue_title1'] = crash_andr['issue_title'].str.replace('line ','')
crash_andr['issue_title'] = crash_andr['issue_title'].apply(lambda x: x.split('line')[0]) #Remove strings after a specified words or numbers

crash_ios = read_sql(ios1)
crash_ios['issue_title'] = crash_ios['issue_title'].apply(lambda x: x.split('line')[0])
'''
#Number of manufacturers
'''
def table(x, y):
    c1 = crash_andr.groupby(['date', x], as_index=False)['event_id']. \
        count().sort_values(ascending=True, by='date').rename(columns={'event_id': y})
    c1["rank"] = c1.groupby("date").rank(method="min", ascending=False).astype(int)
    return c1
#Number of manufactureres
m = 'manufacturer' ; m2 = 'num_crashes'
ct_ma1 = table(m,m2).rename(columns={'rank':'rank_crashes'})
'''
#2) ISSUE TITLE ERRORS
# 'CustomHomeCardView.java','LightSettingActivityLib.java','LoginContentProvider.java','Parcel.java',PfmData.java'
'''
def manuCount(x):
    '''
    :param x: list of manufacturers in the data frame
    :return: Select the crashes per month for each manufacturers
    '''
    d7 = crash_andr.groupby(['date', 'manufacturer'], as_index=False)['event_id']. \
    count().sort_values(ascending=[True, False], by=['date', 'event_id'])
    d = d7[d7['manufacturer'].str.contains(x)]
    d = d.drop(columns=['manufacturer'])
    d = d.rename(columns={'event_id':x})
    #return d

def timeseries(x, y):
    '''
    :param x: issue title
    :param y: List of top five issue title
    :return: a dataframe with a timeseries element
    '''
    d3 = crash_andr.groupby(['date', x], as_index=False)['event_id']. \
            count().sort_values(ascending=[True,False], by=['date','event_id'])#.rename(columns={'event_id': 'num_issue_title'})
    d5 = d3[d3[x].str.contains(y)].rename(columns={'event_id':y})
    d5 = d5.drop(columns=[x])
    d5['date'] = pd.to_datetime(d5['date'].str.strip(), format = '%Y-%m-%d')
    #return d5
#d4 = d3.groupby('date').head(5)  #top five values for issue title for each date

sam = 'samsung'
sam1 = 'HUAWEI'
iss4 = 'issue_title'; iss5 = 'CustomHomeCardView.java'
sam1 = manuCount(sam1);
issue_top1 = timeseries(iss4,iss5)

#MERGE BETWEEN MANUFACTURER AND ISSUE TITLE
issue_out1 = pd.merge(sam1,issue_top1, on = 'date')
'''
CORRELATION BETWEEN MANUFACTURER AND TYPE OF ERRORS
'''
def corr1(x,y):
    '''
    :param x: One of the list of manufacturers
    :param y: One of the list among the issue_title columns
    :return: correlation between two variables on row wise
    '''
    issue_out1['date'] = pd.to_datetime(issue_out1['date'])
    is2 = issue_out1.resample('W', on='date')[x,y].corr().unstack()
    is2 = is2.reset_index(drop=False)
    is2 = is2.iloc[:,[0,2]]
    is2 = is2.rename(columns={'date/':'date'})
    is2['date'] = is2.date.map(lambda x: x.strftime('%Y-%m-%d'))
    #return is2


def all_in_one(x1,y,z):
    '''
    :param x: name of the manufacturer
    :param y: name of the selected column for the analysis
    :param z: name of the issue title
    :return: The weekly correlation figure
    '''
    counts = manuCount(x1);
    issue_top1 = timeseries(y,z)
    #MERGE BETWEEN MANUFACTURER AND ISSUE TITLE
    issue_out1 = pd.merge(counts,issue_top1, on='date')
    #f = corr1(x,z)
    #return f
    issue_out1['date'] = pd.to_datetime(issue_out1['date'])
    is2 = issue_out1.resample('W', on='date')[x1,z].corr().unstack()
    is2 = is2.reset_index(drop=False)
    is2 = is2.iloc[:, [0, 2]]
    is2 = is2.rename(columns={'date/': 'date'})
    is2['date'] = is2.date.map(lambda x: x.strftime('%Y-%m-%d'))
    is3 = corr1(x,z)
    return is3

if __name__== "__main__":
    x3 = 'HUAWEI'
    x4 = 'issue_title'
    x5 = 'CustomHomeCardView.java'
    #f = all_in_one(x3, x4, x5)
    #print('Weekly Correlation for: ' + str(x3) + ' with ' + str(x5))
    #print(f)
    yy = list(['samsung','HUAWEI'])
for tak in yy:
    f = all_in_one(yy, x4, x5)
    print(tak)
    #print('Weekly Correlation for: ' + str(x3) + ' with ' + str(x5))
    #print(f)


# END