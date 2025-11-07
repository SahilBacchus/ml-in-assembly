
# void fit(double x[], double y[], int m, double* theta_0, double* theta_1, double alpha, int epochs)
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
	.global fit 
fit:
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
	

