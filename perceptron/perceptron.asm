
	
# int predict(double x[], int n, double weights[])
#
# parameters		registers
# double* x 		a0
# int n			a1
# doulbe* weights	a2
#
# local variables	registers 
# int i 		t0 
# double z		ft0
	.text
	.global predict 
predict:
	fld	ft0, (a2)	# z = weights[0] 	
	mv	t0, zero	# i = 0
for_loop_pred:
	bge	t0, a1, end_loop_pred # if (i >= n) goto end_loop__pred
	slli	t1, t0, 3	# t1 = I * 8
	add	t2, a0, t1	# t2 = &x[i]
	add	t3, a2, t1	# t3 = &weights[i]
	addi	t3, t3, 8	# t3 = &weights[i+1]
	fld	ft1, (t2)	# ft1 = x[i]
	fld	ft2, (t3)	# ft2 = weights[i + 1]
	fmul.d	ft3, ft1, ft2	# ft3 = x[i] * weights[i + 1]
	fadd.d	ft0, ft0, ft3	# z += weights[i + 1] * x[i]
	addi	t0, t0, 1	# i++
	j	for_loop_pred
end_loop_pred:

	# call step(z)
	fmv.d	fa0, ft0
	call	step
	
	ret
	

			
# int step(double z)
#
# parameters		registers
# double z		fa0
	.text
	.global step 
step: 	
	fcvt.d.w ft0, zero	# ft0 = 0 
	fle.d	a0, ft0, fa0	# a0 = (0.0 <= z) ? 1 : 0
	ret
	

