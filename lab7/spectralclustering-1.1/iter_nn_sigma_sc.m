for nn=-5:1:5
    A=gen_nnd(X,round(log(size(X,1)))+nn,size(X,1));
    for si=-2:1:2
        [a b]=sc2(A,si,2);
        scatter(X(:,1),X(:,2),5,a);
        fprintf('nn offset: %d, sigma: %d, eval1: %.6f, eval2: %.6f\n',nn,si,b(1),b(2));
        pause;
    end
end