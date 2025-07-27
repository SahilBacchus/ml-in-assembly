.data
x:	.double 1, 2, 3, 4	# x array	
y:	.double 3, 5, 7, 9	# y array 
x_test: .double 5, 6		# x_test array
y_pred: .space 16		# y_pred array( 2 doubles) 
beta_0: .double 0 		# beta_0 
beta_1: .double 0 		# beta_1

fmt_model_stats: .asciz "==== Model Stats ===="
fmt_slope:	.asciz "\nSlope: "
fmt_intercept:	.asciz "\nIntercept: "
fmt_reg_line:	.asciz	"\nRegression Line: y = "
fmt_plus:	.asciz	" + "
fmt_x:		.asciz	"x"
fmt_testing:	.asciz "\n\n===== Testing ===="
fmt_x_equals:	.asciz "\n  x = "
fmt_arrow_y:	.asciz " -> y = "

# startup code
#
	.text
	.global _start
_start: 
	andi	sp, sp, -32 	# round sp down to a multiple of 32
	jal	main		# note this will return 0 if successful (a0 = 0) 
	li	a7, 93		# ecall "exit" call number
	ecall



# int main(void)
#
# local variables	registers 
# int i 		s0
# double* x_test	s1
# double* y_pred	s2 
# double beta_0		fs0
# double beta_1 	fs1
	.text 
	.global main
main: 
	# Prologue
	addi	sp, sp, -32
	sw	ra, 28(sp)
	sw	s0, 24(sp)
	sw	s1, 20(sp)
	sw	s2, 16(sp)
	fsd 	fs0, 8(sp)
	fsd	fs1, 0(sp)

	# call fit(x, y, 4, &beta_0, &beta_1)
	la	a0, x		
	la	a1, y
	li 	a2, 4 
	la	a3, beta_0
	la	a4, beta_1
	call	fit
	
	fld	fs0, beta_0, t0		# fs0 = beta_0
	fld	fs1, beta_1, t0		# fs1 = beta_1
	
	# call predict(x_test, y_pred, 2, beta_0, beta_1)
	la	a0, x_test
	la	a1, y_pred
	li	a2, 2
	fmv.d	fa0, fs0
	fmv.d	fa1, fs1
	call	predict 
	
	# printf("\n==== Model Stats ====")
	la	a0, fmt_model_stats
	li	a7, 4
	ecall
	
	# printf("\nSlope: %lf", beta_1)
	la	a0, fmt_slope
	li	a7, 4		# ecall "PrintString" call number  
	ecall
	fmv.d	fa0, fs1
	li	a7, 3 		# ecall "PrintDouble" call number 
	ecall
	
	# printf("\nIntercept: %lf", beta_0)
	la	a0, fmt_intercept
	li	a7, 4
	ecall
	fmv.d	fa0, fs0
	li	a7, 3 
	ecall
	
	# printf("\nRegression Line: y = %lf + %lfx", beta_0, beta_1)
	la	a0, fmt_reg_line
	li	a7, 4
	ecall
	fmv.d	fa0, fs0
	li	a7, 3 
	ecall
	la	a0, fmt_plus
	li	a7, 4
	ecall
	fmv.d	fa0, fs1
	li	a7, 3
	ecall 
	la	a0, fmt_x
	li	a7, 4
	ecall

	# printf("\n==== Testing  ====")
	la	a0, fmt_testing
	li	a7, 4
	ecall
	
	li	s0, 0		# s0 = 0 
	li	t0, 2 		# t0 = 0
	la	s1, x_test	# s1 = x_test
	la	s2, y_pred	# s2 = y_pred 
for_loop_print: 
	bge	s0, t0, end_loop_print	# if (i >= 2) goto end_loop_print
	slli	t1, s0, 3	# t1 = i * 8 
	add	t2, s1, t1	# t2 = &x_test[i]
	fld	ft0, (t2)	# ft0 = x_test[i]
	add	t3, s2, t1	# t3 = &y_pred[i]
	fld	ft1, (t3)	# ft1 = y_pred[i]
	
	# printf( "\n  x = %lf", x_test[i])
	la	a0, fmt_x_equals
	li	a7, 4
	ecall
	fmv.d	fa0, ft0
	li	a7, 3 
	ecall 
	
	# printf(" -> y = %lf", y_pred[i])
	la	a0, fmt_arrow_y
	li	a7, 4
	ecall
	fmv.d	fa0, ft1
	li	a7, 3 
	ecall 
	
	addi	s0, s0, 1	# i++
	j	for_loop_print
end_loop_print: 	
	li	a0, 0		# a0 = 0 --> return 0
	
	# Epilogue 
	fld	fs1, 0(sp)
	fld	fs0, 8(sp)
	lw	s2, 16(sp)
	lw	s1, 20(sp)
	lw	s0, 24(sp)
	lw	ra, 28(sp)
	addi	sp, sp, 32
	
	ret
	
	

# void fit(double x[], double y[], int n, double* beta_0, double* beta_1);
#
# parameters		registers
# double* x 		a0
# double* y 		a1
# int n			a2
# doulbe* beta_0	a3
# double* beta_1	a4
#
# local variables	registers 
# int i 		t0 
# double x_sum		ft0
# double y_sum		ft1
# double xy_sum		ft2
# double x_squared_sum	ft3
# double x_mean		ft4
# double y_mean 	ft5
# double beta_1_num	ft10
# double beta_1_denom	ft11
	.text
	.global fit 
fit: 
	mv	t0, zero	# i = 0
	fcvt.d.w ft0, zero	# x_sum = 0 
	fmv.d	ft1, ft0	# y_sum = 0 
	fmv.d 	ft2, ft0	# xy_sum = 0 
	fmv.d	ft3, ft0	# x_squared_sum = 0 
for_loop_fit: 
	bge	t0, a2, end_loop_fit # if (i >= n) goto end_loop_fit
	slli	t1, t0, 3	# t1 = i * 8
	add	t2, a0, t1	# t2 = &x[i]
	add	t3, a1, t1	# t3 = &y[i]
	fld	ft6, (t2)	# ft6 = x[i]
	fld	ft7, (t3)	# ft7 = y[i]
	fadd.d	ft0, ft0, ft6	# x_xum += x{i}
	fadd.d	ft1, ft1, ft7	# y_sum += y[i]
	fmul.d	ft8, ft6, ft7 	# ft8 = x[i] * y[i]
	fadd.d	ft2, ft2, ft8	# xy_sum += x[i] * y[i]
	fmul.d	ft9, ft6, ft6	# ft9 = x[i] * x[i]
	fadd.d  ft3, ft3, ft9	# x_squared_sum += x[i] * x[i]
	addi	t0, t0, 1	# i++
	j	for_loop_fit
end_loop_fit: 	
	fcvt.d.w ft9, a2	# ft9 = (double) n 
	fdiv.d	ft4, ft0, ft9	# x_mean = x_sum / n 
	fdiv.d	ft5, ft1, ft9	# y_mean = y_sum / n
	fmul.d	ft6, ft4, ft5	# ft6 = x_meam * y_mean 
	fmul.d	ft6, ft6, ft9	# ft6 *= n
	fsub.d	ft10, ft2, ft6	# beta_1_num = xy_sum - n * x_mean * y_mean
	fmul.d	ft7, ft4, ft4	# ft7 = x_mean * x_mean 
	fmul.d	ft7, ft7, ft9	# ft7 *= n
	fsub.d  ft11, ft3, ft7	# beta_1_denom = x_squared_sum - n * x_mean * x_mean
	fdiv.d	ft8, ft10, ft11 # ft8 = beta_1_num / beta_1_denom
	fsd	ft8, (a4)	# *beta_1 = beta_1_num / beta_1_denom
	fmul.d	ft9, ft8, ft4	# ft9 = (*beta_1) * x_mean
	fsub.d	ft9, ft5, ft9	# ft9 = y_mean - (*beta_1) * x_mean
	fsd	ft9, (a3)	# *beta_0 = y_mean - (*beta_1) * x_mean
	ret 
	
	
	
# void predict(double x[], double y_pred[], int n, double beta_0, double beta_1)
#
# parameters		registers
# double* x 		a0
# double* y_pred 	a1
# int n			a2
# doulbe beta_0		fa0
# double beta_1		fa1
#
# local variables	registers 
# int i 		t0 
	.text
	.global predict 
predict: 	
	mv	t0, zero	# i = 0
for_loop_pred:
	bge	t0, a2, end_loop_pred # if (i >= n) goto end_loop__pred
	slli	t1, t0, 3	# t1 = I * 8
	add	t2, a0, t1	# t2 = &x[i]
	fld	ft0, (t2)	# ft0 = x[i]
	fmul.d	ft1, fa1, ft0	# ft1 = beta_1 * x[i]
	fadd.d	ft1, ft1, fa0	# ft1 += beta_0
	add	t3, a1, t1	# t3 = &y_pred[i]
	fsd	ft1, (t3)	# y_pred[i] = beta_0 + beta_1 * x[i]
	addi	t0, t0, 1	# i++
	j	for_loop_pred
end_loop_pred:
	ret
	

