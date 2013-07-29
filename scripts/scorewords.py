# -*- coding: utf-8 -*-
"""
Created on Mon Jul 15 12:31:00 2013

@author: EeshanMalhotra
"""

from __future__ import print_function
import os
import errno


def scoreword(word,termDict):
    if word in termDict:
        return termDict[word]
    else:
        return 0
    

def cleantext(text):
    punc=(",./<>;:@#'?&-{}[]()+=!$%^&*\n")
    
    clean = text.translate(None, punc)
    clean=clean.lower()
    clean=clean.replace("  "," ")
    
    return clean    
    
def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise

def main():
    
    sentimentFile="../data/AFINN-111.txt"
    booklabel="misc/threemeninaboat"
    bookFile="../data/"+booklabel+".txt"
    
    
    #Initialize sentiment dictionary
    sentimentFileHandle = open(sentimentFile)
    termDict = {} 
    for line in sentimentFileHandle:
        term, score  = line.split("\t") 
        termDict[term] = int(score)
    

    
    #Read bookfile in batches    
    bookFileHandle=open(bookFile)
    
    scores=[]
    
    #Doing a line by line implementation for easy scaling
    for line in bookFileHandle:
        
        line = cleantext(line)
            
        words=line.split(" ")
        
        for word in words:
            score = scoreword(word,termDict)
            scores.append(score)
    
    
    #Display/Write all scores
    
    outfile="../data/" + booklabel + ".csv"
    outFileHandle=open(outfile, 'w')
        
    for s in scores:
        #print(s)
        outFileHandle.write(str(s)+'\n')
    
    print("done")
if __name__ == '__main__':
    main()
