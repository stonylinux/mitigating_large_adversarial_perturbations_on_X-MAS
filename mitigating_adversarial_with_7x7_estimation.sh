#!/bin/bash
#
#

# Initial mitigation starts

convert $1.png -fx '( p[-3,-3] + p[-3,-2] + p[-3,-1] + p[-3,0] + p[-3,1] + p[-3,2] + p[-3, 3] + p[-2,-3] + p[-2,-2] + p[-2,-1] + p[-2,0] + p[-2,1] + p[-2,2] + p[-2, 3] + p[-1,-3] + p[-1,-2] + p[-1,-1] + p[-1,0] + p[-1,1] + p[-1,2] + p[-1, 3] + p[0,-3] + p[0,-2] + p[0,-1] + p[0,0] + p[0,1] + p[0,2] + p[0,3] + p[1,-3] + p[1,-2] + p[1,-1] + p[1,0] + p[1,1] + p[1,2] + p[1,3] + p[2,-3] + p[2,-2] + p[2,-1] + p[2,0] + p[2,1] + p[2,2] + p[2,3] + p[3,-3] + p[3,-2] + p[3,-1] + p[3,0] + p[3,1] + p[3,2] + p[3,3])/49' $1_ma0.png

convert $1.png $1_ma0.png -fx 'u[0].p[0,0]-u[1].p[0,0]' $1_meps0.png

convert $1_ma0.png $1.png -fx 'u[0].p[0,0]-u[1].p[0,0]' $1_peps0.png

## Check the upper and lower bound of the mitigated samples
convert $1.png $1_meps0.png $1_peps0.png -fx '( (u[1].p[0,0]> 0) &&  (u[2].p[0,0]== 0) && ((u[0].p[0,0] - u[1].mean) > (u[0].minima)) )?u[0].p[0,0] - u[1].mean:( (u[1].p[0,0] == 0) &&  (u[2].p[0,0]> 0) && ((u[0].p[0,0]+u[2].mean) < (u[0].maxima)) )?u[0].p[0,0]+u[2].mean:u[0].p[0,0]' $1_mitigated_step0.png

# Initial mitigation ends


# iterative mitigation starts
for i in {0..99}
do
	convert $1_mitigated_step$i.png -fx '( p[-3,-3] + p[-3,-2] + p[-3,-1] + p[-3,0] + p[-3,1] + p[-3,2] + p[-3, 3] + p[-2,-3] + p[-2,-2] + p[-2,-1] + p[-2,0] + p[-2,1] + p[-2,2] + p[-2, 3] + p[-1,-3] + p[-1,-2] + p[-1,-1] + p[-1,0] + p[-1,1] + p[-1,2] + p[-1, 3] + p[0,-3] + p[0,-2] + p[0,-1] + p[0,0] + p[0,1] + p[0,2] + p[0,3] + p[1,-3] + p[1,-2] + p[1,-1] + p[1,0] + p[1,1] + p[1,2] + p[1,3] + p[2,-3] + p[2,-2] + p[2,-1] + p[2,0] + p[2,1] + p[2,2] + p[2,3] + p[3,-3] + p[3,-2] + p[3,-1] + p[3,0] + p[3,1] + p[3,2] + p[3,3])/49' $1_ma$((i+1)).png


	convert $1_mitigated_step$i.png $1_ma$((i+1)).png -fx 'u[0].p[0,0]-u[1].p[0,0]' $1_meps$((i+1)).png

	convert $1_ma$((i+1)).png $1_mitigated_step$i.png -fx 'u[0].p[0,0]-u[1].p[0,0]' $1_peps$((i+1)).png

	convert $1_mitigated_step$i.png $1_meps$((i+1)).png $1_peps$((i+1)).png $1_meps$i.png $1_peps$i.png $1_ma0.png -fx '( (u[1].p[0,0]> 0) &&  (u[2].p[0,0]== 0) && ((u[0].p[0,0] - u[1].mean) >= (u[5].p[0,0])) && (u[1].mean < u[3].mean) )?u[0].p[0,0] - u[1].mean:( (u[2].p[0,0]> 0) && (u[1].p[0,0] == 0) &&  ((u[0].p[0,0]+u[2].mean) <= (u[5].p[0,0])) && (u[2].mean < u[4].mean) )?u[0].p[0,0]+u[2].mean:u[0].p[0,0]' $1_mitigated_step$((i+1)).png
done
# iterative mitigation ends

convert $1_mitigated_step100.png  -fx '((p[-1,-1]+p[-1,0]+p[-1,1]+p[0,-1]+p[0,1]+p[1,-1]+p[1,0]+p[1,1])+p[0,0])/9' $1_mitigated_and_soothed_by_ma.png

convert $1_mitigated_step100.png -quality 20 $1_mitigated_and_soothed_by_JPEG.jpg

