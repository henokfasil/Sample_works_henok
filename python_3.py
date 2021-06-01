# Henok Fasil Telila
# A crashlytics analysis based on data from BiGQuery (Google Cloud Platform)

import google.cloud
from google.cloud import bigquery
from google.cloud import bigquery_storage_v1beta1
from oauth2client.service_account import ServiceAccountCredentials
from google.oauth2 import service_account
from sqlalchemy import create_engine
import config
from datetime import datetime, timedelta
import pandas as pd
import pyarrow
import pymysql
import sys,io
import os

abspath = os.path.abspath(__file__)
#abspath
dname = os.path.dirname(abspath)
os.chdir(dname)
print("The current working directory is", os.getcwd())

def scarica(giorno):
    key_path='app-bancoposta-93c3e72ee36b.json'
    project_id='app-bancoposta'
    #for project_id in project_ids:
    credentials = service_account.Credentials.from_service_account_file(key_path,scopes=["https://www.googleapis.com/auth/cloud-platform"],)
    bqclient = bigquery.Client(
        credentials=credentials,
        project=credentials.project_id,#project_id
    )

    bqstorageclient = bigquery_storage_v1beta1.BigQueryStorageClient(
        credentials=credentials
    )
    # Download query results.
    stringa_config=str('mysql+pymysql://' + config.get_username() + ':' + config.get_password() + '@' + config.get_indirizzo() + '/' + config.get_database())

    # if project_id='postepay-1268':
    #tables=['firebase_crashlytics.posteitaliane_posteapp_apppostepay_ANDROID','firebase_crashlytics.it_poste_postepay_IOS']
    #device=['android','ios']
    #APP=['postepay','postepay']

    #elif project_id='app-bancoposta':
    tables = ['firebase_crashlytics.posteitaliane_posteapp_appbpol_ANDROID']#,'firebase_crashlytics.it_poste_bpol_IOS']
    device = ['android', 'ios']
    APP = ['bancoposta', 'bancoposta']

    #tables=['firebase_crashlytics.it_poste_bpol_IOS']
    #device=['ios']
    #APP=['bancoposta']


    for t in range(tables.__len__()):
        try:
            query_string = f""" SELECT  event_timestamp, user.id, is_fatal, device.manufacturer,device_orientation,
                device.model,operating_system.name as os_name, application.display_version as BancoPosta_version,
                memory.used as memory_used,memory.free as memory_free,storage.used as storage_used,
                storage.free as storage_free,issue_title,issue_subtitle,crashlytics_sdk_version as sdk_version, blame_frame.file as blame_frame                              
                FROM {tables[t]} where date(event_timestamp)='{giorno}' limit 10"""
            #exit(1)
            dataframe = bqclient.query(query_string).result().to_dataframe(bqstorage_client=bqstorageclient)

            #bqclient.query() does a connection to the big query data base.
            dataframe.to_csv('hnk_crashlytics_'+device[t]+'_'+APP[t]+'.csv')
            #dataframe.to_json('demo_crashlytics_' + device[t] + '_' + APP[t] + '.json')
            #pippo = pd.read_json('demo_crashlytics_ios_bancoposta.json')
            #pippo.to_csv('pippo.csv', index=None)

            engine = create_engine(stringa_config)
            name ='hnk_crashlytics_'+device[t]+'_'+APP[t]
            print(name)
            # Since the try block raises an error, the except block will be executed.
            # Without the try block, the program will crash and raise an error:
            try:
                engine.execute(f"""delete from {name} where date(event_timestamp) = '{giorno}'""")
                #when >= '{giorno}' it deletes files next to that data
            except Exception:
                pass
            a = pd.read_csv(name + '.csv') #, sep=',', index_col=0)  #, keep_date_col=True

            a.to_sql(name, con=engine, if_exists='append') #when it writs to DB, it adds on the existing data, if =replace, it replaces
            index = dataframe.index
            number_of_rows = str(len(index))
            print('Written: '+str(giorno)+'\t'+number_of_rows+'\t'+device[t]+'\t'+APP[t])
        except Exception as e:
            print('ERROR: ' + device[t] + '_' + APP[t])
            print(e)
            pass

#__name__=="__main__"...#https://stackoverflow.com/questions/419163/what-does-if-name-main-do
#if we are on the same module and if we use that module it execute the function stated underneath,
# if not it skips the code. Example below.

if __name__ == "__main__":
    numero_giorni=5
    while numero_giorni>1:
        giorno = datetime.strftime(datetime.now() + timedelta(days=-numero_giorni), '%Y-%m-%d')
        numero_giorni -= 1
        print(giorno)
        #exit()
        scarica(giorno)
