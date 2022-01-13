#include <unistd.h>         // defines read() and write()
#include <stdlib.h>         // defines exit()
#include <stdio.h>

#define STDIN   0
#define STDOUT  1

unsigned int getInt(char* string) {
    unsigned int digitValue = 1;
    unsigned int result = 0;
    char* digit = string;
    while (*digit != '\n') digit++;	// Obtain the address of
    digit--;						// the last digit character
    while (digit >= string) {       // stop if at beginning of string
        if (*digit == ' ') break;   // ignore leading spaces
        if (*digit < '0' || *digit > '9') {     // test for bad digit
            char* errorMessage = "Bad Number.\n";
            write(STDOUT,errorMessage,12);
            exit(0);
        }
        // use the MUL (dword) instruction here (unsigned multiply)
        // be careful to understand its operands and results
        result += (*digit - '0') * digitValue;  // accumulate digit value
        digitValue *= 10;           // update digit value
        digit--;					// walk backwards from least
    }								// significant to most
    return result;
}


void makeDecimal(unsigned int n) {
    // use the DIV (dword) instruction here (unsigned divide)
    // be careful to understand its operands and results
    unsigned int remainder = n % 10;
    unsigned int  quotient = n / 10;
    if (quotient > 0) makeDecimal(quotient);  // notice recursion!
    char digit = remainder + '0';   // convert to ASCII character
    write(STDOUT,&digit,1);         // print the digit
}


int readNumber() {
    char data[20];
    char* prompt = "Enter a positive integer: ";
    write(STDOUT,prompt,26);
    read(STDIN,data,20);
    return getInt(data);
}


unsigned int gcd(unsigned int n, unsigned int m) {
    if      (n > m) return gcd(n - m, m    );   // recursion
    else if (n < m) return gcd(    n, m - n);   // recursion
    else            return n;			        // base case
}


int main() {
    printf("GCD in C\n");
    char newLineChar = '\n';
    unsigned int a, b, answer;
    a = readNumber();
    b = readNumber();
    answer = gcd(a,b);
    char* message = "Greatest common divisor = ";
    write(STDOUT,message,26);
    makeDecimal(answer);
    write(STDOUT,&newLineChar,1);
    exit(0);
}
