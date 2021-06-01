# Henok Fasil Telila
# A web scrapping analysis using elasticsearch database.
# I am able to develop a log parser that splits data based on objectives.

import os
from elasticsearch import Elasticsearch
#Paths

pathz = r"C:\\Users\\Asus2\\Dropbox\\Poste_Digital\\Telila_Henok\\12_upload_log_files\\files\\"
abspathx = os.path.abspath(pathz)
dnamex = os.path.dirname(abspathx)
os.chdir(dnamex)

#Elastiserver conneciton
clientlocal = Elasticsearch([{'host': 'localhost', 'port': 9200}])
client = Elasticsearch(['192.168.3.65'],scheme="http",port=9200,)


#Parser function

def parser_NEW(x,y): #we have used this function to parse directly and upload the json format directly into server
    with open(x, "r") as ral:
        for line in ral:
            try:
                log = {
                    "date":line.split(" ")[0],
                    "time":line.split(" ")[1],
                    "type":line.split(" ")[3], #INFO
                    "code":line.split(" ")[4],
                    "server":line.split(" ")[5],
                    "message1":line.split(" ")[6],
                    "message2":line.split(" ")[7],
                    "message3":line.split()[8:len(line)]
                    }
                #print(log)
                res = client.index(index= y, body=log)
                #print(res)
            except:
                log = {"log" : line}
                res = client.index(index= y, body=log)
                #print(res)



