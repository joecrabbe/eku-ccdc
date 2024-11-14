import os
import subprocess
import datetime
lastRefresh = ""
filters = []
def main():
    while True:
        os.system("clear")
        readCont = getFileCont("/etc/gemini/read.log")
        os.system('echo "' + readCont + '" >> /etc/gemini/active.log')
        os.system("mv /etc/gemini/buffer.log /etc/gemini/read.log")
        os.system("touch /etc/gemini/buffer.log")
        os.system('echo "' + readCont + '" + >> /var/log/masterGemini.log')
        lastRefresh = datetime.datetime.today()
        logs = getFileCont("/etc/gemini/active.log")
        logList = logs.split('\n')
        
        for log in logList:
            print(log)
    
        x = True
        while(x):
            option = input("Enter command: ").lower()
            if(len(option) != 0):
                x = False
        if(option == "refresh" or option == "re"):
            pass
        elif(option == "filter"):
            x = True
            newFilter = input("Enter filter to add: ").lower()
            firstSplit = newFilter.split(" ")
            if(firstSplit[0] == "machine"):
                pass
            elif(firstSplit[0] == "message" or firstSplit[0] == "log"):
                pass
            else:
                pass
        else:
            printHelp()
    
    
main()
def getFileCont(file):
    command = "cat " + file
    try:
        fileCont = subprocess.check_output(command, shell=True)
        fileDecode = fileCont.decode("utf-8")
        return fileDecode
    except subprocess.CalledProcessError as e:
        return ""
def printFilters():
    message = ""
    for filter in filters:
        message = message + "[" + filter + "], "
    print(message[:len(message)-2])
def printHelp():
    print("""
Controler for Gemini EDR System:

    Commands:
        
        Refresh - Refreshes the current log list
        Filter - Adds a filter to the current search
    
    Filter Format:
        
        Legend:
            {...} - Interchangable, same effect either way
            (...) - One or the Other
            [...] - Variable Input
            
        Filter by machine: 'machine (is/is not) [ip/machine_name(fedora/ecom/centos/debian/etc)]'
        Filter by content: '{log/message} (does/does not) contain [string]'

""")
def printFormat():
    print("""
Filter Format:
        
    Legend:
        {...} - Interchangable, same effect either way
        (...) - One or the Other
        [...] - Variable Input
            
    Filter by machine: 'machine (is/is not) [ip/machine_name(fedora/ecom/centos/debian/etc)]'
    Filter by content: '{log/message} (does/does not) contain [string]'
""")