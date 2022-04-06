import os
# assign directory
directory = 'terraform'
newFileContent = ''
# iterate over files in
# that directory
for filename in os.listdir(directory):
    f = os.path.join(directory, filename)
    # checking if it is a file
    if os.path.isfile(f):
        f = open(f, "r")
        newFileContent = newFileContent +'\n'+ f.read()
        f.close()
f = open("Combined.tf", "a")
f.write(newFileContent)
f.close()
