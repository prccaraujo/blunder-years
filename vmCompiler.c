#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hashmap.h"
#include "vmCompiler.h"

#define OK 0
#define ERRO_VAR_ALREADY_EXIST -1
#define ERRO_VAR_DONT_EXIST -2
#define ERRO_VAR_INVALID_TYPE -3


enum eType{_VOID,_INTS,_INTA};

struct sEntryVar{
    Type type;
    char *name;
    int memAdr;
};


struct sEntryFun{
    Type type;
    char *name;
    Type *args;
    map_t vars;
    int addrCount;
};

static EntryFun gloContext;
static EntryFun funContext;
//static map_t mVarMap;
static map_t mFuncMap;
//static int addressCounter;

int initVarMap()
{
    gloContext = (EntryFun) malloc(sizeof(struct sEntryFun));
    gloContext->vars = hashmap_new();
    gloContext->addrCount = 0;
    //undifined
    gloContext->args = NULL;
    gloContext->type = _VOID;
    gloContext->name = NULL;
	//addressCounter = 0;
	//mVarMap = hashmap_new();
	return 0;
}


EntryFun containsFun(char* varName)
{
    EntryFun varEntry; //= (Entry) malloc(sizeof(Entry));
    
    if(!(hashmap_get(mFuncMap, varName, (any_t*) &varEntry) == MAP_OK))
        varEntry = NULL;
    return varEntry;    
}


EntryVar containsVar(EntryFun fun, char* varName)
{
	EntryVar varEntry; //= (Entry) malloc(sizeof(Entry));
	
	if(!(hashmap_get(fun->vars, varName, (any_t*) &varEntry) == MAP_OK))
		varEntry = NULL;
	return varEntry;	
}

int decFun(Type type,char* funName, Type* args){
    int ret;
    if(!containsFun(funName)) {
        EntryFun newFun = (EntryFun) malloc(sizeof(struct sEntryFun));
        newFun->name = strdup(funName);
        newFun->type = type;
        newFun->args = args;
        newFun->vars = hashmap_new();
        newFun->addrCount = 0;
//        printf("(delar)%s -> %d\n", newFun->name, newFun-> memAdr);
        hashmap_put(mFuncMap, funName, (any_t) newFun);
        funContext = newFun;
        ret = OK;
    } else {
        ret = ERRO_VAR_ALREADY_EXIST;
    }
    return ret;
}

void endDecFun(){
    funContext = NULL;
}

int decVar(char* varName, int size)
{
    EntryFun context; 
    int err = 0;
    if (funContext == NULL) { 
        context = gloContext;
        err += (containsVar(gloContext, varName) != NULL);
    } else {
        context = funContext;        
        err += (containsVar(funContext, varName) != NULL);
        err += (containsVar(gloContext, varName) != NULL);
    }
    if(!err)
	{
		EntryVar newVar = (EntryVar) malloc(sizeof(struct sEntryVar));
		if(size>1)
		{
			newVar->type = _INTA;
		}
		else
		{
			newVar->type = _INTS;
		}
		newVar->name = strdup(varName);
		newVar->memAdr = context->addrCount;
		context->addrCount+=size;

		hashmap_put(context->vars, varName, (any_t) newVar);

		return OK;
	}
	return ERRO_VAR_ALREADY_EXIST;
}


Addr getAddr(char* varName)
{
	EntryVar varEntry;
	int memAddr = ERRO_VAR_DONT_EXIST;
    char scope;

	if(varEntry = containsVar(gloContext,varName))
	{
		memAddr = varEntry->memAdr;
	}

    if (funContext == NULL) { 
        scope = 'L';    
    } else {
        scope = 'G';
    }
    Addr ret = {memAddr,scope};

	return ret;
}
