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
    

def scorebatch(words,termDict):
    totalscore = 0
    for word in words:
        s = scoreword(word,termDict)
        totalscore+=s
    return totalscore


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
    bookFile="../data/ataleoftwocities.txt"
    booklabel="atotc"
    totwords=136319
    nbatches=1000
    batchsize=1#totwords/nbatches
    
    #Initialize sentiment dictionary
    sentimentFileHandle = open(sentimentFile)
    termDict = {} 
    for line in sentimentFileHandle:
        term, score  = line.split("\t") 
        termDict[term] = int(score)
    

    
    #Read bookfile in batches    
    bookFileHandle=open(bookFile)
    
    scores=[]
    oldwords=[]
    
    ctr=0
    #Doing a line by line implementation for easy scaling
    
    for line in bookFileHandle:
        
        line = cleantext(line)
            
        newwords=line.split(" ")
        words=oldwords+newwords
        reqd = batchsize - ctr
        if len(words) > reqd:
            oldwords = words[reqd:]
            words = words[:reqd]
        else:
            oldwords = words
            continue
        
        bscore = scorebatch(words,termDict)
        scores.append(bscore)
    
    #Left-over words
    bscore = scorebatch(oldwords,termDict)
    scores.append(bscore)
    
    #Display/Write all scores
    
    mkdir_p("../data/"+booklabel)    
    outfile="../data/" + booklabel + "/" + booklabel + "." + str(batchsize) + ".csv"
    outFileHandle=open(outfile, 'w')
        
    ctr=0
    for s in scores:
        outline=str(ctr)+","+str(s*100.0/batchsize)
        print(outline)
        outFileHandle.write(outline+'\n')
        ctr+=batchsize
    
    
    #print("--------")
    #print(len(scores),"scores generated")
        
    
if __name__ == '__main__':
    main()
