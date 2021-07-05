#this file contain a crawlled code from the go movies .com,just required little modification to make it run faster
from bs4 import BeautifulSoup
import requests
def crawlFromGoMovies(ls):
    gomovieDB=dict()
    key="null"
    for i in range(len(ls)-1):
        if i==10:
            return gomovieDB
        else :
            r=requests.get(ls[i])
            data = r.text
            soup = BeautifulSoup(data,"lxml")
            for token in soup.find_all("div",class_="mvic-desc"):
                for htag in token.find_all("h3"):
                    key=htag.text
            for atag in soup.find_all("div", class_="mvici-left"): 
                order=[]
                for link in atag.find_all('a'): 
                    attr=link.get_text()
                    order.append(attr)
            gomovieDB[key]=order
    return gomovieDB

#this function will search the movies via generae
def searchGenrae(genreDict):
    for key in genreDict:
        flag=1
        flag2=1
        print("\n\nTitle:\n--------------------")        
        print(key)
        print("\nSub-Genre:\n--------------------")
        for attr in genreDict[key]:
            if flag==1 and (attr!="Action" or attr!="Crime"or attr!="Thriller" or attr!="Drama" or attr!="Adventure"):
               print("\nCasting::\n--------------------")
               flag=0
            if attr=='United States' or attr =='United Kingdom' or attr =='USA' or attr=='UK':
                print("\nCountry::\n--------------------")
            print(attr)
        print('\n') 

#this function will search the movies via title
def searchMovie(fullDict):
   key=input("\nEnter a Movie Name to be search \n")
   for genre in fullDict:
    for title in fullDict[genre]:
        if title==key:
            flag=1
            flag2=1
            print("\n\nTitle:\n--------------------")        
            print(key)
            print("\nSub-Genre:\n--------------------")
            for attr in fullDict[genre][key]:
                if flag==1 and (attr!="Action" or attr!="Crime"or attr!="Thriller" or attr!="Drama" or attr!="Adventure"):
                   print("\nCasting::\n--------------------")
                   flag=0
                if attr=='United States' or attr =='United Kingdom' or attr =='USA' or attr=='UK':
                    print("\nCountry::\n--------------------")
                print(attr)
            print('\n') 
            

#this function will return the links of  genre movies
def getLinksFromGenre(path):
    r  = requests.get(path)
    data = r.text
    soup = BeautifulSoup(data,"lxml")
    actionLinks=[]
    for atag in soup.find_all( "div",class_="movies-list movies-list-full"):
        for link in atag.find_all('a',class_="ml-mask jt"):
            actionLinks.append(link['href'])
    return actionLinks
    
    
#main starting of the code
#crawling begin
gomovieDictionary=dict()
linkGenre=list()
gomovieDB=dict()
actionLinks=list()

linkGenre.append("https://gomovies.sc/genre/action/")
linkGenre.append("https://gomovies.sc/genre/crime/")
linkGenre.append("https://gomovies.sc/genre/horror /")
linkGenre.append("https://gomovies.sc/genre/drama/")


for i in range(len(linkGenre)):
    actionLinks=getLinksFromGenre(linkGenre[i])
    gomovieDB=crawlFromGoMovies(actionLinks)
    if i==0:
        gomovieDictionary['action']=gomovieDB
    elif i==1:
        gomovieDictionary['crime']=gomovieDB
    elif i==2:
        gomovieDictionary['horror']=gomovieDB
    elif i==3:
        gomovieDictionary['drama']=gomovieDB
    
#crawling ends and data structure has been prepared


#main body to do task;.....
Var=input("press:\n1.To search a genre\n2.To search a movie\n3.To exit\ninput-> ")
flag=1
while(flag):
    if Var=='1':
        gen=input("\nEnter the genre: ")
        searchGenrae(gomovieDictionary[gen])
    elif Var =='2':
        searchMovie(gomovieDictionary)
    elif print("Invalid input\n"):
        Var=input("press:\n1.To search a genre\n2.To search a movie\n3.To exit\ninput-> ")
    if Var=='3':
        flag=0


#end file gomovies
