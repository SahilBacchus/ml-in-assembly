
	
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
	

