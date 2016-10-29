# TODO: Matthew Nemitz 260506071
.data
bitmapDisplay: .space 0x80000 # enough memory for a 512x256 bitmap display
resolution: .word  512 256    # width and height of the bitmap display

windowlrbt:
.float -2.5 2.5 -1.25 1.25  					# good window for viewing Julia sets
#.float -3 2 -1.25 1.25  					# good window for viewing full Mandelbrot set
#.float -0.807298 -0.799298 -0.179996 -0.175996 		# double spiral
#.float -1.019741354 -1.013877846  -0.325120847 -0.322189093 	# baby Mandelbrot
 
bound: .float 100	# bound for testing for unbounded growth during iteration
maxIter: .word 16	# maximum iteration count to be used by drawJulia and drawMandelbrot
scale: .word 16		# scale parameter used by computeColour

# Julia constants for testing, or likewise for more examples see
# https://en.wikipedia.org/wiki/Julia_set#Quadratic_polynomials  
JuliaC0:  .float 0    0    # should give you a circle, a good test, though boring!
JuliaC1:  .float 0.25 0.5 
JuliaC2:  .float 0    0.7 
JuliaC3:  .float 0    0.8 

# a demo starting point for iteration tests
z0: .float  0 0

# TODO: define various constants you need in your .data segment here
i: .asciiz "i"
plus: .asciiz " + "
newline: .asciiz "\n"
########################################################################################
.text

	# TODO: Write your function testing code here
	la	$a0	JuliaC1
	l.s	$f12	($a0)
	l.s	$f13	4($a0)
	jal	printComplex
	jal	printNewLine
	li 	$v0 	10 # exit
	syscall


# TODO: Write your functions to implement various assignment objectives here
########################################################################################
# Puts complex number from two float args to the console. First is the real component, second imaginary
printComplex:
	# First print $f12 float as is (real component)
	addi	$v0	$0	2
	syscall
	# Next print plus sign, changing $v0 from 2 to 4 for string...
	la	$a0	plus
	addi	$v0	$v0	2
	syscall
	# Then next float
	addi	$v0	$v0	-2
	mov.s	$f12	$f13
	syscall
	# Finally the i
	addi	$v0	$v0	2
	la	$a0	i
	syscall
	jr	$ra
printNewLine:
	la	$a0	newline
	li	$v0	4
	syscall
	jr	$ra
########################################################################################
# Computes a colour corresponding to a given iteration count in $a0
# The colours cycle smoothly through green blue and red, with a speed adjustable 
# by a scale parametre defined in the static .data segment
computeColour:
	la $t0 scale
	lw $t0 ($t0)
	mult $a0 $t0
	mflo $a0
ccLoop:
	slti $t0 $a0 256
	beq $t0 $0 ccSkip1
	li $t1 255
	sub $t1 $t1 $a0
	sll $t1 $t1 8
	add $v0 $t1 $a0
	jr $ra
ccSkip1:
  	slti $t0 $a0 512
	beq $t0 $0 ccSkip2
	addi $v0 $a0 -256
	li $t1 255
	sub $t1 $t1 $v0
	sll $v0 $v0 16
	or $v0 $v0 $t1
	jr $ra
ccSkip2:
	slti $t0 $a0 768
	beq $t0 $0 ccSkip3
	addi $v0 $a0 -512
	li $t1 255
	sub $t1 $t1 $v0
	sll $t1 $t1 16
	sll $v0 $v0 8
	or $v0 $v0 $t1
	jr $ra
ccSkip3:
 	addi $a0 $a0 -768
 	j ccLoop
