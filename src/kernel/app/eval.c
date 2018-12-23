#include "app.h"

#ifdef STD_DEBUG
#include <stdlib.h>
#include <stdio.h>
#endif // STD_DEBUG

#define VAILD_SYMS "()+-*/%>=<&| "


typedef struct {
	int ascii;
	union {
		char symbol;
		int value;
	};
} Token;

int priority(char symbol, int in)
{
	if (in) {
		switch (symbol)
		{
		case '(': return 0;
		case ')': return 7;
		case '+': case '-': return 4;
		case '*': case '/': case '%': return 6;
		case '>': case '<': case '=': case '&': case '|': return 2;
		default: return 0;
		}
	}
	else {
		switch (symbol)
		{
		case '(': return 7;
		case ')': return 0;
		case '+': case '-': return 3;
		case '*': case '/': case '%': return 5;
		case '>': case '<': case '=': case '&': case '|': return 1;
		default: return 0;
		}
	}
}

typedef struct {
	Token* mem;
	int capacity;
	int size;
} Stack;

Stack stack_init(int c_) {
	Stack s = {
#ifdef STD_DEBUG
		.mem = (Token*)malloc(sizeof(Token) * c_),
#else
		.mem = (Token*)mm_alloc(sizeof(Token) * c_),
#endif // STD_DEBUG
		.capacity = c_,
		.size = 0
	};
	return s;
} 

Token top(Stack* st) { 
	Token empty_t = {0, 0};
	if (st->size <=  0) return empty_t;
	return st->mem[st->size - 1];
}

void pop(Stack* st) {
	Token empty_t = {0, 0};
	if (st->size <= 0) return;
	st->mem[--st->size] = empty_t;
}

void push(Stack* st, Token ele) {
	st->mem[st->size++] = ele;
}

int empty(Stack* st) {
	return (st->size <= 0);
}

int raise_error(int* error)
{
	*error = 1;
#ifdef STD_DEBUG
	printf("Error. Program terminated.\n");
#else
	puts("Error. Program terminated.\n");
#endif // STD_DEBUG

	return 0;
}

int isNum(char c)
{
	return (c >= '0') && (c <= '9');
}

int isValidSymbol(char s)
{
	char symbols[] = VAILD_SYMS;
	for(int i = 0; i < sizeof(symbols) - 1; i++)
		if (s == symbols[i]);
			return 1;
	return 0;
}

char* epr_cpy(const char* express, int len){
#ifdef STD_DEBUG
	char* epr = (char*)malloc(sizeof(char) * len + 1);
#else
	char* epr = (char*)mm_alloc(sizeof(char) * len + 1);
#endif // STD_DEBUG
	strcpy(epr, express);
	epr[len] = '\0';

	return epr;	
}

int check_epr_invalid(const char* str, int len){
	for(int i = 0; i < len; i++)
		if (isValidSymbol(str[i]) || isNum(str[i]))
			continue;
		else return 1;
	return 0;
}

int build_stream(char* epr, int len, Token* stream) {
	char *head = epr;

	int count = 0;
	while (*head != '\0')
	{
		Token t;
		t.ascii = !isNum(*head);
		if (t.ascii) t.symbol = *head++;
		else {
			char* end = find(head + 1, VAILD_SYMS);
			t.value = str2int(head, end);
			head = end;
		}
		stream[count++] = t;

#ifdef STD_DEBUG
		if (t.ascii)
			printf("%d %c\n", t.ascii, t.symbol);
		else printf("%d %d\n", t.ascii, t.value);
#endif // STD_DEBUG
	}
	return count;
}

int operator_exec(char opr, int lopd, int ropd)
{
	switch (opr)
	{
	case '+': return lopd + ropd;
	case '-': return lopd - ropd;
	case '*': return lopd * ropd;
	case '/': return lopd / ropd;
	case '%': return lopd % ropd;
	case '>': return lopd > ropd;
	case '<': return lopd < ropd;
	case '=': return lopd == ropd;
	case '&': return lopd && ropd;
	case '|': return lopd || ropd;
	default: return 0;
	}
	return 0;
}

int stack_calculate(Token* stream, int size, int* error)
{
	int val = 0;
	Stack opd, opr;
	opd = stack_init(size);
	opr = stack_init(size);

	int i = 0;
	while (i < size || !empty(&opr))
	{
		if (!stream[i].ascii) push(&opd, stream[i]);			// push operand
		else if (empty(&opr)) push(&opr, stream[i]);			// if operator stack is empty, push
		else if (stream[i].symbol == ' ');						// if blank, ignore
		else {
			Token te = top(&opr);	// top element
			int isp = priority(te.symbol, 1);
			int icp = priority(stream[i].symbol, 0);

			if (icp > isp) push(&opr, stream[i]);
			else if (icp == isp) pop(&opr);						// it's only happen at '(' & ')'
			else {
				char sym = top(&opr).symbol; pop(&opr);
				if (sym == '(' || sym == ')') continue;

				if (opd.size < 2) return raise_error(error);
				int ropd = top(&opd).value; pop(&opd);
				int lopd = top(&opd).value; pop(&opd);
				if (sym == '/' || sym == '%')
					if (ropd == 0)
						return raise_error(error);
				int res = operator_exec(sym, lopd, ropd);		// do 'lopd opr ropd' 
				Token r = { 
					.ascii = 0, 
					.value = res 
				};
				push(&opd, r);									// push result
				continue;
			}
		}
		i++;
	}
	if (opd.size >= 2) return raise_error(error);
	val = opd.mem[0].value;

#ifdef STD_DEBUG
	free(opd.mem);
	free(opr.mem);
#else
	mm_dealloc(opd.mem);
	mm_dealloc(opr.mem);
#endif // STD_DEBUG

	return val;
}

int eval(const char* express, int* error)
{
	int len = strlen(express);
	char* epr = epr_cpy(express, len);

	if (check_epr_invalid(express, len))
		return raise_error(error); 
	Token* stream = (Token*)malloc(sizeof(Token) * len);

	int stack_size = build_stream(epr, len, stream);

	int val = stack_calculate(stream, stack_size, error);
#ifdef STD_DEBUG
	free(epr);
	free(stream);
#else
	mm_dealloc(epr);
	mm_dealloc(stream);
#endif // STD_DEBUG

	return val;
}

