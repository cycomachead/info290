load X;

%% question 2
A = gen_nnd(X, 7, 500);
[clusters, evals] = sc(A, 0, 2);

%% question 3
scatter(X(:,1), X(:,2), 5, clusters);

%% question 4
% No, it did not!
evals

%% question 5
k_heuristic = ceil(log(size(X, 1)));
for i = -5:5
    runexpl2(X, 2, k_heuristic + i, 0);
    disp(k_heuristic + i);
    pause;
end

% 7 + 2 = 9 seems to be optimal

%% question 6 (data2)
[x1,y1] = randr(50, 5000, 0.20);
[x2,y2] = randr(20, 4000, 0.05);
x = [x1 x2]';
y = [y1 y2]';
X2 = [x y];
scatter(x,y);

%% question 7 data2 clustering
k_heuristic = ceil(log(size(X2, 1)));
c2 = runexpl2(X2, 2, k_heuristic + 2, 0);

%% question 7 accuracy
accuracy([ones(5000, 1); 2 * ones(4000, 1)], c2)

%% question 7 data3
[x1,y1] = randr(25, 5000, 0.05);
[x2,y2] = randr(20, 4000, 0.05);
x = [x1 x2]';
y = [y1 y2]';
X3 = [x y];
scatter(x, y);

%% question 7 data3 clustering
k_heuristic = ceil(log(size(X3, 1)));
c3 = runexpl2(X3, 2, k_heuristic + 4, 0);

%% question 7 accuracy
accuracy([ones(5000, 1); 2 * ones(4000, 1)], c3)

%% question 7 data4
[x1,y1] = randr(30, 5000, 0.4);
[x2,y2] = randr(20, 4000, 0.4);
x = [x1 x2]';
y = [y1 y2]';
X4 = [x y];
scatter(x, y);

%% question 7 data4 clustering
k_heuristic = ceil(log(size(X4, 1)));
c4 = runexpl2(X4, 2, k_heuristic + 4, 0);

%% question 7 accuracy
accuracy([ones(5000, 1); 2 * ones(4000, 1)], c4)

%% question 7 data5
[x1,y1] = randr(30, 5000, 0.3);
[x2,y2] = randr(20, 4000, 0.4);
[x3,y3] = randr(14, 3000, 0.1);
x = [x1 x2 x3]';
y = [y1 y2 y3]';
X5 = [x y];
scatter(x, y);

%% question 7 data5 clustering
k_heuristic = ceil(log(size(X4, 1)));
c5 = runexpl2(X5, 3, k_heuristic + 5, 0);

%% question 7 accuracy
accuracy([ones(5000, 1); 2 * ones(4000, 1); 3 * ones(3000, 1)], c5)

