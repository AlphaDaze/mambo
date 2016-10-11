/*
  This file is part of MAMBO, a low-overhead dynamic binary modification tool:
      https://github.com/beehive-lab/mambo

  Copyright 2013-2016 Cosmin Gorgovan <cosmin at linux-geek dot org>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

.syntax unified

.global th_to_arm
.func th_to_arm
.thumb_func
th_to_arm:
  bx pc
.endfunc

.code 32
.global dispatcher_trampoline
.func   dispatcher_trampoline
dispatcher_trampoline:
  #R2 is available at this point
  #TODO: INSTALL our own stack

#A subroutine must preserve the contents of the registers r4-r8, r10, r11 and SP (and r9 in PCS variants that designate r9 as v6).
  SUB SP, SP, #4
  PUSH {r3, r4, r9, r12, lr}
  MOV R2, R1
  # PUSH CPSR
  MRS r1, CPSR
  PUSH {R1}
  # R0 is target, R1 where to put address
  ADD R1, SP, #24
  LDR R3, disp_thread_data
  LDR R9, dispatcher_addr

  # provide 8-byte alignment of the SP
  MOV R4, SP
  BIC SP, #0x7
  BLX R9
  MOV SP, R4

  # RESTORE CPSR
  POP {R1}
  MSR CPSR, r1
  LDR R0, scratch_space
  LDM R0, {R0-R2}
  POP {r3, r4, r9, r12, lr, pc}
ret_addr: .word 0
dispatcher_addr: .word dispatcher
scratch_space: .word 0
.endfunc

  SUB PC, PC, #3
.global trace_head_incr
.func   trace_head_incr
.thumb_func
trace_head_incr:
  NOP
  PUSH {LR}
  NOP // MOVW R1, #counter_base & 0xFFFF    
  NOP
  NOP // MOVT R1, #counter_base >> 16
  NOP
  //NOP // ADD R1, R1, R0
  LDRB R2, [R1, R0]
  SUBW  R2, R2, #1
  STRB R2, [R1, R0]
  CBZ  R2, create_trace_trampoline
  ADD R2, SP, #4
  LDM R2, {R0-R2, LR}
  LDR PC, [SP], #20
create_trace_trampoline:
  BX PC
  NOP
.code 32
  MRS r2, CPSR
  PUSH {R2, R3, R4, R9, R12}

  ADD R2, SP, #20
  MOV R1, R0
  LDR R0, disp_thread_data
  LDR R3, =create_trace

  MOV R4, SP
  BIC SP, #0x7
  BLX R3
  MOV SP, R4
  
  POP {R2, R3, R4, R9, R12}
  MSR CPSR, r2
  
  ADD R2, SP, #4
  LDM R2, {R0-R2, LR}
  LDR PC, [SP], #20
.endfunc

.global syscall_wrapper
.func   syscall_wrapper
.code 32
syscall_wrapper:
  # R8 is native address of the following instruction
  # R9 is address where the contents of R8, R9 and R14 are saved
  # R14 is address where to return in the code cache
          PUSH {r0- r12, r14}

          MOV R0, R7
          MOV R1, SP
          MOV R2, R8
          LDR r3, disp_thread_data

          LDR r4, syscall_handler_pre_addr
          # provide 8-byte alignment of the SP
          MOV R5, SP
          BIC SP, #0x7
          BLX r4
          MOV SP, R5
          
          # don't execute the syscall if pre handler returns 0
          CMP R0, #0
          BEQ s_w_r
          
          POP {r0-r12, r14}

          SVC 0

          PUSH {r0-r12, r14}
                    
          MOV R0, R7
          MOV R1, SP
          MOV R2, R8
          LDR r3, disp_thread_data
          
          LDR r4, syscall_handler_post_addr
          # provide 8-byte alignment of the SP
          MOV R5, SP
          BIC SP, #0x7
          BLX r4
          MOV SP, R5
          
          CMP R0, #0
          BEQ s_w_r

          ADD SP, #4
          POP {r1-r12, r14}
          B dbm_start_thread

s_w_r:    POP {r0-r12, r14}
          
          LDR R8, [R9, #0]
          STR R14, sys_r_addr
          LDR R14, [R9, #8]
          LDR R9, [R9, #4]
          LDR PC, sys_r_addr
sys_r_addr:
.word 0

syscall_handler_pre_addr: .word syscall_handler_pre
syscall_handler_post_addr: .word syscall_handler_post
.endfunc

.global disp_thread_data
disp_thread_data:
.word 0

.global dbm_start_thread
.func dbm_start_thread
dbm_start_thread: 
  STR R0, thread_s_addr
  LDR R14, [R9, #8]
  LDR R8, [R9, #0]
  LDR R9, [R9, #4]
  MOV R0, #0
  LDR PC, thread_s_addr
thread_s_addr:
.word 0
.endfunc

.global end_of_dispatcher_s
end_of_dispatcher_s:
