#include <ctype.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct row {
	char* name;
	char* value;
	char* data_type;
	char* token;
	int scope;
} sym_row;

typedef struct table{
	int count_rows;
	sym_row* node;
} sym_table;

sym_table* init_table(){
	sym_table* tb = (sym_table*)malloc(sizeof(sym_table));
	tb->node=NULL;
	tb->count_rows=0;
}

sym_table* init_row(sym_table* table){
	table->node = (sym_row *)realloc(table->node,(table->count_rows+1)*sizeof(sym_row));
	table->node[table->count_rows].name = calloc(20,sizeof(char));
	table->node[table->count_rows].data_type = calloc(20,sizeof(char));
	table->node[table->count_rows].value = calloc(20,sizeof(char));
	table->node[table->count_rows].token = calloc(20,sizeof(char));
	table->node[table->count_rows].scope = 0;
	return table;
}

int insert(sym_table* table, char* name, void* v, char* data_type, char* token, int scope){
	char* value=calloc(100,sizeof(char));
	if(!strcmp(data_type,"i32"))
		sprintf(value,"%ld",*(long *)v);
	else if(!strcmp(data_type,"f32"))
		sprintf(value,"%f",*(float *)v);
	else if(!strcmp(data_type,"str"))
		memcpy(value,(char *)v+1,strlen((char *)v)-2);

	if(!table->count_rows)
		init_row(table);
	else{
		for(int i=0;i<table->count_rows;i++){
			if (!strcmp(table->node[i].name,name) && !strcmp(table->node[i].data_type,data_type))
				return 0;
		}
		init_row(table);
	}

	strcpy(table->node[table->count_rows].name,name);
	strcpy(table->node[table->count_rows].value,value);
	strcpy(table->node[table->count_rows].data_type,data_type);
	strcpy(table->node[table->count_rows].token,token);
	table->node[table->count_rows].scope = scope;
	table->count_rows++;
	
	//%s\n",table->node[table->count_rows].name);
	return 0;
}

int update(sym_table* table, char* name, void* v, int scope){

	for(int i=0;i<=table->count_rows;i++){
		if (!strcmp(table->node[i].name,name)){		
			// Check types

			char *data_type=calloc(100,sizeof(char));
			strcpy(data_type,table->node[i].data_type);

			char* value=calloc(100,sizeof(char));
			if(!strcmp(data_type,"i32"))
				sprintf(value,"%ld",*(long *)v);
			else if(!strcmp(data_type,"str"))
				memcpy(value,(char *)v+1,strlen((char *)v)-2);

			int l_flag=0;
			int c_flag=0;
			for(int j=0;value[j]!='\0';j++){
				if(!isalnum(value[j]))
					c_flag=1;
				if(!isdigit(value[j]))
					l_flag=1;
			}
			printf("%s %d %d\n",value,l_flag,c_flag);

			// Assign values
			if(l_flag && !c_flag){
				//sprintf(value,"%s",value);
			}
			else if(c_flag)
				//memcpy(value,*(char **)value+1,strlen(*(char **)value)-2);
			
			//table->node[table->count_rows].value = value;		
			return 0;
		}
	}
	return -1;
}

void fetch(sym_table* table,char* name,char* data_type,char* value){
	for(int i=0;i<table->count_rows;i++){
		if (!strcmp(table->node[i].name,name)){
			strcpy(data_type,table->node[i].data_type);
			strcpy(value,table->node[i].value);
		}
	}
}

void display(sym_table* table) {
	printf("\n============================================================================================\n");
	printf(" %-20s %-20s %-20s %-20s %-20s\n", "name", "value", "data-type", "token", "scope");
	printf("============================================================================================\n");

	for (int i = 0; i < table->count_rows; i++) {
		printf(" %-20s %-20s %-20s %-20s %-20d\n", table->node[i].name, table->node[i].value, table->node[i].data_type, table->node[i].token, table->node[i].scope);
	}
	printf("============================================================================================\n");

	FILE *fptr;
	fptr = fopen("./symtab.txt", "w");
	fprintf(fptr, "\n============================================================================================\n");
	fprintf(fptr, " %-20s %-20s %-20s %-20s\n", "name", "value", "data-type", "token");
	fprintf(fptr, "============================================================================================\n");

	for (int i = 0; i < table->count_rows; i++) {
		fprintf(fptr, " %-20s %-20s %-20s %-20s \n", table->node[i].name, table->node[i].value, table->node[i].data_type, table->node[i].token);
	}
	fprintf(fptr, "=======================================================================\n");
	fclose(fptr);
}