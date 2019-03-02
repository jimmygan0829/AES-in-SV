/************************************************************************
Lab 9 Nios Software
Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013
For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include "aes.h"
#include <time.h>

// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *) 0x40;

// Execution mode: 0 for testing, 1 for benchmarking
/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

/** encrypt
 *  Top level AES encryption wrapper.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
int run_mode = 0;

unsigned int RotWord(unsigned int word)
{
	unsigned int temp, tempe;
	temp = word << 8;
	tempe = word >> 24;
	return (temp | tempe);

}

unsigned int SubWord(unsigned int word)
{
	unsigned char temp[4];
//	printf("WORD, b/s %08x \n", word);
	temp[0]=word>>24;
	temp[1]=word>>16;
	temp[2]=word>>8;
	temp[3]=word;
//	printf("before subwording %08x \n",((temp[0] << 24) | (temp[1] << 16) | (temp[2] << 8) | temp[3]));
	int i;
	for (i = 0; i < 4; i++)
	{
		temp[i] = aes_sbox[temp[i]];
	}
//	printf("\n what the subword %x \n",((temp[0] << 24) | (temp[1] << 16) | (temp[2] << 8) | temp[3]));
	return ((temp[0] << 24) | (temp[1] << 16) | (temp[2] << 8) | temp[3]);
}

void SubBytes(unsigned char* msg)
{
	int i;
	for (i = 0; i < 16; i++)
	{
		uint index1 = (msg[i] >> 4) & 0x0f;
		uint index2 = msg[i] & 0x0f;

		msg[i] = aes_sbox[index1*16 + index2];
	}
}

void ShiftRows(unsigned char* msg)
{
	unsigned char temp;

	temp = msg[4];
	msg[4]=msg[5];
	msg[5]=msg[6];
	msg[6]=msg[7];
	msg[7]=temp;

	temp = msg[8];
	msg[8] = msg[10];
	msg[10] = temp;
	temp = msg[9];
	msg[9] = msg[11];
	msg[11] = temp;

	temp = msg[15];
	msg[15] = msg[14];
	msg[14] = msg[13];
	msg[13] = msg[12];
	msg[12] = temp;
}
void MixColumns(unsigned char* msg)
{
	int i;
	unsigned char temp[16];
	for (i = 0; i < 4; i++)
	{
		temp[i] = (gf_mul[msg[i]][0]) ^ (gf_mul[msg[i+4]][1]) ^ msg[i+8] ^ msg[i+12];
		temp[i+4] = msg[i] ^ (gf_mul[msg[i+4]][0]) ^ (gf_mul[msg[i+8]][1]) ^ msg[i+12];
		temp[i+8] = msg[i] ^ msg[i+4] ^ (gf_mul[msg[i+8]][0]) ^ (gf_mul[msg[i+12]][1]);
		temp[i+12] = (gf_mul[msg[i]][1]) ^ msg[i+4] ^ msg[i+8] ^ (gf_mul[msg[i+12]][0]);
	}
	memcpy(msg, temp, sizeof(temp));
}
void AddRoundKey(unsigned char* msg, unsigned int* curr_key, int round )
{
	int i;
//	printf("input_msg in addrounfkey \n");
//		for(i = 0; i < 16; i++){
//							printf("%02x ", msg[i]);
//							if(i==3|i==7|i==11|i==15){
//								printf("\n");}
//						}
	for (i = 0; i < 4; ++i)
	{
	msg[i] = msg[i] ^ ((curr_key[4*round+i]>>24)&0x0ff);
	msg[i+4] = msg[i+4] ^ ((curr_key[4*round+i]>>16)&0x0ff);
	msg[i+8] = msg[i+8] ^ ((curr_key[4*round+i]>>8)&0x0ff);
	msg[i+12] = msg[i+12] ^ ((curr_key[4*round+i])&0x0ff);
	}
//	printf("input_msg after addrounfkey \n");
//			for(i = 0; i < 16; i++){
//								printf("%x ", msg[i]);
//								if(i==3|i==7|i==11|i==15){
//									printf("\n");}
//			}
}

void KeyExpansion(unsigned int* keyin, unsigned int* roundkey)
{	int marker = 1;
	unsigned int temp;
	int i;
//	printf ("roudkey keye \n");
//	for(i = 0; i < 44; i++){
//				printf("%08x ", roundkey[i]);
//				if(i%4 == 3)
//				printf("\n");
//	}

	for (i = 0; i < 4; ++i)
	{
		roundkey[i] = (keyin[i] << 24) | (keyin[i+4] << 16)|
		(keyin[i + 8] << 8) | (keyin[i + 12]) ;
	}
//	printf ("roudkey check after expand \n");
//		for(i = 0; i < 44; i++){
//
//							printf("%08x ", roundkey[i]);
//							if(i%4 == 3)
//								printf("\n");
//		}

	for (i = 4; i < 44; i++)
	{
		unsigned int tempe;
		temp = roundkey[i-1];
		if (i % 4 == 0)
		{

			tempe = RotWord(temp);
//			if (marker ==1 ){
//				printf("tempe RotWord before SubW %08x jesus \n",tempe);
//				marker = 0;
//			}
			temp = SubWord(tempe);
//			printf ("after sub %x \n",temp);
			temp = temp ^ Rcon[i/4];
//			printf ("^rcon %08x \n", temp);
		}
		roundkey[i] = roundkey[i-4] ^ temp;
//		printf ("roundkey in keyexp %08x \n", roundkey[i]);//totally fine :)
	}

}


/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{








	//	printf(" this mah  before decription DONE %x \n", AES_PTR[15]);
		AES_PTR[14] = 1;	// start
//		printf("why the  always zero  START %x \n  ", AES_PTR[14]);
//		printf("en0  %x \n", AES_PTR[4]);
//		printf("en1  %x \n", AES_PTR[5]);
//		printf("en2  %x \n", AES_PTR[6]);
//		printf("en3  %x \n", AES_PTR[7]);
//
//		printf("key0 %x \n", AES_PTR[0]);
//		printf("key1  %x \n", AES_PTR[1]);
//		printf("key2 %x  \n", AES_PTR[2]);
//		printf("key3  %x \n", AES_PTR[3]);
//
//		printf("What the actual [15] AFTER INPUT IS 1 %x \n", AES_PTR[15]);

		while(!AES_PTR[15])
		{
			printf("t");
		}
		AES_PTR[14] = 0;

//		printf("why the always zero  %x \n ", AES_PTR[14]);
//
//		printf("lalalala %x \n",AES_PTR[8]);
//		printf("lalalala %x \n",AES_PTR[9]);
//		printf("lalalala %x \n",AES_PTR[10]);
//		printf("lalalala %x \n",AES_PTR[11]);

}



void encrypt(unsigned char * msg_ascii,
			unsigned char * key_ascii,
			unsigned int * msg_enc,
			unsigned int * key)
{
	int i;
	int row;
	int col;
	int counter;
	unsigned char input_msg[4*4];
	unsigned int state[4];
	unsigned int cipherkey[4*4];
	unsigned int inputkey[4*4];
	unsigned int roundkey[4*11];
	int j;
	// column major population
	for (row = 0; row < 4; row++)
	{
		for (col = 0; col < 4; col++)
		{
			i =  4*col+row ;
			j = 4*row+col;
			input_msg[j] = charsToHex( msg_ascii[2*i], msg_ascii[2*i+1] );
			cipherkey [j] = charsToHex( key_ascii[2*i], key_ascii[2*i+1] );
			cipherkey [j] = cipherkey [j] & 0x0ff;
		}
	}
//	printf("cipherkey 1 \n");
//	for(i = 0; i < 16; i++){
//
//					printf("%02x ", cipherkey[i]);
//					if(i==3|i==7|i==11|i==15){
//						printf("\n");}
//				}
//	printf("input_msg 1 \n");
//	for(i = 0; i < 16; i++){
//
//						printf("%02x ", input_msg[i]);
//						if(i==3|i==7|i==11|i==15){
//							printf("\n");}
//					}


	for(i = 0; i < 44; i++){

						 roundkey[i] = 0;

	} //clear roundkey for first expansion

	KeyExpansion(cipherkey, roundkey);

//	printf("\n after keyex roundkey\n");
//	for(i=0 ; i<44;i++){
//		printf(" %08x \n", roundkey[i]);
//	}

	AddRoundKey(input_msg, roundkey,0);
//	printf("roundkey round 0\n");
//	for(i=0 ; i<44;i++){
//		printf("\n roundkey %08x \n", roundkey);
//	}
//	printf("input_msg after add ROUND key \n");
//		for(i = 0; i < 16; i++){
//
//							printf("%02x ", input_msg[i]);
//							if(i==3|i==7|i==11|i==15){
//								printf("\n");}
//						}

	for (counter = 0; counter < 9; counter++)
	{
		SubBytes(input_msg);
//		printf("input_msg after subbytes \n");
//				for(i = 0; i < 16; i++){
//									printf("%x ", input_msg[i]);
//									if(i==3|i==7|i==11|i==15){
//										printf("\n");}}
		ShiftRows(input_msg);
//		printf("input_msg after shiftrows \n");
//				for(i = 0; i < 16; i++){
//									printf("%x ", input_msg[i]);
//									if(i==3|i==7|i==11|i==15){
//										printf("\n");}}
		MixColumns(input_msg);
//		printf("input_msg after mixcloumns \n");
//						for(i = 0; i < 16; i++){
//											printf("%x ", input_msg[i]);
//											if(i==3|i==7|i==11|i==15){
//												printf("\n");}}
		AddRoundKey( input_msg, roundkey, counter+1 );
	}
	SubBytes(input_msg);
	ShiftRows(input_msg);
	AddRoundKey(input_msg, roundkey, 10 );
//	printf("cipherkey still  \n");
//		for(i = 0; i < 16; i++){
//
//						printf("%02x ", cipherkey[i]);
//						if(i==3|i==7|i==11|i==15)
//							printf("\n");
//
//
//					}
	for (i = 0; i < 4; ++i)
	{
		state[i] = (input_msg[4*i] << 24) | (input_msg[4*i+1] << 16) | (input_msg[4*i+2] << 8) | (input_msg[4*i+3]);
		inputkey[i] = (cipherkey[4*0 + i] << 24) | (cipherkey[4*1 + i] << 16) | (cipherkey[4*2 + i] << 8) | (cipherkey[4*3 + i]);
	}

//	printf("input key after all \n");
//					for(i = 0; i < 4; i++){
//						printf("%x \n", inputkey[i]);}
//	for(i = 0; i < 4; i++){
//					printf("\n final state %08x \n", state[i]);}
	unsigned int temp2[16];
	for (i=0;i<4;i++){
		temp2[4*i]		= (state[i]>>24)&0x0ff;
		temp2[4*i+1]	=(state[i]>>16)&0x0ff;
		temp2[4*i+2]	=(state[i]>>8)&0x0ff;
		temp2[4*i+3]	=(state[i])&0x0ff;
	}
//	printf("temp2 \n");
//							for(i = 0; i < 16; i++){
//												printf("%x ", temp2[i]);
//												if(i==3|i==7|i==11|i==15){
//													printf("\n");}}
	for (i =0;i<4;i++){
		msg_enc[i] = (temp2[i] << 24) | (temp2[i+4] << 16)|
				(temp2[i + 8] << 8) | (temp2[i + 12]) ;
	}
//	for(i = 0; i < 4; i++){
//			printf("%x \n",msg_enc[i]);}

//	AES_PTR[10] = 0xDEADBEEF;
//	if (AES_PTR[10] != 0xDEADBEEF){
//		printf ("error \n");}

	AES_PTR[4] = msg_enc[0];
	AES_PTR[5] = msg_enc[1];
	AES_PTR[6] = msg_enc[2];
	AES_PTR[7] = msg_enc[3];

	memcpy(key, inputkey, sizeof(inputkey));
	AES_PTR[0] = key[0];
	AES_PTR[1] = key[1];
	AES_PTR[2] = key[2];
	AES_PTR[3] = key[3];
}



/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */

int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];
	AES_PTR[14] = 0;	// don't start
	AES_PTR[15] = 0;	// not done

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			msg_enc[0] = AES_PTR[4];
			msg_enc[1] = AES_PTR[5];
			msg_enc[2] = AES_PTR[6];
			msg_enc[3] = AES_PTR[7];
			printf("\nEncrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
//			printf("The key is %08x %08x %08x %08x\n", key[0], key[1], key[2], key[3]);
			decrypt(msg_enc, msg_dec, key);
			msg_dec[0] = AES_PTR[8];
			msg_dec[1] = AES_PTR[9];
			msg_dec[2] = AES_PTR[10];
			msg_dec[3] = AES_PTR[11];
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++) {
			decrypt(msg_enc, msg_dec, key);
			printf("%i ", i);
		}
		printf("\n");
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Decryption Speed: %f KB/s \n", speed);
	}
	return 0;
}
