from sys import argv

script, filename = argv

txt = open(filename)

file = open("yay.txt", "w") 
file.write("Here's your file %r:" % filename)
file.write("txt.read()")
txt.close()
file.close() 
