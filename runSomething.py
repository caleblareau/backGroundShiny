from sys import argv

script, filename, var1 = argv

txt = open(filename) # If we actually wanted to do something with it. 

file = open("yay.txt", "w") 
file.write("Here's your file directory on the shiy app %r:" % filename)
file.write("\n")
file.write(var1)
txt.close()
file.close() 
