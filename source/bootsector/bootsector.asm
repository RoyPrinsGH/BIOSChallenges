org 0x7C00
bits 16

jmp short start
nop

;;;;;;;;;;;;;;;;
; FAT12 header ;
;;;;;;;;;;;;;;;;

bdb_oem:                    db "MSWIN4.1"
bdb_bytes_per_sector:       dw 512
bdb_sectors_per_cluster:    db 1
bdb_reserved_sectors:       dw 1
bdb_number_of_fats:         db 2
bdb_root_entries:           dw 0xE0
bdb_total_sectors:          dw 2880
bdb_media_descriptor:       db 0xF0
bdb_sectors_per_fat:        dw 9
bdb_sectors_per_track:      dw 18
bdb_number_of_heads:        dw 2
bdb_hidden_sectors:         dd 0
bdb_total_sectors_big:      dd 0

ebr_drive_number:           db 0
ebr_reserved:               db 0
ebr_signature:              db 0x29
ebr_volume_id:              dd 0x12345678
ebr_volume_label:           db 'OS         '
ebr_file_system:            db 'FAT12   '

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Setup stack and jump to main ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

start:
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    jmp main

;;;;;;;;;;;;;;;;;;;;
; Main entry point ;
;;;;;;;;;;;;;;;;;;;;

main:
    mov si, msg_loading
    call print_string

    ; clear the screen
    mov ah, 0x0
    mov al, 0x13
    int 0x10

    mov bx, 0

    ; VGA memory starts at 0xA000
    mov ax, 0xA000
    mov es, ax

.draw_frame:
    inc bx
    mov cx, 0
    mov dx, 0

.horizontal_loop:
    push dx ; mul overwrites dx, so we need to save it

    ; set di to the correct position in the video memory
    mov di, cx
    mov ax, dx
    push bx
    mov bx, vga_width
    mul bx
    pop bx
    add di, ax

    pop dx

    ; write the color to the video memory
    mov al, dl
    add al, cl
    add al, bl

    mov es:[di], al

    inc cx
    cmp cx, vga_width
    je .vertical_loop
    jmp .horizontal_loop

.vertical_loop:
    mov cx, 0
    inc dx
    cmp dx, vga_height
    je .draw_frame
    jmp .horizontal_loop

.halt:
    cli
    hlt


;;;;;;;;;;;;;;;;;;;;;
; Standard routines ;
;;;;;;;;;;;;;;;;;;;;;

;
; Prints a string to the screen
;
; Parameters:
;   ds:si - pointer to the string
;
print_string:
    push si
    push ax

.loop:
    lodsb           ; load the next byte from ds:si into al and increment si
    or al, al       ; set the zero flag if al is zero
    jz .done        ; if al is zero, we are done
    mov ah, 0x0E    ; int 0x10 teletype function which outprint_string al to the screen
    mov bh, 0       ; page number needs to be set to 0
    int 0x10
    jmp .loop

.done:
    pop ax
    pop si
    ret


%define ENDL 0x0D, 0x0A
msg_loading:                db 'Loading...', ENDL, 0
vga_width:                  equ 320
vga_height:                 equ 200

times 510-($-$$) db 0
dw 0xAA55

buffer: