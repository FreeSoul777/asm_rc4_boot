#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>
#define N 313
#define D 197

int rc4_c(char inbuf[], size_t buflen, const char *key, size_t keylen);

int main()
{
    char password[] = "password";
    size_t datalen;
    size_t key_len = strlen(password);
    char data[N], buffer = 0;
    FILE *bin; 
    bin = fopen("boot.bin", "rb+");
    
    int i = 0;
    for(i = 0; i < D; i++) {
	buffer = fgetc(bin);
    }
    buffer = '\0';
        
    datalen = fread(data, sizeof (char), N-1, bin);
    data[N] = '\0';
    printf("\nDatalen = %d  &&  %s\n", datalen, data);

    if( datalen <= 1) return 0;
    
    rc4_c(data, datalen, password, key_len);

    printf("Message: %s\n", data);

//    rc4_c(data, datalen, password, key_len);

//    printf("Message: %s\n", data);

    for (i = 0; i < N; i++) {
	fseek(bin, D + i, SEEK_SET);
	buffer = data[i];
	fputc(buffer, bin);
	fseek(bin, D + i + 1, SEEK_SET);
    }

    fclose(bin);
    return 0;
}


int rc4_c(char inbuf[], size_t buflen, const char *key, size_t keylen)
{
    char s[256];
    unsigned int i;
    unsigned char j;
    unsigned char temp;

    for(i = 0; i < 256; i++){
        s[i] = i;
    }

    j = 0;
    for(i = 0; i < 256; i++){
        j = j + s[i] + key[i % keylen];
        temp = s[i]; // swap
        s[i] = s[j];
        s[j] = temp;
    }

    j = 0;
    for(i = 0; i < buflen; i++){
        unsigned char c;
        unsigned char t;
        c = i + 1;
        j += s[c];
        temp = s[c]; // swap
        s[c] = s[j];
        s[j] = temp;
        t = s[c] + s[j];
        inbuf[i] = inbuf[i] ^ s[t];
    }

    return buflen;

}

