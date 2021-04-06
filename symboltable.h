#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>

#define HASH_TABLE_SIZE 100

typedef struct row {
	char* name;
	char* str_value;
	int i_value;
	float f_value;
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
	table->node[table->count_rows].str_value = "null";
	table->node[table->count_rows].i_value = -1000;
	table->node[table->count_rows].f_value = -1000.0;
	table->node[table->count_rows].token = "null";
	table->node[table->count_rows].scope = 0;
	return table;
}

int insert(sym_table* table, char* name, void* value, char* data_type, char* token, int scope){
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
	if(!strcmp(data_type,"i32"))
		table->node[table->count_rows].i_value = *(int *)value;
	else if(!strcmp(data_type,"f32"))
		table->node[table->count_rows].f_value = *(float *)value;
	else if(!strcmp(data_type,"str"))
		table->node[table->count_rows].str_value = (char *)value;

	table->node[table->count_rows].data_type = data_type;
	table->node[table->count_rows].token = token;
	table->node[table->count_rows].scope = scope;
	table->count_rows++;
	return 0;
}

int update(sym_table* table, char* name, char* value, char* data_type, char* token, int scope){
	for(int i=0;i<table->count_rows;i++){
		if (!strcmp(table->node[i].name,name) && !strcmp(table->node[i].data_type,data_type)){
			if(!strcmp(data_type,"i32"))
				table->node[table->count_rows].i_value = *(int *)value;
			else if(!strcmp(data_type,"f32"))
				table->node[table->count_rows].f_value = *(float *)value;
			else if(!strcmp(data_type,"str"))
				table->node[table->count_rows].str_value = (char *)value;
		}
		return 0;
	}
	return -1;
}

void display(sym_table* table) {

	printf("\n============================================================================================\n");
	printf(" %-20s %-20s %-20s %-20s %-20s\n", "name", "value", "data-type", "token", "scope");
	printf("============================================================================================\n");

	for (int i = 0; i < table->count_rows; i++) {
		if(!strcmp(table->node[i].data_type,"i32"))
			printf(" %-20s %-20d %-20s %-20s %-20d\n", table->node[i].name, table->node[i].i_value, table->node[i].data_type, table->node[i].token, table->node[i].scope);
		else if(!strcmp(table->node[i].data_type,"f32"))
			printf(" %-20s %-20f %-20s %-20s %-20d\n", table->node[i].name, table->node[i].f_value, table->node[i].data_type, table->node[i].token, table->node[i].scope);
		else if(!strcmp(table->node[i].data_type,"str"))
			printf(" %-20s %-20s %-20s %-20s %-20d\n", table->node[i].name, table->node[i].str_value, table->node[i].data_type, table->node[i].token, table->node[i].scope);
	}
	printf("============================================================================================\n");
	/*
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
	*/
}