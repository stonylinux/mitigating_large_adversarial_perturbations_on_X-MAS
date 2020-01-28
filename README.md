# mitigating_large_adversarial_perturbations_on_X-MAS
This page has the codes and data appeared in the paper, "Mitigating large adversarial perturbations on X-MAS (X minus Moving Averaged Samples)" [https://arxiv.org/abs/1912.12170]

1. Prerequiste
   1) The adversarial examples are generated by FGSM (Fast Gradient Sign Method) based attacks on ResNet-50.  
      You can find the codes for the FGSM based attacks on https://github.com/hmph/adversarial-attacks.  
      Also, you can get the target weight kernel for the FGSM based attacks from https://github.com/KaimingHe/deep-residual-networks  
      The numbers in the prediction accuracies can be little different (actually very litte different) accordiing to the floating-point formats (e.g. half vs single vs double) that machines support.  
     
   2) mitigation runs several ImageMagick's "convert" scripts such that you need to have ImageMaick (https://imagemagick.org/index.php) on your environment.  
  
   3) $\epsilon$ of an adversarial example is noted as "eps#" in the adversarial example file.  
      <pre> ambulance_ifgsm_adversarial_eps64.png: ambulance image crafted by the basic iterative FGSM attack with $\epsilon$ = 64
       ambulance_fgsm_adversarial_eps16.png: ambulance image crafted by the fast FGSM attack with $\epsilon$ = 16   
       ambulance_ifgsm_ll_adversarial_eps64.png: ambulance image crafted by the iterative least-likely FGSM attack with $\epsilon$ = 64
       
   4) The benign versions of the adversarial examples on this site end with "_224x224.png"  
      <pre> ambulance_224x224.png is the benign version of the adversarial example "ambulance_ifgsm_adversarial_eps64.png".  

2. Once you get the adversarial example "adversarial_example.png", you can run the mitigation script as below.

   1) When 3x3 Wavg (i.e. moving average kernel) is used to find the estimated perturbation $\hat{\epsilon}$

       <pre>./mitigating_adversarial_with_3x3_estimation.sh adversarial_example
       => Do not type the file format ".png"

   2) When 7x7 Wavg (i.e. moving average kernel) is used to find the estimated perturbation $\hat{\epsilon}$
      <pre>./mitigating_adversarial_with_7x7_estimation.sh adversarial_example
      => Do not type the file format ".png"

3. Then, you will get the following three to be fed into the inference on the ResNet-50 having the weights you are using to craft "adversarial_example.png"

   1) <pre>adversarial_example_mitigated_step100.png
      - It is just mitigated not soothed.
      
   2) <pre>adversarial_example_mitigated_and_soothed_by_ma.png     
      - It is mitigated and soothed by 3x3 moving average filter

   3) <pre>adversarial_example_mitigated_and_soothed_by_JPEG.jpg 
      - It is mitigated and soothed by JPEG encoding (quality is set 20 out of 100).

4. Running Examples

   1)  We got "ambulance_ifgsm_ll_adversarial_eps64.png" by the iterative least-likely FGSM attack with epsilon=64 on ResNet-50.  
        "ambulance_fgsm_adversarial_eps64.png" is crafted by the fast FGSM attack with epsilon=64 on ResNet-50.      
       "ambulance_ifgsm_adversarial_eps64.png" is generated by the basic iterative FGSM attack with epsilon=64 on ResNet-50.    
         
        The prediction accuracy of unmitigated "ambulance_ifgsm_ll_adversarial_eps64.png" is    
       
        <pre>../caffe-master/inference_resnet.sh   ambulance_ifgsm_ll_adversarial_eps64.png    
          
        where "../caffe-master/inference_resnet.sh" is the inference with ResNet-50 weight used for "iterative least-likely FGSM attack"      
          
        ---------- Prediction for ambulance_ifgsm_ll_adversarial_eps64.png ----------   
        0.0066 - "n03345487 fire engine, fire truck"  
        0.0064 - "n04065272 recreational vehicle, RV, R.V."  
        ...  
        0.0046 - "n02701002 ambulance"    
    
    2) Run mitigation with 7x7 moving average window for the estimated perturbation  
      
       <pre>./mitigating_adversarial_with_7x7_estimation.sh ambulance_ifgsm_ll_adversarial_eps64  
   
    3) Prediction accuracy of the "just" mitigated output   
      
       <pre>../caffe-master/inference_resnet.sh ambulance_ifgsm_ll_adversarial_eps64_mitigated_step100.png   
  
       ---------- Prediction for ambulance_ifgsm_ll_adversarial_eps64_mitigated_step100.png ----------  
       0.9517 - "n02701002 ambulance"  
       0.0237 - "n03977966 police van, police wagon, paddy wagon, patrol wagon, wagon, black Maria"  
       0.0074 - "n04336792 stretcher"  

    4) Prediction accuracy of the mitigated and soothed by 3x3 moving average filter  
      
       <pre>../caffe-master/inference_resnet.sh ambulance_ifgsm_ll_adversarial_eps64_mitigated_and_soothed_by_ma.png   
         
       ---------- Prediction for ambulance_ifgsm_ll_adversarial_eps64_mitigated_and_soothed_by_ma.png ----------  
       0.9418 - "n02701002 ambulance"  
       0.0242 - "n03977966 police van, police wagon, paddy wagon, patrol wagon, wagon, black Maria"  
       0.0132 - "n03796401 moving van"  
  
    5) Prediction accuracy of the mitigated and soothed by JPEG encoding (quality is set as 20 out of 100)  
      
       <pre>../caffe-master/inference_resnet.sh ambulance_ifgsm_ll_adversarial_eps64_mitigated_and_soothed_by_JPEG.jpg  
         
       ---------- Prediction for ambulance_ifgsm_ll_adversarial_eps64_mitigated_and_soothed_by_JPEG.jpg ----------  
       0.9793 - "n02701002 ambulance"  
       0.0147 - "n03796401 moving van"  
       0.0036 - "n03977966 police van, police wagon, paddy wagon, patrol wagon, wagon, black Maria"  


