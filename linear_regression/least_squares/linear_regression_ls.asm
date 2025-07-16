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
for_loop: 
	bge	t0, a2, end_loop # if (i >= n) goto end_loop
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
	j	for_loop
end_loop: 	
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
for_loop:
	bge	t0, a2, end_loop # if (i >= n) goto end_loop
	slli	t1, t0, 3	# t1 = I * 8
	add	t2, a0, t1	# t2 = &x[i]
	fld	ft0, (t2)	# ft0 = x[i]
	fmul.d	ft1, fa1, ft0	# ft1 = beta_1 * x[i]
	fadd.d	ft1, ft1, fa0	# ft1 += beta_0
	add	t3, a1, t1	# t3 = &y_pred[i]
	fsd	ft1, (t3)	# y_pred[i] = beta_0 + beta_1 * x[i]
	addi	t0, t0, 1	# i++
	j	for_loop
end_loop:
	ret
	

