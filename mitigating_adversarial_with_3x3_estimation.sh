#!/bin/bash

# Initial mitigation starts
#
# Find W_{avg}*X_{adv}
convert $1.png -fx '((p[-1,-1]+p[-1,0]+p[-1,1]+p[0,-1]+p[0,1]+p[1,-1]+p[1,0]+p[1,1])+p[0,0])/9' $1_ma0.png

# Find X_{adv} - W_{avg}*X_{adv} for X_{adv} > W_{avg}*X_{adv}
convert $1.png $1_ma0.png -fx 'u[0].p[0,0]-u[1].p[0,0]' $1_meps0.png

# Find W_{avg}*X_{adv} - X_{adv} for X_{adv} < W_{avg}*X_{adv}
convert $1_ma0.png $1.png -fx 'u[0].p[0,0]-u[1].p[0,0]' $1_peps0.png

# Check the upper and lower bound of the mitigated samples
convert $1.png $1_meps0.png $1_peps0.png -fx '( (u[1].p[0,0]> 0) &&  (u[2].p[0,0]== 0) && ((u[0].p[0,0] - u[1].mean) > (u[0].minima)) )?u[0].p[0,0] - u[1].mean:( (u[1].p[0,0] == 0) &&  (u[2].p[0,0]> 0) && ((u[0].p[0,0]+u[2].mean) < (u[0].maxima)) )?u[0].p[0,0]+u[2].mean:u[0].p[0,0]' $1_mitigated_step0.png

# Initial mitigation ends


# iterative mitigation starts 
for i in {0..99}
do
	convert $1_mitigated_step$i.png -fx '((p[-1,-1]+p[-1,0]+p[-1,1]+p[0,-1]+p[0,1]+p[1,-1]+p[1,0]+p[1,1])+p[0,0])/9' $1_ma$((i+1)).png

	convert $1_mitigated_step$i.png $1_ma$((i+1)).png -fx 'u[0].p[0,0]-u[1].p[0,0]' $1_meps$((i+1)).png

	convert $1_ma$((i+1)).png $1_mitigated_step$i.png -fx 'u[0].p[0,0]-u[1].p[0,0]' $1_peps$((i+1)).png

	# Check the upper and lower bound of the mitigated samples
  #
	# DO NOT mitigate X_{adv}^{p-1}  
	#
	# if \hat{\epsilon}_{p} \geq \hat{\epsilon}_{p-1}
  # or
  # if X_{adv}^{p-1} - \hat{\epsilon}_{p} < W_{avg}*X_{adv} (for X_{adv}^{p-1} > W_{avg}*X_{adv})
  # or
  # if X_{adv}^{p-1} + \hat{\epsilon}_{p} > W_{avg}*X_{adv} (for X_{adv}^{p-1} < W_{avg}*X_{adv})
	convert $1_mitigated_step$i.png $1_meps$((i+1)).png $1_peps$((i+1)).png $1_meps$i.png $1_peps$i.png $1_ma0.png -fx '( (u[1].p[0,0]> 0) &&  (u[2].p[0,0]== 0) && ((u[0].p[0,0] - u[1].mean) >= (u[5].p[0,0])) && (u[1].mean < u[3].mean) )?u[0].p[0,0] - u[1].mean:( (u[2].p[0,0]> 0) && (u[1].p[0,0] == 0) &&  ((u[0].p[0,0]+u[2].mean) <= (u[5].p[0,0])) && (u[2].mean < u[4].mean) )?u[0].p[0,0]+u[2].mean:u[0].p[0,0]' $1_mitigated_step$((i+1)).png
done
# iterative mitigation ends

# Soothing filter part here!
# 3x3 Moving average as a soothing filter
convert $1_mitigated_step100.png  -fx '((p[-1,-1]+p[-1,0]+p[-1,1]+p[0,-1]+p[0,1]+p[1,-1]+p[1,0]+p[1,1])+p[0,0])/9' $1_mitigated_by_ma.png

# JPEG encoding with the quality 20 (out of 100)
convert $1_mitigated_step100.png -quality 20 $1_mitigated_with_JPEG.jpg

