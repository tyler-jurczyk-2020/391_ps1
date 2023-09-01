/*
 * tab:2
 *
 * edit_dist_asm.S - inplementation of computing edit distance between two (linked) lists
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice and the following
 * two paragraphs appear in all copies of this software.
 *
 * IN NO EVENT SHALL THE AUTHOR OR THE UNIVERSITY OF ILLINOIS BE LIABLE TO
 * ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
 * DAMAGES ARISING OUT  OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 * EVEN IF THE AUTHOR AND/OR THE UNIVERSITY OF ILLINOIS HAS BEEN ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE AUTHOR AND THE UNIVERSITY OF ILLINOIS SPECIFICALLY DISCLAIM ANY
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE
 * PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND NEITHER THE AUTHOR NOR
 * THE UNIVERSITY OF ILLINOIS HAS ANY OBLIGATION TO PROVIDE MAINTENANCE,
 * SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 * Author:        Xiang Li
 * Version:       1
 * Creation Date: Sat Aug 20 2022
 * History:
 *    XL    1    Sat Aug 20 2022
 *        First written.
 */

.data
  UNUSED  = 0
  VAL   = 4
  NEXT = 8

.text
.global edit_dist_asm

# Edit Dist ASM (Assembly)
# Declaration is in edit_dist.h
#
# Registers:
#   EAX - Return Value
#   EBX - root1
#   ESI - root2
#   you may choose how to store your local/temp variables
#

edit_dist_asm:
  pushl %ebp
  movl %esp, %ebp

  # EBX and ESI
  movl 8(%ebp), %ebx
  movl 12(%ebp), %esi
  # --- STUDENT CODE STARTS HERE ---
  # Allocate space for insert, delete, and replace
  addl $-12, %esp 
  # Save callee-modified Registers
  pushl %ebx
  pushl %esi
  # If (root1 == NULL and root2 == NULL)
  movl %ebx, %eax
  orl %esi, %eax 
  cmp $0, %eax
  jnz continue1
  movl $0, %eax  
  jmp exit
# If (root1 == NULL)
continue1:
  cmp $0, %ebx
  jnz continue2
  # Call recursively
  movl NEXT(%esi), %esi
  call edit_dist_asm
  # On Return
  addl $1, %eax
  jmp exit
# If (root2 == NULL)
continue2:
  cmp $0, %esi
  jnz continue3
  # Call recursively
  movl NEXT(%esi), %esi
  call edit_dist_asm
  # On Return
  addl $1, %eax
  jmp exit
# If (root1->val == root2->val)
continue3:
  movl VAL(%ebx), %ebx
  movl VAL(%esi), %esi
  cmp %ebx, %esi
  jnz continue4
  # Call recursively
  movl NEXT(%esi), %esi
  movl NEXT(%ebx), %ebx
  call edit_dist_asm
  # On Return
  jmp exit
continue4:
# Set insert
  movl NEXT(%ebx), %ebx
  call edit_dist_asm
  movl %eax, -4(%ebp)
# Set delete
  movl NEXT(%esi), %esi
  call edit_dist_asm
  movl %eax, -8(%ebp)
# Set replace (Note that root1->next and root2->next already set above)
  call edit_dist_asm
  movl %eax, -12(%bp)
# If (insert <= delete && insert <= replace)
  movl -4(%ebp), %ebx
  movl -8(%ebp), %esi
  cmp %ebx, %esi
  jb next
  movl -12(%ebp), %esi
  cmp %ebx, %esi
  jb next
  addl $1, %ebx 
  movl %ebx, %eax
  jmp exit
# If (insert delete <= replace)
next:
  movl -8(%ebp), %esi
  cmp %esi, %ebx
  jb next_next
  addl $1, %esi
  movl %esi, %eax
  jmp exit
# Return 1 + replace
next_next:
  movl -12(%ebp), %eax 
  addl $1, %eax
  jmp exit


  # --- STUDENT CODE ENDS HERE ---
exit:
  # Restore callee-modified registers
  popl %esi
  popl %ebx
  leave
  ret

