import os
import random
# assign directory
directory = 'terraform'
newFileContent = ''
# iterate over files in
# that directory
open('Combined.tf', 'w').close()
for filename in os.listdir(directory):
    f = os.path.join(directory, filename)
    # checking if it is a file
    if os.path.isdir(f):
        list = os.listdir(f)
        randomChoice = random.choice(list)
        while os.path.isdir(os.path.join(f,randomChoice)):
            randomChoice = random.choice(list)
        
        f = os.path.join(f,randomChoice)
        f = open(f, "r")
        newFileContent = newFileContent +'\n'+ f.read()
        f.close()
    elif os.path.isfile(f):
        f = open(f, "r")
        newFileContent = newFileContent +'\n'+ f.read()
        f.close()
f = open("Combined.tf", "a")
f.write(newFileContent)
f.close()
