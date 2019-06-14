import tkinter as tk
from tkinter import filedialog
import sys
import os
import datetime

root = tk.Tk()
root.withdraw()
sql_file = filedialog.askopenfilename(
     title='Select SQL File', initialdir=r'C:\\')

if not sql_file:
    print('No file Selected, Process Cancelled')
    sys.exit()

file_path = os.path.dirname(sql_file)      
f = open(sql_file, 'r')
lines = f.readlines()
f.close()

search_word = 'into'
lines_into = [x[x.lower()
                .find(search_word):]
                .lower()                
                .replace('[', ' ')
                .replace(']', ' ')
                .strip()               
                .split(' ')
               for x in lines 
               if search_word in x.lower()]

into_1 = [' '.join(y.split()) for x in lines_into for y in x]
into_2 = set()

for x in range(0, len(into_1)):
    if (into_1[x] == search_word 
        and x != len(into_1) - 1):
        into_2.add(into_1[x + 1])


search_word = 'from'
search_word_not = 'both from'
search_word_not_2 = 'from date)'
search_word_not_3 = '(both from'
search_word_not_4 = 'from ('
lines_from = [x[x.lower()
                .find(search_word):]
                .lower()                
                .replace('[', ' ')
                .replace(']', ' ')
                .strip()               
                .split(' ')
               for x in lines 
               if search_word in x.lower()
               if search_word_not not in x.lower()
               if search_word_not_2 not in x.lower()
               if search_word_not_3 not in x.lower()
               if search_word_not_4 not in x.lower()]

from_1 = [' '.join(y.split()) for x in lines_from for y in x]
from_2 = set()

for x in range(0, len(from_1)):
    if (from_1[x] == search_word
        and x != len(from_1) - 1):
            from_2.add(from_1[x + 1])


search_word = 'join'
search_word_not = 'join ('
lines_join = [x[x.lower()
                .find(search_word):]
                .lower()                
                .replace('[', ' ')
                .replace(']', ' ')
                .strip()               
                .split(' ')
               for x in lines 
               if search_word in x.lower()
               if search_word_not not in x.lower()]

join_1 = [' '.join(y.split()) for x in lines_join for y in x]
join_2 = set()


for x in range(0, len(join_1)):
    if (join_1[x] == search_word 
        and x != len(join_1) - 1):
            join_2.add(join_1[x + 1])
    
    
dbo_objects = list(set().union(into_2, from_2, join_2))
out_file = (file_path + 
            r'/'
            'db_objects' + 
            '_' + 
            datetime.datetime.now().strftime("%Y%m%d-%H%M%S") +
            '.txt'
            ) 

with open(out_file, 'w') as f:
    for x in dbo_objects:
        f.write("%s\n" % x)
f.close()


print('Success: File ' + out_file + ' is updated with results')
