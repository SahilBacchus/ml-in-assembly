
	
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
	

