function [a,r] = generatera(pa,rewardSequence); 

a = sum(rand>cumsum([0 pa(:)']));
r = rewardSequence(a);

