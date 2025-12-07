

# TODO:
# possibly redo this since I am overwriting a registers 
# epilogue and prolgue has been added to train() but s registers are not used yet  [completed]
# pointer arithmetic seems wonky in the weight update loop --? check that out 



# void train(double X[][2], double Y[], int num_samples, int num_features, double weights[], double eta, int epochs)
#
# parameters		registers
# double X[][2] 	a0
# double Y[]		a1
# int num_samples	a2
# int num_features	a3
# double weights[]	a4
# int epochs		a5
# double eta		fa0
#
# local variables	registers 
# int i 		s6
# int epoch		s7
# int j			s8
# int y_pred		s9 
# double error		fs1
	.text
	.global train 
train:
	# Prologue
	addi	sp, sp, -48
	sw	ra, 44(sp)
	sw	s0, 40(sp)
	sw	s1, 36(sp)
	sw	s2, 32(sp)
	sw	s3, 28(sp)
	sw	s4, 24(sp)
	sw	s5, 20(sp)
	fsd 	fs0, 12(sp)
	
	mv	s0, a0		# s0 = double X[][2]
	mv	s1, a1		# s1 = doulbe Y[]
	mv	s2, a2		# s2 = num_samples 
	mv	s3, a3		# s3 = num_features 
	mv 	s4, a4		# s4 = weights[]
	mv	s5, a5		# s5 = epochs
	fmv.d	fs0, fa0	# fs0 = eta
	mv	s6, zero	# i = 0
for_loop_init_weights:
	bgt 	s6, s3, end_loop_init_weights	# if (i > num_features) goto end_loop_iniit_weights
	slli 	t0, s6, 3	# t0 = i * 8
	add 	t1, s4, t0	# t1 = &weights[i]
	fcvt.d.w ft0, zero	# ft0 = 0.0
	fsd	ft0, (t1)	# weights[i] = 0.0
	addi 	s6, s6, 1	# i++
	j for_loop_init_weights
end_loop_init_weights:
	
	mv	s7, zero	# epoch = 0
for_loop_epochs:
	bge	s7, s5, end_loop_epochs	# if (epoch >= epochs) goto end_loop_epochs
	mv	s6, zero	# i = 0
for_samples_loop:
	bge	s6, s2, end_samples_loop # if (i >= num_samples) goto end_samples_loop
	slli	t0, s6, 4	# t0 = i * 16 (2 doubles) 
	add	t1, s0, t0	# t1 = &X[i][0]
	
	# call predict(X[i], num_features, weights)
	mv	a0, t1
	mv	a1, s3
	mv	a2, s4
	call predict
	
	mv	s9, a0		# y_pred = predict(X[i], num_features, weights)
	slli 	t2, s6, 3	# t2 = i * 8 
	add	t3, s1, t2	# t3 = &Y[i]
	fld	ft1, (t3)	# ft1 = Y{i]
	fcvt.d.w ft2, s9	# ft2 = (double) y_pred
	fsub.d	fs1, ft1, ft2	# error = Y[i] - y_pred
	
	fmul.d ft3, fs0, fs1	# ft3 = eta * error
	fld	ft4, (s4)	# ft4 = weights[0]
	fadd.d	ft4, ft4, ft3	# ft4 = weights[0] +  eta * error
	fsd ft4, (s4)		# weights[0] += eta*error
	
	mv	s8, zero	# j = 0
for_weights_update_loop: 
	bge	s8, s3, end_weights_update_loop	# if ( j >= num_features) goto end_weights_update_loop
	slli 	t0, s6, 4	# t0 = i * 16 (2 doubles)
	slli	t1, s8, 3	# t1 = j * 8 
	add	t0, t0, t1 	# t0 = i * 16 + j * 8
	add	t1, s0, t0	# t1 = &X[i}{j}
	fld	ft5, (t1)	# ft5 = X[i][j]
	fmul.d	ft6, ft3, ft5	# ft7 = eta * error * X[i][j]
	addi	t2, t0, 8	# t2 = (j + 1) * 8
	add	t3, s4, t2	# t3 = &weights[j+1]
	fld	ft7, (t3)	# ft7 = weights[j+1]
	fadd.d	ft7, ft7, ft6 	# ft7 += eta * error * X[i][j]
	fsd	ft7, (t3)	# weights[j + 1] += eta * error * X[i][j]
	addi	s8, s8, 1	# j++
	j	for_weights_update_loop
end_weights_update_loop:

	addi	s6, s6, 1	# i++
	j	for_samples_loop
end_samples_loop:

	addi 	s7, s7, 1	# epoch++
	j	for_loop_epochs
end_loop_epochs:

	# Epilogue
	fld	fs0, 12(sp)
	lw	s5, 20(sp)
	lw	s4, 24(sp)
	lw	s3, 28(sp)
	lw	s2, 32(sp)
	lw	s1, 36(sp)
	lw	s0, 40(sp)
	lw	ra, 44(sp)
	addi	sp, sp, 48
	
	ret
	
		
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
	# Prologue 
	addi	sp, sp, -16
	sw	ra, 12(sp)
	
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
	
	# Epilogue 
	lw	ra, 12(sp)
	addi	sp, sp, 16

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
	

