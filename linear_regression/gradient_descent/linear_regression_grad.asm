.data
x:	.double 1, 2, 3, 4	# x array	
y:	.double 3, 5, 7, 9	# y array 
x_test: .double 5, 6		# x_test array
y_pred: .space 16		# y_pred array( 2 doubles) 
theta_0: .double 0 		# theta_0 
theta_1: .double 0 		# theta_1
alpha:	.double 0.1		# alpha
epochs:	.word 100		# epochs

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
# double theta_0	fs0
# double theta_1 	fs1
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

	# call train(x, y, 4, &theta_0, &theta_1, 0.1, 100)
	la	a0, x		
	la	a1, y
	li 	a2, 4 
	la	a3, theta_0
	la	a4, theta_1
	fld	fa0, alpha, t0
	lw	a5, epochs
	
	call	train
	
	fld	fs0, theta_0, t0		# fs0 = theta_0
	fld	fs1, theta_1, t0		# fs1 = theta_1
	
	# call predict(x_test, y_pred, 2, theta_0, theta_1)
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
	
	# printf("\nSlope: %lf", theta_1)
	la	a0, fmt_slope
	li	a7, 4		# ecall "PrintString" call number  
	ecall
	fmv.d	fa0, fs1
	li	a7, 3 		# ecall "PrintDouble" call number 
	ecall
	
	# printf("\nIntercept: %lf", theta_0)
	la	a0, fmt_intercept
	li	a7, 4
	ecall
	fmv.d	fa0, fs0
	li	a7, 3 
	ecall
	
	# printf("\nRegression Line: y = %lf + %lfx", theta_0, theta_1)
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
	
	# printf( "\n  x = %lf -> y = %lf", x_test[i], y_pred[i])
	la	a0, fmt_x_equals
	li	a7, 4
	ecall
	fmv.d	fa0, ft0
	li	a7, 3 
	ecall 
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
	
	
	
# void train(double x[], double y[], int m, double* theta_0, double* theta_1, double alpha, int epochs)
#
# parameters		registers
# double* x 		a0
# double* y		a1
# int m			a2
# doulbe* theta_0	a3
# double* theta_1	a4
# int epochs		a5
# double  alpha		fa0
#
# local variables	registers 
# int epoch 		t0 
# int i			t1
# grad_0		ft0
# grad_1		ft1
# y_pred		ft2
# error			ft3
	.text
	.global train 
train:
	li	t0, 1		# epoch = 1
for_loop_epoch:
	bgt	t0, a5, end_loop_epoch	# if (epoch > epochs) goto end_loop_epoch
	fcvt.d.w ft0, zero	# grad_0 = 0 
	fmv.d	ft1, ft0	# grad_1 = 0
	mv 	t1, zero	# i = 0
for_loop_grad:
	bge	t1, a2, end_loop_grad # if (i >= m) goto end_loop_grad
	slli	t2, t1, 3	# t2 = i * 8 
	add	t3, a0, t2	# t3 = &x[i]
	add	t4, a1, t2	# t4 = &y[i]
	fld	ft4, (t3)	# ft4 = x[i]
	fld 	ft5, (t4)	# ft5 = y[i]
	fld	ft6, (a4)	# ft6 = *theta_1
	fmul.d	ft2, ft6, ft4	# y_pred = (*theta_1) * x[i[
	fld	ft7, (a3)	# ft7 = *theta_0
	fadd.d	ft2, ft2, ft7	# y_pred += *theta_0
	fsub.d	ft3, ft2, ft5	# error = y_pred - y[i]
	fadd.d	ft0, ft0, ft3	# grad_0 += error
	fmul.d	ft8, ft3, ft4	# ft8 = error * x[i]
	fadd.d	ft1, ft1, ft8	# grad_1 += error * x[i]
	addi	t1, t1, 1	# i++
	j for_loop_grad
end_loop_grad:
	fcvt.d.w ft11, a2	# m = (double) m
	fdiv.d	ft0, ft0, ft11	# grad_0 /= m 
	fdiv.d	ft1, ft1, ft11	# grad_1 /= m 
	fmul.d	ft9, fa0, ft0	# ft9 = alpha * grad_0 
	fsub.d	ft9, ft7, ft9	# ft9 = *theta_0 - alpha * grad_0
	fsd	ft9, (a3)	# *theta_0 -= alpha * grad_0
	fmul.d	ft10, fa0, ft1	# ft10 = alpha * grad_1 
	fsub.d	ft10, ft6, ft10	# ft10 = *theta_1 - alpha * grad_1
	fsd	ft10, (a4)	# *theta_1 -= alpha * grad_1
	addi	t0, t0, 1	# epoch++
	j for_loop_epoch
end_loop_epoch:
	ret 	

	
	
# void predict(double x[], double y_pred[], int n, double theta_0, double theta_1)
#
# parameters		registers
# double* x 		a0
# double* y_pred 	a1
# int n			a2
# doulbe theta_0	fa0
# double theta_1	fa1
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
	fmul.d	ft1, fa1, ft0	# ft1 = theta_1 * x[i]
	fadd.d	ft1, ft1, fa0	# ft1 += theta_0
	add	t3, a1, t1	# t3 = &y_pred[i]
	fsd	ft1, (t3)	# y_pred[i] = theta_0 + theta_1 * x[i]
	addi	t0, t0, 1	# i++
	j	for_loop_pred
end_loop_pred:
	ret
	

