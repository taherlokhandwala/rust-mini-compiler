#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>

#define HASH_TABLE_SIZE 100

struct entry_s
{
	char *lexeme;
	double value;
	int data_type;
	struct entry_s *successor;
};

typedef struct entry_s entry_t;

entry_t **create_table()
{
	entry_t **hash_table_ptr = NULL;

	if ((hash_table_ptr = malloc(sizeof(entry_t *) * HASH_TABLE_SIZE)) == NULL)
		return NULL;

	int i;

	for (i = 0; i < HASH_TABLE_SIZE; i++)
	{
		hash_table_ptr[i] = NULL;
	}

	return hash_table_ptr;
}

uint32_t hash(char *lexeme)
{
	size_t i;
	uint32_t hash;

	for (hash = i = 0; i < strlen(lexeme); ++i)
	{
		hash += lexeme[i];
		hash += (hash << 10);
		hash ^= (hash >> 6);
	}
	hash += (hash << 3);
	hash ^= (hash >> 11);
	hash += (hash << 15);

	return hash % HASH_TABLE_SIZE;
}

entry_t *create_entry(char *lexeme, int value)
{
	entry_t *newentry;

	if ((newentry = malloc(sizeof(entry_t))) == NULL)
	{
		return NULL;
	}

	if ((newentry->lexeme = strdup(lexeme)) == NULL)
	{
		return NULL;
	}

	newentry->value = value;
	newentry->successor = NULL;

	return newentry;
}

entry_t *search(entry_t **hash_table_ptr, char *lexeme)
{
	uint32_t idx = 0;
	entry_t *myentry;

	idx = hash(lexeme);
	myentry = hash_table_ptr[idx];

	while (myentry != NULL && strcmp(lexeme, myentry->lexeme) != 0)
	{
		myentry = myentry->successor;
	}

	if (myentry == NULL)
		return NULL;
	else
		return myentry;
}

entry_t *insert(entry_t **hash_table_ptr, char *lexeme, int value)
{
	entry_t *finder = search(hash_table_ptr, lexeme);
	if (finder != NULL)
		return finder;

	uint32_t idx;
	entry_t *newentry = NULL;
	entry_t *head = NULL;

	idx = hash(lexeme);
	newentry = create_entry(lexeme, value);

	if (newentry == NULL)
	{
		printf("Insert failed. New entry could not be created.");
		exit(1);
	}

	head = hash_table_ptr[idx];

	if (head == NULL)
	{
		hash_table_ptr[idx] = newentry;
	}
	else
	{
		newentry->successor = hash_table_ptr[idx];
		hash_table_ptr[idx] = newentry;
	}
	return hash_table_ptr[idx];
}

void display(entry_t **hash_table_ptr)
{
	int i;
	entry_t *traverser;

	printf("\n====================================================\n");
	printf(" %-20s %-20s %-20s\n", "lexeme", "value", "data-type");
	printf("====================================================\n");

	for (i = 0; i < HASH_TABLE_SIZE; i++)
	{
		traverser = hash_table_ptr[i];

		while (traverser != NULL)
		{
			printf(" %-20s %-20d %-20d \n", traverser->lexeme, (int)traverser->value, traverser->data_type);
			traverser = traverser->successor;
		}
	}
	printf("====================================================\n");

	FILE *fptr;
	fptr = fopen("./symtab.txt", "w");
	fprintf(fptr, "\n====================================================\n");
	fprintf(fptr, " %-20s %-20s %-20s\n", "lexeme", "value", "data-type");
	fprintf(fptr, "====================================================\n");

	for (i = 0; i < HASH_TABLE_SIZE; i++)
	{
		traverser = hash_table_ptr[i];

		while (traverser != NULL)
		{
			fprintf(fptr, " %-20s %-20d %-20d \n", traverser->lexeme, (int)traverser->value, traverser->data_type);
			traverser = traverser->successor;
		}
	}
	fprintf(fptr, "====================================================\n");
	fclose(fptr);
}
