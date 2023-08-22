org 0x7c00                    ; (1)
bits 16                       ; (2)

jmp start                     ; сразу переходим в start

start:
	mov ah, 0x00              ; очистка экрана (3)
   	mov al, 0x03
    	int 0x10
    	mov sp, 0x7c00            ; инициализация стека (4)

get_input:
    xor bx, bx                 ; инициализируем bx как индекс для хранения ввода

input_processing:
    mov ah, 0x0               ; параметр для вызова 0x16
    int 0x16                  ; получаем ASCII код

    cmp al, 0x0d              ; если нажали enter
    je short check_the_input        ; то вызываем функцию, в которой проверяем, какое
                              ; слово было введено
;    cmp al, 0x8               ; если нажали backspace
;    je short backspace_pressed

;    cmp al, 0x3               ; если нажали ctrl+c
;    je short stop_cpu

    mov ah, 0x0e              ; во всех противных случаях - просто печатаем
                              ; очередной символ из ввода
    int 0x10

    mov [input+bx], al        ; и сохраняем его в буффер ввода
    inc bx                    ; увеличиваем индекс

    cmp bx, 10                ; если input переполнен
    je short check_the_input        ; то ведем себя так, будто был нажат enter

    jmp short input_processing      ; и идем заново

;backspace_pressed:
;    cmp bx, 0                 ; если backspace нажат, но input пуст, то
;    je short input_processing       ; ничего не делаем

;    mov ah, 0x0e              ; печатаем backspace. это значит, что каретка
;    int 0x10                  ; просто передвинется назад, но сам символ не сотрется

;    mov al, ' '               ; поэтому печатаем пробел на том месте, куда
;    int 0x10                  ; встала каретка

;    mov al, 0x8               ; пробел передвинет каретку в изначальное положение
;    int 0x10                  ; поэтому еще раз печатаем backspace

;    dec bx
;    mov byte [input + bx], 0    ; и убираем из input последний символ

;    jmp short input_processing      ; и возвращаемся обратно

check_the_input:
    mov byte [input + bx + 1], 0    ; в конце ввода ставим ноль, означающий конец
 
    mov byte [len_key], bl

        call keyFill
        call keyInit
        call keyItem

        mov     si,     msg
        mov     cx,     len_msg
        call    ArrayShow

stop_cpu:
    jmp $                     ; и останавливаем компьютер
                              ; $ означает адрес текущей инструкции
		
ArrayShow:
	mov 	ah, 	0x0e
	mov     al,     0x0d
        int     0x10

        mov     al,     0xa
        int     0x10
        .for:
                mov 	al, 	[si]
                int 	0x10
		inc	si
        loop  .for
ret



 ;     for (int i = 0; i < 256; i++)
 ;     {
 ;       S[i] = (byte)i;
 ;     }

keyFill:
	xor	bl,    	bl
        mov     cx,   	N
	.for:
        	mov 	[Array + bx], 	bl
               	inc 	bl
	loop .for
ret


 ;     int j = 0;
 ;     for (int i = 0; i < 256; i++)
 ;     {
 ;       j = (j + S[i] + key[i % keyLength]) % 256;
 ;       S.Swap(i, j);      
 ;     }

keyInit:
lea	di, 	[Array]
lea	si,	[input]
xor	bx,	bx   ; i = 0
xor	cx,	cx   ; j = 0
.loop:
	add	ch,	[di + bx]   ; j + s[i]
	mov	ax,	bx
	mov	cl,	byte [len_key]    ; i % key_len
	div	cl

	mov	cl,	bl    ; cl = i
	mov	bl, 	ah    ; bl = i % key_len
	add	ch,	[si + bx]    ; j +  key[%]

	mov	bl,	cl           ; bl = i
	mov	ah,	[di + bx]    ; swap
	mov	bl,	ch	     ; bl = j
	mov	al,	[di + bx]
	mov	[di + bx], 	ah
	mov	bl,	cl         ; bl = i
	mov	[di + bx], 	al
	
	inc 	bl
	cmp	bl,	0
	jnz SHORT .loop
ret

;for (int m = 0; m < data.Length; m++) {       
;       x = (x + 1) % 256;
;       y = (y + S[x]) % 256;
;       S.Swap(x, y);
;        cipher[m] = (byte)(data[m] ^ S[(S[x] + S[y]) % 256]);
;}

keyItem:
        lea     di,     [Array]
        lea     si,     [msg]
	mov	cx,	len_msg
        xor     bx,     bx
        xor     dx,     dx
.loop:
        inc	dl			; x += 1
        mov     bl,     dl
        add     dh,     [di + bx] 	; y += s[x]

        mov     al,     [di + bx]  	;  s[x]
        mov     bl,     dh      
        mov     ah,     [di + bx]  	;  s[y]
        mov     [di + bx],      al
        mov     bl,     dl
        mov     [di + bx],      ah

	add 	al,	ah		; t = s[x] + s[y]
	mov	bl,	al		
        mov     ah,     [di + bx]	; s[t]

        mov     al,     [si]	; data[m]
        xor     al,     ah
        mov     [si],      al
	
	inc	si
	loop  .loop
ret


msg: db "'It will not last,' said O'Brien. 'Look me in the eyes. What country is Oceania at war with?'", 0x0d, 0xa, "Winston thought. He knew what was meant by Oceania and that he himself was a citizen of Oceania. He also remembered Eurasia and Eastasia; but who was at war with whom he did not know. In fact he had not been aware tha",  0
len_msg: equ $ - msg - 1 

times 510 - ($-$$) db 0
dw 0xaa55
input: times 10 db 0 
len_key: db 0
N: equ 256
Array: db 256 DUP (0)
;times 1440 * 512 - ($-$$) db 0

