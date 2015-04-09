function cl=runexpl(X2,clusts,nn,sigma)
%[idx,c]=kmeans(X2,clusts);
%pause
%scatter(X2(:,1),X2(:,2),5,idx);
%scatter(X2(:,1),X2(:,2),5,[ones(400,1);2*ones(400,1)]);
A=gen_nnd(X2,nn,500);
[cl ev]=sc(A,sigma,clusts);
ev
ylabel('X1');xlabel('X2');

scatter(X2(:,1),X2(:,2),5,cl)
ylabel('X1');xlabel('X2');
