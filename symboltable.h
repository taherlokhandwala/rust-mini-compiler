#include <ctype.h>
#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct row
{
	char *name;
	long value;
	char *data_type;
	char *token;
	int scope;
} sym_row;

typedef struct table
{
	int count_rows;
	sym_row *node;
} sym_table;

sym_table *init_table()
{
	sym_table *tb = (sym_table *)malloc(sizeof(sym_table));
	tb->node = NULL;
	tb->count_rows = 0;
}

sym_table *init_row(sym_table *table)
{
	table->node = (sym_row *)realloc(table->node, (table->count_rows + 1) * sizeof(sym_row));
	table->node[table->count_rows].name = calloc(20, sizeof(char));
	table->node[table->count_rows].data_type = "i32";
	table->node[table->count_rows].token = calloc(20, sizeof(char));
	table->node[table->count_rows].scope = 0;
	return table;
}

int insert(sym_table *table, char *name, long value, char *token, int scope)
{

	if (!table->count_rows)
		init_row(table);
	else
	{
		for (int i = 0; i < table->count_rows; i++)
		{
			if (!strcmp(table->node[i].name, name))
				return 0;
		}
		init_row(table);
	}

	strcpy(table->node[table->count_rows].name, name);
	table->node[table->count_rows].value = value;
	strcpy(table->node[table->count_rows].token, token);
	table->node[table->count_rows].scope = scope;
	table->count_rows++;
	return 0;
}

int update(sym_table *table, char *name, long value, int scope)
{
	for (int i = 0; i <= table->count_rows; i++)
	{
		if (!strcmp(table->node[i].name, name))
		{
			table->node[i].value = value;
			return 0;
		}
	}
	return -1;
}

int fetch(sym_table *table, char *name, long *value)
{
	for (int i = 0; i < table->count_rows; i++)
	{
		if (!strcmp(table->node[i].name, name))
		{
			*value = table->node[i].value;
			return 1;
		}
	}
	return 0;
}

int get_scope(sym_table *table, char *name)
{
	for (int i = 0; i < table->count_rows; i++)
	{
		if (!strcmp(table->node[i].name, name))
		{
			return table->node[i].scope;
		}
	}
	return 0;
}

void display(sym_table *table)
{
	printf("\n============================================================================================\n");
	printf(" %-20s %-20s %-20s %-20s %-20s\n", "name", "value", "data-type", "token", "scope");
	printf("============================================================================================\n");

	for (int i = 0; i < table->count_rows; i++)
	{
		printf(" %-20s %-20ld %-20s %-20s %-20d\n", table->node[i].name, table->node[i].value, table->node[i].data_type, table->node[i].token, table->node[i].scope);
	}
	printf("============================================================================================\n");

	FILE *fptr;
	fptr = fopen("./symtab.txt", "w");
	fprintf(fptr, "\n============================================================================================\n");
	fprintf(fptr, " %-20s %-20s %-20s %-20s %-20s\n", "name", "value", "data-type", "token", "scope");
	fprintf(fptr, "============================================================================================\n");

	for (int i = 0; i < table->count_rows; i++)
	{
		fprintf(fptr, " %-20s %-20ld %-20s %-20s \n", table->node[i].name, table->node[i].value, table->node[i].data_type, table->node[i].token);
	}
	fprintf(fptr, "=======================================================================\n");
	fclose(fptr);
}