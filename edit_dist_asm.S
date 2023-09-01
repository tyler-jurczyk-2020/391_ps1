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
# Allocate space for insert, delete, and replace
  addl $-12, %esp 
# Save callee-modified Registers
  pushl %ebx
  pushl %esi
  # EBX and ESI
  movl 8(%ebp), %ebx
  movl 12(%ebp), %esi
  # --- STUDENT CODE STARTS HERE ---
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
  pushl NEXT(%esi)
  pushl %ebx
  call edit_dist_asm
  # On Return
  addl $8, %esp
  addl $1, %eax
  jmp exit
# If (root2 == NULL)
continue2:
  cmp $0, %esi
  jnz continue3
  # Call recursively
  pushl %esi
  pushl NEXT(%ebx)
  call edit_dist_asm
  # On Return
  addl $8, %esp
  addl $1, %eax
  jmp exit
# If (root1->val == root2->val)
continue3:
  movl VAL(%ebx), %ebx
  movl VAL(%esi), %esi
  cmp %ebx, %esi
  movl 8(%ebp), %ebx
  movl 12(%ebp), %esi
  jnz continue4
  # Call recursively
  pushl NEXT(%esi)
  pushl NEXT(%ebx)
  call edit_dist_asm
  # On Return
  addl $8, %esp
  jmp exit
continue4:
# Set insert
  pushl %esi
  pushl NEXT(%ebx)
  call edit_dist_asm
  addl $8, %esp
  movl %eax, -4(%ebp)
# Set delete
  pushl NEXT(%esi)
  pushl %ebx
  call edit_dist_asm
  addl $8, %esp
  movl %eax, -8(%ebp)
# Set replace (Note that root1->next and root2->next already set above)
  pushl NEXT(%esi)
  pushl NEXT(%ebx)
  call edit_dist_asm
  addl $8, %esp
  movl %eax, -12(%ebp)
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
# If (delete <= replace)
next:
  movl -8(%ebp), %ebx
  movl -12(%ebp), %esi
  cmp %ebx, %esi
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

