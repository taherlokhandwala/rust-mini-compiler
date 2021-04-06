#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>

#define HASH_TABLE_SIZE 100

typedef struct row {
	char* name;
	char* str_value;
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
	table->node[table->count_rows].name = "null";
	table->node[table->count_rows].data_type = "null";
	table->node[table->count_rows].value = "null";
	table->node[table->count_rows].token = "null";
	table->node[table->count_rows].scope = 0;
	return table;
}

int insert(sym_table* table, char* name, void* v, char* data_type, char* token, int scope){
	char* value=calloc(100,sizeof(char));
	if(!strcmp(data_type,"i32"))
		sprintf(value,"%d",*(int *)v);
	else if(!strcmp(data_type,"f32"))
		sprintf(value,"%f",*(float *)v);
	else if(!strcmp(data_type,"str"))
		memcpy(value,*(char **)v+1,strlen(*(char **)v)-2);

	if(!table->count_rows)
		init_row(table);
	else{
		for(int i=0;i<table->count_rows;i++){
			if (!strcmp(table->node[i].name,name) && !strcmp(table->node[i].data_type,data_type))
				return 0;
		}
		init_row(table);
	}
	
	table->node[table->count_rows].name = name;
	table->node[table->count_rows].value = value;
	table->node[table->count_rows].data_type = data_type;
	table->node[table->count_rows].token = token;
	table->node[table->count_rows].scope = scope;
	table->count_rows++;
	return 0;
}

int update(sym_table* table, char* name, char* value, char* data_type, char* token, int scope){

	/*
	char value[100]={'\0'};
	if(!strcmp(data_type,"i32"))
		sprintf(value,"%d",*(int *)v);
	else if(!strcmp(data_type,"f32"))
		sprintf(value,"%f",*(float *)v);
	else if(!strcmp(data_type,"str"))
		strcpy(value,*(char **)v);
	*/
	for(int i=0;i<table->count_rows;i++)
		if (!strcmp(table->node[i].name,name) && !strcmp(table->node[i].data_type,data_type)){
			table->node[table->count_rows].value = value;
		return 0;
	}
	return -1;
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